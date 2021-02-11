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
  
*///
// PWM DAC
//
// MSBI is the highest bit number. NOT amount of bits!
//
module sigma_delta_dac #(parameter MSBI=7, parameter INV=1'b1)
(
   output reg      DACout, //Average Output feeding analog lowpass
   input  [MSBI:0] DACin,  //DAC input (excess 2**MSBI)
   input           CLK,
   input           RESET
);

reg [MSBI+2:0] DeltaAdder; //Output of Delta Adder
reg [MSBI+2:0] SigmaAdder; //Output of Sigma Adder
reg [MSBI+2:0] SigmaLatch; //Latches output of Sigma Adder
reg [MSBI+2:0] DeltaB;     //B input of Delta Adder

always @(*) DeltaB = {SigmaLatch[MSBI+2], SigmaLatch[MSBI+2]} << (MSBI+1);
always @(*) DeltaAdder = DACin + DeltaB;
always @(*) SigmaAdder = DeltaAdder + SigmaLatch;

always @(posedge CLK or posedge RESET) begin
   if(RESET) begin
      SigmaLatch <= 1'b1 << (MSBI+1);
      DACout <= INV;
   end else begin
      SigmaLatch <= SigmaAdder;
      DACout <= SigmaLatch[MSBI+2] ^ INV;
   end
end

endmodule
