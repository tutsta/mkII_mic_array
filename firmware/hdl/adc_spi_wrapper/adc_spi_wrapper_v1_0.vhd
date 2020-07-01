library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adc_spi_wrapper_v1_0 is
   generic (
      g_simulation : boolean := false);
   port (
      -- Users to add ports here
      -- ADC SPI interface signals
      -- Zynq PS side SPI-0 interface signals
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

      -- User ports ends
      -- Do not modify the ports beyond this line


      -- Ports of Axi Slave Bus Interface S00_AXI -- register interface --
      s00_axi_aclk    : in  std_logic;
      s00_axi_aresetn : in  std_logic;
      s00_axi_awaddr  : in  std_logic_vector(5 downto 0);
      s00_axi_awprot  : in  std_logic_vector(2 downto 0);
      s00_axi_awvalid : in  std_logic;
      s00_axi_awready : out std_logic;
      s00_axi_wdata   : in  std_logic_vector(31 downto 0);
      s00_axi_wstrb   : in  std_logic_vector(3 downto 0);
      s00_axi_wvalid  : in  std_logic;
      s00_axi_wready  : out std_logic;
      s00_axi_bresp   : out std_logic_vector(1 downto 0);
      s00_axi_bvalid  : out std_logic;
      s00_axi_bready  : in  std_logic;
      s00_axi_araddr  : in  std_logic_vector(5 downto 0);
      s00_axi_arprot  : in  std_logic_vector(2 downto 0);
      s00_axi_arvalid : in  std_logic;
      s00_axi_arready : out std_logic;
      s00_axi_rdata   : out std_logic_vector(31 downto 0);
      s00_axi_rresp   : out std_logic_vector(1 downto 0);
      s00_axi_rvalid  : out std_logic;
      s00_axi_rready  : in  std_logic;

      -- Ports of Axi Master Bus Interface M00_AXIS -- FIFO-to-AXI Stream interface --
      m00_axis_aclk    : in  std_logic;
      m00_axis_aresetn : in  std_logic;
      m00_axis_tvalid  : out std_logic;
      m00_axis_tdata   : out std_logic_vector(31 downto 0);
      m00_axis_tstrb   : out std_logic_vector(3 downto 0);
      m00_axis_tlast   : out std_logic;
      m00_axis_tready  : in  std_logic;

      -- Ports of Axi Master Bus Interface M01_AXIS -- Datamover command interface --
      m01_axis_aclk    : in  std_logic;
      m01_axis_aresetn : in  std_logic;
      m01_axis_tvalid  : out std_logic;
      m01_axis_tdata   : out std_logic_vector(71 downto 0);
      m01_axis_tstrb   : out std_logic_vector(8 downto 0);
      m01_axis_tlast   : out std_logic;
      m01_axis_tready  : in  std_logic;

      -- Ports of Axi Slave Bus Interface S01_AXIS -- Datamover status interface --
      s01_axis_aclk    : in  std_logic;
      s01_axis_aresetn : in  std_logic;
      s01_axis_tready  : out std_logic;
      s01_axis_tdata   : in  std_logic_vector(7 downto 0);
      s01_axis_tstrb   : in  std_logic_vector(0 downto 0);
      s01_axis_tlast   : in  std_logic;
      s01_axis_tvalid  : in  std_logic
      );
end adc_spi_wrapper_v1_0;

