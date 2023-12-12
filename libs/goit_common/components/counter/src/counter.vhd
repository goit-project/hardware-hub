--------------------------------------------------------------------------------
--! @file counter.vhd
--! @author Rihards Novickis
--------------------------------------------------------------------------------
-- synthesis VHDL_INPUT_VERSION VHDL_2008
-- synthesis LIBRARY goit_common

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! @brief Simple counter with a dynamic maximum reset value.
entity counter is
  port(
    clk           : in  std_logic; --! clock
    arst_n        : in  std_logic; --! asynchronous negative reset
    en            : in  std_logic; --! enable
    i_counter_max : in  unsigned;  --! counter's reset value
    o_counter     : out unsigned   --! counter's value
  );
end entity;


architecture RTL of counter is
  signal counter_reg, counter_next : unsigned(o_counter'range) := (others => '0');
begin

  -- generate warning in case of nonoptimal signal widths
  assert i_counter_max'length = o_counter'length
    report "Counter maximum and actual signal widths are not optimal"
    severity warning;

  -- reg-state logic
  process(clk, en, arst_n)
  begin
    if arst_n = '0' then
      counter_reg <= (others => '0');
    elsif rising_edge(clk) and en = '1' then
      counter_reg <= counter_next;
    end if;
  end process;

  -- next-state logic
  counter_next <= (others => '0') when counter_reg = i_counter_max else
                  counter_reg + 1;

  -- output
  o_counter <= counter_reg;

end architecture;
