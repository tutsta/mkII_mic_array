
-------------------------------------------------------------------------------
-- (c) Copyright - John Tuthill - 2016
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
--   File Name:             host_spi.vhd
--   Type:                  RTL
--   Contributing authors:  J. Tuthill
--   Created:               Thu Mar 10 07:35:14 2016
--   Template Rev:          1.0
--
--   Title:                 Host SPI control interface.
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
use ieee.std_logic_unsigned.all;


-------------------------------------------------------------------------------
entity host_spi is
   port (
      -- clocks and resets
      clk   : in std_logic;
      reset : in std_logic;

      -- host-side signals
      cs_l : in  std_logic;
      sclk : in  std_logic;
      sdi  : in  std_logic;
      sdo  : out std_logic;

      -- local-side signals
      hst_dv   : out std_logic;
      hst_ack  : in  std_logic;
      cmd      : out std_logic_vector(2 downto 0);
      addr     : out std_logic_vector(2 downto 0);
      hst_din  : in  std_logic_vector(31 downto 0);
      hst_dout : out std_logic_vector(31 downto 0)

      );
end host_spi;

-------------------------------------------------------------------------------
architecture rtl of host_spi is


   ---------------------------------------------------------------------------
   --                 CONSTANT, TYPE AND GENERIC DEFINITIONS                --
   ---------------------------------------------------------------------------

   constant transaction_length_c : integer := 39;  -- total bits in the host transaction
   constant header_len_c         : integer := 7;  -- length of the header including the R/W bit, command bits and address bits
   constant data_start_c         : integer := 9;  -- number of SCLK clocks till the start of the data


   ---------------------------------------------------------------------------
   --                          SIGNAL DECLARATIONS                          --
   ---------------------------------------------------------------------------
   signal reset_reg   : std_logic := '0';
   signal cs_reg      : std_logic := '0';
   signal cs_reg_d1   : std_logic := '0';
   signal cs_rising   : std_logic;
   signal sclk_reg    : std_logic := '0';
   signal sdi_reg     : std_logic := '0';
   signal hst_ack_reg : std_logic := '0';

   signal sclk_reg_d1   : std_logic                     := '0';
   signal sclk_rising   : std_logic;
   signal sclk_falling  : std_logic;
   signal din_des       : std_logic_vector(37 downto 0) := (others => '0');
   signal bit_count_en  : std_logic                     := '0';
   signal bit_count_rst : std_logic                     := '0';
   signal bit_count     : std_logic_vector(5 downto 0)  := "000000";
   signal latch_din     : std_logic;
   signal hst_dv_int    : std_logic                     := '0';
   signal hst_data      : std_logic_vector(37 downto 0) := (others => '0');
   signal sdo_data_en   : std_logic                     := '0';
   signal sdo_int       : std_logic                     := '0';

   signal hst_din_latch   : std_logic_vector(31 downto 0) := (others => '0');
   signal first_bit       : std_logic                     := '0';
   signal first_bit_d1    : std_logic                     := '0';
   signal first_bit_pulse : std_logic;
   signal read_en         : std_logic                     := '0';
   signal read_en_d1      : std_logic                     := '0';
   signal read_en_pulse   : std_logic;



   ---------------------------------------------------------------------------
   --                        COMPONENT DECLARATIONS                         --
   ---------------------------------------------------------------------------



