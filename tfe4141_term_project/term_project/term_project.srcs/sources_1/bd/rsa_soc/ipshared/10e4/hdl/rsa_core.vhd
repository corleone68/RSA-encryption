--------------------------------------------------------------------------------
-- Author       : Oystein Gjermundnes
-- Organization : Norwegian University of Science and Technology (NTNU)
--                Department of Electronic Systems
--                https://www.ntnu.edu/ies
-- Course       : TFE4141 Design of digital systems 1 (DDS1)
-- Year         : 2018
-- Project      : RSA accelerator
-- License      : This is free and unencumbered software released into the 
--                public domain (UNLICENSE)
--------------------------------------------------------------------------------
-- Purpose: 
--   RSA encryption core template. This core currently computes
--   C = M xor key_n
--
--   Replace/change this module so that it implements the function
--   C = M**key_e mod key_n.
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity rsa_core is
	generic (
		-- Users to add parameters here
    C_BLOCK_SIZE          : integer := 256
	);
  port (
    -----------------------------------------------------------------------------
    -- Clocks and reset
    -----------------------------------------------------------------------------      
    clk                    :  in std_logic;
    reset_n                :  in std_logic;
      
    -----------------------------------------------------------------------------
    -- Slave msgin interface
    -----------------------------------------------------------------------------
    -- Message that will be sent out is valid
    msgin_valid            : in std_logic;   
    -- Slave ready to accept a new message
    msgin_ready            : out std_logic;
    -- Message that will be sent out of the rsa_msgin module
    msgin_data             :  in std_logic_vector(C_BLOCK_SIZE-1 downto 0);
    -- Indicates boundary of last packet
    msgin_last             :  in std_logic;
    
    -----------------------------------------------------------------------------
    -- Master msgout interface
    -----------------------------------------------------------------------------
    -- Message that will be sent out is valid
    msgout_valid            : out std_logic;   
    -- Slave ready to accept a new message
    msgout_ready            :  in std_logic;
    -- Message that will be sent out of the rsa_msgin module
    msgout_data             : out std_logic_vector(C_BLOCK_SIZE-1 downto 0);
    -- Indicates boundary of last packet
    msgout_last             : out std_logic;

    -----------------------------------------------------------------------------
    -- Interface to the register block
    -----------------------------------------------------------------------------    
		key_e_d                 :  in std_logic_vector(C_BLOCK_SIZE-1 downto 0);
    key_n                   :  in std_logic_vector(C_BLOCK_SIZE-1 downto 0);
    rsa_status              : out std_logic_vector(31 downto 0)    
          
  );
end rsa_core;


architecture rtl of rsa_core is
component rsa_exp
    generic(word_length : natural := C_BLOCK_SIZE);
    Port ( M : in STD_LOGIC_VECTOR (word_length -1 downto 0);
           E : in STD_LOGIC_VECTOR (word_length -1 downto 0);
           N : in STD_LOGIC_VECTOR (word_length -1 downto 0);
           data_rdy : out STD_LOGIC;
           data_valid : in std_logic;
           clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           done : out STD_LOGIC;
           received : in std_logic;
           result : out STD_LOGIC_VECTOR (word_length -1 downto 0));
end component;
begin


RSA_CORE1: rsa_exp
    generic map(word_length => C_BLOCK_SIZE)
    Port map(
              M => msgin_data,
              E => key_e_d,
              N => key_n,
              data_rdy => msgin_ready,
              data_valid => msgin_valid,
              clk => clk,
              rst => reset_n,
              done => msgout_valid,
              received => msgout_ready,
              result => msgout_data
              );
              
  msgout_last  <= msgin_last;
  rsa_status   <= (others => '0');
end rtl;
