library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-------------------------------------------------------------------------------
-- btn_debouncer
-- A simple, single-bit button debouncer with 2-FF synchronizer.
-- Active-low asynchronous reset.
-------------------------------------------------------------------------------
entity btn_debouncer is
    generic (
        CLK_FREQ    : integer := 100_000_000;  -- Clock frequency in Hz
        STABLE_TIME : integer := 10            -- Required stable time in ms
    );
    port (
        clk     : in  std_logic;  -- System clock
        reset_n : in  std_logic;  -- Asynchronous active-low reset
        button  : in  std_logic;  -- Raw button input
        result  : out std_logic   -- Debounced output
    );
end btn_debouncer;

architecture Behavioral of btn_debouncer is
    -- Pre-compute counter limit to avoid large runtime multiply
    constant COUNT_MAX : integer := (CLK_FREQ / 1000) * STABLE_TIME;

    signal sync_ff   : std_logic_vector(1 downto 0) := (others => '0'); -- 2-FF synchronizer
    signal counter   : integer range 0 to COUNT_MAX := 0;
    signal debounced : std_logic := '0';  -- Registered output
begin

    result <= debounced;

    process (clk, reset_n)
    begin
        if reset_n = '0' then
            sync_ff   <= (others => '0');
            counter   <= 0;
            debounced <= '0';

        elsif rising_edge(clk) then
            -- Shift through 2-FF synchronizer
            sync_ff(0) <= button;
            sync_ff(1) <= sync_ff(0);

            -- Edge detected -> restart counter
            if sync_ff(0) /= sync_ff(1) then
                counter <= 0;
            elsif counter < COUNT_MAX then
                counter <= counter + 1;
            else
                -- Stable: update output
                debounced <= sync_ff(1);
            end if;
        end if;
    end process;

end Behavioral;
