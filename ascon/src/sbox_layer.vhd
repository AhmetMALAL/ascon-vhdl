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

entity sbox_layer is
    Port ( 
        i_sbox_layer_inp:  in std_logic_vector(319 downto 0);
        o_sbox_layer_out: out std_logic_vector(319 downto 0)
    );
end sbox_layer;

architecture Behavioral of sbox_layer is

    -- components --
    component sbox is
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
    end component;

begin

    gen_sboxes: for i in 0 to 63 generate 
                 
        inst_sbox:sbox 
            port map ( 
            
                i_sbox_inp_4 => i_sbox_layer_inp(i+64*4),
                i_sbox_inp_3 => i_sbox_layer_inp(i+64*3),
                i_sbox_inp_2 => i_sbox_layer_inp(i+64*2),
                i_sbox_inp_1 => i_sbox_layer_inp(i+64*1),
                i_sbox_inp_0 => i_sbox_layer_inp(i+64*0),
                
                o_sbox_out_4 => o_sbox_layer_out(i+64*4),
                o_sbox_out_3 => o_sbox_layer_out(i+64*3),
                o_sbox_out_2 => o_sbox_layer_out(i+64*2),
                o_sbox_out_1 => o_sbox_layer_out(i+64*1),
                o_sbox_out_0 => o_sbox_layer_out(i+64*0)
            );
            
    end generate gen_sboxes;

end Behavioral;
