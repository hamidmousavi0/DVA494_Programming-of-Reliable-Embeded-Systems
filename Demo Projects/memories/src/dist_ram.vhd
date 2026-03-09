-- Single-Port RAM with Asynchronous Read (Distributed RAM)
-- File: dist_ram.vhd
-- Reference: Xilinx UG901 (Vivado Synthesis)

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dist_ram is
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
end dist_ram;

architecture syn of dist_ram is
    type ram_type is array ((2**A_WIDTH)-1 downto 0) of std_logic_vector(D_WIDTH-1 downto 0);
    signal RAM : ram_type;
    
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if (we = '1') then
                RAM(to_integer(unsigned(a))) <= di;
            end if;
        end if;
    end process;

    -- Asynchronous read
    do <= RAM(to_integer(unsigned(a)));
end syn;
