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

module jt51_interpol_tb;


	wire fir_sample;
	reg	fir_clk;
	wire signed [15:0] left_out;
	wire signed [15:0] right_out;


	initial begin // 50MHz
		fir_clk = 0;
		forever #10 fir_clk = ~fir_clk;
	end

	initial begin
		rst = 0;
		#(280*3) rst=1;
		#(280*4) rst=0;
	end

	initial begin 
		$dumpfile("jt51_interpol.lxt");
		$dumpvars();
		$dumpon;
	end

	always @(posedge prog_done) #100 $finish;			

	initial #(1000*1000*10) $finish;

`include "../common/jt51_test.vh"

jt51_interpol i_jt51_interpol (
	.clk        (fir_clk    ),
	.rst        (rst        ),
	.sample_in  (sample     ),
	.left_in    (xleft    	),
	.right_in   (xright   	),
	.left_other (16'd0 		),
	.right_other(16'd0		),
	.out_l		(left_out   ),
	.out_r		(right_out  ),
	.sample_out (fir_sample )
);


endmodule
