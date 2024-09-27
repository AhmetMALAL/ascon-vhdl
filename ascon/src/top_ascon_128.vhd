----------------------------------------------------------------------------------
-- Author       : Ahmet MALAL
-- Project Name : ASCON Algorithm - VHDL Implementation 
-- Create Date  : 21.07.2024
--
-- Additional Comments:
--
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
 
entity top_ascon_128 is
    Generic (
        G_DATA_WIDTH : integer := 32
    );
    Port ( 
        clk : in std_logic; 
        rst : in std_logic; 
        
        i_data          : in std_logic_vector(G_DATA_WIDTH-1 downto 0);
        i_data_valid    : in std_logic;
         
        o_cipher        : out std_logic_vector(G_DATA_WIDTH-1 downto 0);
        o_cipher_valid  : out std_logic;
        o_tag           : out std_logic_vector(G_DATA_WIDTH-1 downto 0);
        o_tag_valid     : out std_logic
    );
end top_ascon_128;

architecture Behavioral of top_ascon_128 is


    -- components --
    component ascon_128 is
        Port (  
            clk             : in std_logic; 
            rst             : in std_logic; 
            
            i_start         : in std_logic; 
            i_key           : in std_logic_vector(127 downto 0);        
            i_iv            : in std_logic_vector( 63 downto 0);        
            i_assoc_data    : in std_logic_vector( 63 downto 0);     
            i_nonce         : in std_logic_vector(127 downto 0);     
            i_plain         : in std_logic_vector( 63 downto 0);
            
            o_cipher        : out std_logic_vector( 63 downto 0);
            o_cipher_valid  : out std_logic;
            o_tag           : out std_logic_vector(127 downto 0);
            o_tag_valid     : out std_logic
        );
    end component;
    
    -- constants --
    constant C_TAG_SIZE     : integer := 128;
    constant C_RATE_SIZE    : integer := 64;
    constant C_KEY_SIZE     : integer := 128;
    constant C_IV_SIZE      : integer := 64;
    constant C_NONCE_SIZE   : integer := 128;
    
    -- types --
    type t0_state is (TAG_IDLE,TAG_PROCESS);
    type t1_state is (CIPHER_IDLE,CIPHER_PROCESS);

    -- signals -- 
    signal state_tag    : t0_state;
    signal state_cipher : t1_state;
    
    signal start        : std_logic;
    signal valid_cipher : std_logic;
    signal valid_tag    : std_logic;
    
    signal key      : std_logic_vector(C_KEY_SIZE-1 downto 0);
    signal iv       : std_logic_vector(C_IV_SIZE-1 downto 0);
    signal nonce    : std_logic_vector(C_NONCE_SIZE-1 downto 0);
    signal cipher   : std_logic_vector(C_RATE_SIZE-1 downto 0);
    signal assoc_data   : std_logic_vector(C_RATE_SIZE-1 downto 0);
    signal plain        : std_logic_vector(C_RATE_SIZE-1 downto 0);
    signal tag      : std_logic_vector(C_TAG_SIZE-1 downto 0);
    
    signal reg_cipher   : std_logic_vector(C_RATE_SIZE-1 downto 0);
    signal reg_tag      : std_logic_vector(C_TAG_SIZE-1 downto 0);
    
