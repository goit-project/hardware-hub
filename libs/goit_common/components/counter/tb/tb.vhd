library ieee;
library goit_common;
library vunit_lib;

context vunit_lib.vunit_context;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use vunit_lib.com_pkg.all;


entity tb is
  generic(
    runner_cfg : string;
    COUNTER_MAX_VALUE : natural := 15
  );
end entity;


architecture RTL of tb is
  -----------------------------------------------------------------------------
  -- DUT interfacing
  -----------------------------------------------------------------------------
  signal clk           : std_logic := '0';
  signal arst_n        : std_logic := '1';
  signal en            : std_logic := '0';
  signal i_counter_max : unsigned(3 downto 0) := (others => '0');
  signal o_counter     : unsigned(3 downto 0) := (others => '0');

  -----------------------------------------------------------------------------
  -- Clock
  -----------------------------------------------------------------------------
  signal CLK_PERIOD : time := 10 ns;

begin
  -----------------------------------------------------------------------------
  -- DUT instantation
  -----------------------------------------------------------------------------
  DUT: entity goit_common.counter
  port map(
    clk           => clk,
    arst_n        => arst_n,
    en            => en,
    i_counter_max => i_counter_max,
    o_counter     => o_counter);

  -----------------------------------------------------------------------------
  -- Clock generation
  -----------------------------------------------------------------------------
  clk <= not clk after CLK_PERIOD/2;

  -----------------------------------------------------------------------------
  -- VUnit test sequencer
  -----------------------------------------------------------------------------
  process
    procedure dut_cycle_reset is
    begin
      arst_n <= '0';
      wait until falling_edge(clk);
      arst_n <= '1';
    end procedure;

    variable expected : integer;
  begin
    test_runner_setup(runner, runner_cfg);

    while test_suite loop

      if run("reset") then
        -- prepare counter
        i_counter_max <= to_unsigned(COUNTER_MAX_VALUE, i_counter_max'length);
        dut_cycle_reset;
        en <= '1';

        -- wait couple of counter iterations
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);

        -- check if counter value is not 0
        check(o_counter /= 0, "Non-zero counter value expected before");

        -- cycle reset and check counter value
        dut_cycle_reset;
        check(o_counter = 0, "Zero counter value expected after reset");


      elsif run("counter_full") then
        -- prepare counter
        i_counter_max <= to_unsigned(COUNTER_MAX_VALUE, i_counter_max'length);
        dut_cycle_reset;
        en <= '1';

        -- check couple of counter runs
        for i in 0 to 3*(COUNTER_MAX_VALUE+1) loop
		  expected := i mod (COUNTER_MAX_VALUE+1);

		  check(o_counter = expected, "Counter value check ("
            & "EXPECTED: " & integer'image(expected) & "; "
            & "GOT: " & integer'image(to_integer(o_counter))
            & ")");

		  wait until falling_edge(clk);
        end loop;


      elsif run("counter_full_variable") then
        -- prepare counter
        i_counter_max <= to_unsigned(COUNTER_MAX_VALUE, i_counter_max'length);
        dut_cycle_reset;
        en <= '1';

        -- check couple of counter runs
        for i in 0 to COUNTER_MAX_VALUE loop
 		  i_counter_max <= to_unsigned(i, i_counter_max'length);
          for j in 0 to i loop
		    expected := j;

		    check(o_counter = expected, "Counter value check ("
              & "EXPECTED: " & integer'image(expected) & "; "
              & "GOT: " & integer'image(to_integer(o_counter))
              & ")");

		    wait until falling_edge(clk);
          end loop;
        end loop;
      end if;

    end loop;

    test_runner_cleanup(runner);
  end process;

end architecture;
