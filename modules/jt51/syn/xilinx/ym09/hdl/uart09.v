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
  
*/module uart09 #(parameter width=10 )(
	input  wire clk,
	input  wire rst,
	input  wire uart_rx,
	output wire uart_tx,
	
	output wire [7:0] uart_rx_byte, 
	output wire uart_received,
	input  wire uart_transmit,
	input  wire [7:0] uart_tx_byte,	
	input	 wire [7:0] mem_data_o, 
	output wire [7:0] uart_error_count,
	input  wire uart_speed,
	// IRQ handling
	input  wire rx_status_clear,
	input  wire tx_status_clear,	
	output reg  rx_status,
	output reg  tx_status,
	// Load RAM from UART
	output wire [width-1:0] fsm_addr,	
	output wire             fsm_wr,
	output wire             cpu_rst,
	input  wire             dump_memory,
	output wire [7:0]       led
);

wire uart_tx_done, uart_error;

reg [4:0] clk_divider;

always @(posedge clk or posedge rst ) begin : uart_speed_ff
	if( rst ) begin
		clk_divider <= 5'd2; // 921600 kbps
	end
	else begin
		if( uart_speed ) 
			clk_divider <= 5'd2; // 921.600 kbps			
		else
			clk_divider <= 5'd4; // 460 kbps
	end
end

wire uart_tx_wr, uart_tx_memory;

uart_transceiver u_uart(
	.sys_rst( rst ),
	.sys_clk( clk ),

	.uart_rx( uart_rx ),
	.uart_tx( uart_tx ), // serial signal to transmit. High when idle
	.clk_divider ( clk_divider ),  // 115 or 230 kbps		
	.uart_divider( 5'd8        ), 
	
	.rx_data ( uart_rx_byte  ),
	.rx_done ( uart_received ),
	.rx_error( uart_error    ),
	.rx_error_count( uart_error_count ),
  
	.tx_data( uart_tx_memory ? mem_data_o : uart_tx_byte  ),
	.tx_wr  ( uart_transmit | uart_tx_wr ),
	.tx_done( uart_tx_done  )
);

fsm_control #(12)u_control (
	.clk          ( clk           ),
	.rst          ( rst           ), 
	.cpu_rst      ( cpu_rst       ),
	.dump_memory  ( dump_memory   ),
	// memory control
	.fsm_addr     ( fsm_addr      ),
	.fsm_wr       ( fsm_wr        ),
	// UART wires
	.uart_received( uart_received ),
	.uart_tx_done ( uart_tx_done  ),
	.uart_tx_wr   ( uart_tx_wr    ),
	.uart_tx_memory(uart_tx_memory),
	.led          ( led           )
);

always @( posedge clk or posedge rst) begin : rx_status_ff
	if( rst ) begin
		rx_status <= 1'b0;
	end
	else
		if( uart_received ) 
			rx_status <= 1'b1;
		else if( rx_status_clear ) 
      rx_status <= 1'b0;
end

always @( posedge clk or posedge rst) begin : tx_status_ff
	if( rst ) begin
		tx_status <= 1'b0;
	end
	else
		if( uart_tx_done )
      tx_status <= 1'b1;
		else if( tx_status_clear ) 
      tx_status <= 1'b0;
end


endmodule
