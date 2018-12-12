library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FM_Mod_Mult is
    generic( word_length : natural := 256);
    Port ( N_i : in STD_LOGIC_VECTOR (word_length -1  downto 0);
           X : in STD_LOGIC_VECTOR (word_length -1  downto 0);
           Y : in STD_LOGIC_VECTOR (word_length -1  downto 0);
           NY : in STD_LOGIC_VECTOR (word_length   downto 0);
           enable : in STD_LOGIC;
           ready : out STD_LOGIC;
           result : out STD_LOGIC_VECTOR (word_length -1  downto 0);
           clk : in STD_LOGIC;
           rst : in STD_LOGIC);
end FM_Mod_Mult;

architecture Behavioral of FM_Mod_Mult is
-----------------------Component Declarations--------------------------------------------
component LUT
generic(n : natural := word_length);
    Port ( x_i : in STD_LOGIC;
           y_0 : in STD_LOGIC;
           c_0 : in STD_LOGIC;
           s_0 : in STD_LOGIC;
           MY : in STD_LOGIC_VECTOR (n downto 0);
           M : in STD_LOGIC_VECTOR (n-1 downto 0);
           Y : in STD_LOGIC_VECTOR (n-1 downto 0);
           result : out STD_LOGIC_VECTOR (n downto 0));
end component;

component CSA
      generic( n : natural := word_length);
  Port ( A : in STD_LOGIC_VECTOR (n downto 0);
         B : in STD_LOGIC_VECTOR (n downto 0);
         C : in STD_LOGIC_VECTOR (n downto 0);
         S : out STD_LOGIC_VECTOR (n+1 downto 0);
         C_out : out STD_LOGIC_VECTOR (n+1 downto 0));
end component;

--component r_shift_reg
--     generic( n : natural := word_length);
--   Port ( data : in STD_LOGIC_VECTOR (n + 1 downto 0);
--          rst : in std_logic;
--          clk : in std_logic;
--          wr_e : in std_logic;
--          d_out : out STD_LOGIC_VECTOR (n downto 0);
--          lsb_out : out std_logic);
--end component;

component mod_mult 
    generic(N : natural := word_length);
    Port (
           en : in STD_LOGIC;
           clk: in std_logic;
           rst : in STD_LOGIC;
           X : in STD_LOGIC_VECTOR (N-1 downto 0);
           wr_en : out std_logic;
           xi : out STD_LOGIC;
           dv : out std_logic
           );
end component;

component CLA
    generic(word_length: natural := word_length + 4
            );
            
    Port ( a : in STD_LOGIC_VECTOR (word_length -1  downto 0);
           b : in STD_LOGIC_VECTOR (word_length -1   downto 0);
           cin : in STD_LOGIC;
           --sum : out STD_LOGIC_VECTOR (word_length -1   downto 0);
           --cout : out STD_LOGIC;
           result : out std_logic_vector(word_length -1 downto 0)
            
           );
end component;

component CLS 
    generic(word_length: natural := word_length + 4
            );
            
    Port ( a : in STD_LOGIC_VECTOR (word_length -1  downto 0);
           b : in STD_LOGIC_VECTOR (word_length -1   downto 0);
           cin : in STD_LOGIC;
           --sum : out STD_LOGIC_VECTOR (word_length -1   downto 0);
           --cout : out STD_LOGIC;
           result : out std_logic_vector(word_length -1 downto 0)
            
           );
end component;


component reg 
    generic(N : natural := 16);
    Port ( D : in STD_LOGIC_VECTOR (N downto 0);
           wr_en : in std_logic;
           clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           lsb_out : out std_logic;
           Q : out STD_LOGIC_VECTOR (N downto 0));
end component;

component r_shift
     generic(N : natural := 16);
   Port ( x_in : in STD_LOGIC_VECTOR (N+1 downto 0);
          x_out : out STD_LOGIC_VECTOR (N downto 0));