begin

    inst_ascon_top: ascon_128 
    port map (
        clk         => clk, 
        rst         => rst, 
        
        i_start         => start,
        i_key           => key,
        i_iv            => iv, 
        i_assoc_data    => assoc_data,
        i_nonce         => nonce,
        i_plain         => plain,
        
        o_cipher        => cipher,
        o_cipher_valid  => valid_cipher,
        o_tag           => tag,
        o_tag_valid     => valid_tag        
    );
    
    start           <= i_data_valid;

    pr_main: process (clk,rst)
    begin 
        if rst = '1' then 
            key         <= (others=> '0');
            iv          <= (others=> '0');
            nonce       <= (others=> '0');
            plain       <= (others=> '0');                  
            assoc_data  <= (others=> '0');                  
        elsif rising_edge(clk) then

            for i in 0 to C_KEY_SIZE/G_DATA_WIDTH-1 loop 
                key(G_DATA_WIDTH-1+G_DATA_WIDTH*i downto G_DATA_WIDTH*i) <= i_data;
            end loop;    

            for i in 0 to C_IV_SIZE/G_DATA_WIDTH-1 loop 
                iv(G_DATA_WIDTH-1+G_DATA_WIDTH*i downto G_DATA_WIDTH*i) <= i_data;
            end loop;    
            
            for i in 0 to C_NONCE_SIZE/G_DATA_WIDTH-1 loop 
                nonce(G_DATA_WIDTH-1+G_DATA_WIDTH*i downto G_DATA_WIDTH*i) <= i_data;
            end loop;    
            
            for i in 0 to C_RATE_SIZE/G_DATA_WIDTH-1 loop 
                plain(G_DATA_WIDTH-1+G_DATA_WIDTH*i downto G_DATA_WIDTH*i) <= i_data;
            end loop;    

            for i in 0 to C_RATE_SIZE/G_DATA_WIDTH-1 loop 
                assoc_data(G_DATA_WIDTH-1+G_DATA_WIDTH*i downto G_DATA_WIDTH*i) <= i_data;
            end loop; 
            
        end if;
    end process;
    
    pr_cipher:process(clk,rst)
    variable ctr : integer;
    begin 
        if rst = '1' then
            ctr := 0;
            state_cipher    <= CIPHER_IDLE;
            reg_cipher      <= (others=>'0');
            o_cipher_valid <= '0';
            o_cipher        <= (others=>'0');
        elsif rising_edge(clk) then  
            
            -- create pulse
            o_cipher_valid <= '0';

            case state_cipher is  
                when CIPHER_IDLE => 
                    ctr := 0;
                    if valid_cipher = '1' then
                        reg_cipher      <= cipher;
                        state_cipher    <= CIPHER_PROCESS; 
                    end if;
                when CIPHER_PROCESS => 
                    o_cipher_valid <= '1';
                    o_cipher <= reg_cipher(reg_cipher'high downto reg_cipher'length-o_cipher'length);
                    reg_cipher<= reg_cipher(reg_cipher'high-o_cipher'length downto 0) & reg_cipher(reg_cipher'high downto reg_cipher'length-o_cipher'length);
                    if ctr = C_RATE_SIZE/G_DATA_WIDTH-1 then  
                        state_cipher <= CIPHER_IDLE; 
                    end if;
                    ctr := ctr + 1;
                when others => 
                    null;
            end case;
        end if;
    end process;
    
    pr_tag:process(clk,rst)
    variable ctr : integer;
    begin 
        if rst = '1' then
            ctr := 0;
            state_tag   <= TAG_IDLE;
            reg_tag     <= (others=>'0');
            o_tag_valid <= '0';
            o_tag       <= (others=>'0');
        elsif rising_edge(clk) then  
            
            -- create pulse
            o_tag_valid <= '0';

            case state_tag is  
                when TAG_IDLE => 
                    ctr := 0;
                    if valid_tag = '1' then
                        reg_tag     <= tag;
                        state_tag   <= TAG_PROCESS; 
                    end if;
                when TAG_PROCESS => 
                    o_tag_valid <= '1';
                    o_tag <= reg_tag(reg_tag'high downto reg_tag'length-o_tag'length);
                    reg_tag <= reg_tag(reg_tag'high-o_tag'length downto 0) & reg_tag(reg_tag'high downto reg_tag'length-o_tag'length);
                    if ctr = C_TAG_SIZE/G_DATA_WIDTH-1 then  
                        state_tag   <= TAG_IDLE; 
                    end if;
                    ctr := ctr + 1;
                when others => 
                    null;
            end case;
        end if;
    end process;


end Behavioral;
