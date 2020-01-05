
-------------------------------------------------------------------------------
-- (c) Copyright -  2019
--
-- All Rights Reserved.
--
-- Restricted Use.
--
-- Copyright protects this code. Except as permitted by the Copyright Act, you
-- may only use the code as expressly permitted under the terms on which the
-- code was licensed to you.
--
-------------------------------------------------------------------------------
--   File Name:             adc_spi_stream.vhd
--   Type:                  RTL
--   Contributing authors:  J. Tuthill
--   Created:               Sun Oct 27 17:21:41 2019
--   Template Rev:          1.0
--
--   Title:                 SPI streaming interface for the MAX11040 sample data receiver.
--   Description: 
--   
--   
--
--   
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



-------------------------------------------------------------------------------
entity adc_spi_stream is
   generic (
      g_sck_ratio_pwr : integer := 3;  -- power of 2 PL clock divide ratio, fclk_clk0 = 100MHz
      g_num_devices   : integer := 2    -- number of cascaded MAX11040K devices
      );
   port (
      clk   : in std_logic;
      reset : in std_logic;

      -- Host side signals
      stream_go        : in  std_logic;
      hst_adc_spi_cs   : in  std_logic;  -- active low ADC chip select
      hst_adc_spi_sclk : in  std_logic;
      hst_adc_spi_dout : in  std_logic;
      hst_adc_spi_din  : out std_logic;

      -- ADC SPI interface signals
      adc_spi_cs   : out std_logic;     -- active low ADC chip select
      adc_spi_sclk : out std_logic;
      adc_spi_dout : out std_logic;
      adc_spi_din  : in  std_logic;
      adc_drdy_n   : in  std_logic      -- active low sample data ready signal
      );
end adc_spi_stream;

-------------------------------------------------------------------------------
architecture rtl of adc_spi_stream is


   ---------------------------------------------------------------------------
   --                 CONSTANT, TYPE AND GENERIC DEFINITIONS                --
   ---------------------------------------------------------------------------
   constant c_read_data_reg_cmd : std_logic_vector(7 downto 0) := "10110001";
   constant c_sample_read_bits  : integer                      := (g_num_devices * 96) - 1;

   type sm_states_t is (idle_st,              --00
                        wait_for_drdy_st,     --01
                        assert_cs_st,         --02
                        send_read_cmd_st,     --03
                        cmd_data_wait_st,     --04
                        read_sample_data_st,  --05
                        end_read_st,          --06
                        release_cs_st);       --07

   ---------------------------------------------------------------------------
   --                          SIGNAL DECLARATIONS                          --
   ---------------------------------------------------------------------------
   -- State Machine
   signal sm_state       : sm_states_t := idle_st;
   signal s_state_decode : std_logic_vector(2 downto 0);

   signal s_sclk_div_cnt      : unsigned(4 downto 0)          := "00000";
   signal s_sclk_free_run     : std_logic;
   signal s_sclk_free_run_d1  : std_logic                     := '0';
   signal s_sclk_rising       : std_logic;
   signal s_sclk_rising_d1    : std_logic                     := '0';
   signal s_sclk_falling      : std_logic;
   signal s_sclk_out_reg      : std_logic                     := '1';
   signal s_spi_mux_sel       : std_logic                     := '0';
   signal s_adc_spi_cs        : std_logic                     := '0';  -- inverted ADC chip select signal
   signal s_sclk_en           : std_logic                     := '0';
   signal s_bit_cnt_rst       : std_logic                     := '0';
   signal s_bit_cnt           : unsigned(9 downto 0)          := (others => '0');  -- SPI bit counter
   signal s_cmd_word_reg      : std_logic_vector(7 downto 0)  := (others => '0');
   signal s_adc_dout          : std_logic                     := '0';
   signal s_adc_spi_din       : std_logic;
   signal s_adc_spi_din_reg   : std_logic                     := '0';
   signal s_samp_word_bit_cnt : unsigned(4 downto 0)          := "00000";
   signal s_samp_word         : std_logic_vector(23 downto 0) := (others => '0');
   signal s_samp_word_latch   : std_logic_vector(31 downto 0) := (others => '0');
   signal s_samp_fifo_wren    : std_logic                     := '0';


   ---------------------------------------------------------------------------
   --                        COMPONENT DECLARATIONS                         --
   ---------------------------------------------------------------------------



