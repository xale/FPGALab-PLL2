----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:25:43 12/02/2010 
-- Design Name: 
-- Module Name:    LabPLL2 - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use WORK.AHeinzDeclares.all;

entity LabPLL2 is
port
(
	clk100	: in	std_logic;	-- Master clock
	swrst	: in	std_logic;	-- (Active-low) reset switch
	sw1		: in	std_logic;	-- (AL) Lock-enable toggle button
	sig2	: in	std_logic;	-- Input signal
	fceb	: out	std_logic;	-- Flash-memory controller disable
	sig4	: out	std_logic;	-- Output signal
	sig5	: out	std_logic;	-- Synched version of input signal
	lsdp	: out	std_logic	-- Lock-enable status LED
);
end LabPLL2;

architecture Behavioral of LabPLL2 is
	
	-- Divisor for master-to-toggle-sampling clock
	constant TOGGLE_SAMPLE_CLK_DIV	: integer	:= 3_000_000;
	
	-- Global reset
	signal reset		: std_logic;
	
	-- Top-level global clock
	signal masterClk	: std_logic;
	
	-- Sampling clock for toggle-switch entity
	signal toggleSampleClk	: std_logic;
	
	-- PLL-enable/disable signal
	signal PLLEnable	: std_logic;
	
	-- Output signal from PLL
	signal PLLOut		: std_logic;
	
begin
	
	-- Disable flash-memory controller
	fceb <= AL_OFF;
	
	-- Invert the reset switch
	reset <= NOT swrst;
	
	-- Connect master clock
	masterClk <= clk100;
	
	-- Instantiate clock divider for toggle-switch sampling clock
	ToggleClkSrc: CounterClockDivider
	generic map (MAX_DIVISOR => TOGGLE_SAMPLE_CLK_DIV)
	port map
	(
		clkIn => masterClk,
		reset => reset,
		divisor => TOGGLE_SAMPLE_CLK_DIV,
		clkOut => toggleSampleClk
	);
	
	-- Instantiate toggle-switch entity
	PLLEnableToggle: ToggleD
	port map
	(
		buttonRaw_AL => sw1,
		clk => toggleSampleClk,
		reset => reset,
		bufferedRawOut => open,
		Q => PLLEnable
	);
	
	-- Display enabled/disabled status on LED
	lsdp <= PLLEnable;
	
	-- Instantiate PLL
	PhaseLockedLoop: PhaseLockedLoop250kHz
	port map
	(
		clk100MHz => masterClk,
		reset => reset,
		lockSignal_external => sig2,
		lockEnable => PLLEnable,
		lockSignal_synched => sig5,
		signalOut => PLLOut
	);
	
	-- Output locked/unlocked signal on a pin
	sig4 <= PLLOut;
	
end Behavioral;
