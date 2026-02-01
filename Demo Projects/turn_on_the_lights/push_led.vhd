library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity push_led is
    Port (
    btnC : in std_logic;
    clk: in std_logic;
    led: out std_logic_vector(15 downto 0)
    );
end push_led;

architecture Behavioral of push_led is
    -- signals
    signal reset, btn_state: std_logic;
    signal led_state: std_logic := '0';
    signal btn_state_prev:  std_logic := '0';
begin
    --instatiate components
    reset_generator: entity work.reset_gen
        port map(
        clk => clk,
        reset_n => reset); 
    btn_debounce: entity work.btn_debouncer
        port map(
        clk => clk,
        reset_n => reset,
        button => btnC,
        result => btn_state
        );
        
     -- check the button state on every rising edge of clk.
     toggle_process: process(clk)
     begin
        if rising_edge(clk) then
            if (btn_state = '1') and (btn_state_prev = '0') then
                led_state <= not led_state;
            end if;
            -- Update the stored previous value
            btn_state_prev <= btn_state;
        end if;
       end process;
    led <= (others => led_state);

end Behavioral;
