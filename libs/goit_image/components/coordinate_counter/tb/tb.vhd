library ieee;
library goit_common;
library goit_image;
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
  signal clk             : std_logic := '0';
  signal arst_n          : std_logic := '0';
  signal en              : std_logic := '0';
  signal i_counter_max_x : unsigned(3 downto 0) := (others => '0');
  signal i_counter_max_y : unsigned(3 downto 0) := (others => '0');
  signal o_counter_x     : unsigned(3 downto 0) := (others => '0');
  signal o_counter_y     : unsigned(3 downto 0) := (others => '0');

  -----------------------------------------------------------------------------
  -- Clock
  -----------------------------------------------------------------------------
  signal CLK_PERIOD : time := 10 ns;

begin
  -----------------------------------------------------------------------------
  -- DUT instantation
  -----------------------------------------------------------------------------
  DUT: entity goit_image.coordinate_counter
  port map(
    clk             => clk,
    arst_n          => arst_n,
    en              => en,
    i_counter_max_x => i_counter_max_x,
    i_counter_max_y => i_counter_max_y,
    o_counter_x     => o_counter_x,
    o_counter_y     => o_counter_y);

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

    --variable expected : integer;
  begin
    test_runner_setup(runner, runner_cfg);

    while test_suite loop

      if run("reset") then
        -- prepare counter
        i_counter_max_x <= to_unsigned(COUNTER_MAX_VALUE, i_counter_max_x'length);
        i_counter_max_y <= to_unsigned(COUNTER_MAX_VALUE, i_counter_max_y'length);
        dut_cycle_reset;
        en <= '1';

        -- wait couple of counter iterations
		for i in 0 to COUNTER_MAX_VALUE+3 loop
          wait until rising_edge(clk);
        end loop;

        -- check if counter value is not 0
        check(o_counter_x /= 0, "Non-zero x-counter value expected before");
        check(o_counter_y /= 0, "Non-zero y-counter value expected before");

        -- cycle reset and check counter value
        dut_cycle_reset;
        check(o_counter_x = 0, "Zero x-counter value expected after reset");
        check(o_counter_y = 0, "Zero y-counter value expected after reset");


      elsif run("counter_full") then
	    error("Test not implemented");


      elsif run("counter_full_variable") then
	    error("Test not implemented");

      end if;

    end loop;

    test_runner_cleanup(runner);
  end process;

end architecture;
