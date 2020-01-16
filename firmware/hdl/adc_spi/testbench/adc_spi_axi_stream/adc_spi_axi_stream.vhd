
-------------------------------------------------------------------------------
-- (c) Copyright - 2020
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
--   File Name:             adc_spi_axi_stream.vhd
--   Type:                  RTL
--   Contributing authors:  J. Tuthill
--   Created:               Sat Jan 11 11:43:11 2020
--   Template Rev:          1.0
--
--   Title:                 Top-level wrapper for testing the ADC SPI to AXI interface
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
entity adc_spi_axi_stream is
   generic (
      g_implementation : boolean := true  -- set true for implementation, false for simulation
      );
   port (
      -- clocks and resets
      clk              : in std_logic;
      reset            : in std_logic;
      m00_axis_aresetn : in std_logic;

      -- PS host SPI interface and control signals
      stream_go   : in  std_logic;
      spi0_sclk_i : out std_logic;
      spi0_sclk_o : in  std_logic;
      spi0_mosi_i : out std_logic;
      spi0_mosi_o : in  std_logic;
      spi0_miso_i : out std_logic;
      spi0_ss_i   : out std_logic;
      spi0_ss_o   : in  std_logic;

      -- ADC SPI external interface signls
      spi_sclk   : out std_logic;
      spi_mosi   : out std_logic;
      spi_miso   : in  std_logic;
      spi_ss     : out std_logic;
      adc_drdy_n : in  std_logic;

      -- AXI-S master interface signals
      m00_axis_tvalid : out std_logic;
      m00_axis_tdata  : out std_logic_vector(31 downto 0);
      m00_axis_tstrb  : out std_logic_vector(3 downto 0);
      m00_axis_tlast  : out std_logic;
      m00_axis_tready : in  std_logic
      );
end adc_spi_axi_stream;

-------------------------------------------------------------------------------
architecture rtl of adc_spi_axi_stream is


   ---------------------------------------------------------------------------
   --                 CONSTANT, TYPE AND GENERIC DEFINITIONS                --
   ---------------------------------------------------------------------------

   constant c_m00_axis_tdata_width : integer := 32;
   constant c_m00_axis_start_count : integer := 32;

   ---------------------------------------------------------------------------
   --                          SIGNAL DECLARATIONS                          --
   ---------------------------------------------------------------------------
   signal s_fifo_dout  : std_logic_vector(31 downto 0);
   signal s_fifo_rden  : std_logic;
   signal s_fifo_full  : std_logic;
   signal s_fifo_empty : std_logic;

   ---------------------------------------------------------------------------
   --                        COMPONENT DECLARATIONS                         --
   ---------------------------------------------------------------------------

   component adc_spi_stream_wrap
      generic (
         g_implementation : boolean);
      port (
         clk         : in  std_logic;
         reset       : in  std_logic;
         stream_go   : in  std_logic;
         spi0_sclk_i : out std_logic;
         spi0_sclk_o : in  std_logic;
         spi0_mosi_i : out std_logic;
         spi0_mosi_o : in  std_logic;
         spi0_miso_i : out std_logic;
         spi0_ss_i   : out std_logic;
         spi0_ss_o   : in  std_logic;
         spi_sclk    : out std_logic;
         spi_mosi    : out std_logic;
         spi_miso    : in  std_logic;
         spi_ss      : out std_logic;
         adc_drdy_n  : in  std_logic;
         fifo_dout   : out std_logic_vector(31 downto 0);
         fifo_rden   : in  std_logic;
         fifo_full   : out std_logic;
         fifo_empty  : out std_logic);
   end component;

   component fifo2axi4s_v1_0
      generic (
         c_m00_axis_tdata_width : integer;
         c_m00_axis_start_count : integer);
      port (
         fifo_din         : in  std_logic_vector(31 downto 0);
         fifo_rden        : out std_logic;
         fifo_empty       : in  std_logic;
         fifo_full        : in  std_logic;
         m00_axis_aclk    : in  std_logic;
         m00_axis_aresetn : in  std_logic;
         m00_axis_tvalid  : out std_logic;
         m00_axis_tdata   : out std_logic_vector(c_m00_axis_tdata_width-1 downto 0);
         m00_axis_tstrb   : out std_logic_vector((c_m00_axis_tdata_width/8)-1 downto 0);
         m00_axis_tlast   : out std_logic;
         m00_axis_tready  : in  std_logic);
   end component;

begin


   ---------------------------------------------------------------------------
   --                    INSTANTIATE COMPONENTS                             --
   ---------------------------------------------------------------------------

   adc_spi_stream_wrap_1 : adc_spi_stream_wrap
      generic map (
         g_implementation => g_implementation)
      port map (
         clk         => clk,
         reset       => reset,
         stream_go   => stream_go,
         spi0_sclk_i => spi0_sclk_i,
         spi0_sclk_o => spi0_sclk_o,
         spi0_mosi_i => spi0_mosi_i,
         spi0_mosi_o => spi0_mosi_o,
         spi0_miso_i => spi0_miso_i,
         spi0_ss_i   => spi0_ss_i,
         spi0_ss_o   => spi0_ss_o,
         spi_sclk    => spi_sclk,
         spi_mosi    => spi_mosi,
         spi_miso    => spi_miso,
         spi_ss      => spi_ss,
         adc_drdy_n  => adc_drdy_n,
         fifo_dout   => s_fifo_dout,
         fifo_rden   => s_fifo_rden,
         fifo_full   => s_fifo_full,
         fifo_empty  => s_fifo_empty);

   fifo2axi4s_v1_0_1 : fifo2axi4s_v1_0
      generic map (
         c_m00_axis_tdata_width => c_m00_axis_tdata_width,
         c_m00_axis_start_count => c_m00_axis_start_count)
      port map (
         fifo_din         => s_fifo_dout,
         fifo_rden        => s_fifo_rden,
         fifo_empty       => s_fifo_empty,
         fifo_full        => s_fifo_full,
         m00_axis_aclk    => clk,
         m00_axis_aresetn => m00_axis_aresetn,
         m00_axis_tvalid  => m00_axis_tvalid,
         m00_axis_tdata   => m00_axis_tdata,
         m00_axis_tstrb   => m00_axis_tstrb,
         m00_axis_tlast   => m00_axis_tlast,
         m00_axis_tready  => m00_axis_tready);

   ---------------------------------------------------------------------------
   --                      CONCURRENT SIGNAL ASSIGNMENTS                    --
   ---------------------------------------------------------------------------


   ---------------------------------------------------------------------------
   --                         CONCURRENT PROCESSES                          --
   ---------------------------------------------------------------------------

   ---------------------------------------------------------------------------
   --  Process:  ADC_SPI_AXI_STREAM_PROCESS  
   --  Purpose:  
   --  Inputs:   
   --  Outputs:  
   ---------------------------------------------------------------------------
--    ADC_SPI_AXI_STREAM_PROCESS : process

--    begin

--    end process ADC_SPI_AXI_STREAM_PROCESS;

end rtl;
-------------------------------------------------------------------------------
