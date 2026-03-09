----------------------------------------------------------------------------------
-- Description: 
--    A professional, parameterized template for a LUT-based (Distributed) ROM.
--    This implementation uses asynchronous (combinational) read.
--    Xilinx synthesis attributes explicitly direct the tool to implement 
--    the memory using LUTs rather than Block RAM (BRAM).
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity lut_rom is
    generic (
        ADDR_WIDTH : integer := 3;  -- 2^ADDR_WIDTH = number of words in ROM
        DATA_WIDTH : integer := 12  -- Number of bits per ROM word
    );
    port (
        addr : in  std_logic_vector(ADDR_WIDTH - 1 downto 0);
        dout : out std_logic_vector(DATA_WIDTH - 1 downto 0)
    );
end lut_rom;

architecture Behavioral of lut_rom is

    -- 1. Define the ROM array type
    type rom_type is array (0 to (2**ADDR_WIDTH) - 1) of std_logic_vector(DATA_WIDTH - 1 downto 0);

    -- 2. Define the ROM content constants
    constant ROM_ARRAY : rom_type := (
        0 => "000011000100",
        1 => "010011010010",
        2 => "010011011011",
        3 => "011011000010",
        4 => "000011110001",
        5 => "011111010110",
        6 => "010011010000",
        7 => "111110011111"
    );

    -- 3. Synthesis Directives (Xilinx specific)
    -- The "rom_style" attribute instructs the synthesis tool on how to infer the ROM.
    -- "distributed" forces LUTs, preventing Block RAM inference.
    attribute rom_style : string;
    attribute rom_style of ROM_ARRAY : constant is "distributed";

begin

    -- 4. Asynchronous Read Logic
    -- Without a clock, the output immediately follows the input address.
    dout <= ROM_ARRAY(to_integer(unsigned(addr)));

end Behavioral;
