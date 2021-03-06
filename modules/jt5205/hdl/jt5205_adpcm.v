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
  
*//*  This file is part of JT5205.
    JT5205 program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    JT5205 program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with JT5205.  If not, see <http://www.gnu.org/licenses/>.

    Author: Jose Tejada Gomez. Twitter: @topapate
    Version: 1.0
    Date: 30-10-2019 */

module jt5205_adpcm(
    input                      rst,
    input                      clk,
    (* direct_enable *) input  cen_hf,
    (* direct_enable *) input  cen_lo,
    input             [ 3:0]   din,
    output reg signed [11:0]   sound
);

reg [ 5:0] delta_idx, idx_inc;
reg [10:0] delta[0:48];

reg [11:0] dn, qn;
reg        up;
reg [ 2:0] factor;
reg [ 3:0] din_copy;
reg [ 5:0] next_idx;
reg signed [12:0] unlim;

always @(posedge clk, posedge rst) begin
    if( rst ) begin
        factor    <= 3'd0;
        up        <= 1'b0;
        next_idx  <= 6'd0;
        dn        <= 12'd0;
        qn        <= 12'd0;
    end else if(cen_hf) begin
        up <= cen_lo;
        if( up ) begin
            factor   <= din_copy[2:0];
            dn       <= { 1'b0, delta[delta_idx] };
            qn       <= { 1'd0, delta[delta_idx]>>3};
            next_idx <= din_copy[2] ? (delta_idx+idx_inc) : (delta_idx-6'd1);
        end else begin
            if(factor[2]) begin
                qn <= qn + dn;
            end
            dn     <= dn>>1;
            factor <= factor<<1;
            if( next_idx>6'd48)
                next_idx <= din_copy[2] ? 6'd48 : 6'd0;
        end
    end
end

function signed [12:0] extend;
    input signed [11:0] a;
    extend = { a[11], a };
endfunction

always @(*) begin
    unlim = din_copy[3] ? extend(sound) - {1'b0,qn} :
                          extend(sound) + {1'b0,qn};
end

wire signed [12:0] lim_pos =  13'd2047;
wire signed [12:0] lim_neg = -13'd2048;

wire ovp = unlim>lim_pos;
wire ovn = unlim<lim_neg;

always @(posedge clk, posedge rst) begin
    if( rst ) begin
        delta_idx <= 6'd0;
        sound     <= -12'd2;
        din_copy  <= 4'd0;
    end else if(cen_lo) begin
        case( din[1:0] )
            2'd0: idx_inc <= 6'd2;
            2'd1: idx_inc <= 6'd4;
            2'd2: idx_inc <= 6'd6;
            2'd3: idx_inc <= 6'd8;
        endcase
        din_copy  <= din;
        delta_idx <= next_idx;
        sound     <= ovp ? 12'd2047 : ovn ? -12'd2048 : unlim[11:0];
    end
end

initial begin
delta[ 0] = 11'd0016; delta[ 1] = 11'd0017; delta[ 2] = 11'd0019; delta[ 3] = 11'd0021; delta[ 4] = 11'd0023; delta[ 5] = 11'd0025; delta[ 6] = 11'd0028; 
delta[ 7] = 11'd0031; delta[ 8] = 11'd0034; delta[ 9] = 11'd0037; delta[10] = 11'd0041; delta[11] = 11'd0045; delta[12] = 11'd0050; delta[13] = 11'd0055; 
delta[14] = 11'd0060; delta[15] = 11'd0066; delta[16] = 11'd0073; delta[17] = 11'd0080; delta[18] = 11'd0088; delta[19] = 11'd0097; delta[20] = 11'd0107; 
delta[21] = 11'd0118; delta[22] = 11'd0130; delta[23] = 11'd0143; delta[24] = 11'd0157; delta[25] = 11'd0173; delta[26] = 11'd0190; delta[27] = 11'd0209; 
delta[28] = 11'd0230; delta[29] = 11'd0253; delta[30] = 11'd0279; delta[31] = 11'd0307; delta[32] = 11'd0337; delta[33] = 11'd0371; delta[34] = 11'd0408; 
delta[35] = 11'd0449; delta[36] = 11'd0494; delta[37] = 11'd0544; delta[38] = 11'd0598; delta[39] = 11'd0658; delta[40] = 11'd0724; delta[41] = 11'd0796; 
delta[42] = 11'd0876; delta[43] = 11'd0963; delta[44] = 11'd1060; delta[45] = 11'd1166; delta[46] = 11'd1282; delta[47] = 11'd1411; delta[48] = 11'd1552; 
end

endmodule