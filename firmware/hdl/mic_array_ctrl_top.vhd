
-------------------------------------------------------------------------------
-- (c) Copyright - John Tuthill - 2017
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
--   File Name:             mic_array_ctrl_top.vhd
--   Type:                  RTL
--   Contributing authors:  J. Tuthill
--   Created:               Mon Sep 25 16:18:16 2017
--   Template Rev:          1.0
--
--   Title:                 Top-level of controller for the mic array FPGA.
--   Description: 
--   
--   Maximum of 8 devices cascadable : 8x4 = 32 channels
--
--   
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mic_array_ctrl_pkg.all;



-------------------------------------------------------------------------------
entity mic_array_ctrl_top is
   port (
      clk   : in std_logic;
      reset : in std_logic;

      -- host SPI interface
      host_cs_l : in  std_logic;
      host_sclk : in  std_logic;
      host_sdi  : in  std_logic;
      host_sdo  : out std_logic;

      -- host parallel interface
      host_usb_data : out std_logic_vector(7 downto 0);
      host_wr_l     : out std_logic;
      host_rd_l     : out std_logic;
      host_si_wua   : out std_logic;

      -- ADC interface
      adc_sclk  : out std_logic;        -- SPI serial clock
      adc_cs    : out std_logic;        -- device chip select
      adc_dout  : in  std_logic;        -- serial data from ADCs
      adc_din   : out std_logic;        -- serial data to ADCs
      adc_drdy  : in  std_logic;        -- conversion result ready
      adc_fault : in  std_logic;        -- ADC fault
      adc_ovflw : in  std_logic         -- ADC overflow

      );
end mic_array_ctrl_top;

-------------------------------------------------------------------------------
architecture rtl of mic_array_ctrl_top is


   ---------------------------------------------------------------------------
   --                 CONSTANT, TYPE AND GENERIC DEFINITIONS                --
   ---------------------------------------------------------------------------


   type top_ctrl_states_t is (idle_st,         --00
                              hst_ack_st,      --01
                              cmd_decode_st);  --02


   ---------------------------------------------------------------------------
   --                          SIGNAL DECLARATIONS                          --
   ---------------------------------------------------------------------------
   -- State Machine
   signal sm_state : top_ctrl_states_t := idle_st;

   -- local top-level signals
   signal s_reset_sum       : std_logic;
   signal s_hard_reset      : std_logic                     := '0';
   signal s_soft_reset      : std_logic                     := '0';
   signal s_clear_regs      : std_logic                     := '0';
   signal s_hst_ack_top     : std_logic                     := '0';
   signal s_hst_dv_reg      : std_logic                     := '0';
   signal s_cmd_reg         : std_logic_vector(2 downto 0)  := cmd_nop_c;
   signal s_local_write_bus : std_logic_vector(31 downto 0) := (others => '0');
   signal s_samp_inst_en    : std_logic;
   signal s_data_rate_en    : std_logic;
   signal s_config_en       : std_logic;
   signal s_status_en       : std_logic;
   signal s_trans_len       : std_logic_vector(2 downto 0);

   -- local registers
   signal s_samp_inst_ctrl_reg : std_logic_vector(31 downto 0) := (others => '0');
   signal s_data_rate_ctrl_reg : std_logic_vector(15 downto 0) := (others => '0');
   signal s_config_reg         : std_logic_vector(7 downto 0)  := (others => '0');
   signal s_status_reg         : std_logic_vector(31 downto 0) := (others => '0');

   -- host SPI signals
   signal s_hst_dv   : std_logic;
   signal s_hst_ack  : std_logic;
   signal s_cmd      : std_logic_vector(2 downto 0);
   signal s_addr     : std_logic_vector(2 downto 0);
   signal s_addr_reg : std_logic_vector(2 downto 0) := "000";
   signal s_hst_din  : std_logic_vector(31 downto 0);
   signal s_hst_dout : std_logic_vector(31 downto 0);

   -- control state machine signals
   signal s_hst_ack_ctrl    : std_logic;
   signal s_adc_wr_en       : std_logic;
   signal s_adc_spi_rw      : std_logic;
   signal s_adc_spi_rw_done : std_logic;
   signal s_local_we        : std_logic;
   signal s_source          : std_logic;
   signal s_trig_start_str  : std_logic;
   signal s_trig_stop_str   : std_logic;

   -- ADC controller signals
   signal s_adc_dout : std_logic_vector(31 downto 0);

   ---------------------------------------------------------------------------
   --                        COMPONENT DECLARATIONS                         --
   ---------------------------------------------------------------------------
   component host_spi
      port (
         clk      : in  std_logic;
         reset    : in  std_logic;
         cs_l     : in  std_logic;
         sclk     : in  std_logic;
         sdi      : in  std_logic;
         sdo      : out std_logic;
         hst_dv   : out std_logic;
         hst_ack  : in  std_logic;
         cmd      : out std_logic_vector(2 downto 0);
         addr     : out std_logic_vector(2 downto 0);
         hst_din  : in  std_logic_vector(31 downto 0);
         hst_dout : out std_logic_vector(31 downto 0));
   end component;

   component control_sm
      port (
         clk             : in  std_logic;
         reset           : in  std_logic;
         hst_dv          : in  std_logic;
         hst_ack         : out std_logic;
         cmd             : in  std_logic_vector(2 downto 0);
         adc_wr_en       : out std_logic;
         adc_spi_rw      : out std_logic;
         adc_spi_rw_done : in  std_logic;
         local_we        : out std_logic;
         source          : out std_logic;
         trig_start_str  : out std_logic;
         trig_stop_str   : out std_logic);
   end component;

   component addr_decode
      port (
         clk          : in  std_logic;
         addr         : in  std_logic_vector(1 downto 0);
         samp_inst_en : out std_logic;
         data_rate_en : out std_logic;
         config_en    : out std_logic;
         status_en    : out std_logic;
         trans_len    : out std_logic_vector(2 downto 0));
   end component;
   

