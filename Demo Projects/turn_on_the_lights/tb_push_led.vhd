library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity push_led_tb is
--  Port ( );
end push_led_tb;

architecture Behavioral of push_led_tb is
   --Inputs
   signal clk : std_logic := '0';
   signal reset_n : std_logic := '0';
   signal button_in : std_logic := '0';
   --Outputs
   signal led : std_logic_vector(15 downto 0);
   
   -- Clock period definitions
   constant clock_period : time := 10ns; --20ns=50 000 000Hz
begin
    dut: entity work.push_led 
        port map(btnC => button_in,
                clk => clk,
                led => led);
    
    -- Clock process definitions
   Clock_process :process
   begin
        clk <= '0';
        wait for clock_period/2;
        clk <= '1';
        wait for clock_period/2;
   end process;
   
   -- Stimulus process
   stim_proc: process
   begin        
        button_in <= '0';
      -- wait for reset generator
      wait for 10 ms;
        --first activity
        button_in <= '1';   wait for 2ms;
        button_in <= '0';   wait for 3ms;
        button_in <= '1';   wait for 1ms;
        button_in <= '0';   wait for 5ms;
        --second activity
        button_in <= '1';   wait for 1ms;
        button_in <= '0';   wait for 1ms;
        button_in <= '1';   wait for 15 ms;
        button_in <= '0';   wait for 2ms;
        button_in <= '1';   wait for 1ms;
        button_in <= '0';   
      wait;
   end process;
end Behavioral;
