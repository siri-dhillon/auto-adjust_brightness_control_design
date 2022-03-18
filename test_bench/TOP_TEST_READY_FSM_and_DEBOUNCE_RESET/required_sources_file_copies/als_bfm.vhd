library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity als_bfm is
  port (
    -- Testbench interface (next sample to send)
    next_sample : in unsigned(7 downto 0);

    -- DUT interface
    cs : in std_logic;
    sclk : in std_logic;
    miso : out std_logic
  );
end als_bfm;

architecture beh of als_bfm is

  -- From ADC081S021 datasheet, page 7:
  -- Minimum ^CS pulse width
  constant t_cs : time := 10 ns;

  -- ^CS setup time prior to SCLK falling edge  =  min time permitted between CS pulled low -> SCLK falling edge
  constant t_cssu : time := 10 ns;

  -- ^CS hold time after SCLK falling edge
  constant t_csh : time := 1 ns;

  -- Delay from ^CS until SDATA TRI-STATE disabled
  constant t_en : time := 20 ns;

  -- Data access time after SCLK falling edge
  constant t_acc : time := 40 ns;

  -- SCLK to data valid hold time
  constant t_h : time := 7 ns;

  --cs signal delayed by one delta cycle (no simulation time)
  signal cs_delta_delay : std_logic;

begin

 ------     BUS Functional Model (BFM) ----------------------
 BFM_PROC : process
  variable send_bits : std_logic_vector(15 downto 0) := (others => '0');
 begin
   miso <= 'Z';
   wait until falling_edge(cs);

   wait for t_en; --time required from falling edge CS until SDATA 'X' (tri-state)
   miso <= 'X';

   --set the data bits according to the serial timing characteristics of the light sensor
   send_bits(12 downto 5) := std_logic_vector(next_sample);

   for i in 15 downto 0 loop
      wait until falling_edge(sclk);
      --wait for the hold time after the falling edge before data is placed on line 
      wait for t_h;
      miso <= 'X';
      wait for t_acc - t_h; --wait for the "data access time after SCLK falling edge" - thold overlap
      miso <= send_bits(i);
   end loop;

 end process;
 ---------------------------------------------------------------

   -----     Timing violation checks -----------------------------
   cs_delta_delay <= cs;
   process
   begin
     wait until falling_edge(sclk);
 
     assert cs'stable(t_cssu)
       report "CS Setup time prior to SCLK violated" severity failure;
   end process;
 
   process
   begin
     wait until falling_edge(cs);
 
     assert cs_delta_delay'stable(t_cs)  --bc cs just changed, this is an event on cs. Need a signal delayed by 1 delta cycle wrt cs
       report "t_cs violated (min CS pulse time)" severity failure;
 
     assert sclk /= '0' or sclk'stable(t_csh)
       report "t_csh violated (cs hold time after falling sclk)" severity failure;
   end process;
  --------------------------------------------------------------
  
end architecture;