architecture arch_imp of adc_spi_wrapper_v1_0 is


   ---------------------------------------------------------------------------
   --                 CONSTANT, TYPE AND GENERIC DEFINITIONS                --
   ---------------------------------------------------------------------------

   -- NOTE: the Bythe-To-Transfer (BTT) = Max Burst Length x (Streaming Data width)/8
   constant dm_bytes_to_transfer_c : integer := 64;

   type ctrl_sm_states_t is (idle_st,              --00
                             latch_cmd_st,         --01
                             wait_fifo_full_st,    --02
                             send_txfr_cmd_st,     --03
                             read_txfr_stat_st,    -- 04
                             check_txfr_stat_st,   --05
                             inc_burst_cnt_st,     --06
                             check_burst_cnt_st);  --07


   ---------------------------------------------------------------------------
   --                          SIGNAL DECLARATIONS                          --
   ---------------------------------------------------------------------------
   -- State Machine
   signal l_sm_state             : ctrl_sm_states_t              := idle_st;
   signal l_state_decode         : std_logic_vector(3 downto 0);
   signal l_watchdog_cnt         : unsigned(28 downto 0)         := (others => '0');
   signal l_watchdog_err         : std_logic                     := '0';
   signal l_adc_stream_go        : std_logic;
   signal l_adc_stream_go_reg    : std_logic                     := '0';
   signal l_adc_stream_go_rising : std_logic;
   signal l_adc_spi_ctrl_reset   : std_logic;
   signal l_dm_ps_reset          : std_logic;
   signal l_dm_reset_n           : std_logic;
   signal l_dm_start_addr_inc    : std_logic                     := '0';
   signal l_dm_start_addr        : std_logic_vector(31 downto 0);
   signal l_dm_start_addr_latch  : unsigned(31 downto 0)         := (others => '0');
   signal l_dm_bursts            : std_logic_vector(15 downto 0);
   signal l_dm_bursts_latch      : std_logic_vector(15 downto 0) := (others => '0');
   signal l_dm_burst_cnt_inc     : std_logic                     := '0';
   signal l_dm_burst_cnt         : unsigned(15 downto 0)         := (others => '0');
   signal l_dm_burst_cnt_reached : std_logic;
   signal l_dm_send_command      : std_logic;
   signal l_dm_send_done         : std_logic;
   signal l_dm_command_word      : std_logic_vector(71 downto 0);
   signal l_dm_read_status       : std_logic;
   signal l_dm_status_rdy        : std_logic;
   signal l_dm_status            : std_logic_vector(7 downto 0);
   signal l_fifo_dout            : std_logic_vector(31 downto 0);
   signal l_fifo_rden            : std_logic;
   signal l_fifo_full            : std_logic;
   signal l_fifo_empty           : std_logic;


   ---------------------------------------------------------------------------
   --                        COMPONENT DECLARATIONS                         --
   ---------------------------------------------------------------------------
   component adc_spi_wrapper_v1_0_s00_axi
      port (
         adc_stream_go      : out std_logic;
         adc_spi_ctrl_reset : out std_logic;
         dm_reset_n         : out std_logic;
         dm_start_addr      : out std_logic_vector(31 downto 0);
         dm_bursts          : out std_logic_vector(15 downto 0);
         dm_status          : in  std_logic_vector(7 downto 0);
         s_axi_aclk         : in  std_logic;
         s_axi_aresetn      : in  std_logic;
         s_axi_awaddr       : in  std_logic_vector(5 downto 0);
         s_axi_awprot       : in  std_logic_vector(2 downto 0);
         s_axi_awvalid      : in  std_logic;
         s_axi_awready      : out std_logic;
         s_axi_wdata        : in  std_logic_vector(31 downto 0);
         s_axi_wstrb        : in  std_logic_vector(3 downto 0);
         s_axi_wvalid       : in  std_logic;
         s_axi_wready       : out std_logic;
         s_axi_bresp        : out std_logic_vector(1 downto 0);
         s_axi_bvalid       : out std_logic;
         s_axi_bready       : in  std_logic;
         s_axi_araddr       : in  std_logic_vector(5 downto 0);
         s_axi_arprot       : in  std_logic_vector(2 downto 0);
         s_axi_arvalid      : in  std_logic;
         s_axi_arready      : out std_logic;
         s_axi_rdata        : out std_logic_vector(31 downto 0);
         s_axi_rresp        : out std_logic_vector(1 downto 0);
         s_axi_rvalid       : out std_logic;
         s_axi_rready       : in  std_logic);
   end component;

   component adc_spi_wrapper_v1_0_m00_axis
      generic (
         c_m_start_count : integer);
      port (
         fifo_din       : in  std_logic_vector(31 downto 0);
         fifo_rden      : out std_logic;
         fifo_empty     : in  std_logic;
         fifo_full      : in  std_logic;
         m_axis_aclk    : in  std_logic;
         m_axis_aresetn : in  std_logic;
         m_axis_tvalid  : out std_logic;
         m_axis_tdata   : out std_logic_vector(31 downto 0);
         m_axis_tstrb   : out std_logic_vector(3 downto 0);
         m_axis_tlast   : out std_logic;
         m_axis_tready  : in  std_logic);
   end component;

   component adc_spi_wrapper_v1_0_m01_axis
      port (
         datamover_command_word : in  std_logic_vector(71 downto 0);
         send_command           : in  std_logic;
         send_done              : out std_logic;
         m_axis_aclk            : in  std_logic;
         m_axis_aresetn         : in  std_logic;
         m_axis_tvalid          : out std_logic;
         m_axis_tdata           : out std_logic_vector(71 downto 0);
         m_axis_tstrb           : out std_logic_vector(8 downto 0);
         m_axis_tlast           : out std_logic;
         m_axis_tready          : in  std_logic);
   end component;

   component adc_spi_wrapper_v1_0_s01_axis
      port (
         read_status     : in  std_logic;
         txfr_status_rdy : out std_logic;
         txfr_status     : out std_logic_vector(7 downto 0);
         s_axis_aclk     : in  std_logic;
         s_axis_aresetn  : in  std_logic;
         s_axis_tready   : out std_logic;
         s_axis_tdata    : in  std_logic_vector(7 downto 0);
         s_axis_tstrb    : in  std_logic_vector(0 downto 0);
         s_axis_tlast    : in  std_logic;
         s_axis_tvalid   : in  std_logic);
   end component;

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