end component;
----------------------Signal Declarations-----------------------------------------------------------
--signal s_xi, s_s0, s_c0, s_wr_e, s_dv, s_ready : std_logic;
--signal s_LUTres, s_LUTreg_res : std_logic_vector(word_length downto 0);
--signal s_co_out,s_sumo_out, s_rsum_out,s_rc_out: std_logic_vector(word_length downto 0);

--------------------Signal Declarations-----------------------------------------------------------
signal s_xi, s_s0, s_c0, s_wr_e, s_dv : std_logic;
signal s_LUTres : std_logic_vector(word_length downto 0);
signal s_c_out, s_sum_out, s_rsum_out, s_rc_out: std_logic_vector(word_length downto 0);

signal s_CSA_Cout, s_CSA_Sout : std_logic_vector(word_length +1 downto 0);
signal s_CLA_res, s_CLS_res  : std_logic_vector(word_length +3 downto 0);
signal s_cout , s_sum, s_N : std_logic_vector(word_length+3 downto 0);
signal s_result, zero: std_logic_vector(word_length -1 downto 0);

-----------------Architecture Body-----------------------------------------------------------------
begin 

s_cout <= "000" & s_c_out;
s_sum <= "000" & s_sum_out;
s_N <= "0000" & N_i;
zero <= (others => '0'); 

---------------------Port declarations-------------------------------------------------------------

--LUT_mem : reg
--      generic map(N => 16)
--         port map(
--            D => s_LUTres,
--            clk => clk,
--            wr_en => s_wr_e,
--            lsb_out => open,
--            rst => rst,
--            Q => s_LUTreg_res
--            );
            


LUT1: LUT
    generic map( n => word_length)
    port map(
        x_i => s_xi,
        y_0 => Y(0),
        c_0 => s_c0,
        s_0 => s_s0,
        MY => NY,
        M =>  N_i,
        Y =>  Y,
       result => s_LUTres
       );

C_REG : reg
    generic map (n => word_length)
    port map(
        D => s_c_out,
        rst => rst,
        clk =>  clk,
        wr_en => s_wr_e,
        Q => s_rc_out,
        lsb_out => s_c0 
        ); 
 
 S_REG : reg 
            generic map (n => word_length)
            port map(
                D => s_sum_out,
                rst => rst,
                clk =>  clk,
                wr_en => s_wr_e,
                Q => s_rsum_out,
                lsb_out => s_s0 
                ); 
  CSA1 : CSA
    generic map(n => word_length)
    port map(

        A => s_rc_out,
        B => s_LUTres,
        C => s_rsum_out,
        S => s_CSA_Sout,
        C_out => s_CSA_Cout
        ); 
   R_SHIFT_S: r_shift
    generic map (N => word_length)
    port map(
        x_in => s_CSA_Sout,
        x_out => s_sum_out
        );
    
     R_SHIFT_C: r_shift
           generic map (N => word_length)
           port map(
               x_in => s_CSA_Cout,
               x_out => s_c_out
               );    
   Loop_cont : mod_mult
    generic map(N => word_length)
    port map(
        en => enable,
        clk => clk,
        rst => rst,
        X => X,
        wr_en => s_wr_e,
        xi => s_xi,
        dv => s_dv
        );  
   CLA1 : CLA 
    generic map(word_length => word_length +4)
    port map (
        a =>  s_sum,
        b =>  s_cout,
        cin => '0',
        result => s_CLA_res
        );
     CLS1 : CLS 
            generic map(word_length => word_length +4)
            port map (
                a =>  s_CLA_res,
                b =>   s_N,
                cin => '1',
                result => s_CLS_res
                );
-----------------------Output logic--------------------------------------------------
s_result <= s_CLS_res(word_length -1 downto 0) when ((s_dv = '1') and (s_CLA_res >= s_N)) else
            s_CLA_res(word_length -1 downto 0) when ((s_dv = '1') and (s_CLA_res < s_N)) else
            (others => '0');
               
result <= s_result; 
ready <= s_dv;
 

end Behavioral;
