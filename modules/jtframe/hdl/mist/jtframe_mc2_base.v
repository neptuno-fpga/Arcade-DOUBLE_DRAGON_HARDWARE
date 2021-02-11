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
    Date: 27-10-2017 */
/*
 * Revision MC 1.2 by Oduvaldo ( ducasp@gmail.com )
 * Date: 28/12/2020
 * Changes: Fix joy1/2_s not being initialized, causing misbehavior when
 *          no joystick was attached.
 * 
 * Revision MC 1.1 by Oduvaldo ( ducasp@gmail.com )
 * Date: 18/12/2020
 * Changes: MODE + START -> OSD
 *          MODE + X -> 1P Start
 *          MODE + Y -> 2P Start
 *          MODE + B -> COIN
 *          START + A -> PAUSE
 */

`timescale 1ns/1ps

module jtframe_mc2_base #(parameter
    CONF_STR        = "CORE",
    CONF_STR_LEN    = 4,
    SIGNED_SND      = 1'b0,
    COLORW          = 4
) (
    input           rst,
    input           clk_sys,
    input           clk_rom,
    input           clk_vga,
    input           clk_40,
    input           SDRAM_CLK,      // SDRAM Clock
    output          osd_shown,
     
  

    // Base video
    input   [1:0]   osd_rotate,
    input [COLORW-1:0] game_r,
    input [COLORW-1:0] game_g,
    input [COLORW-1:0] game_b,
    input           LHBL,
    input           LVBL,
    input           hs,
    input           vs, 
    input           pxl_cen,
    // Scan-doubler video
    input   [5:0]   scan2x_r,
    input   [5:0]   scan2x_g,
    input   [5:0]   scan2x_b,
    input           scan2x_hs,
    input           scan2x_vs,
    output          scan2x_enb, // scan doubler enable bar = scan doubler disable.
    // Final video: VGA+OSD or base+OSD depending on configuration
    output  [5:0]   VIDEO_R,
    output  [5:0]   VIDEO_G,
    output  [5:0]   VIDEO_B,
    output          VIDEO_HS,
    output          VIDEO_VS,
    // SPI interface to arm io controller
    inout           SPI_DO,
    input           SPI_DI,
    input           SPI_SCK,
    input           SPI_SS2,
    input           SPI_SS3,
    input           SPI_SS4,
    input           CONF_DATA0,
    // control
    output [31:0]   status,
    output [31:0]   joystick1,
    output [31:0]   joystick2,
    output [31:0]   joystick3,
    output [31:0]   joystick4,
    output          ps2_kbd_clk,
    output          ps2_kbd_data,
    // Sound
    input           clk_dac,
    input   [15:0]  snd_left,
    input   [15:0]  snd_right,
    output          snd_pwm_left,
    output          snd_pwm_right,
    // ROM load from SPI
    output [22:0]   ioctl_addr,
    output [ 7:0]   ioctl_data,
    output          ioctl_wr,
    output          downloading,
  
     
     //MC2 
    input  [7:0] keys_i,
    input       pll_locked,
    input       video_direct,
    input wire  joy1_up_i,
    input wire  joy1_down_i,
    input wire  joy1_left_i,
    input wire  joy1_right_i,
    input wire  joy1_p6_i,
    input wire  joy1_p9_i,
    input wire  joy2_up_i,
    input wire  joy2_down_i,
    input wire  joy2_left_i,
    input wire  joy2_right_i,
    input wire  joy2_p6_i,
    input wire  joy2_p9_i,
    output wire joyX_p7_o
);

wire ypbpr;

`ifndef SIMULATION
    `ifndef NOSOUND

    function [19:0] snd_padded;
        input [15:0] snd;
        reg   [15:0] snd_in;
        begin
            snd_in = {snd[15]^SIGNED_SND, snd[14:0]};
            snd_padded = { 1'b0, snd_in, 3'd0 };
        end
    endfunction

    hifi_1bit_dac u_dac_left
    (
      .reset    ( rst                  ),
      .clk      ( clk_dac              ),
      .clk_ena  ( 1'b1                 ),
      .pcm_in   ( snd_padded(snd_left) ),
      .dac_out  ( snd_pwm_left         )
    );



        `ifdef STEREO_GAME
       hifi_1bit_dac u_dac_right
        (
          .reset    ( rst                  ),
          .clk      ( clk_dac              ),
          .clk_ena  ( 1'b1                 ),
          .pcm_in   ( snd_padded(snd_right)),
          .dac_out  ( snd_pwm_right        )
        );


        `else
        assign snd_pwm_right = snd_pwm_left;
        `endif
    `endif
`else // Simulation:
assign snd_pwm_left = 1'b0;
assign snd_pwm_right = 1'b0;
`endif

`ifndef JTFRAME_MIST_DIRECT
`define JTFRAME_MIST_DIRECT 1'b1
`endif

`ifndef SIMULATION
/*
user_io #(.STRLEN(CONF_STR_LEN), .ROM_DIRECT_UPLOAD(`JTFRAME_MIST_DIRECT)) u_userio(
    .clk_sys        ( clk_sys   ),
    .conf_str       ( CONF_STR  ),
    .SPI_CLK        ( SPI_SCK   ),
    .SPI_SS_IO      ( CONF_DATA0),
    .SPI_MISO       ( SPI_DO    ),
    .SPI_MOSI       ( SPI_DI    ),
    .joystick_0     ( joystick2 ),
    .joystick_1     ( joystick1 ),
    .joystick_3     ( joystick3 ),
    .joystick_4     ( joystick4 ),
    .status         ( status    ),
    .ypbpr          ( ypbpr     ),
    .scandoubler_disable ( scan2x_enb ),
    // keyboard
    .ps2_kbd_clk    ( ps2_kbd_clk  ),
    .ps2_kbd_data   ( ps2_kbd_data ),
    // unused ports:
    .serial_strobe  ( 1'b0      ),
    .serial_data    ( 8'd0      ),
    .sd_lba         ( 32'd0     ),
    .sd_rd          ( 1'b0      ),
    .sd_wr          ( 1'b0      ),
    .sd_conf        ( 1'b0      ),
    .sd_sdhc        ( 1'b0      ),
    .sd_din         ( 8'd0      )
);
*/
assign scan2x_enb = status[5] ^ video_direct;

`else
assign joystick1 = 32'd0;
assign joystick2 = 32'd0;
assign status    = 32'd0;
assign ps2_kbd_data = 1'b0;
assign ps2_kbd_clk  = 1'b0;
`ifndef SCANDOUBLER_DISABLE
assign scan2x_enb   = 1'b0;
`define SCANDOUBLER_DISABLE 1'b0
initial $display("INFO: Use -d SCANDOUBLER_DISABLE=1 if you want video output.");
`endif
assign scan2x_enb = `SCANDOUBLER_DISABLE;
assign ypbpr = 1'b0;
`endif

reg  [7:0]  osd_keys = 8'b11111111;

data_io  #(.STRLEN(CONF_STR_LEN)) u_datain (
    .SPI_SCK            ( SPI_SCK      ),
    .SPI_SS2            ( SPI_SS2      ),
    .SPI_DI             ( SPI_DI       ),
    .SPI_DO             ( SPI_DO       ),
    
     .data_in               ( osd_s & osd_keys ),
     .conf_str              ( CONF_STR      ),
     .status                    ( status        ),
    
    .clk_sys            ( clk_rom      ),
    .ioctl_download     ( downloading  ),
    .ioctl_addr         ( ioctl_addr   ),
    .ioctl_dout         ( ioctl_data   ),
    .ioctl_wr           ( ioctl_wr     ),
    .ioctl_index        ( /* unused*/  )
);

// OSD will only get simulated if SIMULATE_OSD is defined
`ifndef SIMULATE_OSD
`ifndef SCANDOUBLER_DISABLE
`ifdef SIMULATION
`define BYPASS_OSD
`endif
`endif
`endif

`ifdef SIMINFO
initial begin
    $display("INFO: use -d SIMULATE_OSD to simulate the MiST OSD")
end
`endif


`ifndef BYPASS_OSD
// include the on screen display
wire [5:0] osd_r_o;
wire [5:0] osd_g_o;
wire [5:0] osd_b_o;
wire       HSync = scan2x_enb ? ~hs : vga_hs_s;
wire       VSync = scan2x_enb ? ~vs : vga_vs_s;
wire       HSync_osd, VSync_osd;
wire       CSync_osd = ~(HSync_osd ^ VSync_osd);

function [5:0] extend_color;
    input [COLORW-1:0] a;
    case( COLORW )
        3: extend_color = { a, a[2:0] };
        4: extend_color = { a, a[3:2] };
        5: extend_color = { a, a[4] };
        6: extend_color = a;
        7: extend_color = a[6:1];
        8: extend_color = a[7:2];
    endcase
endfunction

wire [5:0] game_r6 = extend_color( game_r );
wire [5:0] game_g6 = extend_color( game_g );
wire [5:0] game_b6 = extend_color( game_b );
wire [5:0] game_Br6 = extend_color( vga_col_s[11:8] );
wire [5:0] game_Bg6 = extend_color( vga_col_s[7:4] );
wire [5:0] game_Bb6 = extend_color( vga_col_s[3:0] );
wire [11:0]vga_col_s;
wire       vga_hs_s,vga_vs_s;

framebuffer #(256,240,12,1) framebuffer (
		.clk_sys    ( clk_sys              ),
		.clk_i      ( pxl_cen              ),
		.RGB_i      ({game_r,game_g,game_b}),
		.hblank_i   ( ~LHBL                ),
		.vblank_i   ( ~LVBL                ),
		.dis_db_i   ( status[14]           ),
		.rotate_i   ( 2'b00                ), 
		.clk_vga_i  ( clk_vga              ),//(status[1]) ? clk_40 : clk_vga ), //800x600 or 640x480
		.RGB_o      ( vga_col_s            ),
		.hsync_o    ( vga_hs_s             ),
		.vsync_o    ( vga_vs_s             )
);

osd #(0,0,3'b001) osd (
   .clk_sys    ( scan2x_enb ? clk_sys : clk_vga ),

   // spi for OSD
   .SPI_DI     ( SPI_DI       ),
   .SPI_SCK    ( SPI_SCK      ),
   .SPI_SS3    ( SPI_SS2      ),

   .rotate     ( osd_rotate   ),

   .R_in       ( scan2x_enb ? game_r6 : game_Br6 ),
   .G_in       ( scan2x_enb ? game_g6 : game_Bg6 ),
   .B_in       ( scan2x_enb ? game_b6 : game_Bb6 ),
   .HSync      ( HSync        ),
   .VSync      ( VSync        ),

   .R_out      ( osd_r_o      ),
   .G_out      ( osd_g_o      ),
   .B_out      ( osd_b_o      ),
   .HSync_out  ( HSync_osd    ),
   .VSync_out  ( VSync_osd    ),

   .osd_shown  ( osd_shown    )
);

wire  [5:0] sl_r_s, sl_g_s, sl_b_s;

scanlines scanlines
(
		.clk_sys   ( (~scan2x_enb) ? clk_vga : clk_sys),

		.scanlines ( status[4:3]) ,
		.ce_x2     ( 1'b1 ),

		.r_in     ( osd_r_o      ),
		.g_in     ( osd_g_o      ),
		.b_in     ( osd_b_o      ),
		.hs_in    ( (~scan2x_enb) ? vga_hs_s : ~hs    ),
		.vs_in    ( (~scan2x_enb) ? vga_vs_s : ~vs    ),

		.r_out ( sl_r_s ),
		.g_out ( sl_g_s ),
		.b_out ( sl_b_s )
);

wire [5:0] Y, Pb, Pr;
wire [5:0] r, g, b;

rgb2ypbpr u_rgb2ypbpr
(
    .red   ( osd_r_o ),
    .green ( osd_g_o ),
    .blue  ( osd_b_o ),
    .y     ( Y       ),
    .pb    ( Pb      ),
    .pr    ( Pr      )
);

assign r = ypbpr ? Pr : osd_r_o;
assign g = ypbpr ? Y  : osd_g_o;
assign b = ypbpr ? Pb : osd_b_o;

assign VIDEO_R = sl_r_s;
assign VIDEO_G = sl_g_s;
assign VIDEO_B = sl_b_s;

// a minimig vga->scart cable expects a composite sync signal on the VIDEO_HS output.
// and VCC on VIDEO_VS (to switch into rgb mode)
assign VIDEO_HS = (scan2x_enb | ypbpr) ? CSync_osd : HSync_osd;
assign VIDEO_VS = (scan2x_enb | ypbpr) ? 1'b1 : VSync_osd;
`else
assign VIDEO_R  = game_r;// { game_r, game_r[3:2] };
assign VIDEO_G  = game_g;// { game_g, game_g[3:2] };
assign VIDEO_B  = game_b;// { game_b, game_b[3:2] };
assign VIDEO_HS = hs;
assign VIDEO_VS = vs;
`endif

//--------- ROM DATA PUMP ----------------------------------------------------
    
        reg [15:0] power_on_s   = 16'b1111111111111111;
        reg [7:0] osd_s = 8'b11111111;
        
        wire hard_reset = ~pll_locked;
        
        //--start the microcontroller OSD menu after the power on
        always @(posedge clk_sys) 
        begin
        
                if (hard_reset == 1)
                    power_on_s = 16'b1111111111111111;
                else if (power_on_s != 0)
                begin
                    power_on_s = power_on_s - 1;
                    osd_s = 8'b00111111;
                end 
                    
                
                if (downloading == 1 && osd_s == 8'b00111111)
                    osd_s = 8'b11111111;
            
        end 

//-----------------------
reg joy1_up_q   ; reg joy1_up_0;
reg joy1_down_q ; reg joy1_down_0;
reg joy1_left_q ; reg joy1_left_0;
reg joy1_right_q; reg joy1_right_0;
reg joy1_p6_q   ; reg joy1_p6_0;
reg joy1_p9_q   ; reg joy1_p9_0;

reg joy2_up_q   ; reg joy2_up_0;
reg joy2_down_q ; reg joy2_down_0;
reg joy2_left_q ; reg joy2_left_0;
reg joy2_right_q; reg joy2_right_0;
reg joy2_p6_q   ; reg joy2_p6_0;
reg joy2_p9_q   ; reg joy2_p9_0;

   always @(posedge clk_sys) 
   begin
         joy1_up_0    <= joy1_up_i;
         joy1_down_0  <= joy1_down_i;
         joy1_left_0  <= joy1_left_i;
         joy1_right_0 <= joy1_right_i;
         joy1_p6_0    <= joy1_p6_i;
         joy1_p9_0    <= joy1_p9_i;
      
         joy2_up_0    <= joy2_up_i;
         joy2_down_0  <= joy2_down_i;
         joy2_left_0  <= joy2_left_i;
         joy2_right_0 <= joy2_right_i;
         joy2_p6_0    <= joy2_p6_i;
         joy2_p9_0    <= joy2_p9_i;
   end 
   
    always @(posedge clk_sys) 
   begin
         joy1_up_q    <= joy1_up_0;
         joy1_down_q  <= joy1_down_0;
         joy1_left_q  <= joy1_left_0;
         joy1_right_q <= joy1_right_0;
         joy1_p6_q    <= joy1_p6_0;
         joy1_p9_q    <= joy1_p9_0;

         joy2_up_q    <= joy2_up_0;
         joy2_down_q  <= joy2_down_0;
         joy2_left_q  <= joy2_left_0;
         joy2_right_q <= joy2_right_0;
         joy2_p6_q    <= joy2_p6_0;
         joy2_p9_q    <= joy2_p9_0;
     
   end
//--- Joystick read with sega 6 button support----------------------
    reg clk_sega_s;

    parameter CLK_SPEED =  48000;
    localparam TIMECLK = (9 * (CLK_SPEED/1000)); // calculate ~9us from the master clock
    reg [9:0] delay;

    always@(posedge clk_sys)
    begin
    delay <= delay - 10'd1;

    if (delay == 10'd0) 
        begin
            clk_sega_s <= ~clk_sega_s;
            delay <= TIMECLK; 
        end
    end
    
    assign joystick1[9:0] = { joyControls_s[3], joyControls_s[0], joyControls_s[1], ~joy1_s[5], ~joy1_s[4], ~joy1_s[6], ~joy1_s[0], ~joy1_s[1], ~joy1_s[2], ~joy1_s[3] };
    assign joystick2[9:0] = {  1'b0 , 1'b0, joyControls_s[2], ~joy2_s[6], ~joy2_s[4], ~joy2_s[5], ~joy2_s[0], ~joy2_s[1], ~joy2_s[2], ~joy2_s[3] };

    reg [3:0]joyControls_s = 4'b0000; //-- Pause, 2P Start, 1P Start, Coin
    reg [11:0]joy1_s = 12'b111111111111;
    reg [11:0]joy2_s = 12'b111111111111;
    reg joyP7_s;

    reg [7:0]state_v = 8'd0;
    reg [7:0]count_cycles = 8'd100;
    reg j1_sixbutton_v = 1'b0;
    reg j2_sixbutton_v = 1'b0;

    always @(negedge clk_sega_s)
    begin

        state_v <= state_v + 8'd1;

        case (state_v)          //-- joy_s format MXYZ SACB RLDU
            8'd0:
                begin
                    if (count_cycles != 8'd0)
                        count_cycles <= count_cycles - 8'd1;
                    joyP7_s <=  1'b0;
                end
            8'd1:
                joyP7_s <=  1'b1;
            8'd2:
                begin
                    joy1_s[3:0] <= {joy1_right_q, joy1_left_q, joy1_down_q, joy1_up_q}; //-- R, L, D, U
                    joy2_s[3:0] <= {joy2_right_q, joy2_left_q, joy2_down_q, joy2_up_q}; //-- R, L, D, U
                    joy1_s[5:4] <= {joy1_p9_q, joy1_p6_q}; //-- C, B
                    joy2_s[5:4] <= {joy2_p9_q, joy2_p6_q}; //-- C, B                    
                    joyP7_s <= 1'b0;
                    j1_sixbutton_v <= 1'b0; //-- Assume it's not a six-button controller
                    j2_sixbutton_v <= 1'b0; //-- Assume it's not a six-button controller
                end
            8'd3:
                begin
                    if (joy1_right_q == 1'b0 && joy1_left_q == 1'b0) // it's a megadrive controller
                            joy1_s[7:6] <= { joy1_p9_q , joy1_p6_q }; //-- Start, A
                    else
                            joy1_s[7:4] <= { 1'b1, 1'b1, joy1_p9_q, joy1_p6_q }; //-- read A/B as master System

                    if (joy2_right_q == 1'b0 && joy2_left_q == 1'b0) // it's a megadrive controller
                            joy2_s[7:6] <= { joy2_p9_q , joy2_p6_q }; //-- Start, A
                    else
                            joy2_s[7:4] <= { 1'b1, 1'b1, joy2_p9_q, joy2_p6_q }; //-- read A/B as master System

                    joyP7_s <= 1'b1;
                end
            8'd4:
                joyP7_s <= 1'b0;
            8'd5:
                begin
                    if (joy1_down_q == 1'b0 && joy1_up_q == 1'b0)
                        j1_sixbutton_v <= 1'b1; // --it's a six button

                    if (joy2_down_q == 1'b0 && joy2_up_q == 1'b0)
                        j2_sixbutton_v <= 1'b1; // --it's a six button

                    joyP7_s <= 1'b1;
                end
            8'd6:
                begin
                    if (j1_sixbutton_v == 1'b1)
                        joy1_s[11:8] <= { joy1_right_q, joy1_left_q, joy1_down_q, joy1_up_q }; //-- Mode, X, Y e Z
                    
                    
                    if (j2_sixbutton_v == 1'b1)
                        joy2_s[11:8] <= { joy2_right_q, joy2_left_q, joy2_down_q, joy2_up_q }; //-- Mode, X, Y e Z

                    joyP7_s <= 1'b0;
                end
            default:
                joyP7_s <= 1'b1;
        endcase
        joyControls_s[0] <= ~(joy1_s[11]|joy1_s[4]); //-- Coin: Joy1 Mode + B
        joyControls_s[1] <= ~(joy1_s[11]|joy1_s[10]); //-- 1p start: Joy1 Mode + X
        joyControls_s[2] <= ~(joy1_s[11]|joy1_s[9]); //-- 2p start: Joy1 Mode + Y
        if (count_cycles == 8'd0)
            joyControls_s[3] <= ~(joy1_s[7]|joy1_s[6]); //-- Pause: Start + A

        if (joy1_s[7] || joy1_s[11])
            osd_keys[7:0] <= { keys_i[7], keys_i[6], keys_i[5], keys_i[4]&joy1_s[4]&joy1_s[5]&joy1_s[6], keys_i[3]&joy1_s[3], keys_i[2]&joy1_s[2], keys_i[1]&joy1_s[1], keys_i[0]&joy1_s[0]};
        else
            osd_keys[7:0] <= { 1'b0, 1'b1, 1'b1, keys_i[4]&joy1_s[4]&joy1_s[5]&joy1_s[6], keys_i[3]&joy1_s[3], keys_i[2]&joy1_s[2], keys_i[1]&joy1_s[1], keys_i[0]&joy1_s[0]};
    end
    
    assign joyX_p7_o = joyP7_s;
    //---------------------------


endmodule