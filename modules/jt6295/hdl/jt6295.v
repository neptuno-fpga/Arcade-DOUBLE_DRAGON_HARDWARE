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

module jt6295(
    input                  rst,
    input                  clk,
    input                  cen /* direct_enable */,        
    input                  ss,        // ss pin: selects sample rate
    // CPU interface
    input                  wrn,  // active low
    input         [ 7:0]   din,
    output        [ 7:0]   dout,
    // ROM interface
    output        [17:0]   rom_addr,
    input         [ 7:0]   rom_data,
    input                  rom_ok,
    // Sound output
    output signed [13:0]   sound
);

wire        cen_sr;  // sampling rate
wire        cen_sr4, cen_sr4b; // 4x sampling rate 
wire        cen_sr32; // 32x sampling rate

wire [ 3:0] busy, ack, start, stop;
wire [17:0] start_addr, stop_addr ,
            ch_addr;
wire [ 9:0] ctrl_addr;
wire [ 7:0] ch_data, ctrl_data;
wire [ 3:0] data0, data1, data2, data3, pipe_data;
wire [ 3:0] att, pipe_att;
wire        ctrl_ok, ch_cs, ctrl_cs, zero;
wire signed [11:0] pipe_snd;

assign      dout = { 4'hf, busy | start };

jt6295_timing u_timing(
    .clk        ( clk       ),
    .cen        ( cen       ),
    .ss         ( ss        ),
    .cen_sr     ( cen_sr    ),
    .cen_sr4    ( cen_sr4   ),
    .cen_sr4b   ( cen_sr4b  ),
    .cen_sr32   ( cen_sr32  )
);

// ROM interface
assign ch_cs = cen_sr4b;

jt6295_rom u_rom(
    .rst        ( rst           ),
    .clk        ( clk           ),
    .cen4       ( cen_sr4       ),
    .cen32      ( cen_sr32      ),
    // Each parallel accessing device
    .adpcm_addr ( ch_addr       ),
    .ctrl_addr  ( { 8'd0, ctrl_addr } ),
    // Data
    .adpcm_dout ( ch_data       ),
    .ctrl_dout  ( ctrl_data     ),
    // Ok
    .ctrl_ok    ( ctrl_ok       ),
    // ROM interface
    .rom_addr   ( rom_addr      ),
    .rom_data   ( rom_data      ),
    .rom_ok     ( rom_ok        )
);

// CPU interface

jt6295_ctrl u_ctrl(
    .rst        ( rst           ),
    .clk        ( clk           ),
    .cen1       ( cen_sr        ),
    .cen4       ( cen_sr4       ),
    // CPU
    .wrn        ( wrn           ),
    .din        ( din           ),
    // Channel address
    .start_addr ( start_addr    ),
    .stop_addr  ( stop_addr     ),
    // Attenuation
    .att        ( att           ),
    // ROM interface
    .rom_addr   ( ctrl_addr     ),
    .rom_data   ( ctrl_data     ),
    .rom_ok     ( ctrl_ok       ),

    .start      ( start         ),
    .stop       ( stop          ),
    .busy       ( busy          ),
    .ack        ( ack           ),
    .zero       ( zero          )
);

jt6295_serial u_serial(
    .rst        ( rst           ),
    .clk        ( clk           ),
    .cen        ( cen_sr        ), 
    .cen4       ( cen_sr4       ),
    // Flow
    .start_addr ( start_addr    ),
    .stop_addr  ( stop_addr     ),
    .att        ( att           ),
    .start      ( start         ),
    .stop       ( stop          ),    
    .busy       ( busy          ),
    .ack        ( ack           ),
    .zero       ( zero          ),
    // ADPCM data feed    
    .rom_addr   ( ch_addr       ),
    .rom_data   ( ch_data       ),
    // serialized data
    .pipe_en    ( pipe_en       ),
    .pipe_att   ( pipe_att      ),
    .pipe_data  ( pipe_data     )
);

wire pipe_en;

jt6295_adpcm u_adpcm(
    .rst        ( rst           ),
    .clk        ( clk           ),
    .cen        ( cen_sr4       ), 
    // serialized data
    .en         ( pipe_en       ),
    .att        ( pipe_att      ),
    .data       ( pipe_data     ),
    .sound      ( pipe_snd      )
);

jt6295_acc u_acc(
    .rst        ( rst           ),
    .clk        ( clk           ),
    .cen        ( cen_sr        ),
    .cen4       ( cen_sr4       ),
    // serialized data
    .sound_in   ( pipe_snd      ),
    .sound_out  ( sound         )
);

`ifdef SIMULATION
integer fsnd;
initial begin
    fsnd=$fopen("jt6295.raw","wb");
end
wire signed [15:0] snd_log = { sound, 2'b0 };
always @(posedge cen_sr) begin
    $fwrite(fsnd,"%u", {snd_log, snd_log});
end
`endif
endmodule