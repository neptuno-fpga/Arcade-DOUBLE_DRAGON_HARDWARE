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
  
*//*  This file is part of JTDD.
    JTDD program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    JTDD program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with JTDD.  If not, see <http://www.gnu.org/licenses/>.

    Author: Jose Tejada Gomez. Twitter: @topapate
    Version: 1.0
    Date: 19-12-2019 */

// Clocks are derived from H counter on the original PCB
// Yet, that doesn't seem to be important and it only
// matters the frequency of the signals:
// E,Q: 3 MHz
// Q is 1/4th of wave advanced

`timescale 1ns/1ps

module jtdd_adpcm(
    input               clk,
    input               rst,
    (*direct_input*)    input cpu_cen,
    (*direct_input*)    input cen_oki,        // 375 kHz
    // communication with main CPU
    input   [ 7:0]      cpu_dout,
    input   [ 1:0]      cpu_AB,
    input               cs,
    // ROM
    output     [15:0]   rom_addr,
    output              rom_cs,
    input      [ 7:0]   rom_data,
    input               rom_ok,

    // Sound output
    output  signed [11:0] snd
);

reg [9:0] cnt;
reg [3:0] din;
(*keep*) reg [7:0] addr0, addr1;
(*keep*) reg       ad_rst, start;
wire     sample;
wire     over = addr0 == addr1;
(*keep*) reg fail;

always @(posedge clk, posedge rst) begin
    if(rst) begin
        addr0  <= 8'd0;
        addr1  <= 8'd0;
        ad_rst <= 1'b1;
        cnt    <= 10'd0;
        din    <= 4'b0;
    end else begin
        if(cs) begin
            case(cpu_AB)
                2'd0: ad_rst <= 1'b0;
                2'd1: addr1  <= cpu_dout;
                2'd2: addr0  <= cpu_dout;
                2'd3: begin
                    ad_rst <= 1'b1;       // stop
                    cnt    <= 10'd0;
                end
            endcase
            if( cpu_AB != 2'd0 ) begin
                ad_rst <= 1'b1;
                cnt    <= 10'd0;
            end
        end
        if(rom_ok) din  <= !cnt[0] ? rom_data[7:4] : rom_data[3:0];
        if( !ad_rst ) begin
            if( sample ) begin
                fail <= !rom_ok;
                cnt  <= cnt + 10'd1;
                if(&cnt) addr0 <= addr0+8'd1;
            end
            if( over ) begin
                ad_rst <= 1'b1;
                cnt    <= 10'd0;
            end
        end
    end
end

assign rom_addr = { addr0[6:0], cnt[9:1] };
assign rom_cs   = 1'b1;

jt5205 u_decod(
    .rst    ( ad_rst    ),
    .clk    ( clk       ),
    .cen    ( cen_oki   ),
    .sel    ( 2'b10     ),
    .din    ( din       ),
    .sound  ( snd       ),
    .irq    ( sample    )
);

endmodule