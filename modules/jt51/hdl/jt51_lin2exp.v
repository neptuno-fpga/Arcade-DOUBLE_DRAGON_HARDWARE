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
  
*//*  This file is part of JT51.

    JT51 is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    JT51 is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with JT51.  If not, see <http://www.gnu.org/licenses/>.
	
	Author: Jose Tejada Gomez. Twitter: @topapate
	Version: 1.0
	Date: 27-10-2016
	*/

`timescale 1ns / 1ps

module jt51_lin2exp(
  input      [15:0] lin,
  output reg [9:0] man,
  output reg [2:0] exp
);

always @(*) begin
  casez( lin[15:9] )
    // negative numbers
    7'b10?????: begin
        man = lin[15:6];
        exp = 3'd7;
      end
    7'b110????: begin
        man = lin[14:5];
        exp = 3'd6;
      end
    7'b1110???: begin
        man = lin[13:4];
        exp = 3'd5;
      end
    7'b11110??: begin
        man = lin[12:3];
        exp = 3'd4;
      end
    7'b111110?: begin
        man = lin[11:2];
        exp = 3'd3;
      end
    7'b1111110: begin
        man = lin[10:1];
        exp = 3'd2;
      end
    7'b1111111: begin
        man = lin[ 9:0];
        exp = 3'd1;
      end    
    // positive numbers
    7'b01?????: begin
        man = lin[15:6];
        exp = 3'd7;
      end
    7'b001????: begin
        man = lin[14:5];
        exp = 3'd6;
      end
    7'b0001???: begin
        man = lin[13:4];
        exp = 3'd5;
      end
    7'b00001??: begin
        man = lin[12:3];
        exp = 3'd4;
      end
    7'b000001?: begin
        man = lin[11:2];
        exp = 3'd3;
      end
    7'b0000001: begin
        man = lin[10:1];
        exp = 3'd2;
      end
    7'b0000000: begin
        man = lin[ 9:0];
        exp = 3'd1;
      end
    
    default: begin
        man = lin[9:0];
        exp = 3'd1;
      end
  endcase
end

endmodule
