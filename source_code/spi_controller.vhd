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

    signal data_bits : std_logic_vector(14 downto 0):="000000000000000";
    signal sclk_counter : integer;
    signal clk_counter : integer;
    signal sclk_sig : std_logic;

    --flipflop signals
    signal inputFF: std_logic;
    signal inputFF2: std_logic;
    signal stable_miso: std_logic;
    
    -- counter signal 
    signal max_count : integer;
    
    -- sclk rising edge and falling edge signal
      -- if sclk_edge = 1 then it is rising edge 
      -- else it is falling edge
    signal sclk_rising_edge: std_logic:='0';

begin 

max_count <= clk_hz/sclk_hz; -- this is equal to 25 

--after 3 clocks, we will get a stable value
SYNCHRONIZER: process (clk) 
begin
   if rising_edge(clk) then
        inputFF <= miso;
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
        clk_counter <= 0; -- figure out where else to change clk_counter to zero
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
            
            if (ready = '1' ) then
              --tCS Minimum CS pulse width should be minimum of 10 ns.
              --We set to 20ns
              if (clk_counter mod 2 = 0) then
                state <= TRANSMISSION;
              end if;
            end if ;
                
        when TRANSMISSION =>
         -- generate sclk 
         -- If clock_counter is divisible by max count (25), then we flip the bits
         -- every 25 clock cycles, we output 1 sclk_sig
         -- previously, we enter if statement once and never again
         -- eg. clk_counter = 25, then clk_counter++, but 25 stays the same

         -- accomodating wait for falling edge cs 
            
            
            cs <= '0'; 

            -- t_su delay = 10 ns 
                -- create a wait for 10 ns before sclk first falling edge 
            if ((clk_counter mod max_count) = 0) then 
                sclk_sig <= not sclk_sig;
                if (sclk_sig = '0') then 
                  sclk_counter <= sclk_counter + 1;
                  -- right shift by 1 
                  -- the data bits shuft right every time sclk pulses 
                  data_bits <= std_logic_vector(shift_left(unsigned(data_bits), 1)); 
                else 
                  sclk_rising_edge <= '1'; 
                end if;
                sclk <= sclk_sig;
            end if;
            
            
 
              -- accept 1 bit       
              -- data inside data_bit will be XXX...101
              -- reading values at rising edge 
              if sclk_rising_edge = '1' then 
                data_bits(0) <= stable_miso; 
                sclk_rising_edge <= '0';
              end if;
            
           
            -- on the 11th sclk cycle - data is passed to output data and valid is set to 1
            if (sclk_counter = 12) then 
                --remove garabage bit delay we put into data_bits and only grab the 8bits
                            -- the 16 bits received - we are saving 8 bits using right shift 
                            data <= data_bits(8 downto 1);  
                            valid <= '1';
            elsif (sclk_counter = 16) then 
                    state <= IDLE;
            end if;
      end case;
    end if;
  end if;
end process;
end architecture;
