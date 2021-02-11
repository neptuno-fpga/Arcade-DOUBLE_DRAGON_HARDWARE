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

module test;

reg         rst_n;
reg         clk;
reg         cen = 1'b0;
wire        adc_convst;
wire        adc_sck;
wire        adc_sdi;
wire [11:0] adc_read;

initial begin
    clk = 1'b0;
    #20;
    forever clk = #8 ~clk;
end

initial begin
    rst_n = 1;
    #4;
    rst_n = 0;
    #10;
    rst_n = 1;
    #100_000;
    $finish;
end

always @(negedge clk) cen <= ~cen;

reg [11:0] adc_val;
reg [ 1:0] cnt2 = 2'd0;
reg [11:0] mem[0:3];

initial begin
    mem[0] <= 12'h023;
    mem[1] <= 12'h11f;
    mem[2] <= 12'h1e5;
    mem[3] <= 12'hfbe;
end

always @(posedge adc_convst) begin
    cnt2 <= cnt2==2'd3 ? 2'd0 : cnt2+2'd1;
    adc_val <= mem[cnt2];
end

wire adc_sdo = adc_val[11];

always @(posedge adc_sck) begin
    adc_val <= {adc_val[10:0], 1'b0};
end

jtframe_2308 uut(
    .rst_n      ( rst_n      ),
    .clk        ( clk        ),
    .cen        ( cen        ),
    .adc_sdi    ( adc_sdi    ),
    .adc_convst ( adc_convst ),
    .adc_sck    ( adc_sck    ),
    .adc_sdo    ( adc_sdo    ),
    .adc_read   ( adc_read   )
);

`ifdef NCVERILOG
initial begin
    $shm_open("test.shm");
    $shm_probe(test,"AS");
end
`else 
initial begin
    $dumpfile("test.fst");
    $dumpvars;
end
`endif

endmodule // test