begin


   ---------------------------------------------------------------------------
   --                    INSTANTIATE COMPONENTS                             --
   ---------------------------------------------------------------------------

   -- latch the input de-serialiser when the bit count reaches 39
   latch_din <= '1' when (bit_count = std_logic_vector(to_unsigned(transaction_length_c, 6))) else
                '0';

   ---------------------------------------------------------------------------
   --                      CONCURRENT SIGNAL ASSIGNMENTS                    --
   ---------------------------------------------------------------------------

   cs_rising    <= not(cs_reg) and cs_reg_d1;
   sclk_rising  <= sclk_reg and not(sclk_reg_d1);
   sclk_falling <= not(sclk_reg) and sclk_reg_d1;

   first_bit_pulse <= first_bit and not(first_bit_d1);

   read_en_pulse <= read_en and not(read_en_d1);

   -- assign output signals
   hst_dv   <= hst_dv_int;
   cmd      <= hst_data(37 downto 35);
   addr     <= hst_data(34 downto 32);
   hst_dout <= hst_data(31 downto 0);
   sdo      <= sdo_int;

   ---------------------------------------------------------------------------
   --                         CONCURRENT PROCESSES                          --
   ---------------------------------------------------------------------------

   ---------------------------------------------------------------------------
   --  Process:  HOST_SPI_PROCESS  
   --  Purpose:  
   --  Inputs:   
   --  Outputs:  
   ---------------------------------------------------------------------------
   host_spi_process : process (clk)

   begin
      if rising_edge(clk) then

         -- register input signals
         reset_reg   <= reset;
         cs_reg      <= not(cs_l);
         cs_reg_d1   <= cs_reg;
         sclk_reg    <= sclk;
         sdi_reg     <= sdi;
         hst_ack_reg <= hst_ack;

         -- delay sclk for falling edge detection
         sclk_reg_d1 <= sclk_reg;

         -- enable the input de-serialiser shift register on assertion of cs_l and sclk
         bit_count_en <= cs_reg and sclk_falling;

         -- generate the data transition edge for the out-going serial stream
         sdo_data_en <= cs_reg and sclk_rising;

         -- de-serialise the incomming bit-stream
         bit_count_rst <= latch_din;
         if ((cs_rising = '1') or (reset_reg = '1')) then
            din_des <= (others => '0');
         elsif (bit_count_en = '1') then
            din_des(0) <= sdi_reg;
            for i in 1 to 37 loop
               din_des(i) <= din_des(i-1);
            end loop;
         else
            din_des <= din_des;
         end if;

         -- input serial bit counter and first bit latch
         if ((bit_count_rst = '1') or (reset_reg = '1')) then
            first_bit <= '0';
            bit_count <= "000000";
         elsif (bit_count_en = '1') then
            first_bit <= '1';
            bit_count <= bit_count + 1;
         else
            first_bit <= first_bit;
            bit_count <= bit_count;
         end if;
         first_bit_d1 <= first_bit;

         if (first_bit_pulse = '1') then
            read_en <= sdi_reg;
         else
            read_en <= read_en;
         end if;
         read_en_d1 <= read_en;

         -- host data valid and acknowledge generation logic
         if ((hst_ack_reg = '1') or (reset_reg = '1')) then
            hst_dv_int <= '0';
         elsif (latch_din = '1') then
            hst_dv_int <= '1';
         else
            hst_dv_int <= hst_dv_int;
         end if;

         -- latch the de-serialised host input data bus
         if (reset_reg = '1') then
            hst_data <= (others => '0');
         elsif (latch_din = '1') then
            hst_data <= din_des;
         else
            hst_data <= hst_data;
         end if;

         -- shift out serial data to host
         if ((cs_rising = '1') or (reset_reg = '1')) then
            hst_din_latch <= (others => '0');
         elsif (read_en_pulse = '1') then
            hst_din_latch <= hst_din;
         elsif ((bit_count >= std_logic_vector(to_unsigned(header_len_c, 6))) and (read_en = '1') and (sdo_data_en = '1')) then
            hst_din_latch <= hst_din_latch(30 downto 0) & '0';
         else
            hst_din_latch <= hst_din_latch;
         end if;

         -- clock out the serial data in the correct place in the read cycle
         if ((cs_rising = '1') or (reset_reg = '1')) then
            sdo_int <= '0';
         elsif ((bit_count >= std_logic_vector(to_unsigned(header_len_c, 6))) and (sclk_rising = '1')) then
            sdo_int <= hst_din_latch(31);
         else
            sdo_int <= sdo_int;
         end if;

         
      end if;  -- if rising_edge(clk)

   end process host_spi_process;


end rtl;
-------------------------------------------------------------------------------



