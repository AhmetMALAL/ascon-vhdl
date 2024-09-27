library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package ascon_pkg is

    -- types --
    type ascon_state is record
        x0 : std_logic_vector(63 downto 0);
        x1 : std_logic_vector(63 downto 0);
        x2 : std_logic_vector(63 downto 0);
        x3 : std_logic_vector(63 downto 0);
        x4 : std_logic_vector(63 downto 0);
    end record ascon_state ;
      

end package ascon_pkg;
 
-- Package Body Section
package body ascon_pkg is

 
end package body ascon_pkg;