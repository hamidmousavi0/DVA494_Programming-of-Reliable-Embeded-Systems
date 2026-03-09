library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ocram_tdp_tb is
end entity;

architecture test of ocram_tdp_tb is
    constant A_BITS   : positive := 4;
    constant D_BITS   : positive := 8;
    constant FILENAME : string   := "ram_init.mem";
    
    signal clk1 : std_logic := '0';
    signal ce1  : std_logic := '1';
    signal we1  : std_logic := '0';
    signal a1   : unsigned(A_BITS-1 downto 0) := (others => '0');
    signal d1   : std_logic_vector(D_BITS-1 downto 0) := (others => '0');
    signal q1   : std_logic_vector(D_BITS-1 downto 0);
    
    signal clk2 : std_logic := '0';
    signal ce2  : std_logic := '1';
    signal we2  : std_logic := '0';
    signal a2   : unsigned(A_BITS-1 downto 0) := (others => '0');
    signal d2   : std_logic_vector(D_BITS-1 downto 0) := (others => '0');
    signal q2   : std_logic_vector(D_BITS-1 downto 0);
    
    constant CLK_PERIOD : time := 10 ns;
begin

    uut: entity work.ocram_tdp
        generic map (
            A_BITS   => A_BITS,
            D_BITS   => D_BITS,
            FILENAME => FILENAME
        )
        port map (
            clk1 => clk1,
            ce1  => ce1,
            we1  => we1,
            a1   => a1,
            d1   => d1,
            q1   => q1,
            clk2 => clk2,
            ce2  => ce2,
            we2  => we2,
            a2   => a2,
            d2   => d2,
            q2   => q2
        );

    -- Clock generation
    clk1_process : process
    begin
        clk1 <= '0'; wait for CLK_PERIOD/2;
        clk1 <= '1'; wait for CLK_PERIOD/2;
    end process;
    
    clk2_process : process
    begin
        clk2 <= '0'; wait for CLK_PERIOD/2;
        clk2 <= '1'; wait for CLK_PERIOD/2;
    end process;

    stim_proc : process
    begin
        wait for 20 ns;
        
        -- Test file initialization (read index 15 on Port 1, read index 7 on Port 2)
        wait until rising_edge(clk1);
        a1 <= to_unsigned(15, A_BITS);
        a2 <= to_unsigned(7, A_BITS);
        
        wait for CLK_PERIOD;
        assert (q1 = x"FF") report "Port 1 Init read failed!" severity error;
        assert (q2 = x"77") report "Port 2 Init read failed!" severity error;
        
        -- Write on Port 1, Read on Port 2
        wait until rising_edge(clk1);
        a1 <= to_unsigned(4, A_BITS);
        d1 <= x"D4";
        we1 <= '1';
        
        wait until rising_edge(clk1);
        we1 <= '0';
        a2 <= to_unsigned(4, A_BITS);  -- read on port 2
        
        wait for CLK_PERIOD;
        assert (q2 = x"D4") report "TDP Write Port 1 / Read Port 2 failed!" severity error;
        
        -- Write on Port 2, Read on Port 1
        wait until rising_edge(clk2);
        a2 <= to_unsigned(8, A_BITS);
        d2 <= x"4D";
        we2 <= '1';
        
        wait until rising_edge(clk2);
        we2 <= '0';
        a1 <= to_unsigned(8, A_BITS);  -- read on port 1
        
        wait for CLK_PERIOD;
        assert (q1 = x"4D") report "TDP Write Port 2 / Read Port 1 failed!" severity error;
        
        report "ocram_tdp: All tests passed" severity note;
        wait;
    end process;
end architecture;
