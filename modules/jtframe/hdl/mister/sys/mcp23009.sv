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
  
*///
// MCP23009
// (C) 2019 Alexey Melnikov
//
module mcp23009
(
	input            clk,

	output reg [2:0] btn,
	input      [2:0] led,
	output reg       sd_cd,

	output		     scl,
	inout 		     sda
);


reg        start = 0;
wire       ready;
wire       error;
reg        rw;
wire [7:0] dout;
reg [15:0] din;

i2c #(50_000_000, 500_000) i2c
(
	.CLK(clk),
	.START(start),
	.READ(rw),
	.I2C_ADDR('h20),
	.I2C_WLEN(1),
	.I2C_WDATA1(din[15:8]),
	.I2C_WDATA2(din[7:0]),
	.I2C_RDATA(dout),
	.END(ready),
	.ACK(error),
	.I2C_SCL(scl),
 	.I2C_SDA(sda)
);

always@(posedge clk) begin
	reg  [3:0] idx = 0;
	reg  [1:0] state = 0;
	reg [15:0] timeout = 0;

	if(~&timeout) begin
		timeout <= timeout + 1'd1;
		start   <= 0;
		state   <= 0;
		idx     <= 0;
		btn     <= 0;
		rw      <= 0;
		sd_cd   <= 1;
	end
	else begin
		if(~&init_data[idx]) begin
			case(state)
			0:	begin
					start <= 1;
					state <= 1;
					din   <= init_data[idx];
				end
			1: if(~ready) state <= 2;
			2:	begin
					start <= 0;
					if(ready) begin
						state <= 0;
						if(!error) idx <= idx + 1'd1;
					end
				end
			endcase
		end
		else begin
			case(state)
			0:	begin
					start <= 1;
					state <= 1;
					din   <= {8'h09,5'b00000,led};
				end
			1: if(~ready) state <= 2;
			2:	begin
					start <= 0;
					if(ready) begin
						state <= 0;
						rw <= 0;
						if(!error) begin
							if(rw) {sd_cd, btn} <= {dout[7], dout[5:3]};
							rw <= ~rw;
						end
					end
				end
			endcase
		end
	end
end

wire [15:0] init_data[12] = 
'{
	16'h00F8,
	16'h0138,
	16'h0200,
	16'h0300,
	16'h0400,
	16'h0524,
	16'h06FF,
	16'h0700,
	16'h0800,
	16'h0900,
	16'h0A00,
	16'hFFFF
};

endmodule
