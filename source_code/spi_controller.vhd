entity spi_master is
    generic (
        clk_hz : integer; --FPGA clock 100 MHz
        total_bits : integer --total bits tx by sensor chip
        sclk_hz : integer); --sensor’s frequency 4MHz
    port (
        --fpga system
        clk : in std_logic;
        rst : in std_logic;

        -- slave chip
        cs : out std_logic;
        sclk : out std_logic;
        miso : in std_logic;

        -- Internal interface when obtaining data back from slave chip
        ready : in std_logic;
        valid : out std_logic;
        data : out std_logic_vector(7 downto 0));
end spi_master;

architecture rtl of spi_master is

    type state_type is (IDLE, TRANSMISSION); 
    signal state : state_type;

    signal data_bits : std_logic_vector(10 downto 0):="0000000000";
    signal sclk_counter : integer;
    signal clk_counter : integer;
    signal sclk_sig : std_logic;

    --flipflop signals
    signal inputFF: std_logic;
    signal inputFF2: std_logic;
    signal stable_miso: std_logic;
    

begin 

-- PRESCALE_SCLK: entity work.scale_clock 
-- generic map(
--     fpga_clk => clk_hz;
--     pwm_clk => sclk_hz;
--     pwm_res => 8  -- check this later 
-- )
-- port map(
--     i_clk => clk;
--     i_rst => rst;
--     clock => sclk_sig
-- );

--after 3 clocks, we will get a stable value
SYNCHRONIZER: process (sclk) 
begin
   if rising_edge(sclk) then
      inputFF  <= miso;
      inputFF2 <= inputFF;
      stable_miso <= inputFF2;
   end if;
end process;



SPI_MASTER_FSM_PROC: process(clk)
begin
  if rising_edge(clk) then
    if rst = '1' then
        state <= IDLE;
      -- when reset 
    else

    clk_counter <= clk_counter + 1; 

    
      case state is
        
        when IDLE => 

          -- outputs
            data_bits <= (others => '0');
            sclk <= '1';
            cs <= '1';
            valid <= '0';

            -- counters
            sclk_counter <= 0;
            clk_counter <= 0;
            
            if (ready = '1') then
                state <= TRANSMISSION
            end if ;
                
        when TRANSMISSION =>
         -- generate sclk 
            if (clk_counter = (fpga_hz/sclk_hz)/2) then 
                sclk_counter <= sclk_counter + 1;
                sclk_sig <= not sclk_sig;
            elsif(clk_counter = fpga_hz/sclk_hz) then 
                sclk_sig <= not sclk_sig;
            end if;
            
            sclk <= sclk_sig;
            
         -- the 16 bits received - we are saving 8 bits using right shift 
         if (sclk_counter > 4 and sclk_counter < 15) --read for another 3 cycles
            -- accept 1 bit       
            -- increased data bit by 3 to account for delay
            -- data inside data_bit will be XXX...101

            data_bits(10) <= stable_miso; 
            -- right shift by 1 
            data_bits <= std_logic_vector(shift_right(unsigned(data_bits), 1));
                
         elsif (sclk_counter = 16) then 
            --remove garabage bit delay we put into data_bits and only grab the 8bits
                data <= data_bits(7 downto 0);  
                state <= IDLE;
         end if;



        


      end case;
    end if;
  end if;
end process;
end architecture;
