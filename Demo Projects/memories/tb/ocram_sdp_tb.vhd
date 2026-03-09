library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ocram_sdp_tb is
end entity;

architecture test of ocram_sdp_tb is
    constant A_BITS   : positive := 4;
    constant D_BITS   : positive := 8;
    constant FILENAME : string   := "ram_init.mem";
    
    signal rclk : std_logic := '0';
    signal rce  : std_logic := '1';
    signal wclk : std_logic := '0';
    signal wce  : std_logic := '1';
    signal we   : std_logic := '0';
    signal ra   : unsigned(A_BITS-1 downto 0) := (others => '0');
    signal wa   : unsigned(A_BITS-1 downto 0) := (others => '0');
    signal d    : std_logic_vector(D_BITS-1 downto 0) := (others => '0');
    signal q    : std_logic_vector(D_BITS-1 downto 0);
    
    constant CLK_PERIOD : time := 10 ns;
begin

    uut: entity work.ocram_sdp
        generic map (
            A_BITS   => A_BITS,
            D_BITS   => D_BITS,
            FILENAME => FILENAME
        )
        port map (
            rclk => rclk,
            rce  => rce,
            wclk => wclk,
            wce  => wce,
            we   => we,
            ra   => ra,
            wa   => wa,
            d    => d,
            q    => q
        );

    -- Common clock simulation for this TB (can be decoupled in real use)
    clk_process : process
    begin
        rclk <= '0';
        wclk <= '0';
        wait for CLK_PERIOD/2;
        rclk <= '1';
        wclk <= '1';
        wait for CLK_PERIOD/2;
    end process;

    stim_proc : process
    begin
        wait for 20 ns;
        
        -- Test file initialization (read index 3)
        wait until rising_edge(rclk);
        ra <= to_unsigned(3, A_BITS);
        wait for CLK_PERIOD;
        assert (q = x"33") report "Init read failed at address 3!" severity error;
        
        -- Test write operation on port W, read on port R
        wait until rising_edge(wclk);
        wa <= to_unsigned(5, A_BITS);
        d <= x"BC";
        we <= '1';
        
        wait until rising_edge(wclk);
        we <= '0';
        ra <= to_unsigned(5, A_BITS);
        
        wait for CLK_PERIOD;
        assert (q = x"BC") report "SDP Write/Read failed!" severity error;
        
        report "ocram_sdp: All tests passed" severity note;
        wait;
    end process;
end architecture;
