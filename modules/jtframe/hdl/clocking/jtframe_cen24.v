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
  
*//*  This file is part of JTFRAME.
    JTFRAME program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    JTFRAME program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with JTFRAME.  If not, see <http://www.gnu.org/licenses/>.

    Author: Jose Tejada Gomez. Twitter: @topapate
    Version: 1.0
    Date: 6-12-2019 */

// Input clock must be 24 MHz
// Generates various clock enable signals

module jtframe_cen24(
    input   clk,    // 24 MHz
    output  reg cen12,
    output  reg cen6,
    output  reg cen4,
    output  reg cen3,
    output  reg cen3q, // 1/4 advanced with respect to cen3
    output  reg cen1p5,
    // 180 shifted signals
    output  reg cen12b,
    output  reg cen6b,
    output  reg cen3b,
    output  reg cen3qb,
    output  reg cen1p5b
);

reg [3:0] cencnt =4'd0;
reg [2:0] cencnt3=2'd0;

always @(posedge clk) begin
    cencnt  <= cencnt+4'd1;
    cencnt3 <= cencnt3==3'd5 ? 3'd0 : (cencnt3+3'd1);
end

always @(posedge clk) begin
    cen12  <= cencnt[0] == 1'd0;
    cen12b <= cencnt[0] == 1'd1;
    cen4   <= cencnt3     == 3'd0;
    cen6   <= cencnt[1:0] == 2'd0;
    cen6b  <= cencnt[1:0] == 2'd2;
    cen3   <= cencnt[2:0] == 3'd0;
    cen3b  <= cencnt[2:0] == 3'h4;
    cen3q  <= cencnt[2:0] == 3'b110;
    cen3qb <= cencnt[2:0] == 3'b010;
    cen1p5 <= cencnt[3:0] == 4'd0;
    cen1p5b<= cencnt[3:0] == 4'b1000;
end
endmodule
