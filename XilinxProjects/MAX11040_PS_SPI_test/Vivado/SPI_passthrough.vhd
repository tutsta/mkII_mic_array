
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
      spi_ss   : out std_logic

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
   
   spi_sclk_obuf : obuf
      port map (
         i => spi0_sclk_o,
         o => spi_sclk);

   spi_mosi_obuf : obuf
      port map (
         i => spi0_mosi_o,
         o => spi_mosi);

   spi_miso_ibuf : ibuf
      port map (
         i => spi_miso,
         o => spi0_miso_i);

   spi_cs_obuf : obuf
      port map (
         i => spi0_ss_o,
         o => spi_ss);

   ---------------------------------------------------------------------------
   --                      CONCURRENT SIGNAL ASSIGNMENTS                    --
   ---------------------------------------------------------------------------

   spi0_ss_i   <= '1';
   spi0_sclk_i <= '1';
   spi0_mosi_i <= '0';

   ---------------------------------------------------------------------------
   --                         CONCURRENT PROCESSES                          --
   ---------------------------------------------------------------------------   

end rtl;
-------------------------------------------------------------------------------



