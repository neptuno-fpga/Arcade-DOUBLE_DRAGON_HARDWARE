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

module bus_manager #(parameter RAM_MSB=10)(
//	input		rst50,
//	input		clk50,
//	input		clk_per,
//	input [7:0] cpu_data_out,
	input [7:0] ROM_data_out,
	input [7:0]	RAM_data,
	input [7:0] jt_data_out,
	// Other system elements
	input		game_sel,
	input [7:0]	sound_latch,
	output		clear_irq,
	// CPU control
	output reg [7:0] cpu_data_in,	
	input [15:0]addr,
	input		cpu_vma,
	input		cpu_rw,
	// select signals
	output	reg	RAM_cs,
	output	reg	opm_cs_n
	
);

wire ROM_cs = addr[15];

parameter RAM_START = 16'h6000;
parameter RAM_END = RAM_START+(2**(RAM_MSB+1));
parameter ROM_START=16'h8000;

wire [15:0] ram_start_contra	= 16'h6000;
wire [15:0] ram_end_contra		= 16'h7FFF;
wire [15:0] ram_start_ddragon	= 16'h0000;
wire [15:0] ram_end_ddragon		= 16'h0FFF;

// wire [15:0] rom_start_addr = ROM_START;
// wire [15:0] ym_start_addr	= 16'h2000;
// wire [15:0] ym_end_addr		= 16'h2002;
reg [15:0] irq_clear_addr;

reg LATCH_rd;

//reg	[7:0]	ym_final_d;

always @(*) begin
	if( cpu_rw && cpu_vma)
		casex( {~opm_cs_n, RAM_cs, ROM_cs, LATCH_rd } )
			4'b1XXX: cpu_data_in = jt_data_out;
			4'b01XX: cpu_data_in = RAM_data;
			4'b001X: cpu_data_in = ROM_data_out;
			4'b0001: cpu_data_in = sound_latch;
			default: cpu_data_in = 8'h0;
		endcase
	else
		cpu_data_in = 8'h0;
end

// RAM
wire opm_cs_contra = !addr[15] && !addr[14] && addr[13]; 
wire opm_cs_ddragon= addr>=16'h2800 && addr<=16'h2801;

always @(*)
	if( game_sel ) begin
		RAM_cs	= cpu_vma && (addr>=ram_start_ddragon && addr<=ram_end_ddragon);
		opm_cs_n= !(cpu_vma && opm_cs_ddragon);
		LATCH_rd= cpu_vma && addr==16'h1000; // Sound latch at $1000
		irq_clear_addr = 16'h1000;
	end
	else begin
		RAM_cs 	= cpu_vma && (addr>=ram_start_contra && addr<=ram_end_contra);
		opm_cs_n= !(cpu_vma && opm_cs_contra);
		LATCH_rd= cpu_vma && addr==16'h0; // Sound latch at $0000
		irq_clear_addr = 16'h4000;
	end
	
// Clear IRQ
assign clear_irq = (addr==irq_clear_addr) && cpu_vma ? 1'b1 : 1'b0;
	
endmodule
