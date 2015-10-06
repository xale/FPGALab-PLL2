----------------------------------------------------------------------------------
-- Company:			JHU ECE
-- Engineer:		Alex Heinz
-- 
-- Create Date:		16:07:56 10/25/2010 
-- Design Name:		Lab ShReg
-- Module Name:		ToggleD - Behavioral 
-- Project Name:	Lab ShReg
-- Target Devices:	XILINX Spartan3 XC3S1000
-- Tool versions:	
-- Description:		Push-button toggle switch using a shift-register buffer.
--
-- Dependencies:	IEEE standard libraries, AHeinzDeclares package,
--					Xilinx primitives (IBUF, BUFG)
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;

use WORK.AHeinzDeclares.all;

entity ToggleD is
	port
	(
		-- Raw push-button input (active low)
		buttonRaw_AL	: in	std_logic;
		
		-- Sampling/synchronization clock
		clk				: in	std_logic;
		
		-- Reset
		reset			: in	std_logic;
		
		-- Raw button input after clock buffers and inverter
		bufferedRawOut	: out	std_logic;
		
		-- Toggle output value
		Q				: out	std_logic
	);
end ToggleD;

architecture Behavioral of ToggleD is
	
	-- Constants
	constant SHIFT_REGISTER_LENGTH	: integer	:= 3;
	
	-- Internal signals
	-- Push-button input buffer stages
	signal bufferedRaw_AL	: std_logic;	-- After IBUF
	signal bufferedRaw		: std_logic;	-- After IBUF + inverter
	
	-- Shift register value
	signal shiftRegValue		: std_logic_vector((SHIFT_REGISTER_LENGTH - 1) downto 0);
	signal nextShiftRegValue	: std_logic_vector((SHIFT_REGISTER_LENGTH - 1) downto 0);
	
	-- Synchronized button value
	signal synchedButton	: std_logic;
	signal nextButtonValue	: std_logic;
	
	-- Internal copy of output signal
	signal Q_internal	: std_logic;
		
begin
	
	-- Invert the raw input
	bufferedRaw <= NOT buttonRaw_AL;
	
	-- Synchronized input process
	process (clk, reset)
	begin
	
		-- On reset, clear the shift register and synchronized button value
		if (reset = AH_ON) then
		
			shiftRegValue <= (others => AH_OFF);
			synchedButton <= AH_OFF;
		
		-- On a clock edge, shift a new value into the register from the input
		-- button, and update the synchronized button value, if changed
		elsif rising_edge(clk) then
		
			shiftRegValue <= nextShiftRegValue;
			synchedButton <= nextButtonValue;
		
		end if;
		
	end process;
	
	-- Next-shift register value (shifts in one bit at a time from the button)
	nextShiftRegValue <= shiftRegValue((SHIFT_REGISTER_LENGTH - 2) downto 0) & bufferedRaw;
	
	-- 
	nextButtonValue <=	AH_ON when (shiftRegValue = "111") else
						AH_OFF when (shiftRegValue = "000") else
						synchedButton;
	
	-- Toggle-output process
	process (synchedButton, reset)
	begin
		-- On reset, clear toggle value
		if (reset = AH_ON) then
		
			Q_internal <= AH_OFF;
		
		-- On (synchronized) button press, flip toggle value
		elsif rising_edge(synchedButton) then
		
			Q_internal <= NOT Q_internal;
			
		end if;
		
	end process;
	
	-- Connect internal toggle value to output
	Q <= Q_internal;
	
	-- Expose the raw signal on an output via a clock buffer, for comparison
	C_BUF2:	BUFG port map(I=> bufferedRaw, O => bufferedRawOut);
	
end Behavioral;
