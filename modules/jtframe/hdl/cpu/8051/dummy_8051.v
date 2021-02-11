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
  
*/module mc8051_core(
    input           clk,
    input           reset,
    input  [7:0]    rom_data_i,
    input  [7:0]    ram_data_i,
    input           int0_i,
    input           int1_i,
    input           all_t0_i,
    input           all_t1_i,
    input           all_rxd_i,
    input  [7:0]    p0_i,
    input  [7:0]    p1_i,
    input  [7:0]    p2_i,
    input  [7:0]    p3_i,
    output [7:0]    p0_o,
    output [7:0]    p1_o,
    output [7:0]    p2_o,
    output [7:0]    p3_o,
    output          all_rxd_o,
    output          all_txd_o,
    output          all_rxdwr_o,
    output [15:0]   rom_adr_o,
    output [ 7:0]   ram_data_o,
    output [ 6:0]   ram_adr_o,
    output          ram_wr_o,
    output          ram_en_o,
    input  [ 7:0]   datax_i,
    output [ 7:0]   datax_o,
    output [15:0]   adrx_o,
    output          wrx_o
);

assign rom_adr_o = 16'd0;
assign ram_en_o  = 1'b0;
assign ram_wr_o  = 1'b0;
assign datax_o   = 8'd0;
assign adrx_o    = 16'd0;

assign p0_o      = 8'd0;
assign p1_o      = 8'd0;
assign p2_o      = 8'd0;
assign p3_o      = 8'h20;

assign all_rxd_o = 1'b0;
assign all_txd_o = 1'b0;
assign all_rxdwr_o = 1'b0;

endmodule // mc8051_core