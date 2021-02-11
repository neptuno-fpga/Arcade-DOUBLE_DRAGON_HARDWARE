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
  
*/`timescale 1ns / 1ps

/* load the 6809 code from PC on start up */

module fsm_control  #(parameter width=10)(
	input                  clk,
	input                  rst,
	input                  dump_memory,
	// cpu control
	output reg             cpu_rst,
	// memory control
	output     [width-1:0] fsm_addr,
	output reg             fsm_wr,
	// UART wires
	input                  uart_received,
	input                  uart_tx_done,
	output reg             uart_tx_wr,
	output reg             uart_tx_memory,
	// LED information
	output reg [7:0]       led
);	

reg [      1:0]  rst_cnt; // this is used to delay the memory writing by one clock, and make it last for two clocks.
reg              prog_done,
                 prog_start,
                 dump_start,
                 dump_done,
								 addr_sel;

reg [width-1:0]  fsm_wr_addr,
                 fsm_rd_addr;
								
always @(negedge clk or posedge rst ) begin : addr_selection
	if( rst )
		addr_sel <= 1'b0;
	else begin
		if( prog_start ) addr_sel <= 1'b1;
		if( prog_done  ) addr_sel <= 1'b0;
	end
end
								
assign fsm_addr = addr_sel ? fsm_wr_addr : fsm_rd_addr;

// release reset on negative edge
always @(negedge clk or posedge rst ) begin : reset_release
	if( rst ) begin
		cpu_rst        <=  1'b1;		
		uart_tx_memory <= 1'b0;
	end
	else begin
		if (prog_done  | dump_done ) cpu_rst <= 1'b0;
		if (prog_start | dump_start) cpu_rst <= 1'b1;
		if ( dump_start ) 
			uart_tx_memory <= 1'b1;
		else if( dump_done ) 
			uart_tx_memory <= 1'b0;
	end
end

always @(posedge clk or posedge rst ) begin : fsm_write
	if( rst ) begin		
		fsm_wr <= 1'b0;
	end
	else begin
		if( ^rst_cnt && cpu_rst )
			fsm_wr <= 1'b1;
		else
			fsm_wr <= 1'b0;
	end
end

reg [23:0] led_cnt;

always @(posedge clk or posedge rst ) begin : led_game
	if( rst ) begin	
		led_cnt <= 23'd0;
		led     <= 1'b1;
	end
	else begin
		led_cnt <= led_cnt + 1'b1;
		if( !led_cnt && cpu_rst )
			if( prog_start ) 
				led <= { led[6:0], led[7] };
			else
				led <= { led[0], led[7:1] };
	end
end


always @(posedge clk or posedge rst ) begin : data_input
	if( rst ) begin		
	`ifdef SIM_SKIPPROG
		fsm_wr_addr     <=  {(width){1'b1}};
		rst_cnt      <=  2'b0;
		prog_done    <=  1'b1;
		prog_start   <=  1'b0;		
	`else
		fsm_wr_addr     <=  {(width){1'b1}};
		rst_cnt      <=  2'b0;
		prog_done    <=  1'b0;
		prog_start   <=  1'b0;		
	`endif
	end
	else begin
			/* writes the incoming data until the memory is full.
				it does not admit reload. it will handle the control
				to the CPU after loading the memory. */						
			if( prog_done || (prog_start && (&fsm_wr_addr)  && (&rst_cnt))  ) begin		
				prog_start <= 1'b0;
				prog_done  <= 1'b1;
			end
			else begin
				if( uart_received ) begin
					fsm_wr_addr   <= fsm_wr_addr + 1'b1;
					rst_cnt    <= 2'b0;
					prog_start <= 1'b1;					
				end
				else if( rst_cnt != 2'b11 ) rst_cnt <= rst_cnt + 1'b1;
			end
	end
end

always @(posedge clk or posedge rst ) begin : data_output
	if( rst ) begin		
		fsm_rd_addr <= {(width){1'b0}};
		dump_start  <= 1'b0;
		dump_done   <= 1'b0;
		uart_tx_wr  <= 1'b0;
	end
	else begin
		if( dump_memory ) begin
			fsm_rd_addr <= {(width){1'b0}};
			dump_start  <= 1'b1;
			dump_done   <= 1'b0;
			uart_tx_wr  <= 1'b1;
		end
		else
		if( uart_tx_done && dump_start && !dump_done ) begin
			if( &fsm_rd_addr ) begin
				dump_start <= 1'b0;
				dump_done  <= 1'b1;
			end
			else begin
				fsm_rd_addr <= fsm_rd_addr + 1'b1;
				uart_tx_wr  <= 1'b1;
			end
		end
		else uart_tx_wr <= 1'b0;		

	end
end	

endmodule
