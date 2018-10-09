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
--   File Name:             mic_array_ctrl_pkg.vhd
--   Type:                  RTL
--   Contributing authors:  J. Tuthill
--   Created:               Mon Sep 25 16:18:16 2017
--   Template Rev:          1.0
--
--   Title:                 Definitions package for the microphone array
--                          controller firmware.
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

package mic_array_ctrl_pkg is

   -- command constants
   constant cmd_nop_c       : std_logic_vector(2 downto 0) := "000";
   constant cmd_fetch_c     : std_logic_vector(2 downto 0) := "001";
   constant cmd_read_c      : std_logic_vector(2 downto 0) := "010";
   constant cmd_write_c     : std_logic_vector(2 downto 0) := "011";
   constant cmd_start_str_c : std_logic_vector(2 downto 0) := "100";
   constant cmd_stop_str_c  : std_logic_vector(2 downto 0) := "101";
   constant cmd_clear_err_c : std_logic_vector(2 downto 0) := "110";
   constant cmd_reset_c     : std_logic_vector(2 downto 0) := "111";

end;

package body mic_array_ctrl_pkg is
--Empty
end package body;


