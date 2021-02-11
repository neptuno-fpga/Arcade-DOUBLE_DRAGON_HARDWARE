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

// Each sampling period is divided into 4 regions, one per channel
// each region is further divided into 8 time slots for memory access
// of those, 2 are used for ADPCM data. Those 2 are in the middle of
// the region, so data will be ready for next cen4 pulse. No adpcm_ok
// signal is generated. Data is assumed to be right after two cen32 pulses
// 
// The other 6 regions are used for control data. Ok signals are generated
// and use to gate the progress of the control state machine

module jt6295_rom(
    input             rst,
    input             clk,
    input             cen4,
    input             cen32,

    input      [17:0] adpcm_addr,
    input      [17:0] ctrl_addr,

    output reg [ 7:0] adpcm_dout,
    output reg [ 7:0] ctrl_dout,

    output reg        ctrl_ok,
    // ROM interface
    output reg [17:0] rom_addr,
    input      [ 7:0] rom_data,
    input             rom_ok
);

reg [7:0] st;
reg [1:0] wait2;

always @(posedge clk) begin
    if(cen4 ) st <= 8'h80;
    else if(cen32) st <= { st[6:0], st[7] };
end

wire new_addr = rom_addr != ctrl_addr;

always @(posedge clk) begin
    case(st)
        8'b1,8'b10: begin
            rom_addr   <= adpcm_addr;
            adpcm_dout <= rom_data;
            ctrl_ok    <= 1'b0;
            wait2      <= 2'b0;
        end
        default: begin
            rom_addr   <= ctrl_addr;
            // right after coming in rom_ok will still
            // represent the status for adpcm data
            if(wait2==2'b11 && !new_addr) begin
                ctrl_ok   <= rom_ok;
                ctrl_dout <= rom_data;
            end else ctrl_ok <= 1'b0;
            if( new_addr )
                wait2 <= 2'b0;
            else
                wait2 <= {wait2[0],1'b1};
        end
    endcase
end

endmodule