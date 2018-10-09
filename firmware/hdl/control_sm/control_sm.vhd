
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
--   File Name:             control_sm.vhd
--   Type:                  RTL
--   Contributing authors:  J. Tuthill
--   Created:               Mon Jan 29 13:46:25 2018
--   Template Rev:          1.0
--
--   Title:                 Control state machine
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
use work.mic_array_ctrl_pkg.all;

-------------------------------------------------------------------------------
entity control_sm is
   port (
      -- clocks and resets
      clk   : in std_logic;
      reset : in std_logic;

      -- host-side signals
      hst_dv  : in  std_logic;                     -- data valid from host
      hst_ack : out std_logic;                     -- acknowledge to host
      cmd     : in  std_logic_vector(2 downto 0);  -- command from host

      -- ADC SPI controller
      adc_wr_en       : out std_logic;  -- write enable signal to ADC
      adc_spi_rw      : out std_logic;  -- send SPI transaction to ADC
      adc_spi_rw_done : in  std_logic;  -- send completed from ADC

      -- internal signals
      local_we       : out std_logic;  -- write enable for local internal registers
      source         : out std_logic;   -- select signal for local write bus
      trig_start_str : out std_logic;   -- start data streaming trigger
      trig_stop_str  : out std_logic    -- stop data streaming trigger

      );
end control_sm;

