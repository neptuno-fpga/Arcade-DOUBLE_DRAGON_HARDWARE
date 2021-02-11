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

module fake_tone(
	input rst,
	input clk,
	input ym_p1,
	output onebit
);
	wire [15:0] tone, linear;
	wire sh, so;
		
	ramp_a_tone tonegen( .rst(rst), .clk(clk), .tone(tone) );
	sh_encode encoder(   .rst(rst), .ym_p1(ym_p1), .data(tone), .sh(sh), .so(so) );
	ym_linearize linearizer( .rst(rst), .sh(sh), .ym_so(so), .ym_p1(ym_p1), .linear(linear) );
	sigma_delta1 sd1(    .rst(rst), .clk(clk), .data(linear), .sound(onebit) );	
endmodule

module sh_encode(
	input rst,
	input ym_p1,
	input [15:0] data,
	output reg sh,
	output so
);
	reg [12:0] serial_data;
	reg [3:0] cnt;
	
	assign so = serial_data[0];	
	always @(posedge rst or posedge ym_p1) begin
		if( rst ) begin
			sh <= 1'b0;			
			cnt <= 0;
		end
		else begin			
			cnt <= cnt + 1'b1;
			if( cnt==4'd2 ) begin
				casex( data[15:10] )
					6'b1XXXXX: serial_data <= { 3'd7, data[15:6]}; 
					6'b01XXXX: serial_data <= { 3'd6, data[14:5]}; 
					6'b001XXX: serial_data <= { 3'd5, data[13:4]}; 
					6'b0001XX: serial_data <= { 3'd4, data[12:3]}; 
					6'b00001X: serial_data <= { 3'd3, data[11:2]}; 
					6'b000001: serial_data <= { 3'd2, data[10:1]}; 
					default:   serial_data <= { 3'd1, data[ 9:0]}; 
				endcase
			end
			else serial_data <= serial_data>>1;
			if( cnt==4'd10 ) sh<=1'b1;
			if( cnt==4'd15 ) sh<=1'b0;
		end
	end
endmodule

// it produces a ~440Hz triangular signal at full scale for a 50MHz clock
module ramp_a_tone ( input rst, input clk, output reg [15:0] tone );
	reg up;
	always @(posedge rst or posedge clk) begin
		if( rst ) begin
			up   <= 0;
			tone <= 0;
		end
		else begin
			if( tone == 16'hFFFE ) begin
				up <= 1'b0;
			end
			else if( tone == 16'h1 ) begin
				up <= 1'b1;
			end
			tone <= up ? (tone+1'b1) : (tone-1'b1);
		end
	end
endmodule
