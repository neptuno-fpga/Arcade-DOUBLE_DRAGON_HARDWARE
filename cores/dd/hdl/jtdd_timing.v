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
  
*//*  This file is part of JTDD.
    JTDD program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    JTDD program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with JTDD.  If not, see <http://www.gnu.org/licenses/>.

    Author: Jose Tejada Gomez. Twitter: @topapate
    Version: 1.0
    Date: 2-12-2017 */

`timescale 1ns/1ps

module jtdd_timing(
    input              clk,
    input              rst,
    (*direct_enable*) input pxl_cen,
    input              flip,
    output reg [7:0]   VPOS=8'd0, // VPOS in schematics
    output     [7:0]   HPOS, // HPOS in schematics
    output reg         VBL=1'b0,
    output reg         HBL=1'b0,
    output reg         VS=1'b0,
    output reg         HS=1'b0,
    output     [5:0]   M       // *M in schematics, *M represents ~M
);

reg [8:0] hn=9'd0;
reg [7:0] vn=8'he0;
reg [7:0]  m;
wire hover = hn==9'd383;
wire [8:0] nextn = hover ? 9'd0 : hn+9'd1;
reg aux=1'b0;

always @(posedge clk) begin
    VPOS <= vn ^ {8{flip}};
end

assign M = m[5:0];
assign HPOS = hn[7:0] ^ {8{flip}};

wire [8:0] HS1 = 9'd245+((9'd383-9'd255)>>1);
wire [8:0] HS0 = 9'd265+((9'd383-9'd255)>>1);

always @(posedge clk) if(pxl_cen) begin
    // bus phases
    m  <= 8'd0;
    if( nextn[0] ) m[nextn[3:1]] <= 1'b1;
    // counters
    hn <= nextn;
    //HS <= hn==9'd255+((9'd383-9'd255)>>1); // middle of blanking
    if( hn==HS1 ) begin
        HS <= 1'b1;
        //VS <= vn==8'hef && VBL;
        if( vn==8'he9 && VBL ) VS <= 1'b1;
        if( vn==8'hed && VBL ) VS <= 1'b0;
    end
    if( hn==HS0 ) HS <= 1'b0;
    if( hn == 9'd255 ) begin
        HBL <= 1'b1;
    end else if( hover )begin
        HBL <= 1'b0;
        if( &vn ) begin
            vn <= (VBL&&!aux) ? 8'he8 : 8'h8;
        end else begin
            vn <= vn + 8'd1;
            if( vn == 8'hF7 ) begin
                VBL <= 1'b1;
                aux <= VBL;
            end
        end
        //if( vn == 8'hff && aux ) VBL <= 1'b0;
        if( vn == 8'h08 ) VBL <= 1'b0;
    end
end


endmodule