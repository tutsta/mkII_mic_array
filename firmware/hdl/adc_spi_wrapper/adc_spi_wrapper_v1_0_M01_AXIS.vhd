library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adc_spi_wrapper_v1_0_m01_axis is
   port (
      -- Users to add ports here
      datamover_command_word : in  std_logic_vector(71 downto 0);
      send_command           : in  std_logic;
      send_done              : out std_logic;

      -- User ports ends
      -- Do not modify the ports beyond this line

      -- Global ports
      m_axis_aclk    : in  std_logic;
      -- 
      m_axis_aresetn : in  std_logic;
      -- Master Stream Ports. TVALID indicates that the master is driving a valid transfer, A transfer takes place when both TVALID and TREADY are asserted. 
      m_axis_tvalid  : out std_logic;
      -- TDATA is the primary payload that is used to provide the data that is passing across the interface from the master.
      m_axis_tdata   : out std_logic_vector(71 downto 0);
      -- TSTRB is the byte qualifier that indicates whether the content of the associated byte of TDATA is processed as a data byte or a position byte.
      m_axis_tstrb   : out std_logic_vector(8 downto 0);
      -- TLAST indicates the boundary of a packet.
      m_axis_tlast   : out std_logic;
      -- TREADY indicates that the slave can accept a transfer in the current cycle.
      m_axis_tready  : in  std_logic
      );
end adc_spi_wrapper_v1_0_m01_axis;

architecture implementation of adc_spi_wrapper_v1_0_m01_axis is
   -- Total number of output data                                              
   constant number_of_output_words : integer := 1;


   -- Define the states of state machine                                             
   -- The control state machine oversees the writing of input streaming data to the FIFO,
   -- and outputs the streaming data from the FIFO                                   
   type state is (idle,  -- This is the initial/idle state                    
                  send_stream);  -- In this state the                               
   -- stream data is output through M_AXIS_TDATA        
   -- State variable                                                                 
   signal mst_exec_state : state;

   signal read_pointer : unsigned(1 downto 0) := "00";

   -- AXI Stream internal signals
   --streaming data valid
   signal axis_tvalid       : std_logic;
   --streaming data valid delayed by one clock cycle
   signal axis_tvalid_delay : std_logic;
   --Last of the streaming data 
   signal axis_tlast        : std_logic;
   --Last of the streaming data delayed by one clock cycle
   signal axis_tlast_delay  : std_logic;
   --FIFO implementation signals
   signal stream_data_out   : std_logic_vector(71 downto 0);
   signal tx_en             : std_logic;
   --The master has issued all the streaming data stored in FIFO
   signal tx_done           : std_logic;

   signal send_command_reg     : std_logic := '0';
   signal send_command_d1      : std_logic := '0';
   signal send_command_pending : std_logic := '0';
   signal send_done_int        : std_logic := '0';


begin
   -- I/O Connections assignments

   m_axis_tvalid <= axis_tvalid_delay;
   m_axis_tdata  <= stream_data_out;
   m_axis_tlast  <= axis_tlast_delay;
   m_axis_tstrb  <= (others => '1');


   -- Control state machine implementation                                               
   process(m_axis_aclk)
   begin
      if (rising_edge (m_axis_aclk)) then
         if(m_axis_aresetn = '0') then
            -- Synchronous reset (active low)                                                     
            mst_exec_state <= idle;
         else
            case (mst_exec_state) is
               when idle =>
                  if (send_command_pending = '1') then
                     mst_exec_state <= send_stream;
                  else
                     mst_exec_state <= idle;
                  end if;
                  
               when send_stream =>
                  if (tx_done = '1') then
                     mst_exec_state <= idle;
                  else
                     mst_exec_state <= send_stream;
                  end if;
                  
               when others =>
                  mst_exec_state <= idle;
                  
            end case;
         end if;
      end if;
   end process;


   --tvalid generation
   --axis_tvalid is asserted when the control state machine's state is SEND_STREAM and
   --number of output streaming data is less than the NUMBER_OF_OUTPUT_WORDS.
   axis_tvalid <= '1' when ((mst_exec_state = send_stream) and (read_pointer < to_unsigned(number_of_output_words, 2))) else '0';

   -- AXI tlast generation                                                                        
   -- axis_tlast is asserted number of output streaming data is NUMBER_OF_OUTPUT_WORDS-1          
   -- (0 to NUMBER_OF_OUTPUT_WORDS-1)                                                             
   axis_tlast <= '1' when (read_pointer = to_unsigned(number_of_output_words-1, 2)) else '0';

   -- Delay the axis_tvalid and axis_tlast signal by one clock cycle                              
   -- to match the latency of M_AXIS_TDATA                                                        
   process(m_axis_aclk)
   begin
      if (rising_edge (m_axis_aclk)) then
         if(m_axis_aresetn = '0') then
            axis_tvalid_delay <= '0';
            axis_tlast_delay  <= '0';
         else
            axis_tvalid_delay <= axis_tvalid;
            axis_tlast_delay  <= axis_tlast;
         end if;
      end if;
   end process;


   --read_pointer pointer

   process(m_axis_aclk)
   begin
      if (rising_edge (m_axis_aclk)) then
         if(m_axis_aresetn = '0') then
            read_pointer <= "00";
            tx_done      <= '0';
         else
            if (read_pointer <= to_unsigned(number_of_output_words-1, 2)) then
               if (tx_en = '1') then
                  -- read pointer is incremented after every read from the FIFO          
                  -- when FIFO read signal is enabled.                                   
                  read_pointer <= read_pointer + 1;
                  tx_done      <= '0';
               end if;
            elsif (read_pointer = to_unsigned(number_of_output_words, 2)) then
               -- tx_done is asserted when NUMBER_OF_OUTPUT_WORDS numbers of streaming data
               -- has been out.                                                         
               tx_done <= '1';
            end if;
         end if;
      end if;
   end process;


   --FIFO read enable generation 

   tx_en <= m_axis_tready and axis_tvalid;

   -- FIFO Implementation                                                          

   -- Streaming output data is read from FIFO                                      
   process(m_axis_aclk)
   begin
      if (rising_edge (m_axis_aclk)) then
         if(m_axis_aresetn = '0') then
            stream_data_out <= (others => '0');
         elsif (tx_en = '1') then  -- && M_AXIS_TSTRB(byte_index)                   
            stream_data_out <= datamover_command_word;
         end if;
      end if;
   end process;

   -- Add user logic here

   send_done <= send_done_int;

   process(m_axis_aclk)
   begin
      if (rising_edge (m_axis_aclk)) then
         send_command_reg <= send_command;
         send_command_d1  <= send_command_reg;

         -- assert the send command pending on the rising edge on the input signal
         if (tx_done = '1') then
            send_command_pending <= '0';
            send_done_int        <= '1';
         elsif ((send_command_reg = '1') and (send_command_d1 = '0')) then
            send_command_pending <= '1';
            send_done_int        <= '0';
         else
            send_command_pending <= send_command_pending;
            send_done_int        <= '0';
         end if;
      end if;
   end process;


   -- User logic ends

end implementation;
