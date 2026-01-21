
-- Hello World: Full Adder on Basys3 (DVA494 MDU) - Testbench

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb_full_adder is
--  Port ( );
end tb_full_adder;

architecture Behavioral of tb_full_adder is

	-- Test signals
    signal a   : std_logic := '0';
	signal b   : std_logic := '0';
	signal cin : std_logic := '0';
	signal sum : std_logic;
	signal cout: std_logic;

	signal expected_sum  : std_logic;
	signal expected_cout : std_logic;

begin

	expected_sum  <= a xor b xor cin;
	expected_cout <= (a and b) or (cin and (a xor b));

    -- Entity Instatiation: Unit Under Test
	UUT: entity work.full_adder
        -- argument/port name mapping
		port map (            
			a    => a,
			b    => b,
			cin  => cin,
			sum  => sum,
			cout => cout            
		);
        -- port map(a, b, cin,sum, cout); -- positional mapping

    -- Stimulus
	stim_proc: process
	begin
		a <= '0'; b <= '0'; cin <= '0';
		wait for 10 ns;
		assert (sum = expected_sum and cout = expected_cout)
			report "Mismatch for vector 000" severity error;

		a <= '0'; b <= '0'; cin <= '1';
		wait for 10 ns;
		assert (sum = expected_sum and cout = expected_cout)
			report "Mismatch for vector 001" severity error;

		a <= '0'; b <= '1'; cin <= '0';
		wait for 10 ns;
		assert (sum = expected_sum and cout = expected_cout)
			report "Mismatch for vector 010" severity error;

		a <= '0'; b <= '1'; cin <= '1';
		wait for 10 ns;
		assert (sum = expected_sum and cout = expected_cout)
			report "Mismatch for vector 011" severity error;

		a <= '1'; b <= '0'; cin <= '0';
		wait for 10 ns;
		assert (sum = expected_sum and cout = expected_cout)
			report "Mismatch for vector 100" severity error;

		a <= '1'; b <= '0'; cin <= '1';
		wait for 10 ns;
		assert (sum = expected_sum and cout = expected_cout)
			report "Mismatch for vector 101" severity error;

		a <= '1'; b <= '1'; cin <= '0';
		wait for 10 ns;
		assert (sum = expected_sum and cout = expected_cout)
			report "Mismatch for vector 110" severity error;

		a <= '1'; b <= '1'; cin <= '1';
		wait for 10 ns;
		assert (sum = expected_sum and cout = expected_cout)
			report "Mismatch for vector 111" severity error;

		assert false report "All test vectors passed" severity note;
		wait;
	end process;

end Behavioral;
