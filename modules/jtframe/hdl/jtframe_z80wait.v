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
  
*//*  This file is part of JT_FRAME.
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
    Date: 1-1-2020 */

module jtframe_rom_wait(
    input       rst_n,
    input       clk,
    input       cen_in,
    output      cen_out,
    output      gate,
    // manage access to ROM data from SDRAM
    input       rom_cs,
    input       rom_ok
);
    jtframe_z80wait #(1) u_wait(
        .rst_n      ( rst_n     ),
        .clk        ( clk       ),
        .cen_in     ( cen_in    ),
        .cen_out    ( cen_out   ),
        .gate       ( gate      ),
        // manage access to shared memory
        .dev_busy   ( 1'b0      ),
        // manage access to ROM data from SDRAM
        .rom_cs     ( rom_cs    ),
        .rom_ok     ( rom_ok    )
    );
endmodule

/////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////

module jtframe_dual_wait #(parameter devcnt=2)(
    input       rst_n,
    input       clk,
    input  [1:0]     cen_in,
    output reg [1:0] cen_out,
    output           gate,
    // manage access to shared memory
    input  [devcnt-1:0] dev_busy,
    // manage access to ROM data from SDRAM
    input       rom_cs,
    input       rom_ok
);

/////////////////////////////////////////////////////////////////
// wait_n generation
reg last_rom_cs;
wire rom_cs_posedge = !last_rom_cs && rom_cs;
wire rom_bad = rom_cs && !rom_ok || rom_cs_posedge;

reg [1:0] mark, gated_at;
reg       locked, latched;
assign gate = !( rom_bad || dev_busy || locked || latched);
wire bus_ok = (rom_ok||!rom_cs) && !dev_busy;

always @(posedge clk, negedge rst_n) begin
    if( !rst_n ) begin
        gated_at <= 1'b0;
        latched  <= 1'b0;
    end else begin
        if(cen_in[0]) mark <= 2'b01;
        if(cen_in[1]) mark <= 2'b10;
        if(locked) begin
            gated_at <= mark;
            latched  <= 1'b1;
        end
        latched <= locked;
        if(bus_ok && !locked && latched) begin
            if( gated_at[0] & cen_in[1] ) latched <= 1'b0;
            if( gated_at[1] & cen_in[0] ) latched <= 1'b0;
        end
    end
end

always @(posedge clk)
    cen_out <= cen_in & {2{gate}};


always @(posedge clk or negedge rst_n) begin
    if( !rst_n ) begin
        last_rom_cs <= 1'b1;
        locked      <= 1'b0;
    end else begin
        last_rom_cs <= rom_cs;
        if( rom_bad || dev_busy) begin
            locked  <= 1'b1;
        end
        else begin
            locked <= 1'b0;
        end
    end
end

endmodule

module jtframe_z80wait #(parameter devcnt=2)(
    input       rst_n,
    input       clk,
    input       cen_in,
    output reg  cen_out,
    output      gate,
    // manage access to shared memory
    input  [devcnt-1:0] dev_busy,
    // manage access to ROM data from SDRAM
    input       rom_cs,
    input       rom_ok
);

/////////////////////////////////////////////////////////////////
// wait_n generation
reg last_rom_cs;
wire rom_cs_posedge = !last_rom_cs && rom_cs;

reg       locked;
wire rom_bad;
wire bus_ok = (rom_ok||!rom_cs) && !dev_busy;

assign gate    = !(rom_bad || dev_busy || locked );
assign rom_bad = (rom_cs && !rom_ok) || rom_cs_posedge;

always @(posedge clk)
    cen_out <= cen_in & gate;

always @(posedge clk or negedge rst_n) begin
    if( !rst_n ) begin
        last_rom_cs <= 1'b1;
        locked      <= 1'b0;
    end else begin
        last_rom_cs <= rom_cs;
        if(rom_bad || dev_busy) begin
            locked  <= 1'b1;
        end
        else begin
            locked <= 1'b0;
        end
    end
end

`ifdef SIMULATION
// Count how often there are delays because of ROM waits
integer misses=0;
always @(posedge cen_in) if(!gate) misses<=misses+1;
`endif

endmodule // jtframe_z80wait