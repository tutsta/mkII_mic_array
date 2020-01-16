library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fifo2axi4s_v1_0 is
   generic (
      -- Users to add parameters here

      -- User parameters ends
      -- Do not modify the parameters beyond this line


      -- Parameters of Axi Master Bus Interface M00_AXIS
      c_m00_axis_tdata_width : integer := 32;
      c_m00_axis_start_count : integer := 32
      );
   port (
      -- Users to add ports here
      fifo_din   : in  std_logic_vector(31 downto 0);
      fifo_rden  : out std_logic;
      fifo_empty : in  std_logic;
      fifo_full  : in  std_logic;

      -- User ports ends
      -- Do not modify the ports beyond this line


      -- Ports of Axi Master Bus Interface M00_AXIS
      m00_axis_aclk    : in  std_logic;
      m00_axis_aresetn : in  std_logic;
      m00_axis_tvalid  : out std_logic;
      m00_axis_tdata   : out std_logic_vector(c_m00_axis_tdata_width-1 downto 0);
      m00_axis_tstrb   : out std_logic_vector((c_m00_axis_tdata_width/8)-1 downto 0);
      m00_axis_tlast   : out std_logic;
      m00_axis_tready  : in  std_logic
      );
end fifo2axi4s_v1_0;

architecture arch_imp of fifo2axi4s_v1_0 is

   signal s_fifo_data_rdy : std_logic := '0';

   -- component declaration
   component fifo2axi4s_v1_0_m00_axis is
      generic (
         c_m_axis_tdata_width : integer := 32;
         c_m_start_count      : integer := 32
         );
      port (
         fifo_data_rdy  : in  std_logic;
         fifo_din       : in  std_logic_vector(31 downto 0);
         fifo_rden      : out std_logic;
         m_axis_aclk    : in  std_logic;
         m_axis_aresetn : in  std_logic;
         m_axis_tvalid  : out std_logic;
         m_axis_tdata   : out std_logic_vector(c_m00_axis_tdata_width-1 downto 0);
         m_axis_tstrb   : out std_logic_vector((c_m00_axis_tdata_width/8)-1 downto 0);
         m_axis_tlast   : out std_logic;
         m_axis_tready  : in  std_logic
         );
   end component fifo2axi4s_v1_0_m00_axis;

begin

-- Instantiation of Axi Bus Interface M00_AXIS
   fifo2axi4s_v1_0_m00_axis_inst : fifo2axi4s_v1_0_m00_axis
      generic map (
         c_m_axis_tdata_width => c_m00_axis_tdata_width,
         c_m_start_count      => c_m00_axis_start_count
         )
      port map (
         fifo_data_rdy  => s_fifo_data_rdy,
         fifo_din       => fifo_din,
         fifo_rden      => fifo_rden,
         m_axis_aclk    => m00_axis_aclk,
         m_axis_aresetn => m00_axis_aresetn,
         m_axis_tvalid  => m00_axis_tvalid,
         m_axis_tdata   => m00_axis_tdata,
         m_axis_tstrb   => m00_axis_tstrb,
         m_axis_tlast   => m00_axis_tlast,
         m_axis_tready  => m00_axis_tready
         );

   -- Add user logic here
   fifo_data_ready_proc : process (m00_axis_aclk)
   begin
      if rising_edge(m00_axis_aclk) then
         if (m00_axis_aresetn = '0') then
            s_fifo_data_rdy <= '0';
         else
            if (fifo_empty = '1') then
               s_fifo_data_rdy <= '0';
            elsif (fifo_full = '1') then
               s_fifo_data_rdy <= '1';
            else
               s_fifo_data_rdy <= s_fifo_data_rdy;
            end if;
         end if;
      end if;  -- if rising_edge(m00_axis_aclk)
   end process fifo_data_ready_proc;

   -- User logic ends

end arch_imp;
