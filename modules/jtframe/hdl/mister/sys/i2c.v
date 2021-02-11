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
  
*/
module i2c
(
	input        CLK,

	input        START,
	input        READ,
	input  [6:0] I2C_ADDR,
	input        I2C_WLEN,   // 0 - one byte, 1 - two bytes
	input  [7:0] I2C_WDATA1,
	input  [7:0] I2C_WDATA2,
	output [7:0] I2C_RDATA,
	output reg   END = 1,
	output reg   ACK = 0,

	//I2C bus
	output       I2C_SCL,
 	inout        I2C_SDA
);


//	Clock Setting
parameter CLK_Freq = 50_000_000;	//	50 MHz
parameter I2C_Freq = 400_000;		//	400 KHz

localparam I2C_FreqX2 = I2C_Freq*2;

reg         I2C_CLOCK;
reg  [31:0] cnt;
wire [31:0] cnt_next = cnt + I2C_FreqX2;

always @(posedge CLK) begin
	cnt <= cnt_next;
	if(cnt_next >= CLK_Freq) begin
		cnt <= cnt_next - CLK_Freq;
		I2C_CLOCK <= ~I2C_CLOCK;
	end
end

assign I2C_SCL = SCLK | I2C_CLOCK;
assign I2C_SDA = SDO[3] ? 1'bz : 1'b0;

reg       SCLK = 1;
reg [3:0] SDO  = 4'b1111;
reg [0:7] rdata;

assign I2C_RDATA = rdata;

always @(posedge CLK) begin
	reg old_clk;
	reg old_st;
	reg rd,len;

	reg  [5:0] SD_COUNTER = 'b111111;
	reg [0:31] SD;

	old_clk <= I2C_CLOCK;
	old_st  <= START;
	
	// delay to make sure SDA changed while SCL is stabilized at low
	if(old_clk && ~I2C_CLOCK && ~SD_COUNTER[5]) SDO[0] <= SD[SD_COUNTER[4:0]];
	SDO[3:1] <= SDO[2:0];

	if(~old_st && START) begin
		SCLK <= 1;
		SDO  <= 4'b1111;
		ACK  <= 0;
		END  <= 0;
		rd   <= READ;
		len  <= I2C_WLEN;
		if(READ) SD <= {2'b10, I2C_ADDR, 1'b1, 1'b1, 8'b11111111, 1'b0, 3'b011, 9'b111111111};
			else  SD <= {2'b10, I2C_ADDR, 1'b0, 1'b1, I2C_WDATA1,  1'b1, I2C_WDATA2,  4'b1011};
		SD_COUNTER <= 0;
	end else begin
		if(~old_clk && I2C_CLOCK && ~&SD_COUNTER) begin
			SD_COUNTER <= SD_COUNTER + 6'd1;	
			case(SD_COUNTER)
			      01: SCLK <= 0;
			      10: ACK  <= ACK | I2C_SDA;
			      19: if(~rd) begin
							ACK <= ACK | I2C_SDA;
							if(~len) SD_COUNTER <= 29;
						 end
					20: if(rd)  SCLK <= 1;
					23: if(rd)  END  <= 1;
			      28: if(~rd) ACK  <= ACK | I2C_SDA;
			      29: if(~rd) SCLK <= 1;
			      32: if(~rd) END  <= 1;
			endcase

			if(SD_COUNTER >= 11 && SD_COUNTER <= 18) rdata[SD_COUNTER[4:0]-11] <= I2C_SDA;
		end
	end
end

endmodule
