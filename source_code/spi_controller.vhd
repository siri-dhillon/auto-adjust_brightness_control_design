library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity spi_controller is
    generic (
        clk_hz : integer; --FPGA clock 100 MHz
        total_bits : integer; --total bits tx by sensor chip
        sclk_hz : integer --sensor’s frequency 4MHz
        ); 
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
end spi_controller;

architecture rtl of spi_controller is

    type state_type is (IDLE, TRANSMISSION); 
    signal state : state_type;

    signal data_bits : std_logic_vector(7 downto 0):="00000000";
    signal sclk_counter : integer;
    signal clk_counter : integer;
    signal sclk_sig : std_logic;

    --flipflop signals
    signal inputFF: std_logic;
    signal inputFF2: std_logic;
    signal stable_miso: std_logic;
    
    -- counter signal 
    signal max_count : integer;

begin 

max_count <= clk_hz/sclk_hz;

--after 3 clocks, we will get a stable value
SYNCHRONIZER: process (clk, miso,rst) 
begin
   if rising_edge(clk) then
      inputFF  <= miso;
      inputFF2 <= inputFF;
      stable_miso <= inputFF2;
   end if;
end process;



spi_controller_FSM_PROC: process(clk)
begin
  if rising_edge(clk) then
    if rst = '1' then
        sclk_sig <= '0';
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
                state <= TRANSMISSION;
            end if ;
                
        when TRANSMISSION =>
         -- generate sclk 
         -- If clock_counter is divisible by max count (3), then we flip the bits
         -- every 3 clock cycles, we output 1 sclk_sig
         -- previously, we enter if statement once and never again
         -- eg. clk_counter = 3, then clk_counter++, but 3 stays the same

            if ((clk_counter mod max_count) = 0) then 
                sclk_sig <= not sclk_sig;
                sclk_counter <= sclk_counter + 1;
                sclk <= sclk_sig;
            end if;
            
            
         -- the 16 bits received - we are saving 8 bits using right shift 
         if (sclk_counter > 3 and sclk_counter < 12) then --read for another 3 cycles
            -- accept 1 bit       
            -- data inside data_bit will be XXX...101
            -- data_bits(7) <= stable_miso; 
            data_bits(7) <= miso;  --TESTING WITHOUT SYNCHRONIZER
            -- right shift by 1 
            data_bits <= std_logic_vector(shift_right(unsigned(data_bits), 1));
                
         elsif (sclk_counter = 16) then 
            --remove garabage bit delay we put into data_bits and only grab the 8bits
                data <= data_bits;  
                valid <= '1';
                state <= IDLE;
         end if;
      end case;
    end if;
  end if;
end process;
end architecture;
