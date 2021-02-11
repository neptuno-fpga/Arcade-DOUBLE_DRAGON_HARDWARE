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
  
*/
module i2s
#(
	parameter AUDIO_DW = 16
)
(
	input      reset,
	input      clk,
	input      ce,

	output reg sclk,
	output reg lrclk,
	output reg sdata,

	input [AUDIO_DW-1:0]	left_chan,
	input [AUDIO_DW-1:0]	right_chan
);

always @(posedge clk) begin
	reg  [7:0] bit_cnt;
	reg msclk;

	reg [AUDIO_DW-1:0] left;
	reg [AUDIO_DW-1:0] right;

	if (reset) begin
		bit_cnt <= 1;
		lrclk   <= 1;
		sclk    <= 1;
		msclk   <= 1;
	end
	else begin
		sclk <= msclk;
		if(ce) begin
			msclk <= ~msclk;
			if(msclk) begin
				if(bit_cnt >= AUDIO_DW) begin
					bit_cnt <= 1;
					lrclk <= ~lrclk;
					if(lrclk) begin
						left  <= left_chan;
						right <= right_chan;
					end
				end
				else begin
					bit_cnt <= bit_cnt + 1'd1;
				end
				sdata <= lrclk ? right[AUDIO_DW - bit_cnt] : left[AUDIO_DW - bit_cnt];
			end
		end
	end
end

endmodule
