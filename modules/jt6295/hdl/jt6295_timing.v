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
  
*//*  This file is part of JT6295.
    JT6295 program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    JT6295 program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with JT6295.  If not, see <http://www.gnu.org/licenses/>.

    Author: Jose Tejada Gomez. Twitter: @topapate
    Version: 1.0
    Date: 6-1-2020 */

// SS low  = divides by 164 (25.6 and 6.5kHz)
// SS high = divides by 132 (32   and 8  kHz)

module jt6295_timing(
    input       clk,
    input       cen,
    input       ss,
    output reg  cen_sr,   // Sample rate
    output reg  cen_sr4,  // 4x sample rate
    output reg  cen_sr4b, // 4x sample rate, 180 shift
    output reg  cen_sr32
);

reg  [2:0] base=2'd0;
reg  [5:0] cnt =8'd0;
wire [2:0] lim = ss ? 3'h3 : 3'h4;


always @(posedge clk) begin
    cen_sr4 <= 1'd0;
    cen_sr4b<= 1'd0;
    cen_sr  <= 1'd0;
    cen_sr32<= 1'b0;
    if( cen ) begin
        base    <= (base==lim) ? 3'd0 : base+3'd1;
        if(base==3'd0) cnt <= (cnt==6'd32) ? 6'd0 : cnt+6'd1;

        cen_sr32<= !cnt[5] && base==3'd0;
        cen_sr4 <= !cnt[5] && cnt[2:0] == 3'b000 && base == 3'd0;
        cen_sr4b<= !cnt[5] && cnt[2:0] == 3'b100 && base == 3'd0;
        cen_sr  <= {cnt,base} == 9'd0;
    end
end

endmodule
