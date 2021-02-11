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
  
*/// sigmadelta.v
// two channel second order sigma delta dac
// taken from Minimig

// audio data processing
// stereo sigma/delta bitstream modulator
module sd2_dac (
	input 			clk,			// bus clock
	input	[15:0]	ldatasum,	// left channel data
	input	[15:0] 	rdatasum,	// right channel data
	output	reg 	left=0,		// left bitstream output
	output	reg 	right=0		// right bitsteam output
);

//--------------------------------------------------------------------------------------

// local signals
localparam DW = 16;
localparam CW = 2;
localparam RW  = 4;
localparam A1W = 2;
localparam A2W = 5;

wire [DW+2+0  -1:0] sd_l_er0, sd_r_er0;
reg  [DW+2+0  -1:0] sd_l_er0_prev=0, sd_r_er0_prev=0;
wire [DW+A1W+2-1:0] sd_l_aca1,  sd_r_aca1;
wire [DW+A2W+2-1:0] sd_l_aca2,  sd_r_aca2;
reg  [DW+A1W+2-1:0] sd_l_ac1=0, sd_r_ac1=0;
reg  [DW+A2W+2-1:0] sd_l_ac2=0, sd_r_ac2=0;
wire [DW+A2W+3-1:0] sd_l_quant, sd_r_quant;

// LPF noise LFSR
reg [24-1:0] seed1 = 24'h654321;
reg [19-1:0] seed2 = 19'h12345;
reg [24-1:0] seed_sum=0, seed_prev=0, seed_out=0;
always @ (posedge clk) begin
  if (&seed1)
    seed1 <= 24'h654321;
  else
    seed1 <= {seed1[22:0], ~(seed1[23] ^ seed1[22] ^ seed1[21] ^ seed1[16])};
end
always @ (posedge clk) begin
  if (&seed2)
    seed2 <= 19'h12345;
  else
    seed2 <= {seed2[17:0], ~(seed2[18] ^ seed2[17] ^ seed2[16] ^ seed2[13] ^ seed2[0])};
