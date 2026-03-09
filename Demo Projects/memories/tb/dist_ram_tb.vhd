library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dist_ram_tb is
end dist_ram_tb;

architecture behavior of dist_ram_tb is

    -- Component Declaration for the Unit Under Test (UUT)
    component dist_ram
    generic (
        D_WIDTH : integer := 16;
        A_WIDTH : integer := 6
    );
    port(
        clk : in std_logic;
        we  : in std_logic;
        a   : in std_logic_vector(A_WIDTH-1 downto 0);
        di  : in std_logic_vector(D_WIDTH-1 downto 0);
        do  : out std_logic_vector(D_WIDTH-1 downto 0)
    );
    end component;

    --Inputs
    signal clk : std_logic := '0';
    signal we  : std_logic := '0';
    signal a   : std_logic_vector(5 downto 0) := (others => '0');
    signal di  : std_logic_vector(15 downto 0) := (others => '0');

    --Outputs
    signal do  : std_logic_vector(15 downto 0);

    -- Clock period definitions
    constant clk_period : time := 10 ns;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: dist_ram 
    generic map (
        D_WIDTH => 16,
        A_WIDTH => 6
    )
    port map (
        clk => clk,
        we  => we,
        a   => a,
        di  => di,
        do  => do
    );

    -- Clock process definitions
    clk_process :process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Stimulus process
    stim_proc: process
    begin		
        -- hold reset state for 100 ns.
        wait for 100 ns;	

        -- 1. Write Data to RAM
        wait until rising_edge(clk);
        we <= '1';
        a <= std_logic_vector(to_unsigned(5, 6));
        di <= x"AAAA";

        wait until rising_edge(clk);
        we <= '1';
        a <= std_logic_vector(to_unsigned(10, 6));
        di <= x"5555";

        -- 2. Synchronous Read Checks
        wait until rising_edge(clk);
        we <= '0';
        a <= std_logic_vector(to_unsigned(5, 6));
        
        wait for clk_period;
        assert (do = x"AAAA") report "Read failure at address 5" severity error;

        a <= std_logic_vector(to_unsigned(10, 6));
        wait for clk_period;
        assert (do = x"5555") report "Read failure at address 10" severity error;

        -- 3. Asynchronous Read Check (Changing address without clock edge)
        wait for clk_period/4;
        a <= std_logic_vector(to_unsigned(5, 6));
        wait for 1 ns; -- wait for combinational propagation
        assert (do = x"AAAA") report "Asynchronous read failure at address 5" severity error;

        wait for clk_period;
        report "All simulation tests passed for dist_ram!" severity note;
        wait;
    end process;

end behavior;
