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

    JT51 is distributed in the hope that it will be useful;
    but WITHOUT ANY WARRANTY, without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with JT51.  If not, see <http://www.gnu.org/licenses/>.
    
    Author: Jose Tejada Gomez. Twitter: @topapate
    Version: 1.1
    Date: 15- 4-2016
    */

/*

parameter stg is the stage of the pipelined signal
for instance if signal is xx_VIII, then set stg to 8

*/

module sep32 #(parameter width=10, parameter stg=5'd0)
(
    input   clk,
    input   cen,
    input [width-1:0] mixed,
    input [4:0] cnt,    
    
    output reg [width-1:0]  slot_00,
    output reg [width-1:0]  slot_01,
    output reg [width-1:0]  slot_02,
    output reg [width-1:0]  slot_03,
    output reg [width-1:0]  slot_04,
    output reg [width-1:0]  slot_05,
    output reg [width-1:0]  slot_06,
    output reg [width-1:0]  slot_07,
    output reg [width-1:0]  slot_10,
    output reg [width-1:0]  slot_11,
    output reg [width-1:0]  slot_12,
    output reg [width-1:0]  slot_13,
    output reg [width-1:0]  slot_14,
    output reg [width-1:0]  slot_15,
    output reg [width-1:0]  slot_16,
    output reg [width-1:0]  slot_17,
    output reg [width-1:0]  slot_20,
    output reg [width-1:0]  slot_21,
    output reg [width-1:0]  slot_22,
    output reg [width-1:0]  slot_23,
    output reg [width-1:0]  slot_24,
    output reg [width-1:0]  slot_25,
    output reg [width-1:0]  slot_26,
    output reg [width-1:0]  slot_27,
    output reg [width-1:0]  slot_30,
    output reg [width-1:0]  slot_31,
    output reg [width-1:0]  slot_32,
    output reg [width-1:0]  slot_33,
    output reg [width-1:0]  slot_34,
    output reg [width-1:0]  slot_35,
    output reg [width-1:0]  slot_36,
    output reg [width-1:0]  slot_37 
);

reg [4:0] cntadj;

reg [width-1:0] slots[0:31] /*verilator public*/;

localparam pos0 = 33-stg;

/* verilator lint_off WIDTH */
always @(*)
    cntadj = (cnt+pos0)%32;
/* verilator lint_on WIDTH */

always @(posedge clk) if(cen) begin
    slots[cntadj] <= mixed;
    case( cntadj ) // octal numbers!
        5'o00:  slot_00 <= mixed;
        5'o01:  slot_01 <= mixed;
        5'o02:  slot_02 <= mixed;
        5'o03:  slot_03 <= mixed;
        5'o04:  slot_04 <= mixed;
        5'o05:  slot_05 <= mixed;
        5'o06:  slot_06 <= mixed;
        5'o07:  slot_07 <= mixed;
        5'o10:  slot_10 <= mixed;
        5'o11:  slot_11 <= mixed;
        5'o12:  slot_12 <= mixed;
        5'o13:  slot_13 <= mixed;
        5'o14:  slot_14 <= mixed;
        5'o15:  slot_15 <= mixed;
        5'o16:  slot_16 <= mixed;
        5'o17:  slot_17 <= mixed;
        5'o20:  slot_20 <= mixed;
        5'o21:  slot_21 <= mixed;
        5'o22:  slot_22 <= mixed;
        5'o23:  slot_23 <= mixed;
        5'o24:  slot_24 <= mixed;
        5'o25:  slot_25 <= mixed;
        5'o26:  slot_26 <= mixed;
        5'o27:  slot_27 <= mixed;
        5'o30:  slot_30 <= mixed;
        5'o31:  slot_31 <= mixed;
        5'o32:  slot_32 <= mixed;
        5'o33:  slot_33 <= mixed;
        5'o34:  slot_34 <= mixed;
        5'o35:  slot_35 <= mixed;
        5'o36:  slot_36 <= mixed;
        5'o37:  slot_37 <= mixed;
    endcase             
end
    
endmodule
    
