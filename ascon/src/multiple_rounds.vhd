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

entity multiple_rounds is
    Generic (
        G_COMB_RND      : integer := 6
    );
    Port ( 
        i_rnd_state     :  in std_logic_vector(319 downto 0);
        i_const_start   :  in integer range 0 to 15;
        o_rnd_state     : out std_logic_vector(319 downto 0)
    );
end multiple_rounds;

architecture Behavioral of multiple_rounds is

    -- components --
    component round is
        Port ( 
            i_rnd_state :  in std_logic_vector(319 downto 0);
            i_const     :  in integer range 0 to 15;
            o_rnd_state : out std_logic_vector(319 downto 0)
        );    
    end component;

    -- types --
    type state_array is array (0 to G_COMB_RND) of STD_LOGIC_VECTOR(319 downto 0);
    type rnd_num_array is array (0 to G_COMB_RND-1) of integer range 0 to 15;

    -- signals --
    signal rnd_state        : state_array;
    signal rnd_num_state    : rnd_num_array;

begin


    gen_rnd_num: for i in 0 to G_COMB_RND-1 generate
        rnd_num_state(i) <= i_const_start + i;
    end generate;

    rnd_state(0)    <= i_rnd_state;
    o_rnd_state     <= rnd_state(G_COMB_RND);

    gen_rnd: for i in 0 to G_COMB_RND-1 generate
        inst_round: round 
            port map(
                i_rnd_state => rnd_state(i),
                i_const     => rnd_num_state(i),
                o_rnd_state => rnd_state(i+1)
            );
    end generate;

end Behavioral;
