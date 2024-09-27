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

entity round is
    Port ( 
        i_rnd_state :  in std_logic_vector(319 downto 0);
        i_const     :  in integer range 0 to 15;
        o_rnd_state : out std_logic_vector(319 downto 0)
    );
end round;

architecture Behavioral of round is

    -- components --
    component add_const is
        Port ( 
            i_add_inp:  in std_logic_vector(319 downto 0);
            i_const  :  in integer range 0 to 15;
            o_add_out: out std_logic_vector(319 downto 0)
        );
    end component;

    component sbox_layer is
        Port ( 
            i_sbox_layer_inp:  in std_logic_vector(319 downto 0);
            o_sbox_layer_out: out std_logic_vector(319 downto 0)
        );
    end component;

    component linear_layer is
        Port ( 
            i_linear_inp:  in std_logic_vector(319 downto 0);
            o_linear_out: out std_logic_vector(319 downto 0)
        );
    end component;

    -- signals --
    signal add_const_out : std_logic_vector(319 downto 0);
    signal sbox_layer_out: std_logic_vector(319 downto 0);

begin

    inst_add_const: add_const 
        port map (
            i_add_inp => i_rnd_state, 
            i_const   => i_const,
            o_add_out => add_const_out
        );
    
    inst_sbox_layer: sbox_layer 
        port map (
            i_sbox_layer_inp => add_const_out,
            o_sbox_layer_out => sbox_layer_out
        );
    
    inst_linear_layer: linear_layer 
        port map (
            i_linear_inp => sbox_layer_out,
            o_linear_out => o_rnd_state
        );

end Behavioral;
