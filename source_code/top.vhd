library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top is
  generic (
    clk_hz : integer := 100e6;
    sclk_hz : integer := 4e6;
    clk_counter_bits : integer := 24 --for ready_fsm to periodically generate ready signal for chip
  );
  port (
    clk : in std_logic;
    rst : in std_logic;
    miso : in std_logic;
    cs : out std_logic;
    sclk : out std_logic;
    led_out : out std_logic_vector(7 downto 0)
  );
end top;

architecture rtl of top is

  -- SPI controller signals
  
  --pwm signals


  --------------    READY FSM PROCESS SIGNALS   -------------------------
  -- This counter controls how often samples are fetched and sent
  signal clk_counter : unsigned(clk_counter_bits - 1 downto 0);

  type state_type is (WAITING, RECEIVING, SENDING); 
  signal state : state_type;


  signal prescaler_clk_out : std_logic;
  signal led_signal : std_logic;
  signal pwm_count : integer :=0;
  signal duty_cycle : std_logic_vector(7 downto 0):="00000000";
  signal pwm_count_sig : integer := 0; 
  signal pwm_out_signal : std_logic;

  signal ready : std_logic;
  signal valid : std_logic;
  signal d_rst : std_logic;

  constant total_bits : integer := 16; --???????????
  signal duty_cycle_int : integer :=0;
  

begin
  
  --port map DUT/ instantiate components here -----------------------
    DUT_SCALE_CLOCK : entity work.scale_clock port map (
        i_clk => clk,
        i_rst => d_rst,
        clock => prescaler_clk_out
    );

    duty_cycle_int <= to_integer(unsigned(duty_cycle));
    DUT_PWM : entity work.pwm port map (
        clk => prescaler_clk_out,
        duty_cycle => duty_cycle_int,
        pwm_count => pwm_count_sig,
        pwm_out => pwm_out_signal
    );

    DUT_SPI : entity work.spi_controller
    generic map (
        clk_hz => clk_hz,
        total_bits => total_bits,
        sclk_hz => sclk_hz
    )
    port map (
        clk => clk,
        rst => d_rst,
        cs => cs,
        sclk => sclk,
        miso => miso,
        ready => ready,
        valid => valid,
        data => duty_cycle
    );

    DUT_Deboucer_Reset: entity work.reset_sync 
      generic map(
        rst_strobe_cycles => 128,
        rst_in_active_value => '1',
        rst_out_active_value => '1'
      )
      port map (
        clk => clk, -- Slowest clock that uses rst_out
        rst_in => rst,
        rst_out => d_rst
      );

   READY_FSM_PROC : process(clk)
    begin
      if rising_edge(clk) then
        if d_rst = '1' then
          clk_counter <= (others => '0');
          state <= WAITING;
          ready <= '0';
          
        else
          clk_counter <= clk_counter + 1;
        
          case state is
            
            -- Wait for some time
            when WAITING =>
              -- If every bit in clk_counter is a '1'
              if signed(clk_counter) = to_signed(-1, clk_counter'length) then
                state <= RECEIVING;
                ready <= '1';
              end if;

            -- Fetch the results from the ambient light sensor
            when RECEIVING =>
              if valid = '1' then
                state <= WAITING;
                ready <= '0';
              end if;
            
            -- Wait until the UART module acknowledges the transfer
            when SENDING =>
              -- If timed out
              if clk_counter = 0 then
                state <= WAITING;
              end if;       
          end case;
        end if;
      end if;
    end process;



RESERT_PROC : process(clk,d_rst)
  begin
      
      if d_rst = '1' then 
          led_signal <= '0';
      else 
          led_signal <= pwm_out_signal;
      end if;
  end process;

led_out(7) <= led_signal;
led_out(6) <= led_signal;
led_out(5) <= led_signal;
led_out(4) <= led_signal;
led_out(3) <= led_signal;
led_out(2) <= led_signal;
led_out(1) <= led_signal;
led_out(0) <= led_signal;

end architecture;