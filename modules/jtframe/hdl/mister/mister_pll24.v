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
  
*/`timescale 1ns/1ps

module pll(
    input      refclk,
    output reg locked,
    output reg outclk_0,    // clk_rom, 108 MHz
    output reg outclk_1,    // SDRAM_CLK
    output reg outclk_2=1'b0     // clk_sys, 24 MHz
);

assign locked = 1'b1;

`ifdef BASE_CLK
real base_clk = `BASE_CLK;
initial $display("INFO mister_pll24: base clock set to %f ns",base_clk);
`else
real base_clk = 10.4; // 96MHz
`endif

initial begin
    outclk_0 = 1'b0;
    forever outclk_0 = #(base_clk/2.0) ~outclk_0; // 108 MHz
end

reg div=1'b0;

initial outclk_2=1'b0;

always @(posedge outclk_0) begin
    { outclk_2, div } <= { outclk_2, div } + 2'd1;
end

`ifdef SDRAM_DELAY
real sdram_delay = `SDRAM_DELAY;
initial $display("INFO mister_pll24: SDRAM_CLK delay set to %f ns",sdram_delay);
assign #sdram_delay outclk_1 = outclk_0;
`else
initial $display("INFO mister_pll24: SDRAM_CLK delay set to 0 ns");
assign outclk_1 = outclk_0;
`endif

endmodule // pll