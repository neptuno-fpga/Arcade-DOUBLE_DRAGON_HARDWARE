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
  
*//*  This file is part of JT_GNG.
    JT_GNG program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    JT_GNG program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with JT_GNG.  If not, see <http://www.gnu.org/licenses/>.

    Author: Jose Tejada Gomez. Twitter: @topapate
    Version: 1.0
    Date: 4-2-2019 */

// Based on MiST tutorials

module jtframe_keyboard(
    input clk,
    input rst,

    // ps2 interface
    input ps2_clk,
    input ps2_data,

    // decodes keys
    output reg [9:0] key_joy1,
    output reg [9:0] key_joy2,
    output reg [1:0] key_start,
    output reg [1:0] key_coin,
    output reg key_reset,
    output reg key_pause,
    output reg key_service,
	 output reg [3:0] key_vgactrl,
    output reg [3:0] key_gfx
);

wire valid;
wire error;

reg key_released;
reg key_extended;
reg [7:0] ps2byte;

/* Left e06b, right e074, up e075, down e072,
   CTRL 14, space 29, alt 11, "1" 16, "2" 1e
   "5" 2e, "F3" 4, P 4d, W 1d, a 1c, s 1b, d 23
   z 1a, x 22, c 21 */

always @(posedge clk) begin
    if(rst) begin
      key_released <= 1'b0;
      key_extended <= 1'b0;
      key_joy1     <=  'd0;
      key_joy2     <=  'd0;
      key_coin     <= 2'd0;
      key_start    <= 2'd0;
      key_reset    <= 1'b0;
      key_pause    <= 1'b0;
      key_service  <= 1'b0;
    end else begin
        // ps2 decoder has received a valid ps2byte
        if(valid) begin
            if(ps2byte == 8'he0 /*|| ps2byte == 8'h12*/)
                // extended key code
            key_extended <= 1'b1;
         else if(ps2byte == 8'hf0)
                // release code
            key_released <= 1'b1;
         else begin
                key_extended <= 1'b0;
                key_released <= 1'b0;

                case({key_extended, ps2byte})
                    // first joystick
                    9'h0_29: key_joy1[6] <= !key_released;   // Button 3
                    9'h0_11: key_joy1[5] <= !key_released;   // Button 2
                    9'h0_14: key_joy1[4] <= !key_released;   // Button 1
                    9'h1_75: key_joy1[3] <= !key_released;   // Up
                    9'h1_72: key_joy1[2] <= !key_released;   // Down
                    9'h1_6b: key_joy1[1] <= !key_released;   // Left
                    9'h1_74: key_joy1[0] <= !key_released;   // Right
                    // second joystick
                    9'h0_15: key_joy2[6] <= !key_released;   // Button 3
                    9'h0_1b: key_joy2[5] <= !key_released;   // Button 2
                    9'h0_1c: key_joy2[4] <= !key_released;   // Button 1
                    9'h0_2d: key_joy2[3] <= !key_released;   // Up
                    9'h0_2b: key_joy2[2] <= !key_released;   // Down
                    9'h0_23: key_joy2[1] <= !key_released;   // Left
                    9'h0_34: key_joy2[0] <= !key_released;   // Right
                    // coins
                    9'h2e                : key_coin[0] <= !key_released;  // 1st coin
                    9'h36                : key_coin[1] <= !key_released;  // 2nd coin
                    9'h16, 9'h05 /* F1 */: key_start[0] <= !key_released; // 1P start
                    9'h1e, 9'h06 /* F2 */: key_start[1] <= !key_released; // 2P start
                    // system control
                    9'h4d, 9'h0C /* F4 */   : key_pause <= !key_released;
                    9'h04        /* F3 */   : key_reset <= !key_released;
                    9'h46        /*  9 */   : key_service <= !key_released;
					     9'h0_7E                 : key_vgactrl[0] <= !key_released; //Bloq Despl
					     9'h0_7B, 9'h03 /* F5 */ : key_vgactrl[1] <= !key_released; //F5 y '-' Teclado Numerico "Scanlines"
						  9'h0B          /* F6 */ : key_vgactrl[2] <= !key_released; //F6 "Invertir Pantalla"
						  9'h0_7C        /* *  */ : key_vgactrl[3] <= !key_released; //'*' Teclado Numerico "Modo Test"
                    // GFX enable
                    9'h0_83: key_gfx[0] <= !key_released; // F7: CHAR enable
                    9'h0_0a: key_gfx[1] <= !key_released; // F8: SCR1 enable
                    9'h0_01: key_gfx[2] <= !key_released; // F9: SCR2 enable
                    9'h0_09: key_gfx[3] <= !key_released; // F10:OBJ  enable
                endcase
            end
        end
    end
end

// the ps2 decoder has been taken from the zx spectrum core
ps2_intf ps2_keyboard (
    .CLK     ( clk           ),
    .nRESET  ( !rst          ),

    // PS/2 interface
    .PS2_CLK  ( ps2_clk         ),
    .PS2_DATA ( ps2_data        ),

    // ps2byte-wide data interface - only valid for one clock
    // so must be latched externally if required
    .DATA         ( ps2byte   ),
    .VALID    ( valid  ),
    .ERROR    ( error  )
);


endmodule