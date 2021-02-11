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
  
*/module adc_test(
    input            FPGA_CLK1_50,
    output           LED_USER,
    output           LED_HDD,
    output           LED_POWER,
    output     [7:0] LED,
    // ADC
    output           ADC_CONVST,
    output           ADC_SCK,
    output           ADC_SDI,
    input            ADC_SDO
);

wire clk = FPGA_CLK1_50;
reg  [7:0] ledsr = 8'd1;

reg [25:0] cnt=0;
wire [2:0] LEDmister;
// assign LED = ledsr;
assign {LED_POWER,LED_HDD,LED_USER} = LEDmister; //~{ |ledsr[7:6], |ledsr[5:3], |ledsr[2:0] };

always @(posedge clk) begin 
    if( cnt[25] ) begin
        cnt <= 0;
        ledsr <= { ledsr[6:0], ledsr[7] };
    end else begin
        cnt <= cnt + 26'd1;
    end
end

reg [5:0] rst_sr=6'b100_000;
always @(negedge clk) begin
    rst_sr <= { rst_sr[4:0], 1'b1 };
end

wire rst_n = rst_sr[5];

reg [1:0] cen_cnt=0;
reg cen;
always @(negedge clk) begin
    cen_cnt <= cen_cnt+2'd1;
    cen <= cen_cnt == 2'b00;
end

wire [11:0] adc_read;
assign { LEDmister, LED } = {~adc_read[10:8], adc_read[7:0]};

/*
always @(*) begin
    if( adc_read < 12'd64   ) LEDmister <= 3'b000;
    else
    if( adc_read < 12'd512  ) LEDmister <= 3'b001;
    else
    if( adc_read < 12'd1512 ) LEDmister <= 3'b011;
    else LEDmister <= 3'b111;
end
*/
jtframe_2308 adc(
    .rst_n      ( rst_n      ),
    .clk        ( clk        ),
    .cen        ( cen        ),        // CEN+CLK < 40MHz
    // ADC control
    .adc_sdo    ( ADC_SDO    ),
    .adc_convst ( ADC_CONVST ),
    .adc_sck    ( ADC_SCK    ),
    .adc_sdi    ( ADC_SDI    ),
    // ADC read data
    .adc_read   ( adc_read   )
);


endmodule
