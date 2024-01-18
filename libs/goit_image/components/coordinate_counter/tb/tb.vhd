library ieee;
library goit_common;
library goit_image;
library vunit_lib;
library osvvm;

context vunit_lib.vunit_context;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use vunit_lib.com_pkg.all;
use osvvm.RandomPkg.all;


entity tb is
  generic(
    runner_cfg : string;
    COUNTER_MAX_VALUE_X : natural := 15;
    COUNTER_MAX_VALUE_Y : natural := 15
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
    -- dut/simulation variables
    variable random : RandomPType;
    variable i, dut_y, dut_x : integer := 0;
    variable dut_counter_max_y, dut_counter_max_x : integer := 0;


    procedure dut_cycle_reset is
    begin
      arst_n <= '0';
      wait until falling_edge(clk);
      arst_n <= '1';
    end procedure;


    procedure dut_configure(max_x, max_y : in natural) is
    begin
      i_counter_max_x   <= to_unsigned(max_x, i_counter_max_x'length);
      i_counter_max_y   <= to_unsigned(max_y, i_counter_max_y'length);
      dut_counter_max_x := max_x;
      dut_counter_max_y := max_y;
    end procedure;


    procedure dut_model_update is
    begin
      if en = '1' then
        if dut_x < dut_counter_max_x then
          dut_x := dut_x + 1;
        else
          dut_x := 0;
          if dut_y < dut_counter_max_y then
            dut_y := dut_y + 1;
          else
            dut_y := 0;
          end if;
        end if;
      end if;
    end procedure;
  begin
    test_runner_setup(runner, runner_cfg);
    random.InitSeed(random'instance_name);

    while test_suite loop

      if run("reset") then
        -- prepare counter
        dut_configure(COUNTER_MAX_VALUE_X, COUNTER_MAX_VALUE_Y);
        dut_cycle_reset;
        en <= '1';

        -- wait couple of counter iterations
        for i in 0 to COUNTER_MAX_VALUE_X+3 loop
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
        -- prepare counter
        dut_configure(COUNTER_MAX_VALUE_X, COUNTER_MAX_VALUE_Y);
        dut_cycle_reset;
        en <= '1';

        -- simulate two full cycles of X and Y counter overflow
        while (i < 2) loop
          en <= random.RandSl;
		  wait for CLK_PERIOD*0.1;

          -- compare DUT and model
          check(o_counter_y = dut_y, "Y counter value check ("
            & "EXPECTED: " & integer'image(dut_y) & "; "
            & "GOT: " & integer'image(to_integer(o_counter_y))
            & ")");
          check(o_counter_x = dut_x, "X counter value check ("
            & "EXPECTED: " & integer'image(dut_x) & "; "
            & "GOT: " & integer'image(to_integer(o_counter_x))
            & ")");

          -- update DUT for the next iteration
          dut_model_update;

          -- next clock cycle + simulation finalization check
          wait until falling_edge(clk);
          if dut_x = dut_counter_max_x and dut_y = dut_counter_max_y then
             i := i + 1;
          end if;
        end loop;


      elsif run("counter_full_variable") then
        error("Test not implemented");

      end if;

    end loop;

    test_runner_cleanup(runner);
  end process;

end architecture;
