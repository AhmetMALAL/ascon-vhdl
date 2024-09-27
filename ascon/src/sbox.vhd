----------------------------------------------------------------------------------
-- Author       : Ahmet MALAL
-- Project Name : ASCON Algorithm - VHDL Implementation 
-- Create Date  : 16.07.2024
--
-- Additional Comments:
--
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity sbox is
    Port ( 
        i_sbox_inp_4:  in std_logic;
        i_sbox_inp_3:  in std_logic;
        i_sbox_inp_2:  in std_logic;
        i_sbox_inp_1:  in std_logic;
        i_sbox_inp_0:  in std_logic;
        
        o_sbox_out_4: out std_logic;
        o_sbox_out_3: out std_logic;
        o_sbox_out_2: out std_logic;
        o_sbox_out_1: out std_logic;
        o_sbox_out_0: out std_logic
    );
end sbox;

architecture Behavioral of sbox is

    -- types --
    type int_array is array(0 to 31) of integer range 0 to 31;

    -- constants --
    constant C_SBOX_TABLE : int_array := (4,11,31,20,26,21,9,2,27,5,8,18,29,3,6,28,30,19,7,14,0,13,17,24,16,12,1,25,22,10,15,23);    
    
    -- signals --
    signal i_sbox_inp : std_logic_vector(4 downto 0);
    signal o_sbox_out : std_logic_vector(4 downto 0);

begin
    
--    o_sbox_out_4 <= (i_sbox_inp_4 and i_sbox_inp_1) xor i_sbox_inp_3 xor (i_sbox_inp_2 and i_sbox_inp_1) xor i_sbox_inp_2 xor (i_sbox_inp_1 and i_sbox_inp_0) xor i_sbox_inp_1 xor i_sbox_inp_0;
--    o_sbox_out_3 <= i_sbox_inp_4 xor (i_sbox_inp_2 and i_sbox_inp_3) xor i_sbox_inp_3 xor (i_sbox_inp_3 and i_sbox_inp_1) xor i_sbox_inp_2 xor (i_sbox_inp_1 and i_sbox_inp_2) xor i_sbox_inp_1 xor i_sbox_inp_0;
--    o_sbox_out_2 <= (i_sbox_inp_4 and i_sbox_inp_3) xor i_sbox_inp_4 xor i_sbox_inp_2 xor i_sbox_inp_1 xor '1';
--    o_sbox_out_1 <= (i_sbox_inp_4 and i_sbox_inp_0) xor (i_sbox_inp_3 and i_sbox_inp_0) xor i_sbox_inp_4 xor i_sbox_inp_3 xor i_sbox_inp_2 xor i_sbox_inp_1 xor i_sbox_inp_0;
--    o_sbox_out_0 <= (i_sbox_inp_4 and i_sbox_inp_1) xor i_sbox_inp_4 xor i_sbox_inp_3 xor (i_sbox_inp_1 and i_sbox_inp_0) xor i_sbox_inp_1;

    i_sbox_inp <= i_sbox_inp_4 & i_sbox_inp_3 & i_sbox_inp_2 & i_sbox_inp_1 & i_sbox_inp_0;
    o_sbox_out <= std_logic_vector(to_unsigned(C_SBOX_TABLE(to_integer(unsigned(i_sbox_inp))),5)); 
    
    o_sbox_out_4 <=  o_sbox_out(4);
    o_sbox_out_3 <=  o_sbox_out(3);
    o_sbox_out_2 <=  o_sbox_out(2);
    o_sbox_out_1 <=  o_sbox_out(1);
    o_sbox_out_0 <=  o_sbox_out(0);
    
    

end Behavioral;
