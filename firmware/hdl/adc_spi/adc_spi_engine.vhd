-------------------------------------------------------------------------------
-- (c) Copyright - John Tuthill - 2018
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
--   File Name:             adc_spi_engine.vhd
--   Type:                  RTL
--   Contributing authors:  J. Tuthill
--   Created:               Fri Oct 05 11:50:35 2018
--   Template Rev:          1.0
--
--   Title:                 SPI interface engine for the ADC.
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
entity adc_spi_engine is
   port (
      spi_clk : in std_logic;
      reset   : in std_logic;

      -- fabric side signals
      adc_spi_rw      : in  std_logic;
      adc_spi_rw_done : out std_logic;
      adc_wr_en       : in  std_logic;
      cmd_addr        : in  std_logic_vector(6 downto 0);
      byte_cnt        : in  std_logic_vector(4 downto 0);  -- number of bythes to transfer - 1
      adc_din         : in  std_logic_vector(7 downto 0);
      adc_dout        : out std_logic_vector(7 downto 0);

      -- ADC SPI interface signals
      adc_spi_cs   : out std_logic;
      adc_spi_sclk : out std_logic;
      adc_spi_dout : out std_logic;
      adc_spi_din  : in  std_logic

      );
end adc_spi_engine;

-------------------------------------------------------------------------------
architecture rtl of adc_spi_engine is


   ---------------------------------------------------------------------------
   --                 CONSTANT, TYPE AND GENERIC DEFINITIONS                --
   ---------------------------------------------------------------------------
   type sm_states_t is (idle_st,            --00
                        assert_cs_st,       --01
                        send_cmd_addr_st,   --02
                        wait_for_data_st,   --03
                        rw_data_byte_st,    --04
                        check_byte_cnt_st,  --05
                        deassert_cs_st);    --06


   ---------------------------------------------------------------------------
   --                          SIGNAL DECLARATIONS                          --
   ---------------------------------------------------------------------------
   -- State Machine
   signal s_sm_state     : sm_states_t := idle_st;
   signal s_state_decode : std_logic_vector(2 downto 0);

   signal s_adc_spi_rw       : std_logic                    := '0';
   signal s_adc_spi_rw_d     : std_logic                    := '0';
   signal s_adc_spi_rw_pulse : std_logic;
   signal s_adc_wr_en        : std_logic                    := '0';
   signal s_cmd_addr         : std_logic_vector(6 downto 0) := "0000000";
   signal s_adc_din          : std_logic_vector(7 downto 0) := (others => '0');
   signal s_cmd_addr_l       : std_logic_vector(7 downto 0) := "00000000";
   signal s_byte_cnt_reg     : std_logic_vector(4 downto 0) := "00000";
   signal s_byte_cnt_l       : unsigned(4 downto 0)         := "00000";
   signal s_adc_din_l        : std_logic_vector(7 downto 0) := "00000000";

   -- spi interface signals
   signal s_cs_l         : std_logic := '1';
   signal s_sclk         : std_logic := '1';
   signal s_adc_spi_dout : std_logic := '0';

   -- sequencer and control signals
   signal s_cmd_addr_seq_cnt    : unsigned(8 downto 0) := (others => '0');
   signal s_cmd_addr_seq_cnt_en : std_logic            := '0';
   signal s_sclk_en             : std_logic            := '0';
   signal s_bit_cnt_en          : std_logic            := '0';
   signal s_bit_cnt             : unsigned(3 downto 0) := "0000";
   signal s_inc_byte_cnt        : std_logic            := '0';
   signal s_byte_cnt            : unsigned(4 downto 0) := "00000";


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

   -- rising edge detect on adc_spi_rw
   s_adc_spi_rw_pulse <= s_adc_spi_rw and not(s_adc_spi_rw_d);

   -- assign SPI output signals
   adc_spi_cs   <= s_cs_l;
   adc_spi_sclk <= s_sclk;
   adc_spi_dout <= s_adc_spi_dout;


   -- debug - decode the state machine current state
   s_state_decode <= "000" when s_sm_state = idle_st else
                     "001" when s_sm_state = assert_cs_st else
                     "010" when s_sm_state = send_cmd_addr_st else
                     "011" when s_sm_state = wait_for_data_st else
                     "100" when s_sm_state = rw_data_byte_st else
                     "101" when s_sm_state = check_byte_cnt_st else
                     "110" when s_sm_state = deassert_cs_st else
                     "111";             -- undefined state

   ---------------------------------------------------------------------------
   --                         CONCURRENT PROCESSES                          --
   ---------------------------------------------------------------------------

   ---------------------------------------------------------------------------
   --  Process:  ADC_SPI_ENGINE_PROCESS  
   --  Purpose:  
   --  Inputs:   
   --  Outputs:  
   ---------------------------------------------------------------------------
   adc_spi_engine_process : process(spi_clk)

   begin
      if rising_edge(spi_clk) then
         -- register the input signals
         s_adc_spi_rw   <= adc_spi_rw;
         s_adc_spi_rw_d <= s_adc_spi_rw;
         s_adc_wr_en    <= adc_wr_en;
         s_cmd_addr     <= cmd_addr;
         s_byte_cnt_reg <= byte_cnt;
         s_adc_din      <= adc_din;

         -- latch cmd/addr and data and reset the byte counter
         if ((s_adc_spi_rw_pulse = '1') and (s_sm_state = idle_st)) then
            s_cmd_addr_l <= s_adc_wr_en & s_cmd_addr;
            s_byte_cnt_l <= unsigned(s_byte_cnt_reg);
            s_adc_din_l  <= s_adc_din;
            s_byte_cnt   <= (others => '0');
         end if;

         -- cmd/addr sequence counter
         if s_cmd_addr_seq_cnt_en = '1' then
            s_cmd_addr_seq_cnt <= s_cmd_addr_seq_cnt + 1;
         else
            s_cmd_addr_seq_cnt <= (others => '0');
         end if;

         -- data bit counter
         if s_bit_cnt_en = '1' then
            s_bit_cnt <= s_bit_cnt + 1;
         else
            s_bit_cnt <= (others => '0');
         end if;

         -- data byte counter
         if s_inc_byte_cnt = '1' then
            s_byte_cnt <= s_byte_cnt + 1;
         end if;

         -- SCLK generation
         if s_sclk_en = '1' then
            s_sclk <= not(s_sclk);
         end if;

         -- generate serial cmd/addr out
         if ((s_sm_state = send_cmd_addr_st) and (s_cmd_addr_seq_cnt(0) = '0')) then
            s_adc_spi_dout           <= s_cmd_addr_l(7);
            s_cmd_addr_l(7 downto 1) <= s_cmd_addr_l(6 downto 0);
            s_cmd_addr_l(0)          <= '0';
         end if;

         -- generate serial data out
         if (((s_sm_state = rw_data_byte_st) or (s_sm_state = check_byte_cnt_st)) and (s_cmd_addr_seq_cnt(0) = '0')) then
            s_adc_spi_dout          <= s_adc_din_l(7);
            s_adc_din_l(7 downto 1) <= s_adc_din_l(6 downto 0);
            s_adc_din_l(0)          <= '0';
         end if;

         case s_sm_state is

            when idle_st =>
               if (s_adc_spi_rw_pulse = '1') then
                  s_cmd_addr_seq_cnt_en <= '1';
                  s_cs_l                <= '0';
                  s_sm_state            <= assert_cs_st;
               else
                  s_cmd_addr_seq_cnt_en <= '0';
                  s_cs_l                <= '1';
                  s_sm_state            <= idle_st;
               end if;

            when assert_cs_st =>
               if s_cmd_addr_seq_cnt = to_unsigned(1, 9) then
                  s_sm_state <= send_cmd_addr_st;
               else
                  s_sm_state <= assert_cs_st;
               end if;
               
            when send_cmd_addr_st =>
               if s_cmd_addr_seq_cnt = to_unsigned(17, 9) then
                  s_sclk_en  <= '0';
                  s_sm_state <= wait_for_data_st;
               else
                  s_sclk_en  <= '1';
                  s_sm_state <= send_cmd_addr_st;
               end if;
               
            when wait_for_data_st =>
               if s_cmd_addr_seq_cnt = to_unsigned(21, 9) then
                  s_sclk_en    <= '1';
                  s_bit_cnt_en <= '1';
                  s_sm_state   <= rw_data_byte_st;
               else
                  s_sclk_en    <= '0';
                  s_bit_cnt_en <= '0';
                  s_sm_state   <= wait_for_data_st;
               end if;
               
            when rw_data_byte_st =>
               if (s_bit_cnt = "1110") then
                  s_inc_byte_cnt <= '1';
                  s_sm_state     <= check_byte_cnt_st;
               else
                  s_inc_byte_cnt <= '0';
                  s_sm_state     <= rw_data_byte_st;
               end if;
               
            when check_byte_cnt_st =>
               s_inc_byte_cnt <= '0';
               if s_byte_cnt = s_byte_cnt_l then
                  s_sm_state <= deassert_cs_st;
               else
                  s_sm_state <= rw_data_byte_st;
               end if;
               
            when deassert_cs_st =>
               s_sclk_en  <= '0';
               s_cs_l     <= '0';
               s_sm_state <= idle_st;

            when others =>              -- unhandled state
               s_sm_state <= idle_st;

         end case;
         
      end if;  -- if rising_edge(clk)
      
   end process adc_spi_engine_process;


end rtl;
-------------------------------------------------------------------------------
