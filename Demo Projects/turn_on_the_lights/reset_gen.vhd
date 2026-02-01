library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity reset_gen is
    generic(
        clk_freq : INTEGER := 100_000_000; -- in Hz
        delay_time : INTEGER := 10 );      -- in ms
    Port (
        clk: in std_logic;
        reset_n: out std_logic );
end reset_gen;

architecture Behavioral of reset_gen is
    signal temp : std_logic := '0';
begin
    process(clk)
        variable count : integer range 0 to delay_time*clk_freq/1000;
    begin
        if(clk'event and clk='1') then
            if (count < clk_freq*delay_time/1000)then
                count := count + 1;
            else
                count := 0;
                temp <= '1';
             end if;
        end if;
    end process;
    reset_n <= temp;

end Behavioral;
