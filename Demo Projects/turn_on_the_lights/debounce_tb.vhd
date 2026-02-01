library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-------------------------------------------------------------------------------
-- debounce_tb
-- Professional testbench for btn_debouncer with automated verification.
-- Features:
--   - Self-checking assertions
--   - Pass/fail summary
--   - Multiple test scenarios (bounce filtering, stable propagation, reset)
--   - Configurable parameters matching DUT
-------------------------------------------------------------------------------
entity debounce_tb is
end debounce_tb;

architecture Behavioral of debounce_tb is

    ---------------------------------------------------------------------------
    -- DUT Configuration (must match btn_debouncer generics)
    ---------------------------------------------------------------------------
    constant CLK_FREQ    : integer := 100_000_000;  -- 100 MHz
    constant STABLE_TIME : integer := 10;           -- 10 ms debounce window
    constant CLK_PERIOD  : time    := 10 ns;        -- 100 MHz clock

    -- Derived timing constants
    constant DEBOUNCE_TIME : time := STABLE_TIME * 1 ms;
    constant MARGIN        : time := 100 us;  -- timing tolerance

    ---------------------------------------------------------------------------
    -- Signals
    ---------------------------------------------------------------------------
    signal clk       : std_logic := '0';
    signal reset_n   : std_logic := '0';
    signal button_in : std_logic := '0';
    signal result    : std_logic;

    -- Test control
    signal sim_done  : boolean := false;

    -- Statistics
    shared variable test_count  : integer := 0;
    shared variable pass_count  : integer := 0;
    shared variable fail_count  : integer := 0;

    ---------------------------------------------------------------------------
    -- Procedures for cleaner test code
    ---------------------------------------------------------------------------

    -- Log a message with simulation time
    procedure log(msg : string) is
    begin
        report "[" & time'image(now) & "] " & msg severity note;
    end procedure;

    -- Check condition and update statistics
    procedure check(
        condition : boolean;
        test_name : string;
        fail_msg  : string := ""
    ) is
    begin
        test_count := test_count + 1;
        if condition then
            pass_count := pass_count + 1;
            log("PASS: " & test_name);
        else
            fail_count := fail_count + 1;
            if fail_msg = "" then
                report "FAIL: " & test_name severity error;
            else
                report "FAIL: " & test_name & " - " & fail_msg severity error;
            end if;
        end if;
    end procedure;

    -- Generate bouncy button press (simulates mechanical contact bounce)
    procedure bounce_press(
        signal btn    : out std_logic;
        bounce_count  : integer;
        bounce_period : time
    ) is
    begin
        for i in 1 to bounce_count loop
            btn <= '1'; wait for bounce_period / 2;
            btn <= '0'; wait for bounce_period / 2;
        end loop;
        btn <= '1';  -- settle high
    end procedure;

    -- Generate bouncy button release
    procedure bounce_release(
        signal btn    : out std_logic;
        bounce_count  : integer;
        bounce_period : time
    ) is
    begin
        for i in 1 to bounce_count loop
            btn <= '0'; wait for bounce_period / 2;
            btn <= '1'; wait for bounce_period / 2;
        end loop;
        btn <= '0';  -- settle low
    end procedure;

