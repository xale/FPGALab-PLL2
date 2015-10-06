----------------------------------------------------------------------------------
-- Company:			JHU ECE
-- Engineer:		Alex Heinz
-- 
-- Create Date:		17:28:48 10/16/2010 
-- Design Name:		Lab 2B
-- Module Name:		CounterClockDivider - Behavioral 
-- Project Name:	Lab 2B
-- Target Devices:	Xilinx Spartan3 XC3S1000
-- Description:		Rollover-counter-based clock divider.
--
-- Dependencies:	IEEE standard libraries, numeric_std library,
--					AHeinzDeclares package.
--
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use WORK.AHeinzDeclares.all;

entity CounterClockDivider is
	
	generic
	(
		-- Maximum allowed divisor value, defaults to 5
		MAX_DIVISOR : natural := 5
	);
	
	port
	(
		-- Input (dividend) clock
		clkIn	: in	std_logic;
		
		-- Reset
		reset	: in	std_logic;
		
		-- Clock divisor value
		divisor	: in	integer range 0 to MAX_DIVISOR;
		
		-- Output (quotient) clock
		clkOut	: out	std_logic
	);
	
end CounterClockDivider;

architecture Behavioral of CounterClockDivider is
	
	-- Internal signals
	-- Current counter value
	signal counterValue	: integer range 0 to MAX_DIVISOR;
	
	-- Next counter value
	signal nextValue	: integer range 0 to MAX_DIVISOR;
	
	-- Next output clock value
	signal nextClkOut	: std_logic;
	
begin

	-- Input-clock-edge/reset process
	process(clkIn, reset)
	begin
		-- On reset, clear counter
		if (reset = AH_ON) then
			counterValue <= 0;
		-- On rising edge, assign next counter and output clock value
		elsif rising_edge(clkIn) then
			counterValue <= nextValue;
			clkOut <= nextClkOut;
		end if;
	end process;
	
	-- Next-counter-value logic
	-- Increments each clock, resets when divisor value is reached
	nextValue <=	0 when (counterValue >= divisor) else
					(counterValue + 1);
	
	-- Output clock logic
	nextClkOut <= 	AH_ON when (counterValue >= divisor) else
					AH_OFF;
	
end Behavioral;

