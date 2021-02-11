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
  
*//* This file is part of JT12.

 
    JT12 program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    JT12 program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with JT12.  If not, see <http://www.gnu.org/licenses/>.

    Author: Jose Tejada Gomez. Twitter: @topapate
    Version: 1.0
    Date: 10-12-2018
    
*/

module jt12_comb #(parameter 
    w=16,   // bit width
    m=1     // depth of comb filter
)(
    input               rst,
    input               clk,
(* direct_enable *)    input cen,
    input  signed [w-1:0] snd_in,
    output reg signed [w-1:0] snd_out
);

wire signed [w-1:0] prev;

// m-delay stage
generate
    genvar k;
    reg signed [w-1:0] mem[0:m-1];
    assign prev=mem[m-1];
    for(k=1;k<m;k=k+1) begin : mem_gen
        always @(posedge clk)
            if(rst) begin
                mem[k] <= {w{1'b0}};
            end else if(cen) begin
                mem[k] <= mem[k-1];
            end
    end
    // k=0 (I take out to avoid a warning about mem[k-1] when k is 0)
    always @(posedge clk)
        if(rst) begin
            mem[0] <= {w{1'b0}};
        end else if(cen) begin
            mem[0] <= snd_in;
        end    
endgenerate

// Comb filter at synthesizer sampling rate
always @(posedge clk)
    if(rst) begin
        snd_out <= {w{1'b0}};
    end else if(cen) begin
        snd_out <= snd_in - prev;
    end

endmodule // jt12_comb