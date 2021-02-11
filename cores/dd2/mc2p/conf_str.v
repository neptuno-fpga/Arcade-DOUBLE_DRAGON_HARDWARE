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
  
*/// 00000000001111111111222222222223
// 01234567890123456789012345678901
//           abcdefghijklmnopqrstuv

`define CORE_OSD \
    "OGH,Difficulty,very hard,easy,hard,normal;", \
    "OI,Demo music,OFF,ON;", \
    "OJK,Timer,60,65,80,70;", \
    "OLM,Lives,4,3,2,1;", \
    "OO,Hurricane Kick,easy,normal;", \
    // "ON,Turbo,Off,On;",
`define CORE_KEYMAP \
    "J,Left attack,Jump,Right attack,1P Start,2P Start,Coin,Credits;",
