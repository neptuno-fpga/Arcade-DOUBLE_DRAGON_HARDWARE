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
  
*/`timescale 1ns / 1ps

module test;

reg  rst;
wire irq;
reg  clk, cen=1'b0;
reg [3:0] din=0;
wire signed [11:0] sound;

jt5205 uut(
    .rst        ( rst       ),
    .clk        ( clk       ),
    .cen        ( cen       ),
    .din        ( din       ),
    .sel        ( 2'b0      ),
    .sound      ( sound     ),
    .irq        ( irq       )
);

reg [7:0] data[0:1024*32-1];
reg [3:0] sine_data[0:19];

integer f,fcnt;

initial begin
    sine_data[0] = 0;
    sine_data[1] = 0;
    sine_data[2] = 0;
    sine_data[3] = 3;
    sine_data[4] = 3;
    sine_data[5] = 3;
    sine_data[6] = 7;
    sine_data[7] = 4'hf;
    sine_data[8] = 4'h7;
    sine_data[9] = 4'hf;
    sine_data[10] = 4'h4;
    sine_data[11] = 4'hc;
    sine_data[12] = 4'h4;
    sine_data[13] = 4'hc;
    sine_data[14] = 4'h4; // repeat from here
    sine_data[15] = 4'h0;
    sine_data[16] = 4'h9;
    sine_data[17] = 4'hc;
    sine_data[18] = 4'h8;
    sine_data[19] = 4'h1;
end

initial begin
    clk=1'b0;
    f=$fopen("adpcm_din.bin","rb");
    fcnt=$fread(data,f);
    $fclose(f);
    forever #325.521 clk=~clk;
end

initial begin
    rst = 1'b0;
    #150 rst=1'b1;
    #5000 rst=1'b0;
end

integer cnt=0;

reg last_irq;

always @(posedge clk) begin
    last_irq <= irq;
    if( irq && !last_irq) begin
    `ifdef SINESIM
        din <= sine_data[cnt];
        cnt <= cnt<19 ? cnt+1 : 14;
        if( $time>14_000_000) $finish;
    `else
        din <= !cnt[0] ? data[cnt>>1][7:4] : data[cnt>>1][3:0];
        cnt <= cnt+1;
        if( cnt==fcnt*2 ) $finish;
    `endif
    end
end

integer cen_cnt=0;

always @(posedge clk) begin
    cen <= 1'b0;
    if(cen_cnt==0) cen<=1'b1;
    cen_cnt <= cen_cnt==0 ? 3 : (cen_cnt-1);
end

`ifndef NCVERILOG
    initial begin
        $dumpfile("test.lxt");
        $dumpvars(0,test);
        $dumpon;
    end
`else
    initial begin
        $shm_open("test.shm");
        $shm_probe(test,"AS");
    end
`endif

integer fsnd;
initial begin
    fsnd=$fopen("sound.raw","wb");
end
wire signed [15:0] snd_log = { sound, 4'b0 };
always @(posedge irq) begin
    $fwrite(fsnd,"%u", {snd_log, snd_log});
end

endmodule