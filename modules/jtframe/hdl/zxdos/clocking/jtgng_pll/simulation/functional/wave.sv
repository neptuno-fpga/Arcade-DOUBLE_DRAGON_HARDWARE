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
  
*/# file: wave.sv
# 
# (c) Copyright 2008 - 2010 Xilinx, Inc. All rights reserved.
# 
# This file contains confidential and proprietary information
# of Xilinx, Inc. and is protected under U.S. and
# international copyright and other intellectual property
# laws.
# 
# DISCLAIMER
# This disclaimer is not a license and does not grant any
# rights to the materials distributed herewith. Except as
# otherwise provided in a valid license issued to you by
# Xilinx, and to the maximum extent permitted by applicable
# law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
# WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
# AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
# BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
# INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
# (2) Xilinx shall not be liable (whether in contract or tort,
# including negligence, or under any other theory of
# liability) for any loss or damage of any kind or nature
# related to, arising under or in connection with these
# materials, including for any direct, or any indirect,
# special, incidental, or consequential loss or damage
# (including loss of data, profits, goodwill, or any type of
# loss or damage suffered as a result of any action brought
# by a third party) even if such damage or loss was
# reasonably foreseeable or Xilinx had been advised of the
# possibility of the same.
# 
# CRITICAL APPLICATIONS
# Xilinx products are not designed or intended to be fail-
# safe, or for use in any application requiring fail-safe
# performance, such as life-support or safety devices or
# systems, Class III medical devices, nuclear facilities,
# applications related to the deployment of airbags, or any
# other applications that could lead to death, personal
# injury, or severe property or environmental damage
# (individually and collectively, "Critical
# Applications"). Customer assumes the sole risk and
# liability of any use of Xilinx products in Critical
# Applications, subject only to applicable laws and
# regulations governing limitations on product liability.
# 
# THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
# PART OF THIS FILE AT ALL TIMES.
#
# Get the windows set up
#
if {[catch {window new WatchList -name "Design Browser 1" -geometry 1054x819+536+322}] != ""} {
    window geometry "Design Browser 1" 1054x819+536+322
}
window target "Design Browser 1" on
browser using {Design Browser 1}
browser set \
    -scope nc::jtgng_pll_tb
browser yview see nc::jtgng_pll_tb
browser timecontrol set -lock 0

if {[catch {window new WaveWindow -name "Waveform 1" -geometry 1010x600+0+541}] != ""} {
    window geometry "Waveform 1" 1010x600+0+541
}
window target "Waveform 1" on
waveform using {Waveform 1}
waveform sidebar visibility partial
waveform set \
    -primarycursor TimeA \
    -signalnames name \
    -signalwidth 175 \
    -units ns \
    -valuewidth 75
cursor set -using TimeA -time 0
waveform baseline set -time 0
waveform xview limits 0 20000n

#
# Define signal groups
#
catch {group new -name {Output clocks} -overlay 0}
catch {group new -name {Status/control} -overlay 0}
catch {group new -name {Counters} -overlay 0}

set id [waveform add -signals [list {nc::jtgng_pll_tb.CLK_IN1}]]

group using {Output clocks}
group set -overlay 0
group set -comment {}
group clear 0 end

group insert \
    {jtgng_pll_tb.dut.clk[1]} \
    {jtgng_pll_tb.dut.clk[2]}  \     {jtgng_pll_tb.dut.clk[3]} 
group using {Counters}
group set -overlay 0
group set -comment {}
group clear 0 end

group insert \
    {jtgng_pll_tb.dut.counter[1]} \
    {jtgng_pll_tb.dut.counter[2]}  \     {jtgng_pll_tb.dut.counter[3]} 
group using {Status/control}
group set -overlay 0
group set -comment {}
group clear 0 end

group insert \
   {nc::jtgng_pll_tb.LOCKED}


set id [waveform add -signals [list {nc::jtgng_pll_tb.COUNT} ]]

set id [waveform add -signals [list {nc::jtgng_pll_tb.test_phase} ]]
waveform format $id -radix %a

set groupId [waveform add -groups {{Input clocks}}]
set groupId [waveform add -groups {{Output clocks}}]
set groupId [waveform add -groups {{Status/control}}]
set groupId [waveform add -groups {{Counters}}]