end
always @ (posedge clk) begin
  seed_sum  <= seed1 + {5'b0, seed2};
  seed_prev <= seed_sum;
  seed_out  <= seed_sum - seed_prev;
end

// linear interpolate
localparam ID=4; // counter size, also 2^ID = interpolation rate
reg  [ID+0-1:0] int_cnt = 0;
always @ (posedge clk) int_cnt <= int_cnt + 'd1;

reg  [DW+0-1:0] ldata_cur=0, ldata_prev=0;
reg  [DW+0-1:0] rdata_cur=0, rdata_prev=0;
wire [DW+1-1:0] ldata_step, rdata_step;
reg  [DW+ID-1:0] ldata_int=0, rdata_int=0;
wire [DW+0-1:0] ldata_int_out, rdata_int_out;
assign ldata_step = {ldata_cur[DW-1], ldata_cur} - {ldata_prev[DW-1], ldata_prev}; // signed subtract
assign rdata_step = {rdata_cur[DW-1], rdata_cur} - {rdata_prev[DW-1], rdata_prev}; // signed subtract
always @ (posedge clk) begin
  if (~|int_cnt) begin
    ldata_prev <= ldata_cur;
    ldata_cur  <= ldatasum; //{~ldatasum[DW-1], ldatasum[DW-2:0]}; // convert to offset binary, samples no longer signed!
    rdata_prev <= rdata_cur;
    rdata_cur  <= rdatasum; //{~rdatasum[DW-1], rdatasum[DW-2:0]}; // convert to offset binary, samples no longer signed!
    ldata_int  <= {ldata_cur[DW-1], ldata_cur, {ID{1'b0}}};
    rdata_int  <= {rdata_cur[DW-1], rdata_cur, {ID{1'b0}}};
  end else begin
    ldata_int  <= ldata_int + {{ID{ldata_step[DW+1-1]}}, ldata_step};
    rdata_int  <= rdata_int + {{ID{rdata_step[DW+1-1]}}, rdata_step};
  end
end
assign ldata_int_out = ldata_int[DW+ID-1:ID];
assign rdata_int_out = rdata_int[DW+ID-1:ID];

// input gain x3
wire [DW+2-1:0] ldata_gain, rdata_gain;
assign ldata_gain = {ldata_int_out[DW-1], ldata_int_out, 1'b0} + {{(2){ldata_int_out[DW-1]}}, ldata_int_out};
assign rdata_gain = {rdata_int_out[DW-1], rdata_int_out, 1'b0} + {{(2){rdata_int_out[DW-1]}}, rdata_int_out};


// random dither to 15 bits
/*
reg [DW-1:0] ldata=0, rdata=0;
always @ (posedge clk) begin
  ldata <= ldata_gain[DW+2-1:2] + ( (~(&ldata_gain[DW+2-1-1:2]) && (ldata_gain[1:0] > seed_out[1:0])) ? 15'd1 : 15'd0 );
  rdata <= rdata_gain[DW+2-1:2] + ( (~(&ldata_gain[DW+2-1-1:2]) && (ldata_gain[1:0] > seed_out[1:0])) ? 15'd1 : 15'd0 );
end
*/

// accumulator adders
assign sd_l_aca1 = {{(A1W){ldata_gain[DW+2-1]}}, ldata_gain} - {{(A1W){sd_l_er0[DW+2-1]}}, sd_l_er0} + sd_l_ac1;
assign sd_r_aca1 = {{(A1W){rdata_gain[DW+2-1]}}, rdata_gain} - {{(A1W){sd_r_er0[DW+2-1]}}, sd_r_er0} + sd_r_ac1;

assign sd_l_aca2 = {{(A2W-A1W){sd_l_aca1[DW+A1W+2-1]}}, sd_l_aca1} - {{(A2W){sd_l_er0[DW+2-1]}}, sd_l_er0} - {{(A2W+1){sd_l_er0_prev[DW+2-1]}}, sd_l_er0_prev[DW+2-1:1]} + sd_l_ac2;
assign sd_r_aca2 = {{(A2W-A1W){sd_r_aca1[DW+A1W+2-1]}}, sd_r_aca1} - {{(A2W){sd_r_er0[DW+2-1]}}, sd_r_er0} - {{(A2W+1){sd_r_er0_prev[DW+2-1]}}, sd_r_er0_prev[DW+2-1:1]} + sd_r_ac2;

// accumulators
always @ (posedge clk) begin
  sd_l_ac1 <= sd_l_aca1;
  sd_r_ac1 <= sd_r_aca1;
  sd_l_ac2 <= sd_l_aca2;
  sd_r_ac2 <= sd_r_aca2;
end

// value for quantizaton
assign sd_l_quant = {sd_l_ac2[DW+A2W+2-1], sd_l_ac2} + {{(DW+A2W+3-RW){seed_out[RW-1]}}, seed_out[RW-1:0]};
assign sd_r_quant = {sd_r_ac2[DW+A2W+2-1], sd_r_ac2} + {{(DW+A2W+3-RW){seed_out[RW-1]}}, seed_out[RW-1:0]};

// error feedback
assign sd_l_er0 = sd_l_quant[DW+A2W+3-1] ? {1'b1, {(DW+2-1){1'b0}}} : {1'b0, {(DW+2-1){1'b1}}};
assign sd_r_er0 = sd_r_quant[DW+A2W+3-1] ? {1'b1, {(DW+2-1){1'b0}}} : {1'b0, {(DW+2-1){1'b1}}};
always @ (posedge clk) begin
  sd_l_er0_prev <= (&sd_l_er0) ? sd_l_er0 : sd_l_er0+1;
  sd_r_er0_prev <= (&sd_r_er0) ? sd_r_er0 : sd_r_er0+1;
end

// output
always @ (posedge clk) begin
  left  <= (~|ldata_gain) ? ~left  : ~sd_l_er0[DW+2-1];
  right <= (~|rdata_gain) ? ~right : ~sd_r_er0[DW+2-1];
end

endmodule
