library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;
use std.env.finish;

entity spi_controller_tb is
end spi_controller_tb;

architecture sim of spi_controller_tb is

  constant clk_hz : integer := 12e6; -- 100MHz, slow down for simulation
  constant clk_period : time := 1 sec / clk_hz;

  constant sclk_hz : integer := 4e6; --4MHz

  signal clk : std_logic := '1';
  signal rst : std_logic := '1';

  signal cs : std_logic := 'H';
  signal sclk : std_logic;
  signal miso : std_logic := '0';
  signal ready : std_logic := '0';
  signal valid : std_logic;
  signal data : std_logic_vector(7 downto 0);

  signal next_sample : unsigned(7 downto 0);

begin

  clk <= not clk after clk_period / 2;

  DUT : entity work.spi_controller(rtl)
  generic map (
    clk_hz => clk_hz,
    --data_bits => -----
    sclk_hz => sclk_hz
  )
  port map (
    clk => clk,
    rst => rst,
    cs => cs,
    sclk => sclk,
    miso => miso,
    ready => ready,
    valid => valid,
    data => data
  );

  BFM : entity work.als_bfm(beh)
  port map (
    next_sample => next_sample,
    cs => cs,
    sclk => sclk,
    miso => miso
  );

  SEQUENCER_PROC : process
    procedure print(constant message : string) is
      variable str : line;
    begin
      write(str, message);
      writeline(output, str);
    end procedure;

    procedure verify(constant d : unsigned(7 downto 0)) is
    begin
      print("Expecting: " & to_string(d));
      next_sample <= d;
      ready <= '1';
      wait until valid = '1';
      ready <= '0';
      assert data = std_logic_vector(d)
        report "Incorrect data received from DUT. Received: " & to_string(data) & 
               ", Expected: " & to_string(d)  severity failure;
      print("    Test: Passed. ");
    end procedure;

  begin
    wait for clk_period * 2;
    print("Releasing reset");
    rst <= '0';

    wait for clk_period * 100;
    verify("11111111");
    verify("10000001");
    verify("00000000");
    verify("10000000");
    verify("00000001");
    verify("11110000");
    verify("10101010");
    verify("00001111");
    print("Test: Completed");

    finish;
  end process;

end architecture;