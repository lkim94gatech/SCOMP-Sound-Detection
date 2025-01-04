-- AudioMonitor.vhd
-- Created 2023
--
-- This SCOMP peripheral passes data from an input bus to SCOMP's I/O bus.

library IEEE;
library lpm;

use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use lpm.lpm_components.all;

entity AudioMonitor is
port(
    CS          : in  std_logic;
    IO_WRITE    : in  std_logic;
    SYS_CLK     : in  std_logic;  -- SCOMP's clock
    RESETN      : in  std_logic;
    AUD_DATA    : in  std_logic_vector(15 downto 0);
    AUD_NEW     : in  std_logic;
    IO_DATA     : inout  std_logic_vector(15 downto 0)
);
end AudioMonitor;

architecture a of AudioMonitor is

    signal out_en      : std_logic;
    signal parsed_data : std_logic_vector(15 downto 0);
	 -- 0: Reset, 1: Count, 2: ? , 3: ? ...
	 signal input_data  : std_logic_vector(15 downto 0);
	 signal temp_data   : std_logic_vector(15 downto 0);
	 signal count_data  : std_logic_vector(15 downto 0);
	 signal count_temp  : std_logic_vector(15 downto 0);
	 
	 signal magnitude_data  : std_logic_vector(15 downto 0);
	 signal magnitude_temp  : std_logic_vector(15 downto 0);
	 
	 signal timer_data  : std_logic_vector(15 downto 0);
	 signal timer_started : std_logic;
    signal output_data : std_logic_vector(15 downto 0);
	 
	 signal slow_clk    : std_logic;
	 --signal second_clk    : std_logic;
	 --signal check_slw_count : std_logic_vector(15 downto 0);
	 signal clock_count : std_logic_vector(31 downto 0);
	 --signal s_clock_count : std_logic_vector(31 downto 0);

begin

	-- Use LPM function to create bidirection I/O data bus
	IO_BUS: lpm_bustri
	GENERIC MAP (
		lpm_width => 16
	)
	PORT MAP (
		data     => output_data,
		enabledt => out_en,
		tridata  => IO_DATA
	);

    -- Latch data on rising edge of CS to keep it stable during IN
    process (CS, RESETN) begin
        if rising_edge(CS) then
            output_data <= temp_data;
        end if;
	 end process;

	 -- WHEN CS is rising and IO_WRITE, input_data = IO_DATA
	 -- input_data - 0: Reset, 1: Count, 2: ? , 3: ? ... 
    process (RESETN, CS, SYS_CLK)
    begin	
		  if (RESETN = '0') then
            input_data <= x"1000";
		  elsif rising_edge(CS) AND (IO_WRITE = '1')then
		      input_data <= IO_DATA;
				
		  end if;
    end process;
	 
	 
    -- Drive IO_DATA when needed.
    out_en <= CS AND ( NOT IO_WRITE );
    with out_en select IO_DATA <=
        output_data        when '1',
        "ZZZZZZZZZZZZZZZZ" when others;

    -- This template device just copies the input data
    -- to IO_DATA by latching the data every time a new
    -- value is ready.
    process (RESETN, SYS_CLK)
    begin
        if (RESETN = '0' OR input_data = x"0000") then
            parsed_data <= x"0000";
        elsif (rising_edge(AUD_NEW)) then
            parsed_data <= AUD_DATA;
        end if;
	 end process;

    -- Implements Count Functionality	 
    -- Gets count of "Loud Sound" by using a slow clock and Sound Range of [-8192] ** MAY NEED TO CHANGE RANGE

    process (RESETN, SYS_CLK)
    begin
        if (RESETN = '0') then
            count_data <= x"0000";
            count_temp <= x"0000";
            magnitude_data <= x"0000";
            timer_data <= x"0000";
            timer_started <= '0';
        elsif rising_edge(SYS_CLK) then
            if (input_data = x"0000") then
					count_data <= x"0000";
					count_temp <= x"0000";
					magnitude_data <= x"0000";
					timer_data <= x"0000";
					timer_started <= '0';
			   else
					if (parsed_data < x"8000" AND parsed_data >= x"1800") then
						count_temp <= count_temp + 1;
					end if;

					if slow_clk = '1' AND count_temp > 0 then
						count_data <= count_data + 1;
						count_temp <= x"0000";
					end if;

					if (parsed_data < x"8000" AND parsed_data >= x"1800") AND (magnitude_temp < parsed_data) then
						magnitude_temp <= parsed_data;
					end if;
					
					if slow_clk = '1' AND magnitude_temp > magnitude_data then
						magnitude_data <= magnitude_temp;
						magnitude_temp <= x"0000";
					end if;					

					if (slow_clk = '1' AND count_temp > 0  AND timer_started = '0') then
						timer_started <= '1';
						timer_data <= x"0000";
					elsif (slow_clk = '1' AND count_temp > 0  AND timer_started = '1') then
						timer_started <= '0';
					end if;

					--if (timer_started = '1' AND second_clk = '1') then
					if (timer_started = '1' AND slow_clk = '1') then
						timer_data <= timer_data + 1;
					end if;
			end if;
		end if;
	  end process;

	 	 

	 --If peripheral is RECIEVING DATA, change what is on temp_data depending on IO_DATA
	 process (RESETN, SYS_CLK)
	 begin
	     if (RESETN = '0' OR input_data = x"0000") then
            temp_data <= x"0000";
		  elsif IO_WRITE = '1' AND input_data = x"0001" then
		      temp_data <= count_data;
				--temp_data <= check_slw_count;
			elsif IO_WRITE = '1' AND input_data = x"0002" then
		      temp_data <= magnitude_data;
			elsif IO_WRITE = '1' AND input_data = x"0003" then
		      temp_data <= timer_data;
		  end if;
	 end process;
	 
	 --Adds 1 every system clock, used for calculating slow_clk
	 process (RESETN, SYS_CLK)
	 begin
		  -- 15000000 * 8.3333333333333*10^-8 = 1.25s
	     if (RESETN = '0' OR input_data = x"0000") then
		  --if (RESETN = '0' OR input_data = x"0000") then
            clock_count <= x"00000000";
				--s_clock_count <= x"00000000";
				--check_slw_count <= x"0000";
				slow_clk <= '0';
				--second_clk <= '0';
		  elsif rising_edge(SYS_CLK) then
		      --if clock_count < x"00E4E1C0" then
				if clock_count < x"00B71B00" then
		          clock_count <= clock_count + 1;
				    slow_clk <= '0';
			   elsif clock_count = x"00B71B00" then
				    clock_count <= x"00000000";
					 slow_clk <= '1';
					 --check_slw_count <= check_slw_count + 1;
			   else
				    slow_clk <= '0';
				end if;

		      --if s_clock_count < x"00B71B00" then
		          --s_clock_count <= s_clock_count + 1;
				    --second_clk <= '0';
			   --elsif s_clock_count = x"00B71B00" then
				    --s_clock_count <= x"00000000";
					 --second_clk <= '1';
			   --else
				    --second_clk <= '0';
				--end if;				
		  end if;
	 end process;	 
end a;