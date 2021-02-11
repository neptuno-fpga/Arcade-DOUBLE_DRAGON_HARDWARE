/*
  
   Multicore 2 / Multicore 2+
  
   Copyright (c) 2017-2020 - Victor Trucco

  
   All rights reserved
  
   Redistribution and use in source and synthezised forms, with or without
   modification, are permitted provided that the following conditions are met:
  
   Redistributions of source code must retain the above copyright notice,
   this list of conditions and the following disclaimer.
  
   Redistributions in synthesized form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.
  
   Neither the name of the author nor the names of other contributors may
   be used to endorse or promote products derived from this software without
   specific prior written permission.
  
   THIS CODE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
   AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
   THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
   PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE
   LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
   CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
   SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
   INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
   CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
   ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
   POSSIBILITY OF SUCH DAMAGE.
  
   You are responsible for any legal issues arising from your use of this code.
  
*/`timescale 1ns / 1ps

module pm_clk_real(
	input             clk,
	input             rst,
	input             real_speed,
	input             rst_counter,
	input             irq_n,			// the pm counter does not count when irq_n is low
	input 			  uart_speed,
	output reg        ym_pm,
	output reg [31:0] pm_counter
);
parameter stop=5'd07;
reg [4:0] div_cnt, cambio0, cambio1; 

always @(posedge clk or posedge rst) begin : speed_mux
	if( rst ) begin
		cambio0 <= 5'd2;
		cambio1 <= 5'd4;
	end
	else begin
		if( real_speed ) begin
			cambio0 <= 5'd2;
			cambio1 <= 5'd4;
		end
		else begin // con 8/16 he visto fallar el STATUS del YM una vez
			if( uart_speed ) begin
				cambio0 <= 5'd4;
				cambio1 <= 5'd8;
			end else begin
				cambio0 <= 5'd7;
				cambio1 <= 5'd15;
			end
		end
	end
end

always @(posedge clk or posedge rst) begin : ym_pm_ff
	if( rst ) begin
		div_cnt    <= 5'd0;
		ym_pm      <= 1'b0;
	end
	else begin	
		if(div_cnt>=cambio1) begin // =5'd4 tiempo real del YM
			ym_pm   <= 1'b1;
			div_cnt <= 5'd0;
		end
		else begin
			if( div_cnt==cambio0 ) ym_pm <= 1'b0; // =5'd2 tiempo real
			div_cnt <= div_cnt + 1'b1;
		end
	end
end

reg ultpm;

always @(posedge clk or posedge rst) begin : pm_counter_ff
	if( rst )  begin
		pm_counter <= 32'd0;
		ultpm      <= 1'b0;
	end
	else begin
		ultpm <= ym_pm;
		if(rst_counter) 
			pm_counter <= 32'd0;
		else
			if( irq_n && ym_pm && !ultpm ) 
				pm_counter <= pm_counter + 1'd1;		
	end
end

endmodule
