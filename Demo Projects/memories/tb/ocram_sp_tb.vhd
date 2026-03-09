library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ocram_sp_tb is
end entity;

architecture test of ocram_sp_tb is
    constant A_BITS   : positive := 4;
    constant D_BITS   : positive := 8;
    constant FILENAME : string   := "ram_init.mem";
    
    signal clk : std_logic := '0';
    signal ce  : std_logic := '1';
    signal we  : std_logic := '0';
    signal a   : unsigned(A_BITS-1 downto 0) := (others => '0');
    signal d   : std_logic_vector(D_BITS-1 downto 0) := (others => '0');
    signal q   : std_logic_vector(D_BITS-1 downto 0);
    
    constant CLK_PERIOD : time := 10 ns;
begin

    uut: entity work.ocram_sp
        generic map (
            A_BITS   => A_BITS,
            D_BITS   => D_BITS,
            FILENAME => FILENAME
        )
        port map (
            clk => clk,
            ce  => ce,
            we  => we,
            a   => a,
            d   => d,
            q   => q
        );

    clk_process : process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;

    stim_proc : process
    begin
        wait for 20 ns;
        
        -- Test file initialization (read index 1)
        wait until rising_edge(clk);
        a <= to_unsigned(1, A_BITS);
        we <= '0';
        wait for CLK_PERIOD;
        assert (q = x"11") report "Init read failed at address 1!" severity error;
        
        -- Test write operation
        wait until rising_edge(clk);
        a <= to_unsigned(2, A_BITS);
        d <= x"AA";
        we <= '1';
        
        -- Synchronous Write-First check
        wait for CLK_PERIOD;
        assert (q = x"AA") report "Write-First behavior failed!" severity error;
        
        wait until rising_edge(clk);
        a <= to_unsigned(2, A_BITS);
        we <= '0';
        
        wait for CLK_PERIOD;
        assert (q = x"AA") report "Subsequent read failed!" severity error;
        
        report "ocram_sp: All tests passed" severity note;
        wait;
    end process;
end architecture;
