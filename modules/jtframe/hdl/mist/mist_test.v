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

/* verilator lint_off STMTDLY */

module mist_test;

wire [31:0] frame_cnt;
wire VGA_HS, VGA_VS;
wire led;

wire            downloading;
wire    [22:0]  ioctl_addr;
wire    [ 7:0]  ioctl_data;
wire clk27, rst;
wire [21:0]  sdram_addr;
wire [15:0]  data_read;
wire SPI_SCK, SPI_DO, SPI_DI, SPI_SS2, SPI_SS3, CONF_DATA0;

wire [15:0] SDRAM_DQ;
wire [12:0] SDRAM_A;
wire [ 1:0] SDRAM_BA;
wire SDRAM_DQML, SDRAM_DQMH, SDRAM_nWE,  SDRAM_nCAS,
     SDRAM_nRAS, SDRAM_nCS,  SDRAM_CLK,  SDRAM_CKE;

wire [5:0] VGA_R, VGA_G, VGA_B;
// the pxl_ wires represent the core pure output
// regardless of the scan doubler or the composity sync
wire pxl_clk, pxl_cen, pxl_vb, pxl_hb;

mist_dump u_dump(
    .VGA_VS     ( pxl_vb    ),
    .led        ( led       ),
    .frame_cnt  ( frame_cnt )
);
//887808
test_harness #(.sdram_instance(0),.GAME_ROMNAME(`GAME_ROM_PATH),
    .TX_LEN(`GAME_ROM_LEN) ) u_harness(
    .rst         ( rst           ),
    .clk27       ( clk27         ),
    .pxl_clk     ( pxl_clk       ),
    .pxl_cen     ( pxl_cen       ),
    .pxl_vb      ( pxl_vb        ),
    .pxl_hb      ( pxl_hb        ),
    .downloading ( downloading   ),
    .dwnld_busy  ( ~led          ), // LED is set low during downloading
        // the downloading process can extend pass the downloading signal
        // because of SDRAM content conversion
    .ioctl_addr  ( ioctl_addr    ),
    .ioctl_data  ( ioctl_data    ),
    .SPI_SCK     ( SPI_SCK       ),
    .SPI_SS2     ( SPI_SS2       ),
    .SPI_SS3     ( SPI_SS3       ),
    .SPI_DI      ( SPI_DI        ),
    .SPI_DO      ( SPI_DO        ),
    .CONF_DATA0  ( CONF_DATA0    ),
    // Video dumping. VGA_ signals are equal to game signals in simulation.
    .HS          ( pxl_hb    ),
    .VS          ( pxl_vb    ),
    .red         ( VGA_R[5:2]),
    .green       ( VGA_G[5:2]),
    .blue        ( VGA_B[5:2]),
    .frame_cnt   ( frame_cnt ),
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
    .SDRAM_CKE   ( SDRAM_CKE ),
    // unused
    .H0          ( 1'bz      ),
    .autorefresh ( 1'bz      ),
    .sdram_addr  ( 22'bz     ),
    .data_read   (),
    .loop_rst    (),
    .ioctl_wr    ()
);

`ifdef SIM_UART
wire UART_RX, UART_TX;
assign UART_RX = UART_TX; // make a loop!
`endif

wire AUDIO_L, AUDIO_R;

`SYSTOP UUT(
    .CLOCK_27   ( { 1'b0, clk27 }),
    .VGA_R      ( VGA_R     ),
    .VGA_G      ( VGA_G     ),
    .VGA_B      ( VGA_B     ),
    .VGA_HS     ( VGA_HS    ),
    .VGA_VS     ( VGA_VS    ),
    // SDRAM interface
    .SDRAM_DQ   ( SDRAM_DQ  ),
    .SDRAM_A    ( SDRAM_A   ),
    .SDRAM_DQML ( SDRAM_DQML),
    .SDRAM_DQMH ( SDRAM_DQMH),
    .SDRAM_nWE  ( SDRAM_nWE ),
    .SDRAM_nCAS ( SDRAM_nCAS),
    .SDRAM_nRAS ( SDRAM_nRAS),
    .SDRAM_nCS  ( SDRAM_nCS ),
    .SDRAM_BA   ( SDRAM_BA  ),
    .SDRAM_CLK  ( SDRAM_CLK ),
    .SDRAM_CKE  ( SDRAM_CKE ),
    `ifdef SIM_UART
    .UART_RX    ( UART_RX   ),
    .UART_TX    ( UART_TX   ),
    `endif
    // SPI interface to arm io controller
    .SPI_DO     ( SPI_DO    ),
    .SPI_DI     ( SPI_DI    ),
    .SPI_SCK    ( SPI_SCK   ),
    .SPI_SS2    ( SPI_SS2   ),
    .SPI_SS3    ( SPI_SS3   ),
    .SPI_SS4    ( 1'b0      ),
    .CONF_DATA0 ( CONF_DATA0),
    // sound
    .AUDIO_L    ( AUDIO_L   ),
    .AUDIO_R    ( AUDIO_R   ),
    // unused
    .LED        ( led       ),
    .sim_pxl_cen( pxl_cen   ),
    .sim_pxl_clk( pxl_clk   ),
    .sim_vb     ( pxl_vb    ),
    .sim_hb     ( pxl_hb    )
);


endmodule