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
      byte_cnt        : in  std_logic_vector(4 downto 0);  -- number of bythes to transfer
      adc_din         : in  std_logic_vector(7 downto 0);
      next_byte       : out std_logic;
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
                        wait_last_byte_st,  --06
                        deassert_cs_st);    --07


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
   signal s_adc_din_l        : std_logic_vector(7 downto 0) := "00000000";
   signal s_adc_spi_rw_done  : std_logic                    := '0';
   signal s_adc_spi_din      : std_logic                    := '0';
   signal s_adc_dout         : std_logic_vector(7 downto 0) := "00000000";
   signal s_adc_rd_bit_cnt   : unsigned(3 downto 0)         := "0000";

   -- spi interface signals
   signal s_cs_l         : std_logic := '1';
   signal s_cs_l_d1      : std_logic := '1';
   signal s_sclk         : std_logic := '1';
   signal s_adc_spi_dout : std_logic := '0';

   -- sequencer and control signals
   signal s_cmd_addr_seq_cnt    : unsigned(8 downto 0)         := (others => '0');
   signal s_cmd_addr_seq_cnt_en : std_logic                    := '0';
   signal s_sclk_en             : std_logic                    := '0';
   signal s_bit_cnt_en          : std_logic                    := '0';
   signal s_bit_cnt             : unsigned(3 downto 0)         := "0000";
   signal s_dec_byte_cnt        : std_logic                    := '0';
   signal s_dec_byte_cnt_pipe   : std_logic_vector(5 downto 0) := "000000";
   signal s_byte_cnt            : unsigned(4 downto 0)         := "00000";
   signal s_next_byte           : std_logic                    := '0';


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

   -- assign local side signals
   next_byte <= s_next_byte;
   adc_dout  <= s_adc_dout;

   -- assign SPI output signals
   adc_spi_cs      <= s_cs_l;
   adc_spi_sclk    <= s_sclk;
   adc_spi_dout    <= s_adc_spi_dout;
   adc_spi_rw_done <= s_adc_spi_rw_done;


   -- debug - decode the state machine current state
   s_state_decode <= "000" when s_sm_state = idle_st else
                     "001" when s_sm_state = assert_cs_st else
                     "010" when s_sm_state = send_cmd_addr_st else
                     "011" when s_sm_state = wait_for_data_st else
                     "100" when s_sm_state = rw_data_byte_st else
                     "101" when s_sm_state = check_byte_cnt_st else
                     "110" when s_sm_state = wait_last_byte_st else
                     "111";             -- deassert_cs_st

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
         -- register the ADC input data signal
         s_adc_spi_din <= adc_spi_din;

         -- register the fabric-side input signals
         s_adc_spi_rw   <= adc_spi_rw;
         s_adc_spi_rw_d <= s_adc_spi_rw;
         s_adc_wr_en    <= adc_wr_en;
         s_cmd_addr     <= cmd_addr;
         s_byte_cnt_reg <= byte_cnt;
         s_adc_din      <= adc_din;

         -- generate the 'done' output 
         s_cs_l_d1 <= s_cs_l;
         if ((s_cs_l = '0') and (s_cs_l_d1 = '1')) then  -- falling edge
            s_adc_spi_rw_done <= '0';
         elsif (s_sm_state = idle_st) or ((s_cs_l = '1') and (s_cs_l_d1 = '0')) then  -- rising edge
            s_adc_spi_rw_done <= '1';
         else
            s_adc_spi_rw_done <= s_adc_spi_rw_done;
         end if;

         -- latch cmd/addr and data and reset the byte counter
         if ((s_adc_spi_rw_pulse = '1') and (s_sm_state = idle_st)) then
            s_cmd_addr_l <= s_adc_wr_en & s_cmd_addr;
            s_byte_cnt   <= unsigned(s_byte_cnt_reg);
         end if;

         -- latch the current/next input data byte
         if (((s_adc_spi_rw_pulse = '1') and (s_sm_state = idle_st)) or (s_dec_byte_cnt_pipe(3) = '1')) then
            s_adc_din_l <= s_adc_din;
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
         s_dec_byte_cnt_pipe(0)          <= s_dec_byte_cnt;
         s_dec_byte_cnt_pipe(5 downto 1) <= s_dec_byte_cnt_pipe(4 downto 0);
         -- request next byte
         if s_dec_byte_cnt = '1' then
            s_next_byte <= '1';
         else
            s_next_byte <= '0';
         end if;

         if s_dec_byte_cnt = '1' then
            s_byte_cnt <= s_byte_cnt - 1;
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
         if (((s_sm_state = rw_data_byte_st) or (s_sm_state = check_byte_cnt_st) or (s_sm_state = wait_last_byte_st)) and (s_cmd_addr_seq_cnt(0) = '0')) then
            s_adc_spi_dout          <= s_adc_din_l(7);
            s_adc_din_l(7 downto 1) <= s_adc_din_l(6 downto 0);
            s_adc_din_l(0)          <= '0';
            if (s_adc_spi_rw = '0') then  -- shift in the data byte from the ADC
               s_adc_dout(0)          <= s_adc_spi_din;
               s_adc_dout(7 downto 1) <= s_adc_dout(6 downto 0);
               s_adc_rd_bit_cnt       <= s_adc_rd_bit_cnt + 1;
            end if;
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
               if (s_bit_cnt = "1010") then
                  s_dec_byte_cnt <= '1';
                  s_sm_state     <= check_byte_cnt_st;
               else
                  s_dec_byte_cnt <= '0';
                  s_sm_state     <= rw_data_byte_st;
               end if;

            when check_byte_cnt_st =>
               s_dec_byte_cnt <= '0';
               if (s_byte_cnt = "00000") then
                  s_sm_state <= wait_last_byte_st;
               else
                  s_sm_state <= rw_data_byte_st;
               end if;
               
            when wait_last_byte_st =>
               if (s_dec_byte_cnt_pipe(3) = '1') then
                  s_sm_state <= deassert_cs_st;
               else
                  s_sm_state <= s_sm_state;
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
