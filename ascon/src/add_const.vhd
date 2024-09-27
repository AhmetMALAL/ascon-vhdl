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
 
library work;

entity add_const is
    Port ( 
        i_add_inp:  in std_logic_vector(319 downto 0);
        i_const  :  in integer range 0 to 15;
        o_add_out: out std_logic_vector(319 downto 0)
    );
end add_const;

architecture Behavioral of add_const is

    -- types --
    type const_array is array(0 to 15) of std_logic_vector(7 downto 0);

    -- constants --
    constant C_CONST : const_array := (x"f0",x"e1",x"d2",x"c3",x"b4",x"a5",x"96",x"87",x"78",x"69",x"5a",x"4b",x"3c",x"2d",x"1e",x"0f");    

    -- signals --
    signal s0,s1,s2,s3,s4: std_logic_vector(63 downto 0);

begin

    s0 <= i_add_inp(63+64*0 downto 64*0);
    s1 <= i_add_inp(63+64*1 downto 64*1);
    s2 <= i_add_inp(63+64*2 downto 64*2);
    s3 <= i_add_inp(63+64*3 downto 64*3);
    s4 <= i_add_inp(63+64*4 downto 64*4);

    o_add_out(63+64*0 downto 64*0)  <= s0;
    o_add_out(63+64*1 downto 64*1)  <= s1;

    o_add_out(63+64*2 downto 64*2+8)<= s2(63 downto 8);
    o_add_out( 7+64*2 downto 64*2)  <= s2( 7 downto 0) xor C_CONST(i_const);
    
    o_add_out(63+64*3 downto 64*3)  <= s3;
    o_add_out(63+64*4 downto 64*4)  <= s4;


end Behavioral;
