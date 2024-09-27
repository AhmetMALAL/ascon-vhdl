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
 
entity ascon_128a_tb is
--  Port ( );
end ascon_128a_tb;

architecture Behavioral of ascon_128a_tb is

    -- components --
    component ascon_128a is
        Port ( 
            clk             : in std_logic; 
            rst             : in std_logic; 
            
            s00_axis_tdata  : in std_logic_vector( 63 downto 0); -- IV || Key || Nonce     
            s00_axis_tvalid : in std_logic;
            s00_axis_tlast  : in std_logic;  -- Signal to indicate the end of initial and AD input
            s00_axis_tready :out std_logic;
            
            s01_axis_tdata  : in std_logic_vector( 127 downto 0);     
            s01_axis_tvalid : in std_logic;
            s01_axis_tlast  : in std_logic;  -- Signal to indicate the end of plaintextinput
            s01_axis_tready :out std_logic;
    
            o_cipher        : out std_logic_vector(127 downto 0);
            o_cipher_valid  : out std_logic;
            
            o_tag           : out std_logic_vector(63 downto 0);
            o_tag_valid     : out std_logic;

            o_module_busy   : out std_logic
        );
    end component;

    -- constants --
    constant PERIOD         : time := 10 ns;
    
    -- signals --
    signal clk,rst: std_logic;

    signal valid_out    : std_logic;
    signal valid_tag    : std_logic;
    signal module_busy  : std_logic;
    
    signal s00_axis_tdata     : std_logic_vector( 63 downto 0);
    signal s00_axis_tvalid    : std_logic;
    signal s00_axis_tlast     : std_logic;
    signal s00_axis_tready    : std_logic;

    signal s01_axis_tdata     : std_logic_vector( 127 downto 0);
    signal s01_axis_tvalid    : std_logic;
    signal s01_axis_tlast     : std_logic;
    signal s01_axis_tready    : std_logic;

    signal output       : std_logic_vector(127 downto 0);
    signal tag          : std_logic_vector( 63 downto 0);

begin

    inst_ascon_128: ascon_128a 
    port map (
        clk         => clk, 
        rst         => rst, 

        s00_axis_tdata  => s00_axis_tdata,
        s00_axis_tvalid => s00_axis_tvalid,
        s00_axis_tlast  => s00_axis_tlast,
        s00_axis_tready => s00_axis_tready,

        s01_axis_tdata   => s01_axis_tdata,
        s01_axis_tvalid  => s01_axis_tvalid,
        s01_axis_tlast   => s01_axis_tlast,
        s01_axis_tready  => s01_axis_tready,

        o_cipher        => output,
        o_cipher_valid  => valid_out,
        o_tag           => tag,
        o_tag_valid     => valid_tag,
        o_module_busy   => module_busy        
    );

    ----------------------------------
    -- Process for s00_axis interface
    -- IV || Key || Nonce
    s00_process: process
    begin
        s00_axis_tdata  <= (others => '0');
        s00_axis_tvalid <= '0';
        s00_axis_tlast  <= '0';
        wait until rst = '0';
        wait for 30 ns;
        wait until rising_edge(clk);   

        for i in 0 to 3 loop
            s00_axis_tdata  <= std_logic_vector(to_unsigned(i, s00_axis_tdata'length));
            s00_axis_tvalid <= '1';
            s00_axis_tlast  <= '0';
            wait until rising_edge(clk) and s00_axis_tready = '1';
            --s00_axis_tvalid <= '0';
            --wait until rising_edge(clk);   
        end loop;
        
        s00_axis_tdata  <= std_logic_vector(to_unsigned(4, s00_axis_tdata'length));
        s00_axis_tvalid <= '1';
        s00_axis_tlast  <= '1';
        wait until rising_edge(clk) and s00_axis_tready = '1';
        s00_axis_tvalid <= '0';
        s00_axis_tlast  <= '0';
        wait;
    end process;
    ----------------------------------
    -- Process for s01_axis interface
    -- Associated Data || Plaintext
    s01_process: process
    begin
        s01_axis_tdata  <= (others => '0');
        s01_axis_tvalid <= '0';
        s01_axis_tlast  <= '0';
        wait until rst = '0';
        wait for 100 ns;
        wait until rising_edge(clk);   

        for i in 0 to 4 loop
            s01_axis_tdata  <= std_logic_vector(to_unsigned(i, s01_axis_tdata'length));
            s01_axis_tvalid <= '1';
            s01_axis_tlast  <= '0';
            wait until rising_edge(clk) and s01_axis_tready = '1';
            --s01_axis_tvalid <= '0';
            --wait until rising_edge(clk);   
        end loop;
        s01_axis_tdata  <= std_logic_vector(to_unsigned(5, s01_axis_tdata'length));
        s01_axis_tvalid <= '1';
        s01_axis_tlast  <= '1';
        wait until rising_edge(clk) and s01_axis_tready = '1';
        s01_axis_tvalid <= '0';
        s01_axis_tlast  <= '0';


        for i in 0 to 4 loop
            s01_axis_tdata  <= std_logic_vector(to_unsigned(i, s01_axis_tdata'length));
            s01_axis_tvalid <= '1';
            s01_axis_tlast  <= '0';
            wait until rising_edge(clk) and s01_axis_tready = '1';
            --s01_axis_tvalid <= '0';
            --wait until rising_edge(clk);   
        end loop;
        s01_axis_tdata  <= std_logic_vector(to_unsigned(5, s01_axis_tdata'length));
        s01_axis_tvalid <= '1';
        s01_axis_tlast  <= '1';
        wait until rising_edge(clk) and s01_axis_tready = '1';
        s01_axis_tvalid <= '0';
        s01_axis_tlast  <= '0';


        wait;
    end process;

    ----------------------------------
    pr_rst:process
    begin 
        rst <= '1';
        wait for PERIOD*5;
        wait until rising_edge(clk);       
        rst <= '0';
        wait;
    end process;
    ----------------------------------
    pr_clk: process
    begin 
        clk <= '0';
        wait for PERIOD/2;
        clk <= '1';
        wait for PERIOD/2;
    end process;
    ----------------------------------
    
end Behavioral;
