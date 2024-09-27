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

entity linear_layer is
    Port ( 
        i_linear_inp:  in std_logic_vector(319 downto 0);
        o_linear_out: out std_logic_vector(319 downto 0)
    );
end linear_layer;

architecture Behavioral of linear_layer is

    -- functions --
    function rot_r(input_vector : std_logic_vector; n : integer) 
        return std_logic_vector is
    begin
        if input_vector'length = 0 then
            return input_vector;
        end if;

        -- Perform the circular right shift
        return input_vector(n-1 downto 0) &
               input_vector(input_vector'high downto n);
    end function rot_r;

    -- signals --
    signal s0,s1,s2,s3,s4: std_logic_vector(63 downto 0);

begin
 
    s0 <= i_linear_inp(63+64*4 downto 64*4);
    s1 <= i_linear_inp(63+64*3 downto 64*3);
    s2 <= i_linear_inp(63+64*2 downto 64*2);
    s3 <= i_linear_inp(63+64*1 downto 64*1);
    s4 <= i_linear_inp(63+64*0 downto 64*0);

    o_linear_out(63+64*4 downto 64*4) <= s0 xor rot_r(s0,19) xor rot_r(s0,28);
    o_linear_out(63+64*3 downto 64*3) <= s1 xor rot_r(s1,61) xor rot_r(s1,39);
    o_linear_out(63+64*2 downto 64*2) <= s2 xor rot_r(s2, 1) xor rot_r(s2, 6);
    o_linear_out(63+64*1 downto 64*1) <= s3 xor rot_r(s3,10) xor rot_r(s3,17);
    o_linear_out(63+64*0 downto 64*0) <= s4 xor rot_r(s4, 7) xor rot_r(s4,41);


end Behavioral;
