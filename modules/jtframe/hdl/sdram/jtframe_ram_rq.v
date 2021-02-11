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
    Date: 28-2-2019 */

`timescale 1ns/1ps

////////////////////////////////////////////////////////////
/////// read/write type
/////// simple pass through
/////// It requires addr_ok signal to toggle for each request

module jtframe_ram_rq #(parameter AW=18, DW=8 )(
    input               rst,
    input               clk,
    input [AW-1:0]      addr,
    input [  21:0]      offset,     // It is not supposed to change during game play
    input               addr_ok,    // signals that value in addr is valid
    input [31:0]        din,        // data read from SDRAM
    input               din_ok,
    input               wrin,   
    input               we,
    output reg          req,
    output reg          req_rnw,
    output reg          data_ok,    // strobe that signals that data is ready
    output reg [21:0]   sdram_addr,
    input [DW-1:0]      wrdata,
    output reg [DW-1:0] dout        // sends SDRAM data back to requester
);

    wire  [21:0] size_ext   = { {22-AW{1'b0}}, addr };

    reg    last_cs;
    wire   cs_posedge = addr_ok && !last_cs;
    wire   cs_negedge = !addr_ok && last_cs;

    always @(posedge clk, posedge rst) begin
        if( rst ) begin
            last_cs <= 1'b0;
            req     <= 1'b0;
            data_ok <= 1'b0;
        end else begin
            last_cs <= addr_ok;
            if( cs_posedge ) begin
                req        <= 1'b1;
                req_rnw    <= ~wrin; 
                data_ok    <= 1'b0;
                sdram_addr <= size_ext + offset;
            end
            if( cs_negedge ) data_ok <= 1'b0;
            if( din_ok && we ) begin
                req     <= 1'b0;
                req_rnw <= 1'b1;
                data_ok <= 1'b1;
                dout    <= din;
            end
        end
    end

endmodule
