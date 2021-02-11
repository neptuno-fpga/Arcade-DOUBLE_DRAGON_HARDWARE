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
  
*//*  This file is part of JT5205.
    JT5205 program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    JT5205 program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with JT5205.  If not, see <http://www.gnu.org/licenses/>.

    Author: Jose Tejada Gomez. Twitter: @topapate
    Version: 1.0
    Date: 30-10-2019 */

module jt5205(
    input                  rst,
    input                  clk,
    input                  cen /* direct_enable */,        
    input         [ 1:0]   sel,        // s pin
    input         [ 3:0]   din,
    output signed [11:0]   sound,
    // This output pin is not part of MSM5205 I/O
    // It helps integrating the system as it produces
    // a strobe
    // at the internal clock divider pace
    output                 irq
);

wire               cen_lo, cen_mid;
wire signed [11:0] raw;

assign irq=cen_lo; // Notice that irq is active even if rst is high. This is
    // important for games such as Tora e no michi.

jt5205_timing u_timing(
    .clk    ( clk       ),
    .cen    ( cen       ),
    .sel    ( sel       ),
    .cen_lo ( cen_lo    ),
    .cen_mid( cen_mid   ),
    .cenb_lo(           )
);

jt5205_adpcm u_adpcm(
    .rst    ( rst       ),
    .clk    ( clk       ),
    .cen_lo ( cen_lo    ),
    .cen_hf ( cen       ),
    .din    ( din       ),
    .sound  ( raw       )
);

jt5205_interpol2x u_interpol(
    .rst    ( rst       ),
    .clk    ( clk       ),
    .cen_mid( cen_mid   ),
    .din    ( raw       ),
    .dout   ( sound     )
);

endmodule