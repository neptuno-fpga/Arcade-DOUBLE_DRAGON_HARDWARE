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

module ym_sync(
  input rst,  
  input clk,
  // YM2151 pins
	input ym_p1,
  input ym_so,
  input ym_sh1,
  input ym_sh2,
	input ym_irq_n,
	input [7:0] ym_data,
	//
	output reg ym_p1_sync,
	output reg ym_so_sync,
	output reg ym_sh1_sync,
	output reg ym_sh2_sync,
	output reg ym_irq_n_sync,
	output reg [7:0] ym_data_sync
);

reg p1_0, so_0, sh1_0, sh2_0, irq_0;
reg [7:0] data0;

always @(posedge ym_p1 or posedge rst ) begin : first_sync
	if( rst ) begin
		p1_0  <= 1'b0;
		so_0  <= 1'b0;
		sh1_0 <= 1'b0;
		sh2_0 <= 1'b0;
		irq_0 <= 1'b1;
		data0 <= 8'h0;
	end
	else begin
		p1_0  <= ym_p1;
		so_0  <= ym_so;
		sh1_0 <= ym_sh1;
		sh2_0 <= ym_sh2;
		irq_0 <= ym_irq_n;
		data0 <= ym_data;
	end
end

always @(posedge clk or posedge rst ) begin : second_sync
	if( rst ) begin
		ym_p1_sync    <= 1'b0;
		ym_so_sync    <= 1'b0;
		ym_sh1_sync   <= 1'b0;
		ym_sh2_sync   <= 1'b0;
		ym_irq_n_sync <= 1'b1;
		ym_data_sync  <= 8'h0;
	end
	else begin
		ym_p1_sync    <= p1_0;
		ym_so_sync    <= so_0;
		ym_sh1_sync   <= sh1_0;
		ym_sh2_sync   <= sh2_0;
		ym_irq_n_sync <= irq_0;
		ym_data_sync  <= data0;
	end
end

endmodule