begin

-- Instantiation of ADC SPI streaming interface
   adc_spi_stream_wrap_1 : adc_spi_stream_wrap
      generic map (
         g_implementation => not(g_simulation))
      port map (
         clk         => s00_axi_aclk,
         reset       => l_adc_spi_ctrl_reset,
         stream_go   => l_adc_stream_go,
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
         fifo_dout   => l_fifo_dout,
         fifo_rden   => l_fifo_rden,
         fifo_full   => l_fifo_full,
         fifo_empty  => l_fifo_empty);

-- Instantiation of Axi Bus Interface S00_AXI
   -- Register interface to the Zynq PS software
   adc_spi_wrapper_v1_0_s00_axi_inst : adc_spi_wrapper_v1_0_s00_axi
      port map (
         adc_stream_go      => l_adc_stream_go,
         adc_spi_ctrl_reset => l_adc_spi_ctrl_reset,
         dm_reset_n         => l_dm_ps_reset,
         dm_start_addr      => l_dm_start_addr,
         dm_bursts          => l_dm_bursts,
         dm_status          => l_dm_status,
         s_axi_aclk         => s00_axi_aclk,
         s_axi_aresetn      => s00_axi_aresetn,
         s_axi_awaddr       => s00_axi_awaddr,
         s_axi_awprot       => s00_axi_awprot,
         s_axi_awvalid      => s00_axi_awvalid,
         s_axi_awready      => s00_axi_awready,
         s_axi_wdata        => s00_axi_wdata,
         s_axi_wstrb        => s00_axi_wstrb,
         s_axi_wvalid       => s00_axi_wvalid,
         s_axi_wready       => s00_axi_wready,
         s_axi_bresp        => s00_axi_bresp,
         s_axi_bvalid       => s00_axi_bvalid,
         s_axi_bready       => s00_axi_bready,
         s_axi_araddr       => s00_axi_araddr,
         s_axi_arprot       => s00_axi_arprot,
         s_axi_arvalid      => s00_axi_arvalid,
         s_axi_arready      => s00_axi_arready,
         s_axi_rdata        => s00_axi_rdata,
         s_axi_rresp        => s00_axi_rresp,
         s_axi_rvalid       => s00_axi_rvalid,
         s_axi_rready       => s00_axi_rready
         );

