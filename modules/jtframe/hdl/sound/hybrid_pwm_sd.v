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
  
*/// Hybrid PWM / Sigma Delta converter
//
// Uses 5-bit PWM, wrapped within a 10-bit Sigma Delta, with the intention of
// increasing the pulse width, since narrower pulses seem to equate to more noise

module hybrid_pwm_sd
(
	input clk,
	input n_reset,
	input [15:0] din,
	output dout
);

reg [4:0] pwmcounter;
reg [4:0] pwmthreshold;
reg [33:0] scaledin;
reg [15:0] sigma;
reg out;

assign dout=out;

always @(posedge clk, negedge n_reset) // FIXME reset logic;
begin
	if(!n_reset)
	begin
		sigma<=16'b00000100_00000000;
		pwmthreshold<=5'b10000;
	end
	else
	begin
		pwmcounter<=pwmcounter+1'b1;

		if(pwmcounter==pwmthreshold)
			out<=1'b0;

		if(pwmcounter==5'b11111) // Update threshold when pwmcounter reaches zero
		begin
			// Pick a new PWM threshold using a Sigma Delta
			scaledin<=33'd134217728 // (1<<(16-5))<<16, offset to keep centre aligned.
				+({1'b0,din}*61440); // 30<<(16-5)-1;
			sigma<=scaledin[31:16]+{4'b0,sigma[10:0]};	// Will use previous iteration's scaledin value
			pwmthreshold<=sigma[15:11]; // Will lag 2 cycles behind, but shouldn't matter.
			out<=1'b1;
		end

	end
end

endmodule
