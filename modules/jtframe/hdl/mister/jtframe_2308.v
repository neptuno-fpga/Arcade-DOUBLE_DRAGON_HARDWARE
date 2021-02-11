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
    Date: 2-4-2019 */

// Driver for LTC2308 ADC

module jtframe_2308(
    input             rst_n,
    input             clk,
    input             cen,        // CEN+CLK < 40MHz
    // ADC control
    input             adc_sdo,
    output reg        adc_convst,
    output reg        adc_sck,
    output            adc_sdi,
    // ADC read data
    output reg [11:0] adc_read
);

parameter ADC_PIN  = 2'b00;
parameter DIV_MAX  = 8'd100;  // frequency divider to get sampling rate

wire [1:0] adc_pin = ADC_PIN;
wire [7:0] div_max = DIV_MAX;

wire [5:0] cfg = { 
    1'b1,   // single ended
    1'b0,   // odd
    adc_pin,
    1'b1,   // unipolar
    1'b0    // sleep
};

// Input frequency divider
reg [7:0] div;

always @(posedge clk or negedge rst_n)
    if(!rst_n) begin
        div <= 8'd0;
    end else if(cen) begin
        div <= div == div_max ? 8'd0 : div+8'd1;
    end

// state machine
// 0 = send CFG
// 1 = read value
reg state;
reg set_cfg;

always @(posedge clk or negedge rst_n)
    if(!rst_n) begin
        state <= 1'b0;
    end else if(cen) begin
        set_cfg  <= 1'b0;
        adc_convst <= 1'b0;

        if( div==8'd0 ) begin
            state <= ~state;
            if( state==1'b0 )
                set_cfg <= 1'b1;
            else
                adc_convst <= 1'b1;
        end        
    end

// Send data
reg  [11:0] scnt, readbuf;
reg  [ 5:0] cfg_sr;

assign adc_sdi = cfg_sr[5];

always @(posedge clk or negedge rst_n)
    if(!rst_n) begin
        scnt    <= 'b0;
        adc_sck <= 1'b0;
    end else if(cen) begin
        if( set_cfg ) begin
            scnt  <= ~12'd0;
            cfg_sr <= cfg;
        end
        if( scnt[0] ) begin
            adc_sck <= ~adc_sck;
            // if(toggle) scnt    <= { 1'b0, scnt[11:1] };
            if(  adc_sck ) { cfg_sr } <= { cfg_sr[4:0], 1'b0 };
            if( !adc_sck ) begin
                readbuf <= { readbuf[10:0], adc_sdo };
                scnt    <= { 1'b0, scnt[11:1] };
            end
        end
        else begin
            adc_read <= readbuf;
            adc_sck  <= 1'b0;
        end
    end

endmodule // jtframe_2308