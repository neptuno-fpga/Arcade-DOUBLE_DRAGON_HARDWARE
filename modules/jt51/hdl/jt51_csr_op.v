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
    Version: 1.0
    Date: 23-10-2019
    */

module jt51_csr_op(
    input               rst,
    input               clk,
    input               cen,
    input        [ 7:0] din,
    input               up_dt1_op,  
    input               up_mul_op,  
    input               up_tl_op,   
    input               up_ks_op,   
    input               up_amsen_op,
    input               up_dt2_op,  
    input               up_d1l_op,  
    input               up_ar_op,   
    input               up_d1r_op,  
    input               up_d2r_op,  
    input               up_rr_op, 

    output        [2:0] dt1,
    output        [3:0] mul,
    output        [6:0] tl,
    output        [1:0] ks,
    output              amsen, 
    output        [1:0] dt2,
    output        [3:0] d1l,
    output        [4:0] arate,
    output        [4:0] rate1,
    output        [4:0] rate2,
    output        [3:0] rrate
);

wire    [2:0]   dt1_in  = din[6:4];
wire    [3:0]   mul_in  = din[3:0];
wire    [6:0]   tl_in   = din[6:0];
wire    [1:0]   ks_in   = din[7:6];
wire            amsen_in= din[7];
wire    [1:0]   dt2_in  = din[7:6];
wire    [3:0]   d1l_in  = din[7:4];
wire    [4:0]   ar_in   = din[4:0];
wire    [4:0]   d1r_in  = din[4:0];
wire    [4:0]   d2r_in  = din[4:0];
wire    [3:0]   rr_in   = din[3:0];

wire [30:0] reg0_in = {   
        up_dt1_op   ? dt1_in    : dt1,          // 3
        up_mul_op   ? mul_in    : mul,          // 4
        up_ks_op    ? ks_in     : ks,           // 2
        up_amsen_op ? amsen_in  : amsen,        // 1
        up_dt2_op   ? dt2_in    : dt2,          // 2
        up_d1l_op   ? d1l_in    : d1l,          // 4

        up_ar_op    ? ar_in     : arate,        // 5
        up_d1r_op   ? d1r_in    : rate1,        // 5
        up_d2r_op   ? d2r_in    : rate2    };   // 5

wire [10:0] reg1_in = {
        up_tl_op    ? tl_in     : tl,           // 7
        up_rr_op    ? rr_in     : rrate    };   // 4

wire [30:0] reg0_out;
wire [10:0] reg1_out;

assign { dt1, mul, ks, amsen, dt2, d1l, arate, rate1, rate2, tl, rrate  } 
    = {reg0_out, reg1_out};

// reset to zero
jt51_sh #( .width(31), .stages(32)) u_reg0op(
    .rst    ( rst      ),
    .clk    ( clk      ),
    .cen    ( cen      ),
    .din    ( reg0_in  ),
    .drop   ( reg0_out )
);

// reset to one
jt51_sh #( .width(11), .stages(32), .rstval(1'b1)) u_reg1op(
    .rst    ( rst      ),
    .clk    ( clk      ),
    .cen    ( cen      ),
    .din    ( reg1_in  ),
    .drop   ( reg1_out )
);


endmodule