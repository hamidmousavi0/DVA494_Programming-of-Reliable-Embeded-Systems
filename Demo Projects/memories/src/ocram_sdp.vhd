--
-- Entity:          ocram_sdp
--
-- Description:
-- -------------------------------------
-- Simple Dual-Port On-Chip RAM (Block RAM).
-- 
-- * Dedicated Read Port (rclk, ra, q).
-- * Dedicated Write Port (wclk, wa, d, we).
-- * Supports initialization from a text file.
--
-- =============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity ocram_sdp is
    generic (
        A_BITS   : positive;                         -- number of address bits
        D_BITS   : positive;                         -- number of data bits
        FILENAME : string    := ""                   -- file-name for RAM initialization
    );
    port (
        rclk : in  std_logic;                        -- read clock
        rce  : in  std_logic;                        -- read clock-enable
        wclk : in  std_logic;                        -- write clock
        wce  : in  std_logic;                        -- write clock-enable
        we   : in  std_logic;                        -- write enable
        ra   : in  unsigned(A_BITS-1 downto 0);      -- read address
        wa   : in  unsigned(A_BITS-1 downto 0);      -- write address
        d    : in  std_logic_vector(D_BITS-1 downto 0); -- write data
        q    : out std_logic_vector(D_BITS-1 downto 0)  -- read data
    );
end entity ocram_sdp;

architecture rtl of ocram_sdp is

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

    -- Write process
    process(wclk)
    begin
        if rising_edge(wclk) then
            if wce = '1' then
                if we = '1' then
                    ram(to_integer(wa)) <= d;
                end if;
            end if;
        end if;
    end process;

    -- Read process
    process(rclk)
    begin
        if rising_edge(rclk) then
            if rce = '1' then
                q <= ram(to_integer(ra));
            end if;
        end if;
    end process;

end architecture rtl;
