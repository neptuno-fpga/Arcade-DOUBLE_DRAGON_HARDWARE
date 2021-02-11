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
  
*/`timescale 1ns/1ps

// Test bench for MiSTer
// This only verifies the core module "emu"
// The framework is not simulated

/* verilator lint_off STMTDLY */

module mister_test;

wire [31:0] frame_cnt;
wire VGA_HS, VGA_VS;

wire clk50, rst;
wire SPI_SCK, SPI_DO, SPI_DI, SPI_SS2, CONF_DATA0;

wire [15:0] SDRAM_DQ;
wire [12:0] SDRAM_A;
wire [ 1:0] SDRAM_BA;
wire SDRAM_DQML, SDRAM_DQMH, SDRAM_nWE,  SDRAM_nCAS,
     SDRAM_nRAS, SDRAM_nCS,  SDRAM_CLK,  SDRAM_CKE;

wire [15:0] AUDIO_L, AUDIO_R;
wire        AUDIO_S;

wire        LED_USER;
wire  [1:0] LED_POWER;
wire  [1:0] LED_DISK;

wire  [45:0] HPS_BUS;

// VGA signals
wire        VGA_CLK;
wire        VGA_CE;
wire  [7:0] VGA_R;
wire  [7:0] VGA_G;
wire  [7:0] VGA_B;
wire        VGA_DE, VGA_HB, VGA_VB;

// HDMI signals are basically ignored in this simulation
wire        HDMI_CLK;
wire        HDMI_CE;
wire  [7:0] HDMI_R;
wire  [7:0] HDMI_G;
wire  [7:0] HDMI_B;
wire        HDMI_HS;
wire        HDMI_VS;
wire        HDMI_DE;
wire  [1:0] HDMI_SL;
wire  [7:0] HDMI_ARX;
wire  [7:0] HDMI_ARY;

// the pxl_ wires represent the core pure output
// regardless of the scan doubler or the composity sync
wire pxl_clk, pxl_cen;


mister_dump u_dump(
    .VGA_VS     ( VGA_VS    ),
    .led        ( LED_USER  ),
    .frame_cnt  ( frame_cnt )
);

mister_harness #(.sdram_instance(0),.GAME_ROMNAME(`GAME_ROM_PATH),
    .TX_LEN(887808) ) u_harness(
    .rst         ( rst       ),
    .clk50       ( clk50     ),
    .frame_cnt   ( frame_cnt ),
    .VS          ( VGA_VS    ),
    .dwnld_busy  ( 1'b0      ),
    // VGA
    .VGA_CLK     ( VGA_CLK   ),
    .VGA_CE      ( VGA_CE    ),
    .VGA_DE      ( VGA_DE    ),
    .VGA_R       ( VGA_R     ),
    .VGA_G       ( VGA_G     ),
    .VGA_B       ( VGA_B     ),
    .VGA_HS      ( VGA_HS    ),
    .VGA_VS      ( VGA_VS    ),
    .VGA_HB      ( VGA_HB    ),
    .VGA_VB      ( VGA_VB    ),
    // SDRAM
    .SDRAM_DQ    ( SDRAM_DQ  ),
    .SDRAM_A     ( SDRAM_A   ),
    .SDRAM_DQML  ( SDRAM_DQML),
    .SDRAM_DQMH  ( SDRAM_DQMH),
    .SDRAM_nWE   ( SDRAM_nWE ),
    .SDRAM_nCAS  ( SDRAM_nCAS),
    .SDRAM_nRAS  ( SDRAM_nRAS),
    .SDRAM_nCS   ( SDRAM_nCS ),
    .SDRAM_BA    ( SDRAM_BA  ),
    .SDRAM_CLK   ( SDRAM_CLK ),
    .SDRAM_CKE   ( SDRAM_CKE )
);

`ifdef SIM_UART
wire UART_RX, UART_TX;
assign UART_RX = UART_TX; // make a loop!
`endif

wire VGA_F1;

emu UUT(
    .CLK_50M    (  clk50        ),
    .RESET      (  rst          ),
    .HPS_BUS    (  HPS_BUS      ),
    // VGA
    .VGA_CLK    (  VGA_CLK      ),
    .VGA_CE     (  VGA_CE       ),
    .VGA_R      (  VGA_R        ),
    .VGA_G      (  VGA_G        ),
    .VGA_B      (  VGA_B        ),
    .VGA_HS     (  VGA_HS       ),
    .VGA_VS     (  VGA_VS       ),
    .VGA_DE     (  VGA_DE       ),
    .VGA_F1     (  VGA_F1       ),
    // HDMI -- all ignored --
    .HDMI_CLK   (  HDMI_CLK     ),
    .HDMI_CE    (  HDMI_CE      ),
    .HDMI_R     (  HDMI_R       ),
    .HDMI_G     (  HDMI_G       ),
    .HDMI_B     (  HDMI_B       ),
    .HDMI_HS    (  HDMI_HS      ),
    .HDMI_VS    (  HDMI_VS      ),
    .HDMI_DE    (  HDMI_DE      ),
    .HDMI_SL    (  HDMI_SL      ),
    .HDMI_ARX   (  HDMI_ARX     ),
    .HDMI_ARY   (  HDMI_ARY     ),
    // LEDs
    .LED_USER   (  LED_USER     ),
    .LED_POWER  (  LED_POWER    ),
    .LED_DISK   (  LED_DISK     ),
    // AUDIO
    .AUDIO_L    (  AUDIO_L      ),
    .AUDIO_R    (  AUDIO_R      ),
    .AUDIO_S    (  AUDIO_S      ),
    // SDRAM
    .SDRAM_CLK  (  SDRAM_CLK    ),
    .SDRAM_CKE  (  SDRAM_CKE    ),
    .SDRAM_A    (  SDRAM_A      ),
    .SDRAM_BA   (  SDRAM_BA     ),
    .SDRAM_DQ   (  SDRAM_DQ     ),
    .SDRAM_DQML (  SDRAM_DQML   ),
    .SDRAM_DQMH (  SDRAM_DQMH   ),
    .SDRAM_nCS  (  SDRAM_nCS    ),
    .SDRAM_nCAS (  SDRAM_nCAS   ),
    .SDRAM_nRAS (  SDRAM_nRAS   ),
    .SDRAM_nWE  (  SDRAM_nWE    ),
    // Video output for simulation
    .sim_pxl_cen( pxl_cen       ),
    .sim_pxl_clk( pxl_clk       ),
    .sim_vb     ( VGA_VB        ),
    .sim_hb     ( VGA_HB        )    
);

endmodule