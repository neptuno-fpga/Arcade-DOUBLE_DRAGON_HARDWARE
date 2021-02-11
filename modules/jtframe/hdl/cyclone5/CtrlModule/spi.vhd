--
-- Multicore 2 / Multicore 2+
--
-- Copyright (c) 2017-2020 - Victor Trucco
--
-- All rights reserved
--
-- Redistribution and use in source and synthezised forms, with or without
-- modification, are permitted provided that the following conditions are met:
--
-- Redistributions of source code must retain the above copyright notice,
-- this list of conditions and the following disclaimer.
--
-- Redistributions in synthesized form must reproduce the above copyright
-- notice, this list of conditions and the following disclaimer in the
-- documentation and/or other materials provided with the distribution.
--
-- Neither the name of the author nor the names of other contributors may
-- be used to endorse or promote products derived from this software without
-- specific prior written permission.
--
-- THIS CODE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
-- THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
-- PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE
-- LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
-- CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
-- SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
-- INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
-- CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
-- POSSIBILITY OF SUCH DAMAGE.
--
-- You are responsible for any legal issues arising from your use of this code.
--
		
-- Adapted by AMR from the Chameleon Minimig cfide.vhd file,
-- originally by Tobias Gubener.

-- spi_to_host contains data received from slave device.
-- Busy bit now has a signal of its own.

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;


entity spi_interface is
	port (
		sysclk : in std_logic;
		reset : in std_logic;

		-- Host interface
		spiclk_in : in std_logic;	-- Momentary high pulse
		host_to_spi : in std_logic_vector(7 downto 0);
		spi_to_host : out std_logic_vector(7 downto 0);
		trigger : in std_logic;  -- Momentary high pulse
		busy : buffer std_logic;

		-- Hardware interface
		miso : in std_logic;
		mosi : out std_logic;
		spiclk_out : out std_logic -- 50% duty cycle
	);
end entity;

architecture rtl of spi_interface is
signal sck : std_logic;
signal sd_shift : std_logic_vector(7 downto 0);
signal shiftcnt : std_logic_vector(3 downto 0);
begin

-----------------------------------------------------------------
-- SPI-Interface
-----------------------------------------------------------------	
	spiclk_out <= sck;
	busy <= (not shiftcnt(3)) or trigger; -- Or-ing in the trigger signal makes the busy signal respond immediately
   spi_to_host <= sd_shift;

	PROCESS (sysclk, reset) BEGIN

		IF reset ='0' THEN 
			shiftcnt(3)<='0';
			sck <= '0';
		ELSIF rising_edge(sysclk) then
			IF trigger='1' then
				shiftcnt <= "0111";  -- shift out 8 bits, underflow will set bit 3, mapped to busy
				sd_shift <= host_to_spi(7 downto 0);
				sck <= '1';
			ELSE
				IF spiclk_in='1' and busy='1' THEN
					IF sck='1' THEN
						mosi<=sd_shift(7);
						sck <='0';
					ELSE	
						sck <='1';
						sd_shift <= sd_shift(6 downto 0)&miso;
						shiftcnt <= shiftcnt-1;
					END IF;
				END IF;
			END IF;
		end if;
	END PROCESS;

end architecture;