begin


   ---------------------------------------------------------------------------
   --                    INSTANTIATE COMPONENTS                             --
   ---------------------------------------------------------------------------
   host_spi_1 : host_spi
      port map (
         clk      => clk,
         reset    => s_reset_sum,
         cs_l     => host_cs_l,
         sclk     => host_sclk,
         sdi      => host_sdi,
         sdo      => host_sdo,
         hst_dv   => s_hst_dv,
         hst_ack  => s_hst_ack,
         cmd      => s_cmd,
         addr     => s_addr,
         hst_din  => s_hst_din,
         hst_dout => s_hst_dout);

   control_sm_1 : control_sm
      port map (
         clk             => clk,
         reset           => s_reset_sum,
         hst_dv          => s_hst_dv_reg,
         hst_ack         => s_hst_ack_ctrl,
         cmd             => s_cmd_reg,
         adc_wr_en       => s_adc_wr_en,
         adc_spi_rw      => s_adc_spi_rw,
         adc_spi_rw_done => s_adc_spi_rw_done,
         local_we        => s_local_we,
         source          => s_source,
         trig_start_str  => s_trig_start_str,
         trig_stop_str   => s_trig_stop_str);

   addr_decode_1 : addr_decode
      port map (
         clk          => clk,
         addr         => s_addr_reg(1 downto 0),
         samp_inst_en => s_samp_inst_en,
         data_rate_en => s_data_rate_en,
         config_en    => s_config_en,
         status_en    => s_status_en,
         trans_len    => s_trans_len);

   ---------------------------------------------------------------------------
   --                      CONCURRENT SIGNAL ASSIGNMENTS                    --
   ---------------------------------------------------------------------------

   -- chip summary reset
   s_reset_sum <= s_hard_reset or s_soft_reset;

   -- host acknowledge
   s_hst_ack <= s_hst_ack_ctrl or s_hst_ack_top;

   -- host SPI interface input data MUX
   s_hst_din <= s_samp_inst_ctrl_reg when (s_samp_inst_en = '1') else
                ("0000000000000000" & s_data_rate_ctrl_reg) when (s_data_rate_en = '1') else
                ("000000000000000000000000" & s_config_reg) when (s_config_en = '1') else
                s_status_reg                                when (s_status_en = '1') else
                (others => '0');


   ---------------------------------------------------------------------------
   --                         CONCURRENT PROCESSES                          --
   ---------------------------------------------------------------------------

   ---------------------------------------------------------------------------
   --  Process:  MIC_ARRAY_CTRL_TOP_PROCESS  
   --  Purpose:  
   --  Inputs:   
   --  Outputs:  
   ---------------------------------------------------------------------------
   mic_array_ctrl_top_process : process(clk)

   begin
      if rising_edge(clk) then

         -- register hard reset signal
         s_hard_reset <= reset;

         -- register the incomming host signals
         s_hst_dv_reg <= s_hst_dv;
         s_cmd_reg    <= s_cmd;
         s_addr_reg   <= s_addr;

         -- decode reset and clear commands from host
         case sm_state is
            
            when idle_st =>  -- only respond to reset or clear commands
               s_soft_reset <= '0';
               s_clear_regs <= '0';
               if ((s_hst_dv_reg = '1') and ((s_cmd_reg = cmd_reset_c) or (s_cmd_reg = cmd_clear_err_c))) then
                  s_hst_ack_top <= '1';
                  sm_state      <= hst_ack_st;
               else
                  s_hst_ack_top <= '0';
                  sm_state      <= idle_st;
               end if;

            when hst_ack_st =>
               s_hst_ack_top <= '0';
               sm_state      <= cmd_decode_st;

            when cmd_decode_st =>
               sm_state <= idle_st;
               if (s_cmd_reg = cmd_reset_c) then
                  s_clear_regs <= '0';
                  s_soft_reset <= '1';
               elsif (s_cmd_reg = cmd_clear_err_c) then
                  s_clear_regs <= '1';
                  s_soft_reset <= '0';
               else
                  s_clear_regs <= '0';
                  s_soft_reset <= '0';
               end if;

            when others =>              -- unhandled states
               s_clear_regs <= '0';
               s_soft_reset <= '0';
               sm_state     <= idle_st;

         end case;

         -- assign the local write bus
         if (s_source = '1') then
            s_local_write_bus <= s_adc_dout;
         else
            s_local_write_bus <= s_hst_dout;
         end if;

         -- store the local write bus into one of the local registers on a
         -- write cycle
         if (s_local_we = '1') then
            if (s_addr_reg = "000") then
               s_samp_inst_ctrl_reg <= s_local_write_bus;
            elsif (s_addr_reg = "001") then
               s_data_rate_ctrl_reg <= s_local_write_bus(15 downto 0);
            elsif (s_addr_reg = "010") then
               s_config_reg <= s_local_write_bus(7 downto 0);
            elsif (s_addr_reg = "011") then
               s_status_reg <= s_local_write_bus;
            end if;
         end if;

      end if;  -- if rising_edge(clk)

   end process mic_array_ctrl_top_process;

   
end rtl;
-------------------------------------------------------------------------------
