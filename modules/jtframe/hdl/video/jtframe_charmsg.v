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
  
*//*  This file is part of JTFRAME.
    JTFRAME program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    JTFRAME program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with JTFRAME.  If not, see <http://www.gnu.org/licenses/>.

    Author: Jose Tejada Gomez. Twitter: @topapate
    Version: 1.0
    Date: 18-2-2019 */

// Alternative memory for on-screen message generation
// SW = width of the memory address/scan vectors
// msg_width output is a fixed value equal to HVAL

module jtframe_charmsg #(parameter SW=10, HVAL=8'd2, VERTICAL=1)(
    input            clk,
    input            pxl_cen,  /* synthesis direct_enable = 1 */

    input      [3:0] avatar_idx,
    input   [SW-1:0] scan,
    output reg [7:0] msg_low,
    output     [7:0] msg_high
);

wire [7:0] mem_msg, mem_msg_av;

jtframe_ram #(.aw(SW),.synfile("msg.hex"),.simfile("msg.bin")) u_char_msg(
    .clk    ( clk         ),
    .cen    ( pxl_cen     ),
    .data   ( 8'd0        ),
    .addr   ( scan        ),
    .we     ( 1'b0        ),
    .q      ( mem_msg     )
);

`ifdef AVATARS
wire [4:0] av_sel0 = VERTICAL ? scan[9:5] : scan[4:0];
wire [4:0] av_sel1  = VERTICAL ? scan[4:0] : scan[9:5];
localparam [4:0] AVPOS = VERTICAL ? 5'd8 : 5'd22;

wire [8:0] av_scan = { avatar_idx, av_sel0 };

jtframe_ram #(.aw(9),.synfile("msg_av.hex")) u_ram_msg_av(
    .clk    ( clk         ),
    .cen    ( pxl_cen        ),
    .data   ( 8'd0        ),
    .addr   ( av_scan     ),
    .we     ( 1'b0        ),
    .q      ( mem_msg_av  )
);

reg av_col;

always @(*) begin
    av_col  = av_sel1 == AVPOS;
    msg_low = av_col ? mem_msg_av : mem_msg;
end
`else 
always @(*) msg_low = mem_msg;
`endif

assign msg_high = HVAL;

endmodule