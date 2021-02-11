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
  
*//***************************************************************************
       This file is part of "HD63701V0 Compatible Processor Core".
****************************************************************************/
`timescale 1ps / 1ps
// `include "HD63701_defs.i"

module HD63701_Core #(parameter MCWIDTH=24) (
    input           rst,
    input           clk,
    (*direct_enable *) input cen_rise,
    (*direct_enable *) input cen_fall,
    input           NMI,
    input           IRQ,
    input           IRQ2,
    input    [3:0]  IRQ2V,

    output          RW,
    output  [15:0]  AD,
    output  [ 7:0]  DO,
    input   [ 7:0]  DI,

    // for DEBUG
    output    [5:0] PH,
    output [MCWIDTH-1:0] MC,
    output   [15:0] REG_D,
    output   [15:0] REG_X,
    output  [15:0]  REG_S,
    output   [5:0]  REG_C
);

wire [MCWIDTH-1:0] mcode;
wire [7:0]         vect;
wire               inte, fncu;

assign MC = mcode;

HD63701_SEQ #(MCWIDTH) SEQ(
    .clk        ( clk      ),
    .rst        ( rst      ),
    .cen_rise   ( cen_rise ),
    .cen_fall   ( cen_fall ),
                        
    .NMI(NMI),
    .IRQ(IRQ),
    .IRQ2(IRQ2),
    .IRQ2V(IRQ2V),
                        
    .DI(DI),
                        
    .mcout(mcode),
    .vect(vect),
    .inte(inte),
    .fncu(fncu),
                        
    .PH(PH) 
);

HD63701_EXEC #(MCWIDTH) EXEC(
    .clk        ( clk      ),
    .rst        ( rst      ),
    .cen_rise   ( cen_rise ),
    .cen_fall   ( cen_fall ),

    .DI(DI),
    .AD(AD),
    .RW(RW),
    .DO(DO),
                        
    .mcode(mcode),
    .vect(vect),
    .inte(inte),
    .fncu(fncu),
                        
    .REG_D(REG_D),
    .REG_X(REG_X),
    .REG_S(REG_S),
    .REG_C(REG_C)
);

endmodule


