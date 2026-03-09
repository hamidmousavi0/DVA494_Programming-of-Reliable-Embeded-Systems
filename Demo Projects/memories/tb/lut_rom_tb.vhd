----------------------------------------------------------------------------------
-- Description: 
--    Professional self-checking testbench for the lut_rom module.
--    Automatically iterates through all addresses and verifies the output
--    against an expected set of values using VHDL assertions.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity lut_rom_tb is
-- Testbench entity is empty
end lut_rom_tb;

architecture Behavioral of lut_rom_tb is

    -- Component Declaration for DUT
    component lut_rom
        generic (
            ADDR_WIDTH : integer := 3;
            DATA_WIDTH : integer := 12
        );
        port (
            addr : in  std_logic_vector(ADDR_WIDTH - 1 downto 0);
            dout : out std_logic_vector(DATA_WIDTH - 1 downto 0)
        );
    end component;

    -- Testbench Constants
    constant C_ADDR_WIDTH : integer := 3;
    constant C_DATA_WIDTH : integer := 12;
    constant C_DELAY      : time := 10 ns;

    -- Signals
    signal tb_addr : std_logic_vector(C_ADDR_WIDTH - 1 downto 0) := (others => '0');
    signal tb_dout : std_logic_vector(C_DATA_WIDTH - 1 downto 0);

    -- Expected ROM Data Type
    type expected_rom_type is array (0 to (2**C_ADDR_WIDTH) - 1) of std_logic_vector(C_DATA_WIDTH - 1 downto 0);
    
    -- Exact duplicate of expected data for checking
    constant EXPECTED_ROM : expected_rom_type := (
        0 => "000011000100",
        1 => "010011010010",
        2 => "010011011011",
        3 => "011011000010",
        4 => "000011110001",
        5 => "011111010110",
        6 => "010011010000",
        7 => "111110011111"
    );

begin

    -- DUT Instantiation
    DUT: lut_rom
        generic map (
            ADDR_WIDTH => C_ADDR_WIDTH,
            DATA_WIDTH => C_DATA_WIDTH
        )
        port map (
            addr => tb_addr,
            dout => tb_dout
        );

    -- Stimulus & Checking Process
    stim_proc: process
    begin
        report "--- Starting LUT ROM Simulation ---";

        -- Iterate through all addresses
        for i in 0 to (2**C_ADDR_WIDTH) - 1 loop
            
            -- Apply Address
            tb_addr <= std_logic_vector(to_unsigned(i, C_ADDR_WIDTH));
            
            -- Wait for combinational propagation
            wait for C_DELAY;
            
            -- Self-Checking Assertion
            assert (tb_dout = EXPECTED_ROM(i))
                report "Mismatch at address ! Expected: " & integer'image(to_integer(unsigned(EXPECTED_ROM(i)))) & " Got: " & integer'image(to_integer(unsigned(tb_dout)))
                severity error;
                
        end loop;

        report "--- LUT ROM Simulation Completed Successfully ---";
        wait;
    end process;

end Behavioral;