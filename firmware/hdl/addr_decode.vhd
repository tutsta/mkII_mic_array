
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
--   File Name:             addr_decode.vhd
--   Type:                  RTL
--   Contributing authors:  J. Tuthill
--   Created:               Tue Jul 10 17:08:39 2018
--   Template Rev:          1.0
--
--   Title:                 Address decoder module.
--   Description: 
--   
--   Address 0 = Sampling instant control register (32-bits)
--   Address 1 = Data-rate control register (16-bits)
--   Address 2 = Configuration register (8-bits)
--
--   
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



-------------------------------------------------------------------------------
entity addr_decode is
   port (
      clk          : in  std_logic;
      addr         : in  std_logic_vector(1 downto 0);
      samp_inst_en : out std_logic;
      data_rate_en : out std_logic;
      config_en    : out std_logic;
      status_en    : out std_logic;
      trans_len    : out std_logic_vector(2 downto 0)
      );
end addr_decode;

-------------------------------------------------------------------------------
architecture rtl of addr_decode is


   ---------------------------------------------------------------------------
   --                 CONSTANT, TYPE AND GENERIC DEFINITIONS                --
   ---------------------------------------------------------------------------


   ---------------------------------------------------------------------------
   --                          SIGNAL DECLARATIONS                          --
   ---------------------------------------------------------------------------
   signal s_addr_reg         : std_logic_vector(2 downto 0) := "000";
   signal s_samp_inst_en     : std_logic;
   signal s_samp_inst_en_int : std_logic                    := '0';
   signal s_data_rate_en     : std_logic;
   signal s_data_rate_en_int : std_logic                    := '0';
   signal s_config_en        : std_logic;
   signal s_config_en_int    : std_logic                    := '0';
   signal s_status_en        : std_logic;
   signal s_status_en_int    : std_logic                    := '0';
   signal s_trans_len        : std_logic_vector(2 downto 0);
   signal s_trans_len_int    : std_logic_vector(2 downto 0) := "000";


   ---------------------------------------------------------------------------
   --                        COMPONENT DECLARATIONS                         --
   ---------------------------------------------------------------------------



begin


   ---------------------------------------------------------------------------
   --                    INSTANTIATE COMPONENTS                             --
   ---------------------------------------------------------------------------
   s_samp_inst_en <= '1' when (s_addr_reg = "00") else
                     '0';
   s_data_rate_en <= '1' when (s_addr_reg = "01") else
                     '0';
   s_config_en <= '1' when (s_addr_reg = "10") else
                  '0';
   s_status_en <= '1' when (s_addr_reg = "11") else
                  '0';

   -- assign the transaction length (units of bytes)
   s_trans_len <= "100" when (s_addr_reg = "00") else  -- samp. inst. control
                  "010" when (s_addr_reg = "01") else  -- data rate control
                  "001" when (s_addr_reg = "10") else  -- configuration
                  "000";

   -- assign the output signals
   samp_inst_en <= s_samp_inst_en_int;
   data_rate_en <= s_data_rate_en_int;
   config_en    <= s_config_en_int;
   status_en    <= s_status_en_int;
   trans_len    <= s_trans_len_int;


   ---------------------------------------------------------------------------
   --                      CONCURRENT SIGNAL ASSIGNMENTS                    --
   ---------------------------------------------------------------------------



   ---------------------------------------------------------------------------
   --                         CONCURRENT PROCESSES                          --
   ---------------------------------------------------------------------------

   ---------------------------------------------------------------------------
   --  Process:  ADDR_DECODE_PROCESS  
   --  Purpose:  
   --  Inputs:   
   --  Outputs:  
   ---------------------------------------------------------------------------
   addr_decode_process : process (clk)

   begin
      if rising_edge(clk) then
         --register the incomming address
         s_addr_reg <= addr;

         -- register the decoded enable signals
         s_samp_inst_en_int <= s_samp_inst_en;
         s_data_rate_en_int <= s_data_rate_en;
         s_config_en_int    <= s_config_en;
         s_status_en_int    <= s_status_en;

         -- register the output transaction length
         s_trans_len_int <= s_trans_len;
         
      end if;

   end process addr_decode_process;

end rtl;
-------------------------------------------------------------------------------



