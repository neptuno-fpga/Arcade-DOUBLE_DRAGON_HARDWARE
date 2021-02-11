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
  
*///
//
// Copyright (c) 2018 Sorgelig
//
// This program is GPL Licensed. See COPYING for the full license.
//
//
////////////////////////////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module video_cleaner
(
	input            clk_vid,
	input            ce_pix,

	input      [7:0] R,
	input      [7:0] G,
	input      [7:0] B,

	input            HSync,
	input            VSync,
	input            HBlank,
	input            VBlank,

	//optional de
	input            DE_in,

	// video output signals
	output reg [7:0] VGA_R,
	output reg [7:0] VGA_G,
	output reg [7:0] VGA_B,
	output reg       VGA_VS,
	output reg       VGA_HS,
	output           VGA_DE,
	
	// optional aligned blank
	output reg       HBlank_out,
	output reg       VBlank_out,
	
	// optional aligned de
	output reg       DE_out
);

wire hs, vs;
s_fix sync_v(clk_vid, HSync, hs);
s_fix sync_h(clk_vid, VSync, vs);

wire hbl = hs | HBlank;
wire vbl = vs | VBlank;

assign VGA_DE = ~(HBlank_out | VBlank_out);

always @(posedge clk_vid) begin
	if(ce_pix) begin
		HBlank_out <= hbl;

		VGA_HS <= hs;
		if(~VGA_HS & hs) VGA_VS <= vs;

		VGA_R  <= R;
		VGA_G  <= G;
		VGA_B  <= B;
		DE_out <= DE_in;

		if(HBlank_out & ~hbl) VBlank_out <= vbl;
	end
end

endmodule

module s_fix
(
	input clk,
	
	input sync_in,
	output sync_out
);

reg pol;
assign sync_out = sync_in ^ pol;

always @(posedge clk) begin
	integer pos = 0, neg = 0, cnt = 0;
	reg s1,s2;

	s1 <= sync_in;
	s2 <= s1;

	if(~s2 & s1) neg <= cnt;
	if(s2 & ~s1) pos <= cnt;

	cnt <= cnt + 1;
	if(s2 != s1) cnt <= 0;

	pol <= pos > neg;
end

endmodule
