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
    Date: 13-12-2019 */

module jtframe_ff #(parameter W=1 ) (
    input                clk,
    input                rst,
    (*direct_enable*) input cen,
    input       [W-1:0]  din,
    output reg  [W-1:0]  q,
    output reg  [W-1:0]  qn,
    input       [W-1:0]  set,    // active high
    input       [W-1:0]  clr,    // active high
    input       [W-1:0]  sigedge // signal whose edge will trigger the FF
);

reg  [W-1:0] last_edge;

generate
    genvar i;
    for (i=0; i < W; i=i+1) begin: flip_flop
        always @(posedge clk) begin
            if(rst) begin
                q[i] <= 1'b0;
                qn[i] <= 1'b1;
            end
            else if(cen) begin
                last_edge[i] <= sigedge[i];
                if( clr[i] ) begin
                    q[i]  <= 1'b0;
                    qn[i] <= 1'b1;
                end else
                if( set[i] ) begin
                    q[i]  <= 1'b1;
                    qn[i] <= 1'b0;
                end else
                if( sigedge[i] && !last_edge[i] ) begin
                    q[i]  <=  din[i];
                    qn[i] <= ~din[i];
                end
            end
        end
    end
endgenerate

endmodule
