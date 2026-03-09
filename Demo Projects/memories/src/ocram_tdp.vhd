-- 
-- Entity:          ocram_tdp
--
-- Description:
-- -------------------------------------
-- True Dual-Port On-Chip RAM (Block RAM).
-- 
-- * Two fully independent Read/Write ports.
-- * Independent clocks, enables, write enables, addresses, data in, and data out.
-- * Synthesized efficiently via Xilinx recommended shared variable approach.
-- * Supports initialization from a text file.
--
-- =============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity ocram_tdp is
    generic (
        A_BITS   : positive;                         -- number of address bits
        D_BITS   : positive;                         -- number of data bits
        FILENAME : string    := ""                   -- file-name for RAM initialization
    );
    port (
        -- Port 1
        clk1 : in  std_logic;
        ce1  : in  std_logic;
        we1  : in  std_logic;
        a1   : in  unsigned(A_BITS-1 downto 0);
        d1   : in  std_logic_vector(D_BITS-1 downto 0);
        q1   : out std_logic_vector(D_BITS-1 downto 0);
        
        -- Port 2
        clk2 : in  std_logic;
        ce2  : in  std_logic;
        we2  : in  std_logic;
        a2   : in  unsigned(A_BITS-1 downto 0);
        d2   : in  std_logic_vector(D_BITS-1 downto 0);
        q2   : out std_logic_vector(D_BITS-1 downto 0)
    );
end entity ocram_tdp;

architecture rtl of ocram_tdp is

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

    shared variable ram : ram_type := init_ram_from_file(FILENAME);

begin

    -- Port 1 process
    process(clk1)
    begin
        if rising_edge(clk1) then
            if ce1 = '1' then
                if we1 = '1' then
                    ram(to_integer(a1)) := d1;
                end if;
                q1 <= ram(to_integer(a1));
            end if;
        end if;
    end process;

    -- Port 2 process
    process(clk2)
    begin
        if rising_edge(clk2) then
            if ce2 = '1' then
                if we2 = '1' then
                    ram(to_integer(a2)) := d2;
                end if;
                q2 <= ram(to_integer(a2));
            end if;
        end if;
    end process;

end architecture rtl;
