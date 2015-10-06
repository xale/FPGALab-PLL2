----------------------------------------------------------------------------------
-- Company:			JHU ECE
-- Engineer:		Alex Heinz
-- 
-- Create Date:		13:00 09/21/2010 
-- Module Name:		AHeinzDeclares 	
-- Description:		Standard portable "useful stuff" package.
--
-- Dependencies:	IEEE standard libraries
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package AHeinzDeclares is

	-- Types
	-- Simple integer array
	type IntegerArray is array(natural range <>) of integer;
	
	-- ROM for storing seven-segment digit values
	type DigitROM is array(natural range <>) of std_logic_vector(6 downto 0);
	
----------------------------------------------------------------------------------
	
	-- Attributes
	-- Initial value of signal/register at reset (Xilinx attribute)
	attribute INIT	: string;
	
----------------------------------------------------------------------------------

	-- Constants
	-- Basic digital signal values
	constant AH_ON	: std_logic := '1';	-- Active High "On"
	constant AH_OFF	: std_logic := '0';	-- Active High "Off"
	constant AL_ON	: std_logic := '0';	-- Active Low "On"
	constant AL_OFF	: std_logic := '1';	-- Active Low "Off"
	
	-- PS2 Keycode to ASCII lookup table
	constant PS2_KEYCODE_ASCII	: IntegerArray(0 to 255) :=
	(
	--														TAB	`	
		0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	09,	96,	0,	-- 00
	--						Q	1				Z	S	A	W	2	
		0,	0,	0,	0,	0,	81,	49,	0,	0,	0,	90,	83,	65,	87,	50,	0,	-- 10
	--		C	X	D	E	4	3			SPC	V	F	T	R	5	
		0,	67,	88,	68,	69,	52,	51,	0,	0,	32,	86,	70,	84,	82,	53,	0,	-- 20
	--		N	B	H	G	Y	6				M	J	U	7	8	
		0,	78,	66,	72,	71,	89,	54,	0,	0,	0,	77,	74,	85,	55,	56,	0,	-- 30
	--		,	K	I	O	0	9			.	/	L	;	P	-	
		0,	44,	75,	73,	79,	48,	57,	0,	0,	46,	47,	76,	59,	80,	45,	0,	-- 40
	--			'		[	=						]		\		
		0,	0,	39,	0,	91,	61,	0,	0,	0,	0,	0,	93,	0,	92,	0,	0,	-- 50
	--							BSP									
		0,	0,	0,	0,	0,	0,	08,	0,	0,	0,	0,	0,	0,	0,	0,	0,	-- 60
	--							ENT									
		0,	0,	0,	0,	0,	0,	13,	0,	0,	0,	0,	0,	0,	0,	0,	0,	-- 70
	--																
		0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	-- 80
	--																
		0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	-- 90
	--																
		0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	-- A0
	--																
		0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	-- B0
	--																
		0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	-- C0
	--																
		0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	-- D0
	--																
		0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	-- E0
	--																
		0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0	-- F0
	--	0	1	2	3	4	5	6	7	8	9	A	B	C	D	E	F
	);
	
	-- LCD/LED seven-segment display digits (0 through 0xF)
	constant SEVEN_SEG_DIGITS	: DigitROM(0 to 15) :=
	(
		"1110111", "0010010", "1011101", "1011011",	-- 0, 1, 2, 3,
		"0111010", "1101011", "1101111", "1010010",	-- 4, 5, 6, 7,
		"1111111", "1111011", "1111110", "0101111",	-- 8, 9, A, B,
		"1100101", "0011111", "1101101", "1101100"	-- C, D, E, F
	);
	
----------------------------------------------------------------------------------
	
	-- Functions
	-- Four-bit nibble to seven-bit binary-coded-hexadecimal
	-- (used to display to the LED digits on the board)
	function NibbleToHexDigit(nibble : unsigned(3 downto 0))
		return std_logic_vector;
	
----------------------------------------------------------------------------------
	
	-- Components
	-- One-bit toggle latch
	component Toggle1
	port
	(
		S_AL	: in	std_logic;	-- Value-toggle input (active-low)
		RESET	: in	std_logic;	-- Reset signal
		Q		: out	std_logic	-- Latched value
	);
	end component;
	
	-- Shift-register-buffered/synchonized toggle latch
	component ToggleD
	port
	(
		buttonRaw_AL	: in	std_logic;	-- Raw push-button input (active-low)
		clk				: in	std_logic;	-- Sampling/synchronization clock
		reset			: in	std_logic;	-- Reset
		bufferedRawOut	: out	std_logic;	-- Raw button input, after clock
											-- buffers and inverter
		Q				: out	std_logic	-- Synchronized toggle output value
	);
	end component;
	
	-- Generic n-bit register
	component GenericRegister is
	generic (NUM_BITS: natural := 16);	-- Defaults to 16 bits
	port
	(
		clk			: in	std_logic;	-- Clock
		writeEnable	: in	std_logic;	-- Input enable
		clear		: in	std_logic;	-- Clear (zeros register)
		D			: in	std_logic_vector((NUM_BITS - 1) downto 0);	-- Input
		Q			: out	std_logic_vector((NUM_BITS - 1) downto 0)	-- Output
	);
	end component;
	
	-- Generic n-bit eight-function ALU
	component GenericALU8A is
	generic (NUM_BITS: natural := 8);	-- Defaults to 8 bits
	port
	(
		A			: in	std_logic_vector((NUM_BITS - 1) downto 0);	-- Inputs
		B			: in	std_logic_vector((NUM_BITS - 1) downto 0);
		mode		: in	std_logic_vector(2 downto 0);	-- Mode selection bus
		output		: out	std_logic_vector((NUM_BITS - 1) downto 0);	-- Output
		overflow	: out	std_logic						-- Overflow flag
	);
	end component;
	
	-- Counter-based clock divider
	component CounterClockDivider
	generic
	(
		MAX_DIVISOR : natural := 5	-- Maximum allowed divisor value
	);
	port
	(
		clkIn	: in	std_logic;	-- Input (dividend) clock
		reset	: in	std_logic;	-- Reset
		divisor	: in	integer range 0 to MAX_DIVISOR;	-- Clock divisor value
		clkOut	: out	std_logic	-- Output (quotient) clock
	);
	end component;
	
	-- Three-digit decimal clock-edge counter
	component BCD3DigitCounter
	port
	(
		measureClk		: in	std_logic;	-- Measured clock
		measureEnable	: in	std_logic;	-- Measurement enable
		reset			: in	std_logic;	-- Reset
		
		-- Output digits (nibble with decimal value)
		digitOnes		: out	std_logic_vector(3 downto 0);
		digitTens		: out	std_logic_vector(3 downto 0);
		digitHundreds	: out	std_logic_vector(3 downto 0);
		
		-- Measurement overflow: high when all digits read '9'
		overflow		: out	std_logic
	);
	end component;
	
	-- PS/2-keyboard make-code reader
	component PS2MakeCodeReader
	port
	(
		-- Input clock from keyboard (active-low)
		ps2_clk_AL	: in	std_logic;
		
		-- Input (serial) data line from keyboard
		ps2_data	: in	std_logic;
		
		-- Main synchronization clock
		clk			: in	std_logic;
		
		-- Reset
		reset		: in	std_logic;
		
		-- Read-complete (i.e., "new keycode latched") flag
		newcode		: out	std_logic;
		
		-- One-byte keycode output
		keycode		: out	std_logic_vector(7 downto 0)
	);
	end component;
	
	-- SDRAM incrementing-address write-controller
	component RAMWriteController
	port
	(
		-- Synchronized clock from SDRAM controller
		clk				: in	std_logic;
		
		-- Reset (sets next write index to 0)
		reset			: in	std_logic;
		
		-- Pull high to trigger a write
		startWrite		: in	std_logic;
		
		-- Request-write signal to SDRAM controller
		writeRequest	: out	std_logic;
		
		-- Address at which to make the next write
		writeAddress	: out	std_logic_vector(23 downto 0);
		
		-- Write-complete signal, from DRAM controller
		writeDone		: in	std_logic
	);
	end component;
	
	-- 250kHz-range second-order phase-locked loop
	component PhaseLockedLoop250kHz
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
	end component;
	
end package AHeinzDeclares;

package body AHeinzDeclares is

	-- Function definitions
	function NibbleToHexDigit(nibble : unsigned(3 downto 0))
		return std_logic_vector
	is
		-- No internal variables/constants
	begin
		
		-- Convert input nibble to index in lookup table, return the
		-- appropriate seven-segment representation (stored in ROM)
		return SEVEN_SEG_DIGITS(TO_INTEGER(nibble));
		
	end NibbleToHexDigit;
	
end package body AHeinzDeclares;
