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

module jtframe_pll0(
    input    inclk0,
    output   reg c1,      // 12
    output   reg c2,      // 96
    output       c3,     // 96 (shifted by -2.5ns)
    output       c4,
    output   locked
);

assign locked = 1'b1;

`ifdef BASE_CLK
real base_clk = `BASE_CLK;
initial $display("INFO: base clock set to %f ns",base_clk);
`else
// 108 MHz -> 9.259ns
//  96 MHz -> 10.417ns
//  84 MHz -> 11.905ns
//  72 MHz -> 13.889ns X fails
//  48 MHz -> 20.833ns
real base_clk = 20.833;
`endif

initial begin
    c1 = 1'b0;
    forever c1 = #(base_clk/2.0) ~c1; 
end

`ifdef SDRAM_DELAY
real sdram_delay = `SDRAM_DELAY;
initial $display("INFO: SDRAM_CLK delay set to %f ns",sdram_delay);
assign #sdram_delay c2 = c1;
`else
initial $display("INFO: SDRAM_CLK delay set to 1 ns");
assign #1 c2 = c1;
`endif

endmodule // jtgng_pll0


module jtframe_pll1 (
    input inclk0,
    output reg c0     // 25
);

initial begin
    c0 = 1'b0;
    forever c0 = #20 ~c0;
end

endmodule // jtgng_pll1


////////////////////////////////////////////////////
////////////////////////////////////////////////////
// 20 MHz PLL

module jtframe_pll20_fast(
    input    inclk0,
    output   reg c0,     // 20
    output   reg c1,     // 80
    output   reg c2,     // 80 (shifted by -2.5ns)
    output   locked
);

    assign locked = 1'b1;

    `ifdef BASE_CLK
    real base_clk = `BASE_CLK;
    initial $display("INFO: base clock set to %f ns",base_clk);
    `else
    real base_clk = 12.5; // 80 MHz
    `endif

    initial begin
        c1 = 1'b0;
        forever c1 = #(base_clk/2.0) ~c1; // 80 MHz
    end

    reg [1:0] div=2'd0;

    assign c0 = div[1];

    always @(posedge c1) begin
        div <= div+'d1;
    end

    `ifdef SDRAM_DELAY
    real sdram_delay = `SDRAM_DELAY;
    initial $display("INFO pll20: SDRAM_CLK delay set to %f ns",sdram_delay);
    `else
    initial $display("INFO pll20: SDRAM_CLK delay set to 0 ns");
    real sdram_delay = 0;
    `endif

    initial begin
        c2 = 1'b0;
        #(sdram_delay);
        forever c2 = #(base_clk/2.0) ~c2; // 80 MHz
    end
endmodule