library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adc_spi_wrapper_v1_0_s01_axis is
   port (
      -- Users to add ports here
      read_status     : in  std_logic;
      txfr_status_rdy : out std_logic;
      txfr_status     : out std_logic_vector(7 downto 0);

      -- User ports ends
      -- Do not modify the ports beyond this line

      -- AXI4Stream sink: Clock
      s_axis_aclk    : in  std_logic;
      -- AXI4Stream sink: Reset
      s_axis_aresetn : in  std_logic;
      -- Ready to accept data in
      s_axis_tready  : out std_logic;
      -- Data in
      s_axis_tdata   : in  std_logic_vector(7 downto 0);
      -- Byte qualifier
      s_axis_tstrb   : in  std_logic_vector(0 downto 0);
      -- Indicates boundary of last packet
      s_axis_tlast   : in  std_logic;
      -- Data is in valid
      s_axis_tvalid  : in  std_logic
      );
end adc_spi_wrapper_v1_0_s01_axis;

architecture arch_imp of adc_spi_wrapper_v1_0_s01_axis is

   -- Define the states of state machine
   -- The control state machine oversees the writing of input streaming data to the FIFO,
   -- and outputs the streaming data from the FIFO
   type state is (idle,                 -- This is the initial/idle state 
                  write_fifo);  -- In this state FIFO is written with the
   -- input stream data S_AXIS_TDATA 
   signal axis_tready    : std_logic;
   -- State variable
   signal mst_exec_state : state;
   -- FIFO write enable
   signal fifo_wren      : std_logic;
   -- sink has accepted all the streaming data and stored in FIFO
   signal writes_done    : std_logic;

   signal read_status_reg     : std_logic                    := '0';
   signal read_status_d1      : std_logic                    := '0';
   signal read_status_pending : std_logic                    := '0';
   signal txfr_status_int     : std_logic_vector(7 downto 0) := (others => '0');


begin
   -- I/O Connections assignments

   s_axis_tready <= axis_tready;
   -- Control state machine implementation
   process(s_axis_aclk)
   begin
      if (rising_edge (s_axis_aclk)) then
         if(s_axis_aresetn = '0') then
            -- Synchronous reset (active low)
            mst_exec_state <= idle;
         else
            case (mst_exec_state) is
               when idle =>
                  -- The sink starts accepting tdata when 
                  -- there tvalid is asserted to mark the
                  -- presence of valid streaming data 
                  if (s_axis_tvalid = '1')then
                     mst_exec_state <= write_fifo;
                  else
                     mst_exec_state <= idle;
                  end if;
                  
               when write_fifo =>
                  -- When the sink has accepted all the streaming input data,
                  -- the interface swiches functionality to a streaming master
                  if (writes_done = '1') then
                     mst_exec_state <= idle;
                  else
                     -- The sink accepts and stores tdata 
                     -- into FIFO
                     mst_exec_state <= write_fifo;
                  end if;
                  
               when others =>
                  mst_exec_state <= idle;
                  
            end case;
         end if;
      end if;
   end process;

   -- AXI Streaming Sink 
   -- 
   axis_tready <= '1' when (mst_exec_state = write_fifo) else '0';

   process(s_axis_aclk)
   begin
      if (rising_edge (s_axis_aclk)) then
         if(s_axis_aresetn = '0') then
            writes_done <= '0';
         else
            -- This interface only ever reads a single 8-bit word from
            -- the master, so assert the writes_done signal as soon as
            -- the fifo_wren hoes high
            if (fifo_wren = '1') then
               writes_done <= '1';
            else
               writes_done <= '0';
            end if;
         end if;
      end if;
   end process;

   -- FIFO write enable generation
   fifo_wren <= s_axis_tvalid and axis_tready;


   -- Streaming input data byte is stored
   process(s_axis_aclk)
   begin
      if (rising_edge (s_axis_aclk)) then
         if (fifo_wren = '1') then
            txfr_status_int <= s_axis_tdata;
         end if;
      end if;
   end process;


   -- Add user logic here
   -- assign the outputs
   txfr_status_rdy <= writes_done;
   txfr_status     <= txfr_status_int;

   process(s_axis_aclk)
   begin
      if (rising_edge (s_axis_aclk)) then
         read_status_reg <= read_status;
         read_status_d1  <= read_status_reg;

         -- assert the read status request pending on the rising edge on the input signal
         if(s_axis_aresetn = '0') then
            read_status_pending <= '0';
         else
            if (fifo_wren = '1') then
               read_status_pending <= '0';
            elsif ((read_status_reg = '1') and (read_status_d1 = '0')) then
               read_status_pending <= '1';
            else
               read_status_pending <= read_status_pending;
            end if;  -- if (fifo_wren)
         end if;  -- if(s_axis_aresetn)
      end if;  -- if (rising_edge (s_axis_aclk))
   end process;

   -- User logic ends

end arch_imp;
