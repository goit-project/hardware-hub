--------------------------------------------------------------------------------
--! @file coorinate_counter.vhd
--! @author Rihards Novickis
--------------------------------------------------------------------------------
-- synthesis VHDL_INPUT_VERSION VHDL_2008
-- synthesis LIBRARY goit_common

library ieee;
library goit_common;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! @brief TODO.
entity coordinate_counter is
  port(
    clk             : in  std_logic; --! clock
    arst_n          : in  std_logic; --! asynchronous negative reset
    en              : in  std_logic; --! enable
    i_counter_max_x : in  unsigned;  --! counter's max value for x coordinate
    i_counter_max_y : in  unsigned;  --! counter's max value for y coordinate
    o_counter_x     : out unsigned;  --! current x coordinate
    o_counter_y     : out unsigned   --! current y coordinate
  );
end entity;


architecture RTL of coordinate_counter is
  signal en_y : std_logic;
begin

  -- y counter should be active only when x counter is at the maximum value
  en_y <= '1' when en = '1' and o_counter_x = i_counter_max_x else
          '0';

  COUNTER_X: entity goit_common.counter
  port map(
    clk           => clk,
    arst_n        => arst_n,
    en            => en,
    i_counter_max => i_counter_max_x,
    o_counter     => o_counter_x);

  COUNTER_Y: entity goit_common.counter
  port map(
    clk           => clk,
    arst_n        => arst_n,
    en            => en_y,
    i_counter_max => i_counter_max_y,
    o_counter     => o_counter_y);

end architecture;
