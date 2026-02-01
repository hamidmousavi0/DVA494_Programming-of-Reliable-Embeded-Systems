library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-------------------------------------------------------------------------------
-- io_debounce (standalone)
-- Multi-bit debouncer with optional 2-FF input synchronizers.
-- Based on PoC io_Debounce, rewritten without external dependencies.
-------------------------------------------------------------------------------
entity io_debounce is
    generic (
        CLK_FREQ_HZ    : integer  := 100_000_000; -- Clock frequency in Hz
        BOUNCE_TIME_MS : integer  := 20;          -- Debounce window in ms
        BITS           : positive := 1;           -- Number of input bits
        ADD_SYNC       : boolean  := true         -- Add 2-FF synchronizers?
    );
    port (
        clk    : in  std_logic;
        reset  : in  std_logic := '0';            -- Synchronous reset (active high)
        input  : in  std_logic_vector(BITS-1 downto 0);
        output : out std_logic_vector(BITS-1 downto 0)
    );
end io_debounce;

architecture rtl of io_debounce is

    ---------------------------------------------------------------------------
    -- Helper: compute bits needed to hold value N
    ---------------------------------------------------------------------------
    function log2ceil(n : positive) return natural is
        variable result : natural := 0;
        variable val    : natural := n - 1;
    begin
        while val > 0 loop
            val    := val / 2;
            result := result + 1;
        end loop;
        return result;
    end function;

    ---------------------------------------------------------------------------
    -- Constants
    ---------------------------------------------------------------------------
    constant LOCK_CYCLES : integer := (CLK_FREQ_HZ / 1000) * BOUNCE_TIME_MS;
    constant CNT_BITS    : natural := log2ceil(LOCK_CYCLES + 1);

    ---------------------------------------------------------------------------
    -- Signals
    ---------------------------------------------------------------------------
    -- Synchronizer flip-flops (if enabled)
    signal sync_0  : std_logic_vector(BITS-1 downto 0) := (others => '0');
    signal sync_1  : std_logic_vector(BITS-1 downto 0) := (others => '0');

    -- Synchronized (or raw) input
    signal synced  : std_logic_vector(BITS-1 downto 0);

    -- Previous synced value (for edge detection)
    signal prev    : std_logic_vector(BITS-1 downto 0) := (others => '0');

    -- Per-bit down-counters
    type counter_array is array (0 to BITS-1) of unsigned(CNT_BITS-1 downto 0);
    signal counters : counter_array := (others => (others => '0'));

    -- Registered output
    signal out_reg : std_logic_vector(BITS-1 downto 0) := (others => '0');

begin

    ---------------------------------------------------------------------------
    -- Optional 2-FF Synchronizer
    ---------------------------------------------------------------------------
    gen_sync: if ADD_SYNC generate
        process (clk)
        begin
            if rising_edge(clk) then
                sync_0 <= input;
                sync_1 <= sync_0;
            end if;
        end process;
        synced <= sync_1;
    end generate;

    gen_no_sync: if not ADD_SYNC generate
        synced <= input;
    end generate;

    ---------------------------------------------------------------------------
    -- Debounce Logic (one counter per bit)
    ---------------------------------------------------------------------------
    process (clk)
    begin
        if rising_edge(clk) then
            prev <= synced;

            for i in 0 to BITS-1 loop
                if reset = '1' then
                    counters(i) <= (others => '0');
                    out_reg(i)  <= synced(i);

                elsif synced(i) /= prev(i) then
                    -- Edge detected: reload counter
                    counters(i) <= to_unsigned(LOCK_CYCLES, CNT_BITS);

                elsif counters(i) /= 0 then
                    -- Counting down (input changing recently)
                    counters(i) <= counters(i) - 1;

                else
                    -- Counter expired: input stable, update output
                    out_reg(i) <= synced(i);
                end if;
            end loop;
        end if;
    end process;

    output <= out_reg;

end rtl;