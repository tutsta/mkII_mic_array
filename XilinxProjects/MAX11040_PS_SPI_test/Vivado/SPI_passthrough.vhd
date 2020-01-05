
-------------------------------------------------------------------------------
-- (c) Copyright - 2019
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
--   File Name:             SPI_passthrough.vhd
--   Type:                  RTL
--   Contributing authors:  J. Tuthill
--   Created:               Mon Dec 30 11:53:58 2019
--   Template Rev:          1.0
--
--   Title:                 Simple signal passthrough and IO buffer module.
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
entity spi_passthrough is
   port (

      -- PS side interface signals
      ps_spi_ovrd : in  std_logic;
      spi0_sclk_i : out std_logic;
      spi0_sclk_o : in  std_logic;
      spi0_sclk_t : in  std_logic;
      spi0_mosi_i : out std_logic;
      spi0_mosi_o : in  std_logic;
      spi0_mosi_t : in  std_logic;
      spi0_miso_i : out std_logic;
      spi0_miso_o : in  std_logic;
      spi0_miso_t : in  std_logic;
      spi0_ss_i   : out std_logic;
      spi0_ss_o   : in  std_logic;
      spi0_ss_t   : in  std_logic;
      spi0_ss1_o  : in  std_logic;
      spi0_ss2_o  : in  std_logic;

      -- external chip connections
      spi_sclk : out std_logic;
      spi_mosi : out std_logic;
      spi_miso : in  std_logic;
      spi_ss   : out std_logic;

      led_test : out std_logic

      );
end spi_passthrough;

-------------------------------------------------------------------------------
architecture rtl of spi_passthrough is


   ---------------------------------------------------------------------------
   --                 CONSTANT, TYPE AND GENERIC DEFINITIONS                --
   ---------------------------------------------------------------------------


   ---------------------------------------------------------------------------
   --                          SIGNAL DECLARATIONS                          --
   ---------------------------------------------------------------------------
   signal s_local_spi_sclk : std_logic;
   signal s_local_spi_mosi : std_logic;
   signal s_local_spi_miso : std_logic;
   signal s_local_spi_ss   : std_logic;

   -- these signals are here temporarily to mimic the custom SPI signals that
   -- would be coming from the streaming controller
   signal s_extern_spi_sclk : std_logic;
   signal s_extern_spi_mosi : std_logic;
   signal s_extern_spi_miso : std_logic;
   signal s_extern_spi_ss   : std_logic;
   ---------------------------------------------------------------------------
   --                        COMPONENT DECLARATIONS                         --
   ---------------------------------------------------------------------------

   component obuf is
      port (
         i : in  std_logic;
         o : out std_logic
         );
   end component obuf;

   component ibuf is
      port (
         i : in  std_logic;
         o : out std_logic
         );
   end component ibuf;


begin


   ---------------------------------------------------------------------------
   --                    INSTANTIATE COMPONENTS                             --
   ---------------------------------------------------------------------------

   
   s_local_spi_sclk <= spi0_sclk_o when (ps_spi_ovrd = '1') else
                       s_extern_spi_sclk;
   
   spi_sclk_obuf : obuf
      port map (
         i => s_local_spi_sclk,
         o => spi_sclk);

   s_local_spi_mosi <= spi0_mosi_o when (ps_spi_ovrd = '1') else
                       s_extern_spi_mosi;
   
   spi_mosi_obuf : obuf
      port map (
         i => s_local_spi_mosi,
         o => spi_mosi);

   spi_miso_ibuf : ibuf
      port map (
         i => spi_miso,
         o => s_local_spi_miso);

   spi0_miso_i <= s_local_spi_miso when (ps_spi_ovrd = '1') else
                  '0';
   s_extern_spi_miso <= s_local_spi_miso when (ps_spi_ovrd = '0') else
                        '0';

   s_local_spi_ss <= spi0_ss_o when (ps_spi_ovrd = '1') else
                     s_extern_spi_ss;
   spi_cs_obuf : obuf
      port map (
         i => s_local_spi_ss,
         o => spi_ss);

   test_led_obuf : obuf
      port map (
         i => ps_spi_ovrd,
         o => led_test);

   ---------------------------------------------------------------------------
   --                      CONCURRENT SIGNAL ASSIGNMENTS                    --
   ---------------------------------------------------------------------------

   spi0_ss_i   <= '1';
   spi0_sclk_i <= '1';
   spi0_mosi_i <= '0';

   -- TEMPORARY
   s_extern_spi_sclk <= '1';
   s_extern_spi_mosi <= '0';
   s_extern_spi_ss   <= '1';

   ---------------------------------------------------------------------------
   --                         CONCURRENT PROCESSES                          --
   ---------------------------------------------------------------------------   

end rtl;
-------------------------------------------------------------------------------



