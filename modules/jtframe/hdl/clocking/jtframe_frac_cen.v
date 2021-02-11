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
  
*////////////////////////////////////////////////////////////////////////////
// Fractional clock enable signal
// W refers to the number of divided down cen signals available
// each one is divided by 2

module jtframe_frac_cen #(parameter W=2)(
    input         clk,
    input   [9:0] n,         // numerator
    input   [9:0] m,         // denominator
    output reg [W-1:0] cen,
    output reg [W-1:0] cenb // 180 shifted
);

wire [10:0] step={1'b0,n};
wire [10:0] lim ={1'b0,m};
wire [10:0] absmax = lim+step;

reg  [10:0] cencnt=11'd0;
reg  [10:0] next;
reg  [10:0] next2;

always @(*) begin
    next  = cencnt+step;
    next2 = next-lim;
end

reg  half    = 1'b0;
wire over    = next>=lim;
wire halfway = next >= (lim>>1)  && !half;

reg  [W-1:0] edgecnt = {W{1'b0}};
wire [W-1:0] next_edgecnt = edgecnt + 1'b1;
wire [W-1:0] toggle = next_edgecnt & ~edgecnt;

always @(posedge clk) begin
    cen  <= {W{1'b0}};
    cenb <= {W{1'b0}};

    if( cencnt >= absmax ) begin
        // something went wrong: restart
        cencnt <= 11'd0;
    end else
    if( halfway ) begin
        half <= 1'b1;
        cenb[0] <= 1'b1;
    end
    if( over ) begin
        cencnt <= next2;
        half <= 1'b0;
        edgecnt <= next_edgecnt;
        cen <= { toggle[W-2:0], 1'b1 };
    end else begin
        cencnt <= next;
    end
end


endmodule