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

module jtframe_scan2x #(parameter DW=12, HLEN=256)(
    input       rst_n,
    input       clk,
    input       base_cen,
    input       basex2_cen,
    input       [DW-1:0]    base_pxl,
    input       HS,

    output  reg [DW-1:0]    x2_pxl,
    output  reg x2_HS
);

localparam AW=HLEN<=256 ? 8 : (HLEN<=512 ? 9:10 );

reg [DW-1:0] mem0[0:HLEN-1];
reg [DW-1:0] mem1[0:HLEN-1];
reg oddline;
reg [AW-1:0] wraddr, rdaddr, hscnt0, hscnt1;
reg last_HS, last_HS_base;

reg waitHS;

always @(posedge clk) if(base_cen)   last_HS_base <= HS;
always @(posedge clk) if(basex2_cen) last_HS <= HS;

wire HS_posedge =  HS && !last_HS;
wire HSbase_posedge =  HS && !last_HS_base;
wire HS_negedge = !HS &&  last_HS;

always@(posedge clk or negedge rst_n)
    if( !rst_n )
        waitHS  <= 1'b1;
    else begin
        if(HS_posedge ) waitHS  <= 1'b0;
    end

reg alt_pxl; // this is needed in case basex2_cen and base_cen are not aligned.

always@(posedge clk or negedge rst_n)
    if( !rst_n ) begin
        wraddr  <= {AW{1'b0}};
        rdaddr  <= {AW{1'b0}};
        oddline <= 1'b0;
        alt_pxl <= 1'b0;
    end else if(basex2_cen) begin
    if( !waitHS ) begin
        rdaddr  <= rdaddr < (HLEN-1) ? (rdaddr+1) : 0;
        x2_pxl  <= x2_HS ? {DW{1'b0}} : oddline ? mem0[rdaddr] : mem1[rdaddr];
        alt_pxl <= ~alt_pxl;
        if( alt_pxl ) begin
            if( HSbase_posedge ) oddline <= ~oddline;
            wraddr <= HSbase_posedge ? 0 : (wraddr+1);
            if( oddline )
                mem1[wraddr] <= base_pxl;
            else
                mem0[wraddr] <= base_pxl;
        end 
    end
    end

always @(posedge clk or negedge rst_n)
    if( !rst_n ) begin
        x2_HS <= 1'b0;
    end else begin
        if( HS_posedge ) hscnt1 <= wraddr;
        if( HS_negedge ) hscnt0 <= wraddr;
        if( rdaddr == hscnt0 ) x2_HS <= 1'b0;
        if( rdaddr == hscnt1 ) x2_HS <= 1'b1;
    end

endmodule // jtframe_scan2x