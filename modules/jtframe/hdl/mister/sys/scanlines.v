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
  
*/module scanlines #(parameter v2=0)
(
	input             clk,

	input       [1:0] scanlines,
	input      [23:0] din,
	input             hs_in,vs_in,
	input             de_in,

	output reg [23:0] dout,
	output reg        hs_out,vs_out,
	output reg        de_out
);

reg [1:0] scanline;
always @(posedge clk) begin
	reg old_hs, old_vs;

	old_hs <= hs_in;
	old_vs <= vs_in;
	
	if(old_hs && ~hs_in) begin
		if(v2) begin
			scanline <= scanline + 1'd1;
			if (scanline == scanlines) scanline <= 0;
		end
		else scanline <= scanline ^ scanlines;
	end
	if(old_vs && ~vs_in) scanline <= 0;
end

wire [7:0] r,g,b;
assign {r,g,b} = din;

reg [23:0] d;
always @(*) begin
	case(scanline)
		1: // reduce 25% = 1/2 + 1/4
			d = {{1'b0, r[7:1]} + {2'b00, r[7:2]},
			     {1'b0, g[7:1]} + {2'b00, g[7:2]},
				  {1'b0, b[7:1]} + {2'b00, b[7:2]}};

		2: // reduce 50% = 1/2
			d = {{1'b0, r[7:1]},
				  {1'b0, g[7:1]},
				  {1'b0, b[7:1]}};

		3: // reduce 75% = 1/4
			d = {{2'b00, r[7:2]},
			     {2'b00, g[7:2]},
				  {2'b00, b[7:2]}};

		default: d = {r,g,b};
	endcase
end

always @(posedge clk) begin
	reg [23:0] dout1, dout2;
	reg de1,de2,vs1,vs2,hs1,hs2;

	dout   <= dout2; dout2 <= dout1; dout1 <= d;     
	vs_out <= vs2;   vs2   <= vs1;   vs1   <= vs_in; 
	hs_out <= hs2;   hs2   <= hs1;   hs1   <= hs_in; 
	de_out <= de2;   de2   <= de1;   de1   <= de_in; 
end

endmodule
