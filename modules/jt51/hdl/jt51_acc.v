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
  
*//*  This file is part of JT51.

    JT51 is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    JT51 is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with JT51.  If not, see <http://www.gnu.org/licenses/>.
    
    Author: Jose Tejada Gomez. Twitter: @topapate
    Version: 1.1 Date: 14- 4-2017
    Version: 1.0 Date: 27-10-2016
    */

`timescale 1ns / 1ps

module jt51_acc(
    input                   rst,
    input                   clk,
    input                   cen,
    input                   m1_enters,
    input                   m2_enters,
    input                   c1_enters,
    input                   c2_enters,
    input                   op31_acc,
    input           [1:0]   rl_I,
    input           [2:0]   con_I,
    input   signed  [13:0]  op_out,
    input                   ne,     // noise enable
    input   signed  [10:0]  noise,
    output  signed  [15:0]  left,
    output  signed  [15:0]  right,
    output  reg signed  [15:0]  xleft,  // exact outputs
    output  reg signed  [15:0]  xright    
);

reg signed [13:0] op_val;

always @(*) begin
    if( ne && op31_acc ) // cambiar a OP 31
        op_val = { {2{noise[10]}}, noise, 1'd0 };
    else
        op_val = op_out;
end

reg sum_en;

always @(*) begin
    case ( con_I )
        3'd0,3'd1,3'd2,3'd3:    sum_en = m2_enters;
        3'd4:                   sum_en = m1_enters | m2_enters;
        3'd5,3'd6:              sum_en = ~c1_enters;        
        3'd7:                   sum_en = 1'b1;
        default:                sum_en = 1'bx;
    endcase
end

wire ren = rl_I[1];
wire len = rl_I[0];
reg signed [16:0] pre_left, pre_right;
wire signed [15:0] total;
wire signed [16:0] total_ex = {total[15],total};

reg sum_all;

wire rst_sum = c2_enters;
//wire rst_sum = c1_enters;
//wire rst_sum = m1_enters;
//wire rst_sum = m2_enters;

function signed [15:0] lim16;
    input signed [16:0] din;
    lim16 = !din[16] &&  din[15] ? 16'h7fff : 
           ( din[16] && !din[15] ? 16'h8000 : din[15:0] );
endfunction


always @(posedge clk) begin
    if( rst ) begin
        sum_all <= 1'b0;
    end
    else if(cen) begin
        if( rst_sum )  begin
            sum_all <= 1'b1;
            if( !sum_all ) begin
                pre_right <= ren ? total_ex : 17'd0;
                pre_left  <= len ? total_ex : 17'd0;
            end
            else begin
                pre_right <= pre_right + (ren ? total_ex : 17'd0);
                pre_left  <= pre_left  + (len ? total_ex : 17'd0);
            end
        end
        if( c1_enters ) begin
            sum_all <= 1'b0;
            xleft  <= lim16(pre_left);
            xright <= lim16(pre_right);
        end
    end
end
            
reg  signed [15:0] opsum;
wire signed [16:0] opsum10 = {{3{op_val[13]}},op_val}+{total[15],total};

always @(*) begin
    if( rst_sum )
        opsum = sum_en ? { {2{op_val[13]}}, op_val } : 16'd0;
    else begin
        if( sum_en )
            if( opsum10[16]==opsum10[15] )
                opsum = opsum10[15:0];
            else begin
                opsum = opsum10[16] ? 16'h8000 : 16'h7fff;
            end
        else
            opsum = total;
    end
end

jt51_sh #(.width(16),.stages(8)) u_acc(
    .rst    ( rst       ),
    .clk    ( clk       ),
    .cen    ( cen       ),
    .din    ( opsum     ),
    .drop   ( total     )
);


wire signed [9:0] left_man, right_man;
wire [2:0] left_exp, right_exp;

jt51_exp2lin left_reconstruct(
    .lin( left      ),
    .man( left_man  ),
    .exp( left_exp  )
);

jt51_exp2lin right_reconstruct(
    .lin( right     ),
    .man( right_man ),
    .exp( right_exp )
);

jt51_lin2exp left2exp(
  .lin( xleft    ),
  .man( left_man ),
  .exp( left_exp ) );

jt51_lin2exp right2exp(
  .lin( xright    ),
  .man( right_man ),
  .exp( right_exp ) );

`ifdef DUMPLEFT

reg skip;

wire signed [15:0] dump = left;

initial skip=1;

always @(posedge clk)
    if( c1_enters && (!skip || dump) && cen) begin
        $display("%d", dump );
        skip <= 0;
    end

`endif

endmodule
