
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
--   File Name:             adc_spi_stream_wrap.vhd
--   Type:                  RTL
--   Contributing authors:  J. Tuthill
--   Created:               Thu Jan 09 08:54:31 2020
--   Template Rev:          1.0
--
--   Title:                 Top-level wrapper for the MAX11040 ADC SPI interface.
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
entity adc_spi_stream_wrap is
   generic (
      g_implementation : boolean := true  -- set true for implementation, false for simulation
      );
   port (
      -- clocks and reset
      clk   : in std_logic;
      reset : in std_logic;

      -- Zynq PS side SPI-0 interface signals
      stream_go   : in  std_logic;
      spi0_sclk_i : out std_logic;
      spi0_sclk_o : in  std_logic;
      spi0_mosi_i : out std_logic;
      spi0_mosi_o : in  std_logic;
      spi0_miso_i : out std_logic;
      spi0_ss_i   : out std_logic;
      spi0_ss_o   : in  std_logic;

      -- external chip connections
      spi_sclk   : out std_logic;
      spi_mosi   : out std_logic;
      spi_miso   : in  std_logic;
      spi_ss     : out std_logic;
      adc_drdy_n : in  std_logic;

      -- FIFO read-side interface
      fifo_dout  : out std_logic_vector(31 downto 0);
      fifo_rden  : in  std_logic;
      fifo_full  : out std_logic;
      fifo_empty : out std_logic

      );
end adc_spi_stream_wrap;

-------------------------------------------------------------------------------
architecture rtl of adc_spi_stream_wrap is


   ---------------------------------------------------------------------------
   --                 CONSTANT, TYPE AND GENERIC DEFINITIONS                --
   ---------------------------------------------------------------------------
   
   constant c_sck_div_ratio_pwr : integer := 3;
   constant c_num_devices       : integer := 1;


   ---------------------------------------------------------------------------
   --                          SIGNAL DECLARATIONS                          --
   ---------------------------------------------------------------------------

   -- External ADC SPI interface bus signals
   signal s_adc_spi_cs   : std_logic;
   signal s_adc_spi_sclk : std_logic;
   signal s_adc_spi_dout : std_logic;
   signal s_adc_spi_din  : std_logic;
   signal s_adc_drdy_n   : std_logic;

   -- sample data FIFO signals
   signal s_fifo_din   : std_logic_vector(31 downto 0);
   signal s_fifo_wren  : std_logic;
   signal s_fifo_full  : std_logic;
   signal s_fifo_reset : std_logic;

   ---------------------------------------------------------------------------
   --                        COMPONENT DECLARATIONS                         --
   ---------------------------------------------------------------------------

   component adc_spi_stream
      generic (
         g_sck_ratio_pwr : integer;
         g_num_devices   : integer);
      port (
         clk              : in  std_logic;
         reset            : in  std_logic;
         stream_go        : in  std_logic;
         hst_adc_spi_cs   : in  std_logic;
         hst_adc_spi_sclk : in  std_logic;
         hst_adc_spi_dout : in  std_logic;
         hst_adc_spi_din  : out std_logic;
         adc_spi_cs       : out std_logic;
         adc_spi_sclk     : out std_logic;
         adc_spi_dout     : out std_logic;
         adc_spi_din      : in  std_logic;
         adc_drdy_n       : in  std_logic;
         sample_dout      : out std_logic_vector(31 downto 0);
         fifo_wren        : out std_logic;
         fifo_full        : in  std_logic;
         fifo_reset       : out std_logic);
   end component adc_spi_stream;

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

   component fifo_generator_0
      port (
         clk   : in  std_logic;
         srst  : in  std_logic;
         din   : in  std_logic_vector(31 downto 0);
         wr_en : in  std_logic;
         rd_en : in  std_logic;
         dout  : out std_logic_vector(31 downto 0);
         full  : out std_logic;
         empty : out std_logic);
   end component;

begin


   ---------------------------------------------------------------------------
   --                    INSTANTIATE COMPONENTS                             --
   ---------------------------------------------------------------------------

   impl_io_gen : if g_implementation = true generate
      -- Input and output buffers
      spi_sclk_obuf : obuf
         port map (
            i => s_adc_spi_sclk,
            o => spi_sclk);

      spi_mosi_obuf : obuf
         port map (
            i => s_adc_spi_dout,
            o => spi_mosi);

      spi_miso_ibuf : ibuf
         port map (
            i => spi_miso,
            o => s_adc_spi_din);

      spi_cs_obuf : obuf
         port map (
            i => s_adc_spi_cs,
            o => spi_ss);

      adc_drdy_ibuf : ibuf
         port map (
            i => adc_drdy_n,
            o => s_adc_drdy_n);
   end generate impl_io_gen;

   sim_io_gen : if g_implementation = false generate
      spi_sclk      <= s_adc_spi_sclk;
      spi_mosi      <= s_adc_spi_dout;
      s_adc_spi_din <= spi_miso;
      spi_ss        <= s_adc_spi_cs;
      s_adc_drdy_n  <= adc_drdy_n;
   end generate sim_io_gen;

   -- SPI MUX and streaming controller core
   adc_spi_stream_1 : adc_spi_stream
      generic map (
         g_sck_ratio_pwr => c_sck_div_ratio_pwr,
         g_num_devices   => c_num_devices)
      port map (
         clk              => clk,
         reset            => reset,
         stream_go        => stream_go,
         hst_adc_spi_cs   => spi0_ss_o,
         hst_adc_spi_sclk => spi0_sclk_o,
         hst_adc_spi_dout => spi0_mosi_o,
         hst_adc_spi_din  => spi0_miso_i,
         adc_spi_cs       => s_adc_spi_cs,
         adc_spi_sclk     => s_adc_spi_sclk,
         adc_spi_dout     => s_adc_spi_dout,
         adc_spi_din      => s_adc_spi_din,
         adc_drdy_n       => s_adc_drdy_n,
         sample_dout      => s_fifo_din,
         fifo_wren        => s_fifo_wren,
         fifo_full        => s_fifo_full,
         fifo_reset       => s_fifo_reset);

   fifo_generator_0_1 : fifo_generator_0
      port map (
         clk   => clk,
         srst  => s_fifo_reset,
         din   => s_fifo_din,
         wr_en => s_fifo_wren,
         rd_en => fifo_rden,
         dout  => fifo_dout,
         full  => s_fifo_full,
         empty => fifo_empty);

   ---------------------------------------------------------------------------
   --                      CONCURRENT SIGNAL ASSIGNMENTS                    --
   ---------------------------------------------------------------------------

   fifo_full <= s_fifo_full;

   -- tie unused PS SPI interface signals to recommended levels
   spi0_ss_i   <= '1';
   spi0_sclk_i <= '1';
   spi0_mosi_i <= '0';

   ---------------------------------------------------------------------------
   --                         CONCURRENT PROCESSES                          --
   ---------------------------------------------------------------------------

   ---------------------------------------------------------------------------
   --  Process:  ADC_SPI_STREAM_WRAP_PROCESS  
   --  Purpose:  
   --  Inputs:   
   --  Outputs:  
   ---------------------------------------------------------------------------
--   adc_spi_stream_wrap_process : process

--   begin

--   end process adc_spi_stream_wrap_process;

   
   

end rtl;
-------------------------------------------------------------------------------



