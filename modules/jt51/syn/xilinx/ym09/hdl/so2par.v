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
  
*/module so2par(
	input clk,	
	input ym_so,
	input ym_sh1,
	input ym_sh2,
	input ym_p1,
	output reg [15:0] left,
	output reg [15:0] right,
	output reg [15:0] left_exp,
	output reg [15:0] right_exp,	
	output            update_left,
	output            update_right
);

reg [12:0] sreg;
reg last_ym_sh1,last_ym_sh2;

reg [15:0] dr,dl;
reg [15:0] left0_pm, right0_pm;
reg [ 2:0] sr,sl;

reg [15:0] out_r,out_l;
reg update_l, update_r;

always @(posedge ym_p1) begin : sh_edges
	last_ym_sh1 <= ym_sh1;
	last_ym_sh2 <= ym_sh2;
end

always @(posedge ym_p1) begin : shift_register
	// shift register
	sreg <= {ym_so,sreg[12:1]};

	if(last_ym_sh1 & ~ym_sh1)
	begin
		update_r <= 1'b1;
		out_r    <= dr;
		sr       <= sreg[12:10];
		dr       <= {~sreg[9],sreg[8:0],6'b000000};
		right0_pm<= { 3'd0, sreg };
	end else begin
		update_r <= 1'b0;
		if(sr<7) begin
			sr       <= sr + 1;
			dr[14:0] <= dr[15:1];
		end
	end
	
	if(last_ym_sh2 & ~ym_sh2)
	begin
		update_l <= 1'b1;
		out_l    <= dl;		
		sl       <= sreg[12:10];
		dl       <= {~sreg[9],sreg[8:0],6'b000000};
		left0_pm <= { 3'd0, sreg };
	end else begin
		update_l <= 1'b0;
		if(sl<7) begin
			sl       <= sl + 1;
			dl[14:0] <= dl[15:1];
		end
	end
end

reg [1:0] aux_upr, aux_upl;
assign update_right = aux_upr[1];
assign update_left  = aux_upl[1];

always @(posedge clk) begin : update_sync
	aux_upr[0] <= update_r;
	aux_upr[1] <= aux_upr[0];
	aux_upl[0] <= update_l;
	aux_upl[1] <= aux_upl[0];
end

reg [15:0] aux_l, aux_r, left1, right1;

always @(posedge clk) begin : output_sync
	if( update_l | update_r ) begin
		aux_r    <= out_r;
		right    <= aux_r;
		aux_l    <= out_l;
		left     <= aux_l;
		// salidas en formato exponencial
		left1    <= left0_pm;
		left_exp <= left1;
		right1   <= right0_pm;
		right_exp<= right1;
	end
end

endmodule
