--
-- Entity:          ocram_sp
--
-- Description:
-- -------------------------------------
-- Single-Port On-Chip RAM (Block RAM).
-- 
-- * Inferrable as Block RAM (BRAM).
-- * Single clock domain.
-- * Write-First (New Data) behavior mapped natively during synthesis.
-- * Supports initialization from a text file.
--
--
-- =============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity ocram_sp is
    generic (
        A_BITS   : positive;                         -- number of address bits
        D_BITS   : positive;                         -- number of data bits
        FILENAME : string    := ""                   -- file-name for RAM initialization
    );
    port (
        clk : in  std_logic;                         -- clock
        ce  : in  std_logic;                         -- clock enable
        we  : in  std_logic;                         -- write enable
        a   : in  unsigned(A_BITS-1 downto 0);       -- address
        d   : in  std_logic_vector(D_BITS-1 downto 0);-- write data
        q   : out std_logic_vector(D_BITS-1 downto 0)-- read output
    );
end entity ocram_sp;

architecture rtl of ocram_sp is

    type ram_type is array (0 to (2**A_BITS)-1) of std_logic_vector(D_BITS-1 downto 0);

    impure function init_ram_from_file(ram_filename : string) return ram_type is
        file ram_file       : text;
        variable ram_line   : line;
        variable ram_content: ram_type;
        variable bit_vec    : bit_vector(D_BITS-1 downto 0);
    begin
        if ram_filename = "" then
            return (others => (others => '0'));
        end if;

        file_open(ram_file, ram_filename, read_mode);
        for i in 0 to (2**A_BITS)-1 loop
            if not endfile(ram_file) then
                readline(ram_file, ram_line);
                read(ram_line, bit_vec);
                ram_content(i) := to_stdlogicvector(bit_vec);
            else
                ram_content(i) := (others => '0');
            end if;
        end loop;
        file_close(ram_file);
        return ram_content;
    end function;

    signal ram : ram_type := init_ram_from_file(FILENAME);

begin

    process(clk)
    begin
        if rising_edge(clk) then
            if ce = '1' then
                if we = '1' then
                    ram(to_integer(a)) <= d;
                    q <= d;
                else
                    q <= ram(to_integer(a));
                end if;
            end if;
        end if;
    end process;

end architecture rtl;
