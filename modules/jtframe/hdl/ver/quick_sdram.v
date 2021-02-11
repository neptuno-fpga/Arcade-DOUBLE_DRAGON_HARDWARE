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
  
*/module quick_sdram(
    input   SDRAM_nCS,
    input   SDRAM_CLK,
    input   SDRAM_nRAS,
    input   SDRAM_nCAS,
    input   SDRAM_nWE,
    input   SDRAM_CKE,
    input   [12:0] SDRAM_A,
    output  [15:0] SDRAM_DQ
);

// Quick model for SDRAM
reg  [15:0] sdram_mem[0:2**18-1];
reg  [12:0] sdram_row;
//reg  [10:0] sdram_col;
reg  [15:0] sdram_data;
reg  [17:0] sdram_compound;
assign SDRAM_DQ = sdram_data;
initial $readmemh("../../../rom/gng.hex",  sdram_mem, 0, 180223);
always @(posedge SDRAM_CLK) begin
    if( !SDRAM_nCS && !SDRAM_nRAS &&  SDRAM_nCAS && SDRAM_nWE && SDRAM_CKE ) sdram_row <= SDRAM_A;
    if( !SDRAM_nCS &&  SDRAM_nRAS && !SDRAM_nCAS && SDRAM_nWE && SDRAM_CKE ) sdram_compound <= {sdram_row[8:0], SDRAM_A[8:0]};
    sdram_data <= sdram_mem[ sdram_compound ];
end

endmodule // quick_sdram