begin

    ---------------------------------------------------------------------------
    -- DUT Instantiation
    ---------------------------------------------------------------------------
    dut: entity work.btn_debouncer
        generic map (
            CLK_FREQ    => CLK_FREQ,
            STABLE_TIME => STABLE_TIME
        )
        port map (
            clk     => clk,
            reset_n => reset_n,
            button  => button_in,
            result  => result
        );

    ---------------------------------------------------------------------------
    -- Clock Generation
    ---------------------------------------------------------------------------
    clk_proc: process
    begin
        while not sim_done loop
            clk <= '0'; wait for CLK_PERIOD / 2;
            clk <= '1'; wait for CLK_PERIOD / 2;
        end loop;
        wait;
    end process;

    ---------------------------------------------------------------------------
    -- Main Test Sequence
    ---------------------------------------------------------------------------
    stim_proc: process
        variable start_time : time;
    begin
        log("========================================");
        log("Testbench started: btn_debouncer");
        log("CLK_FREQ=" & integer'image(CLK_FREQ) & " Hz, STABLE_TIME=" & integer'image(STABLE_TIME) & " ms");
        log("========================================");

        -----------------------------------------------------------------------
        -- TEST 1: Reset behavior
        -----------------------------------------------------------------------
        log("TEST 1: Reset behavior");
        button_in <= '1';
        reset_n   <= '0';
        wait for CLK_PERIOD * 10;
        check(result = '0', "Output low during reset");

        reset_n <= '1';
        wait for CLK_PERIOD * 5;
        check(result = '0', "Output stays low after reset release (input not yet stable)");

        button_in <= '0';
        wait for CLK_PERIOD * 10;

        -----------------------------------------------------------------------
        -- TEST 2: Short glitch rejection
        -----------------------------------------------------------------------
        log("TEST 2: Short glitch rejection (should be filtered)");
        button_in <= '0';
        wait for DEBOUNCE_TIME + MARGIN;  -- ensure output is 0

        -- Apply short pulse (< debounce time) - should be ignored
        button_in <= '1';
        wait for DEBOUNCE_TIME / 2;
        button_in <= '0';
        wait for DEBOUNCE_TIME + MARGIN;

        check(result = '0', "Short glitch filtered out");

        -----------------------------------------------------------------------
        -- TEST 3: Stable high propagation
        -----------------------------------------------------------------------
        log("TEST 3: Stable HIGH propagation");
        start_time := now;
        button_in <= '1';
        wait for DEBOUNCE_TIME + MARGIN;

        check(result = '1', "Output goes HIGH after stable input");

        -----------------------------------------------------------------------
        -- TEST 4: Stable low propagation
        -----------------------------------------------------------------------
        log("TEST 4: Stable LOW propagation");
        button_in <= '0';
        wait for DEBOUNCE_TIME + MARGIN;

        check(result = '0', "Output goes LOW after stable input");

        -----------------------------------------------------------------------
        -- TEST 5: Bouncy press (realistic button bounce simulation)
        -----------------------------------------------------------------------
        log("TEST 5: Bouncy button press");
        check(result = '0', "Pre-condition: output is LOW");

        -- Simulate mechanical bounce: 5 bounces, 1ms each (total 5ms < 10ms window)
        bounce_press(button_in, 5, 1 ms);

        -- Immediately after bounce, output should still be low (counter restarted)
        wait for CLK_PERIOD * 10;
        check(result = '0', "Output still LOW during bounce");

        -- Now wait for debounce time with stable input
        wait for DEBOUNCE_TIME + MARGIN;
        check(result = '1', "Output HIGH after bounce settles");

        -----------------------------------------------------------------------
        -- TEST 6: Bouncy release
        -----------------------------------------------------------------------
        log("TEST 6: Bouncy button release");
        bounce_release(button_in, 4, 2 ms);

        wait for CLK_PERIOD * 10;
        check(result = '1', "Output still HIGH during release bounce");

        wait for DEBOUNCE_TIME + MARGIN;
        check(result = '0', "Output LOW after release bounce settles");

        -----------------------------------------------------------------------
        -- TEST 7: Rapid toggling (noise rejection)
        -----------------------------------------------------------------------
        log("TEST 7: Rapid toggling / noise rejection");
        button_in <= '0';
        wait for DEBOUNCE_TIME + MARGIN;
        check(result = '0', "Pre-condition: output is LOW");

        -- Rapid toggling at 500us intervals for 8ms (never stable long enough)
        for i in 1 to 16 loop
            button_in <= not button_in;
            wait for 500 us;
        end loop;
        button_in <= '0';
        wait for DEBOUNCE_TIME + MARGIN;

        check(result = '0', "Rapid noise filtered, output stable LOW");

        -----------------------------------------------------------------------
        -- TEST 8: Multiple valid presses
        -----------------------------------------------------------------------
        log("TEST 8: Multiple valid presses");

        -- First press
        button_in <= '1';
        wait for DEBOUNCE_TIME + MARGIN;
        check(result = '1', "First press registered");

        -- First release
        button_in <= '0';
        wait for DEBOUNCE_TIME + MARGIN;
        check(result = '0', "First release registered");

        -- Second press
        button_in <= '1';
        wait for DEBOUNCE_TIME + MARGIN;
        check(result = '1', "Second press registered");

        -- Second release
        button_in <= '0';
        wait for DEBOUNCE_TIME + MARGIN;
        check(result = '0', "Second release registered");

        -----------------------------------------------------------------------
        -- TEST 9: Reset during active debounce
        -----------------------------------------------------------------------
        log("TEST 9: Reset during active debounce");
        button_in <= '1';
        wait for DEBOUNCE_TIME / 2;  -- halfway through debounce
        reset_n <= '0';
        wait for CLK_PERIOD * 5;
        check(result = '0', "Reset clears output mid-debounce");
        reset_n <= '1';
        button_in <= '0';
        wait for DEBOUNCE_TIME + MARGIN;

        -----------------------------------------------------------------------
        -- Summary
        -----------------------------------------------------------------------
        log("========================================");
        log("TEST SUMMARY");
        log("  Total:  " & integer'image(test_count));
        log("  Passed: " & integer'image(pass_count));
        log("  Failed: " & integer'image(fail_count));
        log("========================================");

        if fail_count = 0 then
            report "ALL TESTS PASSED" severity note;
        else
            report "SOME TESTS FAILED" severity failure;
        end if;

        sim_done <= true;
        wait;
    end process;

end Behavioral;
