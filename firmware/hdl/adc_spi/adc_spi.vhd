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
--   File Name:             adc_spi.vhd
--   Type:                  RTL
--   Contributing authors:  J. Tuthill
--   Created:               Fri Oct 05 10:14:03 2018
--   Template Rev:          1.0
--
--   Title:                 Top-level ADC SPI interface.
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
entity adc_spi is
   port (
      clk   : in std_logic;
      reset : in std_logic;

      -- local side signals
      adc_wr_en      : in  std_logic;
      adc_spi_rw     : in  std_logic;
      adc_send_done  : out std_logic;
      trig_start_str : in  std_logic;
      trig_stop_str  : in  std_logic;

      -- ADC device SPI signals
      adc_sclk : out std_logic;         -- SPI serial clock
      adc_cs   : out std_logic;         -- device chip select
      adc_dout : in  std_logic;         -- serial data from ADCs
      adc_din  : out std_logic;         -- serial data to ADCs
      adc_drdy : in  std_logic          -- conversion result ready


      );
end adc_spi;

-------------------------------------------------------------------------------
architecture rtl of adc_spi is


   ---------------------------------------------------------------------------
   --                 CONSTANT, TYPE AND GENERIC DEFINITIONS                --
   ---------------------------------------------------------------------------
   type sm_states_t is (idle_st,            --00
                        start_strm_st,      --01
                        stop_strm_st,       --02
                        halt_strm_st,       --03
                        latch_inputs_st,    --04
                        trigger_spi_st,     --05
                        wait_for_done_st);  --06


   ---------------------------------------------------------------------------
   --                          SIGNAL DECLARATIONS                          --
   ---------------------------------------------------------------------------
   -- State Machine
   signal s_sm_state     : sm_states_t := idle_st;
   signal s_state_decode : std_logic_vector(2 downto 0);

   signal s_trig_start_str : std_logic := '0';
   signal s_trig_stop_str  : std_logic := '0';

   signal s_strm_en         : std_logic := '0';
   signal s_strm_restore_st : std_logic := '0';
   signal s_halt_strm       : std_logic := '0';
   signal s_halt_strm_d     : std_logic := '0';
   signal s_strm_stopped    : std_logic;

   signal s_adc_wr_en : std_logic := '0';
   signal s_spi_rw    : std_logic := '0';


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

   -- debug - decode the state machine current state
   s_state_decode <= "000" when s_sm_state = idle_st else
                     "001" when s_sm_state = start_strm_st else
                     "010" when s_sm_state = stop_strm_st else
                     "011" when s_sm_state = halt_strm_st else
                     "100" when s_sm_state = latch_inputs_st else
                     "101" when s_sm_state = trigger_spi_st else
                     "110" when s_sm_state = wait_for_done_st else
                     "111";             -- undefined state

   ---------------------------------------------------------------------------
   --                         CONCURRENT PROCESSES                          --
   ---------------------------------------------------------------------------

   ---------------------------------------------------------------------------
   --  Process:  ADC_SPI_PROCESS  
   --  Purpose:  
   --  Inputs:   
   --  Outputs:  
   ---------------------------------------------------------------------------
   adc_spi_process : process (clk)

   begin
      if rising_edge(clk) then
         -- register input signals
         s_adc_wr_en      <= adc_wr_en;
         s_spi_rw         <= adc_spi_rw;
         s_trig_start_str <= trig_start_str;
         s_trig_stop_str  <= trig_stop_str;

         -- controller state machine
         case s_sm_state is
            
            when idle_st =>
               s_halt_strm <= '0';
               if s_trig_start_str = '1' then
                  s_sm_state <= start_strm_st;
               elsif s_trig_stop_str = '1' then
                  s_sm_state <= stop_strm_st;
               elsif s_spi_rw = '1' then
                  s_halt_strm <= '1';
                  s_sm_state  <= halt_strm_st;
               else
                  s_sm_state <= idle_st;
               end if;

            when start_strm_st =>
               s_sm_state <= idle_st;

            when stop_strm_st =>
               if s_strm_stopped = '1' then
                  s_sm_state <= idle_st;
               else
                  s_sm_state <= s_sm_state;
               end if;

            when halt_strm_st =>
               s_sm_state <= latch_inputs_st;

            when latch_inputs_st =>
               if reset = '1' then
                  s_sm_state <= idle_st;
               else
                  if s_strm_stopped = '1' then
                     s_sm_state <= trigger_spi_st;
                  else
                     s_sm_state <= s_sm_state;
                  end if;
               end if;

            when trigger_spi_st =>
               s_sm_state <= wait_for_done_st;

            when wait_for_done_st =>
               if reset = '1' then
                  s_sm_state <= idle_st;
               else
                  if s_spi_done = '1' then
                     s_sm_state <= idle_st;
                  else
                     s_sm_state <= s_sm_state;
                  end if;
               end if;

            when others =>
               s_sm_state <= idle_st;
               
         end case;

         -- ADC data streaming control
         s_halt_strm_d <= s_halt_strm;
         if ((s_sm_state = stop_strm_st) or (reset = '1')) then
            s_strm_en <= '0';
         elsif ((s_halt_strm = '1') and (s_halt_strm_d = '0')) then  -- detect rising edge of halt
            s_strm_restore_st <= s_strm_en;
            s_strm_en         <= '0';
         elsif ((s_halt_strm = '0') and (s_halt_strm_d = '1')) then  -- detect falling edge of halt
            s_strm_en <= s_strm_restore_st;
         elsif s_sm_state = start_strm_st then
            s_strm_en <= '1';
         else
            s_strm_en <= s_s_strm_en;
         end if;
         
         
      end if;  -- if rising_edge(clk)

   end process adc_spi_process;

end rtl;
-------------------------------------------------------------------------------
