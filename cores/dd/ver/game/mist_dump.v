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
  
*/`timescale 1ns/1ps

module mist_dump(
    input           VGA_VS,
    input           led,
    input   [31:0]  frame_cnt
);

`ifdef DUMP
`ifndef NCVERILOG // iVerilog:
    initial begin
        // #(200*100*1000*1000);
        $display("DUMP enabled");
        $dumpfile("test.lxt");
    end
    `ifdef DUMP_START
    always @(negedge VGA_VS) if( frame_cnt==`DUMP_START ) begin
    `else
        initial begin
    `endif
        $display("DUMP starts");
        `ifdef DEEPDUMP
            $dumpvars(0,mist_test);
        `else
            $dumpvars(1,mist_test.UUT.u_game);
            $dumpvars(1,mist_test.UUT.u_game.u_main);
            $dumpvars(1,mist_test.UUT.u_game.u_mcu);
            //$dumpvars(1,mist_test.UUT.u_game.u_main);
            //$dumpvars(0,mist_test.UUT.u_game.u_mcu);
            $dumpvars(1,mist_test.frame_cnt);
        `endif
        $dumpon;
    end
`else // NCVERILOG
    `ifdef DUMP_START
    always @(negedge VGA_VS) if( frame_cnt==`DUMP_START ) begin
    `else
    initial begin
    `endif
        $shm_open("test.shm");
        `ifdef DEEPDUMP
            $display("NC Verilog: will dump all signals");
            $shm_probe(mist_test,"AS");
        `else
            $display("NC Verilog: will dump selected signals");
            $shm_probe(frame_cnt);
            //$shm_probe(UUT.u_game,"A");
            //$shm_probe(UUT.u_game.u_rom,"AS");
            //$shm_probe(UUT.u_game.u_main,"A");
            $shm_probe(UUT.u_game.u_sound,"A");
            $shm_probe(UUT.u_game.u_sound.u_adpcm0,"A");
            $shm_probe(UUT.u_game.u_sound.u_adpcm1,"A");
            //$shm_probe(UUT.u_game.u_video,"A");
            //$shm_probe(UUT.u_game.u_video.u_char,"A");
            //$shm_probe(UUT.u_game.u_video.u_scroll,"A");
            //$shm_probe(UUT.u_game.u_video.u_obj,"A");
            //$shm_probe(UUT.u_game.u_mcu,"A");
            //$shm_probe(UUT.u_game.u_mcu.u_6801,"AS");
        `endif
    end
`endif
`endif

endmodule // mist_dump