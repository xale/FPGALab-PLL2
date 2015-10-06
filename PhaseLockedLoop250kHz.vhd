----------------------------------------------------------------------------------
-- Company:			JHU ECE
-- Engineer:		Alex Heinz
-- 
-- Create Date:		19:37:04 11/28/2010 
-- Design Name:		LabPLL
-- Module Name:		PhaseLockedLoop250kHz - Behavioral 
-- Project Name:	LabPLL
-- Target Devices:	Xilinx Spartan3 XC3S1000
-- Description:		A second-order phase-locked loop entity designed to lock onto
--					an external square-wave signal clocked at or near 250 kHz.
--
-- Dependencies:	IEEE standard libraries, AHeinzDeclares package
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use WORK.AHeinzDeclares.all;

entity PhaseLockedLoop250kHz is
port
(
	-- Internal (i.e., FPGA-local) 100 MHz sampling clock
	clk100MHz	: in	std_logic;
	
	-- Reset
	reset		: in	std_logic;
	
	-- External signal, with which this entity will attempt to synchronize
	lockSignal_external	: in	std_logic;
	
	-- Lock-enable; if clear, this entity will not attempt to synchronize with external signal
	lockEnable	: in	std_logic;
	
	-- Synched version of input signal
	lockSignal_synched	: out	std_logic;
	
	-- Output signal
	signalOut	: out	std_logic
);
end PhaseLockedLoop250kHz;

architecture Behavioral of PhaseLockedLoop250kHz is
	
	-- Constants
	-- Clock frequencies
	constant INPUT_CLK_FREQ					: real	:= 100_000.0;	-- kHz
	constant DEFAULT_OUTPUT_CLK_FREQ		: real	:= 250.0;		-- kHz
	
	-- Pure 250kHz signal phase-increment value 
	constant INITIAL_PHASE_INCREMENT_REAL	: real	:=
		((DEFAULT_OUTPUT_CLK_FREQ / INPUT_CLK_FREQ) * (2.0**32));
	constant INITIAL_PHASE_INCREMENT		: signed(31 downto 0)	:=
		TO_SIGNED(INTEGER(INITIAL_PHASE_INCREMENT_REAL), 32);
	
	-- Phase-increment adjustment values
	-- One-shot adjustment gain
	constant PHASE_MEASUREMENT_GAIN			: real	:= (1.0/400.0);
	
	-- Desired number of periods to complete a phase adjustment
	constant TIME_CONSTANT					: real	:= 4.0;
	
	-- (adjustment gain) / (time constant)
	constant TIME_ADJUSTED_GAIN				: real	:=
		(PHASE_MEASUREMENT_GAIN / TIME_CONSTANT);
	
	-- Denominator for "multiply-middle" operation (see below)
	constant MULTIPLY_MIDDLE_DENOMINATOR	: integer	:= (2**16);
	
	-- Final gain multiplier, assuming we use a "multiply-middle" operation:
	-- i.e., multiply by a small integer constant, and divide by a larger
	-- constant (in this case, 2^16) to approximate a floating-point division
	constant FINAL_GAIN_MULTIPLIER_REAL		: real	:=
		(TIME_ADJUSTED_GAIN * REAL(MULTIPLY_MIDDLE_DENOMINATOR));
	constant FINAL_GAIN_MULTIPLIER			: signed(31 downto 0)	:=
		TO_SIGNED(INTEGER(FINAL_GAIN_MULTIPLIER_REAL), 32);
	
	-- Internal signals
	-- Clock-synched input signal
	signal lockSignal		: std_logic;
	signal lockSignal_last	: std_logic;
	
	-- Phase-accumulator value
	signal phaseAccumulator		: signed(31 downto 0);
	signal nextAccumulatorValue	: signed(31 downto 0);
	
	-- Alias for MSB of phase accumulator
	alias accumulatorMSB		: std_logic is phaseAccumulator(31);
	
	-- Phase-accumulator increment
	signal phaseIncrement		: signed(31 downto 0);
	signal phaseDelta			: signed(31 downto 0);
	signal nextIncrementValue	: signed(31 downto 0);
	attribute INIT of phaseIncrement	: signal is "INITIAL_PHASE_INCREMENT";
	
	-- Phase offset between local and input signal
	signal phaseOffset			: signed(31 downto 0);
	
begin
	
	-- Input-signal synchronization process
	process (clk100MHz, reset)
	begin
		-- Clear latched signal value on reset
		if (reset = AH_ON) then
		
			lockSignal <= '0';
			lockSignal_last <= '0';
			
		-- Latch new signal value from input signal on clock edges
		elsif rising_edge(clk100MHz) then
		
			lockSignal <= lockSignal_external;
			lockSignal_last <= lockSignal;	-- Remember last value
			
		end if;
	end process;

	-- Accumulator process
	process (clk100MHz, reset)
	begin
		-- On reset, clear accumulator and reinitialize phase increment value
		if (reset = AH_ON) then
		
			phaseAccumulator <= (others => '0');
			phaseIncrement <= INITIAL_PHASE_INCREMENT;
			
		-- On clock edge, latch next values of accumulator and phase increment
		elsif rising_edge(clk100MHz) then
		
			phaseAccumulator <= nextAccumulatorValue;
			phaseIncrement <= nextIncrementValue;
			
		end if;
	end process;
	
	-- Next-accumulator-value logic
	-- If we have just passed a falling edge of the input signal,
	-- "zero" the accumulator; otherwise, increment the accumulator
	nextAccumulatorValue <=	phaseIncrement when
								((lockEnable = AH_ON) AND
								(lockSignal = AH_OFF) AND
								(lockSignal_last = AH_ON))
							else
							(phaseAccumulator + phaseIncrement);
	
	-- Phase-increment adjustment logic
	-- Delta is calculated from phase offset at (and applied on) the falling edge
	-- of the input signal, assuming locking is enabled
	phaseDelta <=	(phaseAccumulator * FINAL_GAIN_MULTIPLIER) /
					MULTIPLY_MIDDLE_DENOMINATOR;
	nextIncrementValue <=	(phaseIncrement - phaseDelta) when
								((lockEnable = AH_ON) AND
								(lockSignal = AH_OFF) AND
								(lockSignal_last = AH_ON))
							else
							phaseIncrement;
	
	-- Expose synched input signal for diagnostics
	lockSignal_synched <= lockSignal;
	
	-- Output signal (MSB of accumulator)
	signalOut <= phaseAccumulator(31);
	
end Behavioral;