-- Instantiation of Axi Bus Interface M00_AXIS
   -- FIFO-to-AXI stream interface for ADC streaming sample data
   adc_spi_wrapper_v1_0_m00_axis_inst : adc_spi_wrapper_v1_0_m00_axis
      generic map (
         c_m_start_count => 32
         )
      port map (
         fifo_din       => l_fifo_dout,
         fifo_rden      => l_fifo_rden,
         fifo_empty     => l_fifo_empty,
         fifo_full      => l_fifo_full,
         m_axis_aclk    => m00_axis_aclk,
         m_axis_aresetn => m00_axis_aresetn,
         m_axis_tvalid  => m00_axis_tvalid,
         m_axis_tdata   => m00_axis_tdata,
         m_axis_tstrb   => m00_axis_tstrb,
         m_axis_tlast   => m00_axis_tlast,
         m_axis_tready  => m00_axis_tready
         );

-- Instantiation of Axi Bus Interface M01_AXIS
   -- Datamover control interface  
   adc_spi_wrapper_v1_0_m01_axis_inst : adc_spi_wrapper_v1_0_m01_axis
      port map (
         datamover_command_word => l_dm_command_word,
         send_command           => l_dm_send_command,
         send_done              => l_dm_send_done,
         m_axis_aclk            => m01_axis_aclk,
         m_axis_aresetn         => l_dm_reset_n,
         m_axis_tvalid          => m01_axis_tvalid,
         m_axis_tdata           => m01_axis_tdata,
         m_axis_tstrb           => m01_axis_tstrb,
         m_axis_tlast           => m01_axis_tlast,
         m_axis_tready          => m01_axis_tready);

   l_dm_reset_n <= m01_axis_aresetn or not(l_dm_ps_reset);


