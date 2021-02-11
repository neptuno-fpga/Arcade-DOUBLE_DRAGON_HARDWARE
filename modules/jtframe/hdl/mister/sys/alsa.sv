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
  
*///============================================================================
//
//  ALSA sound support for MiSTer
//  (c)2019 Sorgelig
//
//  This program is free software; you can redistribute it and/or modify it
//  under the terms of the GNU General Public License as published by the Free
//  Software Foundation; either version 2 of the License, or (at your option)
//  any later version.
//
//  This program is distributed in the hope that it will be useful, but WITHOUT
//  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
//  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
//  more details.
//
//  You should have received a copy of the GNU General Public License along
//  with this program; if not, write to the Free Software Foundation, Inc.,
//  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
//
//============================================================================

module alsa
(
	input             reset,

	output reg        en_out,
	input             en_in,

	input             ram_clk,
	output reg [28:0] ram_address,
	output reg  [7:0] ram_burstcount,
	input             ram_waitrequest,
	input      [63:0] ram_readdata,
	input             ram_readdatavalid,
	output reg        ram_read,

	input             spi_ss,
	input             spi_sck,
	input             spi_mosi,

	output reg [15:0] pcm_l,
	output reg [15:0] pcm_r
);

reg         spi_new = 0;
reg [127:0] spi_data;
always @(posedge spi_sck, posedge spi_ss) begin
	reg [7:0] mosi;
	reg [6:0] spicnt = 0;

	if(spi_ss) spicnt <= 0;
	else begin
		mosi <= {mosi[6:0],spi_mosi};

		spicnt <= spicnt + 1'd1;
		if(&spicnt[2:0]) begin
			spi_data[{spicnt[6:3],3'b000} +:8] <= {mosi[6:0],spi_mosi};
			spi_new <= &spicnt;
		end
	end
end

reg [31:0] buf_addr;
reg [31:0] buf_len;
reg [31:0] buf_wptr = 0;

always @(posedge ram_clk) begin
	reg n1,n2,n3;
	reg [127:0] data1,data2;

	n1 <= spi_new;
	n2 <= n1;
	n3 <= n2;

	data1 <= spi_data;
	data2 <= data1;

	if(~n3 & n2) {buf_wptr,buf_len,buf_addr} <= data2[95:0];
end

reg [31:0] buf_rptr = 0;
always @(posedge ram_clk) begin
	reg got_first = 0;
	reg ready = 0;
	reg ud = 0;
	reg [31:0] readdata;

	if(~ram_waitrequest) ram_read <= 0;
	if(ram_readdatavalid && ram_burstcount) begin
		ram_burstcount <= 0;
		ready <= 1;
		readdata <= ud ? ram_readdata[63:32] : ram_readdata[31:0];
		if(buf_rptr[31:2] >= buf_len[31:2]) buf_rptr <= 0;
	end

	if(reset) {ready, got_first, ram_burstcount} <= 0;
	else
	if(buf_rptr[31:2] != buf_wptr[31:2]) begin
		if(~got_first) begin
			buf_rptr <= buf_wptr;
			got_first <= 1;
		end
		else
		if(!ram_burstcount && ~ram_waitrequest && ~ready && en_out == en_in) begin
			ram_address <= buf_addr[31:3] + buf_rptr[31:3];
			ud <= buf_rptr[2];
			ram_burstcount <= 1;
			ram_read <= 1;
			buf_rptr <= buf_rptr + 4;
		end
	end

	if(ready & ce_48k) begin
		{pcm_r,pcm_l} <= readdata;
		ready <= 0;
	end
	
	if(ce_48k) en_out <= ~en_out;
end

reg ce_48k;
always @(posedge ram_clk) begin
	reg [15:0] acc = 0;

	ce_48k <= 0;
	acc <= acc + 16'd48;
	if(acc >= 50000) begin
		acc <= acc - 16'd50000;
		ce_48k <= 1;
	end
end

endmodule