-------------------------------------------------------------------------------
architecture rtl of control_sm is


   ---------------------------------------------------------------------------
   --                 CONSTANT, TYPE AND GENERIC DEFINITIONS                --
   ---------------------------------------------------------------------------
   type ctrl_sm_states_t is (idle_st,             --00
                             hst_ack_st,          --01
                             cmd_decode_st,       --02
                             start_streaming_st,  --03
                             stop_streaming_st,   --04
                             hst_source_st,       --05
                             hst_write_reg_st,    --06
                             adc_wait_ack_st,     --07
                             adc_source_st,       --08
                             adc_read_send_st,    --09
                             adc_write_req_st);   --10


   ---------------------------------------------------------------------------
   --                          SIGNAL DECLARATIONS                          --
   ---------------------------------------------------------------------------

   -- State Machine
   signal sm_state     : ctrl_sm_states_t := idle_st;
   signal state_decode : std_logic_vector(3 downto 0);

   -- registered inputs
   signal reset_reg           : std_logic                    := '0';
   signal hst_dv_reg          : std_logic                    := '0';
   signal cmd_reg             : std_logic_vector(2 downto 0) := cmd_nop_c;
   signal adc_spi_rw_done_reg : std_logic                    := '0';

   -- internal versions of the module outputs
   signal hst_ack_int        : std_logic := '0';
   signal trig_start_str_int : std_logic := '0';
   signal trig_stop_str_int  : std_logic := '0';
   signal source_int         : std_logic := '0';
   signal local_we_int       : std_logic := '0';
   signal adc_wr_en_int      : std_logic := '0';
   signal adc_spi_rw_int     : std_logic := '0';

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

   -- assign outputs
   hst_ack        <= hst_ack_int;
   adc_wr_en      <= adc_wr_en_int;
   adc_spi_rw     <= adc_spi_rw_int;
   local_we       <= local_we_int;
   source         <= source_int;
   trig_start_str <= trig_start_str_int;
   trig_stop_str  <= trig_stop_str_int;


   -- debug - decode the state machine current state
   state_decode <= "0000" when sm_state = idle_st else
                   "0001" when sm_state = hst_ack_st else
                   "0010" when sm_state = cmd_decode_st else
                   "0011" when sm_state = start_streaming_st else
                   "0100" when sm_state = stop_streaming_st else
                   "0101" when sm_state = hst_source_st else
                   "0110" when sm_state = hst_write_reg_st else
                   "0111" when sm_state = adc_wait_ack_st else
                   "1000" when sm_state = adc_source_st else
                   "1001" when sm_state = adc_read_send_st else
                   "1010" when sm_state = adc_write_req_st else
                   "1111";              -- undefined state

   ---------------------------------------------------------------------------
   --                         CONCURRENT PROCESSES                          --
   ---------------------------------------------------------------------------

   ---------------------------------------------------------------------------
   --  Process:  CONTROL_SM_PROCESS  
   --  Purpose:  
   --  Inputs:   
   --  Outputs:  
   ---------------------------------------------------------------------------
   control_sm_process : process(clk)

   begin
      if rising_edge(clk) then

         -- register the inputs
         reset_reg           <= reset;
         hst_dv_reg          <= hst_dv;
         cmd_reg             <= cmd;
         adc_spi_rw_done_reg <= adc_spi_rw_done;

         case sm_state is
            
            when idle_st =>
               trig_start_str_int <= '0';
               trig_stop_str_int  <= '0';
               local_we_int       <= '0';
               source_int         <= '0';
               adc_spi_rw_int     <= '0';
               adc_wr_en_int      <= '0';
               -- soft reset and crear commands are handled at the top-level
               if ((hst_dv_reg = '1') and (cmd_reg /= cmd_reset_c) and (cmd_reg /= cmd_clear_err_c)) then
                  hst_ack_int <= '1';
                  sm_state    <= hst_ack_st;
               else
                  hst_ack_int <= '0';
                  sm_state    <= idle_st;
               end if;

            when hst_ack_st =>
               hst_ack_int <= '0';
               sm_state    <= cmd_decode_st;

            when cmd_decode_st =>
               if (cmd_reg = cmd_fetch_c) then
                  source_int <= '1';
                  sm_state   <= adc_source_st;
               elsif (cmd_reg = cmd_write_c) then
                  source_int <= '0';
                  sm_state   <= hst_source_st;
               elsif (cmd_reg = cmd_stop_str_c) then
                  trig_stop_str_int <= '1';
                  sm_state          <= stop_streaming_st;
               elsif (cmd_reg = cmd_start_str_c) then
                  trig_start_str_int <= '1';
                  sm_state           <= start_streaming_st;
               else
                  trig_start_str_int <= '0';
                  trig_stop_str_int  <= '0';
                  sm_state           <= idle_st;
               end if;

            when start_streaming_st =>
               trig_start_str_int <= '0';
               sm_state           <= idle_st;

            when stop_streaming_st =>
               trig_stop_str_int <= '0';
               sm_state          <= idle_st;

            when hst_source_st =>
               local_we_int <= '1';
               sm_state     <= hst_write_reg_st;

            when hst_write_reg_st =>
               local_we_int   <= '0';
               adc_wr_en_int  <= '1';
               adc_spi_rw_int <= '1';
               sm_state       <= adc_wait_ack_st;

            when adc_wait_ack_st =>
               adc_wr_en_int <= '0';
               if (reset_reg = '1') then
                  sm_state <= idle_st;
               else
                  if (adc_spi_rw_done = '1') then
                     adc_spi_rw_int <= '0';
                     sm_state       <= idle_st;
                  else
                     adc_spi_rw_int <= '1';
                     sm_state       <= sm_state;
                  end if;
               end if;
               
            when adc_source_st =>
               adc_wr_en_int  <= '0';
               adc_spi_rw_int <= '1';
               sm_state       <= adc_read_send_st;

            when adc_read_send_st =>
               if (reset_reg = '1') then
                  sm_state <= idle_st;
               else
                  if (adc_spi_rw_done = '1') then
                     adc_spi_rw_int <= '0';
                     local_we_int   <= '1';
                     sm_state       <= adc_write_req_st;
                  else
                     adc_spi_rw_int <= '1';
                     local_we_int   <= '0';
                     sm_state       <= sm_state;
                  end if;
               end if;

            when adc_write_req_st =>
               local_we_int <= '0';
               source_int   <= '0';
               sm_state     <= idle_st;

            -- unhandled states
            when others =>
               sm_state <= idle_st;

         end case;
         

      end if;  --if rising_edge(clk)

   end process control_sm_process;

end rtl;
-------------------------------------------------------------------------------