-- Instantiation of Axi Bus Interface S01_AXIS
   -- Datamover status interface
   adc_spi_wrapper_v1_0_s01_axis_inst : adc_spi_wrapper_v1_0_s01_axis
      port map (
         read_status     => l_dm_read_status,
         txfr_status_rdy => l_dm_status_rdy,
         txfr_status     => l_dm_status,
         s_axis_aclk     => s01_axis_aclk,
         s_axis_aresetn  => s01_axis_aresetn,
         s_axis_tready   => s01_axis_tready,
         s_axis_tdata    => s01_axis_tdata,
         s_axis_tstrb    => s01_axis_tstrb,
         s_axis_tlast    => s01_axis_tlast,
         s_axis_tvalid   => s01_axis_tvalid
         );

   -- Add user logic here

   -- assert watchdog error signal when the watchdog timer expires
   -- 2^28 x 50MHz clock cycles = 5.4 seconds
   l_watchdog_err <= l_watchdog_cnt(28);

   l_dm_burst_cnt_reached <= '1' when (l_dm_burst_cnt = to_unsigned(dm_bytes_to_transfer_c/4, 15)) else
                             '0';

   -- assign the fields of the datamover command word
   -- See page 29 of pg022_axi_datamover.pdf (AXI DataMover v5.1)
   -- NOTE: the Bythe-To-Transfer (BTT) for the DataMover basic mode must be
   -- set as: BTT = selected burst lenght x stream data width in bytes
   -- For a max burst length = 16 and stream data width of 32 bits (4 bytes)
   -- the BTT field should be set to 64
   l_dm_command_word <= "0000" &        -- RSVD
                        std_logic_vector(l_dm_burst_cnt(3 downto 0)) &  -- TAG (the 4 LSB's of the burst counter) 
                        std_logic_vector(l_dm_start_addr_latch) &  -- SADDR start address
                        "00000000" &    -- Ignored
                        '1' &  -- Type (1 = increment, 0 = fixed address)
                        "000000000000000" & std_logic_vector(to_unsigned(dm_bytes_to_transfer_c, 8));  -- BTT (Bytes to transfer)


   -- edge detect the stream go signal
   l_adc_stream_go_rising <= l_adc_stream_go and not(l_adc_stream_go_reg);

   -- debug - decode the state machine current state
   l_state_decode <= "0000" when l_sm_state = idle_st else
                     "0001" when l_sm_state = latch_cmd_st else
                     "0010" when l_sm_state = wait_fifo_full_st else
                     "0011" when l_sm_state = send_txfr_cmd_st else
                     "0100" when l_sm_state = read_txfr_stat_st else
                     "0101" when l_sm_state = check_txfr_stat_st else
                     "0110" when l_sm_state = inc_burst_cnt_st else
                     "0111" when l_sm_state = check_burst_cnt_st else
                     "1111";            -- undefined state

   top_control_proc : process(s00_axi_aclk)
   begin
      if rising_edge(s00_axi_aclk) then
         -- register the stream go signal
         l_adc_stream_go_reg <= l_adc_stream_go;

         -- Top-level control state machine
         if ((s00_axi_aresetn = '0') or (l_watchdog_err = '1')) then
            l_sm_state          <= idle_st;
            l_dm_send_command   <= '0';
            l_dm_read_status    <= '0';
            l_dm_burst_cnt_inc  <= '0';
            l_dm_start_addr_inc <= '0';
         else
            case l_sm_state is
               
               when idle_st =>
                  if (l_adc_stream_go_rising = '1') then
                     l_sm_state <= latch_cmd_st;
                  else
                     l_sm_state <= idle_st;
                  end if;
                  
               when latch_cmd_st =>
                  l_sm_state <= wait_fifo_full_st;

               when wait_fifo_full_st =>
                  l_dm_start_addr_inc <= '0';
                  if (l_fifo_full = '1') then
                     l_sm_state        <= send_txfr_cmd_st;
                     l_dm_send_command <= '1';
                  else
                     l_sm_state        <= wait_fifo_full_st;
                     l_dm_send_command <= '0';
                  end if;

               when send_txfr_cmd_st =>
                  l_dm_send_command <= '0';
                  if (l_dm_send_done = '1') then
                     l_sm_state       <= read_txfr_stat_st;
                     l_dm_read_status <= '1';
                  else
                     l_sm_state       <= send_txfr_cmd_st;
                  end if;

               when read_txfr_stat_st =>
                  l_dm_read_status <= '0';
                  if (l_dm_status_rdy = '1') then
                     l_sm_state <= check_txfr_stat_st;
                  else
                     l_sm_state <= read_txfr_stat_st;
                  end if;

               when check_txfr_stat_st =>
                  if (l_dm_status(7) = '1') then
                     l_sm_state         <= inc_burst_cnt_st;
                     l_dm_burst_cnt_inc <= '1';
                  else
                     l_sm_state         <= check_txfr_stat_st;
                     l_dm_burst_cnt_inc <= '0';
                  end if;

               when inc_burst_cnt_st =>
                  l_dm_burst_cnt_inc <= '0';
                  l_sm_state         <= check_burst_cnt_st;

               when check_burst_cnt_st =>
                  if (l_dm_burst_cnt_reached = '1') then
                     l_sm_state          <= idle_st;
                     l_dm_start_addr_inc <= '0';
                  else
                     l_sm_state          <= wait_fifo_full_st;
                     l_dm_start_addr_inc <= '1';
                  end if;

               -- unhandled states
               when others =>
                  l_sm_state <= idle_st;

            end case;
         end if;  --if (l_watchdog_err = '1') then

         -- latch the data mover start address and number of bursts
         if (l_sm_state = latch_cmd_st) then
            l_dm_start_addr_latch <= unsigned(l_dm_start_addr);
            l_dm_bursts_latch     <= l_dm_bursts;
         elsif (l_dm_start_addr_inc = '1') then
            l_dm_start_addr_latch <= l_dm_start_addr_latch + to_unsigned(dm_bytes_to_transfer_c/4, 32);
         end if;

         if ((s00_axi_aresetn = '0') or (l_sm_state = latch_cmd_st)) then
            l_dm_burst_cnt <= (others => '0');
         elsif (l_dm_burst_cnt_inc = '1') then
            l_dm_burst_cnt <= l_dm_burst_cnt + 1;
         else
            l_dm_burst_cnt <= l_dm_burst_cnt;
         end if;

         -- watchdog counter on the state machine
         if (l_sm_state = idle_st) then
            l_watchdog_cnt <= (others => '0');
         else
            l_watchdog_cnt <= l_watchdog_cnt + 1;
         end if;

      end if;  --if rising_edge(s00_axi_aclk)
   end process top_control_proc;

   -- User logic ends

end arch_imp;
