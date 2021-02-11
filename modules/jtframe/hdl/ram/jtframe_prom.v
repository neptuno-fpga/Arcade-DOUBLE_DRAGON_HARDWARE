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
    Date: 27-10-2017 */

`timescale 1ns/1ps

    // check_start: lowest address at which the memory check
    // comparison is performed. Useful when the dumped file to load
    // has part of it invalid

module jtframe_prom #(parameter dw=8, aw=10, simfile="", offset=0 )(
    input   clk,
    input   cen,
    input   [dw-1:0] data,
    input   [aw-1:0] rd_addr,
    input   [aw-1:0] wr_addr,
    input   we,
    output reg [dw-1:0] q
);

(* ramstyle = "no_rw_check" *) reg [dw-1:0] mem[0:(2**aw)-1];

`ifdef SIMULATION
integer f, readcnt;
`ifndef LOADROM
// load the file only when SPI load is not simulated
initial begin
    if( simfile != "" ) begin
        f=$fopen(simfile,"rb");
        if( f != 0 ) begin
            readcnt=$fseek( f, offset, 0 );
            readcnt=$fread( mem, f );
            $display("INFO: %m file %s loaded",simfile);
            $fclose(f);
        end else begin
            $display("WARNING: %m cannot open %s", simfile);
        end
        end
    else begin
        for( readcnt=0; readcnt<(2**aw)-1; readcnt=readcnt+1 )
            mem[readcnt] = {dw{1'b0}};
        end
end
`endif
// check contents after 80ms
reg [dw-1:0] mem_check[0:(2**aw)-1];
reg check_ok=1'b1;
initial begin
    #(`MEM_CHECK_TIME);
    f=$fopen(simfile,"rb");
    if( f!= 0 ) begin
        readcnt = $fseek( f, offset, 0 );   // return value assigned to readcnt to avoid a warning
        readcnt = $fread( mem_check, f );
        $fclose(f);
        for( readcnt=readcnt-1;readcnt>=0; readcnt=readcnt-1) begin
            if( mem_check[readcnt] != mem[readcnt] ) begin
                $display("ERROR: memory content check failed for file %s (%m) @ 0x%x", simfile, readcnt );
                check_ok = 1'b0;
                //`ifndef IVERILOG
                //break;
                //`else 
                    readcnt = 0; // force a break
                //`endif
            end
        end
        if( check_ok ) $display("INFO: %m memory check succedded");
    end
    else begin
        $display("ERROR: Cannot find file %s to check memory %m", simfile );
    end
end
`endif

// no clock enable for writtings to allow correct operation during SPI downloading.
always @(posedge clk) begin
    if( cen ) q <= mem[rd_addr];
    if( we ) mem[wr_addr] <= data;
end


endmodule // jtframe_ram