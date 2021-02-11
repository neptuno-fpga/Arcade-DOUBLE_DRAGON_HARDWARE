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
  
*/////////////////////////////////////////////////////////////////////
// video output dump
// this is a binary bile with 32 bits per pixel. First 8 bits are the alpha, and set to 0xFF
// The rest are RGB in 8-bit format
// There is no dump while blanking. The inputs pxl_hb and pxl_vb are high during blanking
// The linux tool "convert" can process the raw stream and separate it into individual frames
// automatically

`timescale 1ns/1ps

module video_dump(
    input        pxl_clk,
    input        pxl_cen,
    input        pxl_hb,
    input        pxl_vb,
    input [ 3:0] red,
    input [ 3:0] green,
    input [ 3:0] blue,
    input [31:0] frame_cnt
    //input        downloading
);


`ifdef DUMP_VIDEO
integer fvideo;
initial begin
    fvideo = $fopen("video.raw","wb");
end

wire [31:0] video_dump = { 8'hff, {2{blue}}, {2{green}}, {2{red}} };

// Define VIDEO_START with the first frame number for which
// video will be dumped. If undefined, it will start from frame 0
`ifndef VIDEO_START
`define VIDEO_START 0
`endif

always @(posedge pxl_clk) if(pxl_cen && frame_cnt>=`VIDEO_START ) begin
    if( !pxl_hb && !pxl_vb ) $fwrite(fvideo,"%u", video_dump);
end

`endif

endmodule