begin


   ---------------------------------------------------------------------------
   --                    INSTANTIATE COMPONENTS                             --
   ---------------------------------------------------------------------------


   ---------------------------------------------------------------------------
   --                      CONCURRENT SIGNAL ASSIGNMENTS                    --
   ---------------------------------------------------------------------------

   s_sclk_free_run <= s_sclk_div_cnt(g_sck_ratio_pwr-1);

   s_sclk_rising  <= s_sclk_free_run and not(s_sclk_free_run_d1);
   s_sclk_falling <= not(s_sclk_free_run) and s_sclk_free_run_d1;

   -- MUX the ADC SPI signals between the PS host and this streaming data module
   adc_spi_cs <= not(s_adc_spi_cs) when (s_spi_mux_sel = '1') else
                 hst_adc_spi_cs;
   adc_spi_sclk <= s_sclk_out_reg when (s_spi_mux_sel = '1') else
                   hst_adc_spi_sclk;
   adc_spi_dout <= s_adc_dout when (s_spi_mux_sel = '1') else
                   hst_adc_spi_dout;
   hst_adc_spi_din <= adc_spi_din when (s_spi_mux_sel = '0') else
                      '0';
   s_adc_spi_din <= adc_spi_din when (s_spi_mux_sel = '1') else
                    '0';

   -- MUX the ADC SPI signals between the host PS interface and the strteaming
   -- data read interface


   -- debug - decode the state machine current state
   s_state_decode <= "000" when sm_state = idle_st else
                     "001" when sm_state = wait_for_drdy_st else
                     "010" when sm_state = assert_cs_st else
                     "011" when sm_state = send_read_cmd_st else
                     "100" when sm_state = cmd_data_wait_st else
                     "101" when sm_state = read_sample_data_st else
                     "110" when sm_state = end_read_st else
                     "111";             -- release_cs_st
   ---------------------------------------------------------------------------
   --                         CONCURRENT PROCESSES                          --
   ---------------------------------------------------------------------------

   ---------------------------------------------------------------------------
   --  Process:  SPI_CLK_DIV_PROCESS
   --  Purpose:  Clock divider to generate SPI SCLK from the 100MHz PS FCLK_CLK0
   --  Inputs:   
   --  Outputs:  
   ---------------------------------------------------------------------------
   spi_clk_div_process : process (clk)

   begin
      if rising_edge(clk) then

         -- free-running clock divider
         s_sclk_div_cnt <= s_sclk_div_cnt + 1;

      end if;  --if rising_edge(clk)

   end process spi_clk_div_process;

   ---------------------------------------------------------------------------
   --  Process:  ADC_SPI_STREAM_PROCESS  
   --  Purpose:  
   --  Inputs:   
   --  Outputs:  
   ---------------------------------------------------------------------------
   adc_spi_stream_process : process (clk)

   begin
      if rising_edge(clk) then

         -- SPI bit counter
         s_sclk_free_run_d1 <= s_sclk_free_run;
         s_sclk_rising_d1   <= s_sclk_rising;
         if (s_bit_cnt_rst = '1') then
            s_bit_cnt <= (others => '0');
         -- only increment the bit counter on the falling edge of SCLK
         elsif (s_sclk_falling = '1') then
            s_bit_cnt <= s_bit_cnt + 1;
         else
            s_bit_cnt <= s_bit_cnt;
         end if;

         -- Sample word bit counter
         s_adc_spi_din_reg <= s_adc_spi_din;
         s_samp_fifo_wren  <= '0';
         if ((s_bit_cnt_rst = '1') or (s_samp_word_bit_cnt = to_unsigned(24, 5))) and (s_adc_spi_cs = '1') then
            s_samp_word_bit_cnt             <= (others => '0');
            s_samp_word                     <= (others => '0');
            s_samp_word_latch(31 downto 24) <= (others => s_samp_word(23));  --sign extend to 32 bits
            s_samp_word_latch(23 downto 0)  <= s_samp_word;
            s_samp_fifo_wren                <= '1';
         elsif (s_sclk_falling = '1') then
            s_samp_word_bit_cnt      <= s_samp_word_bit_cnt + 1;
            s_samp_word(0)           <= s_adc_spi_din_reg;
            s_samp_word(23 downto 1) <= s_samp_word(22 downto 0);
         else
            s_samp_word_bit_cnt <= s_samp_word_bit_cnt;
            s_samp_word         <= s_samp_word;
         end if;

         -- SCLK output for sample data streaming
         if (s_sclk_en = '1') then
            s_sclk_out_reg <= s_sclk_free_run;
         else
            s_sclk_out_reg <= s_sclk_out_reg;
         end if;

         -- sample data read command shifter
         if (sm_state = assert_cs_st) then
            s_adc_dout     <= c_read_data_reg_cmd(7);
            s_cmd_word_reg <= c_read_data_reg_cmd(6 downto 0) & '0';
         elsif (((sm_state = send_read_cmd_st) or (sm_state = cmd_data_wait_st))and (s_sclk_rising = '1')) then
            s_adc_dout                 <= s_cmd_word_reg(7);
            s_cmd_word_reg(7 downto 1) <= s_cmd_word_reg(6 downto 0);
            s_cmd_word_reg(0)          <= '0';
         else
            s_adc_dout     <= s_adc_dout;
            s_cmd_word_reg <= s_cmd_word_reg;
         end if;


         -- SPI ADC sample readout state machine
         s_spi_mux_sel <= '0';
         s_adc_spi_cs  <= '0';
         s_sclk_en     <= '0';
         s_bit_cnt_rst <= '0';
         if (reset = '1') then
            sm_state <= idle_st;
         else
            case sm_state is
               when idle_st =>
                  sm_state <= idle_st;
                  if (stream_go = '1') then
                     s_spi_mux_sel <= '1';
                     sm_state      <= wait_for_drdy_st;
                  end if;

               when wait_for_drdy_st =>
                  sm_state      <= wait_for_drdy_st;
                  s_spi_mux_sel <= '1';
                  if (stream_go = '0') then
                     sm_state      <= idle_st;
                     s_spi_mux_sel <= '0';
                  elsif (adc_drdy_n = '0') then
                     sm_state <= assert_cs_st;
                  end if;

               when assert_cs_st =>
                  sm_state      <= assert_cs_st;
                  s_spi_mux_sel <= '1';
                  -- wait for a delayed rising edge of SCLK to ensure required the
                  -- setup time for CS is met
                  if (s_sclk_rising_d1 = '1') then
                     sm_state      <= send_read_cmd_st;
                     s_adc_spi_cs  <= '1';
                     s_sclk_en     <= '1';
                     s_bit_cnt_rst <= '1';
                  end if;

               when send_read_cmd_st =>
                  sm_state      <= send_read_cmd_st;
                  s_spi_mux_sel <= '1';
                  s_adc_spi_cs  <= '1';
                  s_sclk_en     <= '1';
                  if ((s_bit_cnt = to_unsigned(7, 10)) and (s_sclk_falling = '1')) then
                     sm_state  <= cmd_data_wait_st;
                     s_sclk_en <= '0';
                  end if;

               when cmd_data_wait_st =>
                  sm_state      <= cmd_data_wait_st;
                  s_spi_mux_sel <= '1';
                  s_adc_spi_cs  <= '1';
                  if ((s_bit_cnt = to_unsigned(8, 10)) and (s_sclk_falling = '1')) then
                     sm_state      <= read_sample_data_st;
                     s_sclk_en     <= '1';
                     s_bit_cnt_rst <= '1';
                  end if;

               when read_sample_data_st =>
                  sm_state      <= read_sample_data_st;
                  s_spi_mux_sel <= '1';
                  s_adc_spi_cs  <= '1';
                  s_sclk_en     <= '1';
                  if ((s_bit_cnt = to_unsigned(c_sample_read_bits, 10)) and (s_sclk_falling = '1')) then
                     sm_state <= end_read_st;
                  end if;

               when end_read_st =>
                  sm_state      <= end_read_st;
                  s_spi_mux_sel <= '1';
                  s_adc_spi_cs  <= '1';
                  s_sclk_en     <= '1';
                  if (s_sclk_rising = '1') then
                     sm_state  <= release_cs_st;
                     s_sclk_en <= '0';
                  end if;

               when release_cs_st =>
                  sm_state      <= release_cs_st;
                  s_spi_mux_sel <= '1';
                  s_adc_spi_cs  <= '1';
                  if (s_sclk_rising = '1') then
                     s_adc_spi_cs <= '0';
                     sm_state     <= wait_for_drdy_st;
                  end if;
                  
               when others =>
                  sm_state <= idle_st;

            end case;
         end if;
         
      end if;  --if rising_edge(clk)

   end process adc_spi_stream_process;


end rtl;
-------------------------------------------------------------------------------
