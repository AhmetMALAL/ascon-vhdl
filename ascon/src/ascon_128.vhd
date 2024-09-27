----------------------------------------------------------------------------------
-- Author       : Ahmet MALAL
-- Project Name : ASCON-128 Algorithm - VHDL Implementation 
-- Create Date  : 19.08.2024
--
-- Description  : This design implements the ASCON-128 cryptographic algorithm. 
--                The design processes input data through two AXI Stream interfaces
--                and produces a ciphertext and a tag as output. The module also
--                includes a busy signal to indicate when the module is active.
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ascon_128 is
    Port ( 
        clk             : in std_logic; 
        rst             : in std_logic; 
        
        -- AXI Stream interface for IV, Key, Nonce (input)
        s00_axis_tdata  : in std_logic_vector(63 downto 0);  -- IV || Key || Nonce
        s00_axis_tvalid : in std_logic;
        s00_axis_tlast  : in std_logic;  -- Signal to indicate the end of AD input
        s00_axis_tready : out std_logic;
        
        -- AXI Stream interface for AD and Plaintext (input)
        s01_axis_tdata  : in std_logic_vector(63 downto 0); -- AD || Plaintext
        s01_axis_tvalid : in std_logic;
        s01_axis_tlast  : in std_logic;  -- Signal to indicate the end of AD/plaintext input
        s01_axis_tready : out std_logic;

        -- Ciphertext and Tag (output)
        o_cipher        : out std_logic_vector(63 downto 0);
        o_cipher_valid  : out std_logic;
        
        o_tag           : out std_logic_vector(63 downto 0);
        o_tag_valid     : out std_logic;

        -- Module busy signal (output)
        o_module_busy   : out std_logic
    );
end ascon_128;

architecture Behavioral of ascon_128 is

    -- Internal component for multiple rounds of encryption
    component multiple_rounds is
        Generic (
            G_COMB_RND    : integer := 6
        );
        Port ( 
            i_rnd_state   : in std_logic_vector(319 downto 0);
            i_const_start : in integer range 0 to 15;
            o_rnd_state   : out std_logic_vector(319 downto 0)
        );
    end component;

    -- State machine enumeration
    type t_state is (
        ST_INIT,
        ST_INIT_FIRST,
        ST_INIT_SECOND,
        ST_ASSOC_DATA,
        ST_ENCRYPT,
        ST_FINAL_FIRST,
        ST_FINAL_SECOND
    );

    -- Internal signals
    signal state        : t_state;                          -- Current state
    signal temp_ctr     : integer range 0 to 15;            -- Temporary counter
    signal rnd_i        : std_logic_vector(319 downto 0);   -- Input state for multiple rounds
    signal rnd_o        : std_logic_vector(319 downto 0);   -- Output state from multiple rounds
    signal key_i        : std_logic_vector(127 downto 0);   -- Key input for final operations
    signal flag         : std_logic;                        -- Control flag
    
    -- Constant for number of rounds
    constant C_COMB_RND : integer := 6;

begin

    -- Busy signal indicates when the module is active
    o_module_busy <= '0' when state = ST_INIT and temp_ctr = 0 else '1';

    -- Instantiate the multiple_rounds component
    inst_multiple_rounds : multiple_rounds
        generic map (
            G_COMB_RND => C_COMB_RND
        )
        port map (
            i_rnd_state   => rnd_i,
            i_const_start => temp_ctr,
            o_rnd_state   => rnd_o
        );

    -- Main process implementing the state machine
    pr_main: process(clk, rst)
    begin 
        if rst = '1' then 
            -- Reset logic
            rnd_i           <= (others => '0');
            temp_ctr        <= 0;
            state           <= ST_INIT;

            o_cipher        <= (others => '0');
            o_cipher_valid  <= '0';
            o_tag           <= (others => '0');
            o_tag_valid     <= '0';

            s01_axis_tready <= '0';
            s00_axis_tready <= '1';

            flag            <= '0';
            key_i           <= (others => '0');
            
        elsif rising_edge(clk) then 
            
            -- Create pulse for output valid signals
            o_cipher_valid  <= '0';
            o_tag_valid     <= '0';
                           
            case state is 
                ----------------------------------------------------------------
                -- Initial state: Collect data from s00_axis
                ----------------------------------------------------------------
                when ST_INIT => 
                    s00_axis_tready  <= '1';
                    if s00_axis_tvalid = '1' then
                        temp_ctr    <= temp_ctr + 1;
                        rnd_i       <= rnd_i(255 downto 0) & s00_axis_tdata;
                    end if;
                    if temp_ctr = 4 then 
                        s00_axis_tready <= '0';
                        temp_ctr        <= 0;
                        state           <= ST_INIT_FIRST;
                    end if;
                
                ----------------------------------------------------------------
                -- First initialization step: Process IV, Key, Nonce
                ----------------------------------------------------------------
                when ST_INIT_FIRST =>
                    key_i            <= rnd_i(255 downto 128);
                    rnd_i            <= rnd_o;
                    temp_ctr         <= 6;
                    state            <= ST_INIT_SECOND;
                    s01_axis_tready  <= '1';

                ----------------------------------------------------------------
                -- Second initialization step: Prepare for associated data
                ----------------------------------------------------------------
                when ST_INIT_SECOND =>
                    if s01_axis_tvalid = '1' then
                        rnd_i(319 downto 256)   <= rnd_o(319 downto 256) xor s01_axis_tdata; -- RATE
                        rnd_i(255 downto 128)   <= rnd_o(255 downto 128);
                        rnd_i(127 downto   0)   <= rnd_o(127 downto   0) xor key_i; 
                        temp_ctr                <= 6;
                        state                   <= ST_ASSOC_DATA;
                    end if;

                ----------------------------------------------------------------
                -- Process associated data (AD)
                ----------------------------------------------------------------
                when ST_ASSOC_DATA => 
                    if s01_axis_tvalid = '1' then
                        rnd_i(319 downto 256)   <= rnd_o(319 downto 256) xor s01_axis_tdata;
                        rnd_i(255 downto   0)   <= rnd_o(255 downto 0);
                        temp_ctr                <= 6;
                    end if;
                    -- Move to encryption if associated data is done
                    if s01_axis_tlast = '1' then
                        s01_axis_tready <= '1'; -- Ready for receiving plaintext
                        flag            <= '1';
                        state           <= ST_ENCRYPT;
                    end if;

                ----------------------------------------------------------------
                -- Encryption process
                ----------------------------------------------------------------
                when ST_ENCRYPT => 
                    if s01_axis_tvalid = '1' then
                        rnd_i(319 downto 256)   <= rnd_o(319 downto 256) xor s01_axis_tdata; -- RATE
                        rnd_i(255 downto   1)   <= rnd_o(255 downto 1);
                        rnd_i(0)                <= rnd_o(0) xor flag;
                        
                        flag            <= '0';

                        temp_ctr        <= 6;
                        o_cipher        <= rnd_o(319 downto 256) xor s01_axis_tdata;
                        o_cipher_valid  <= '1';
                    end if;

                    if s01_axis_tlast = '1' then
                        s01_axis_tready         <= '0';
                        rnd_i(255 downto 128)   <= rnd_o(255 downto 128) xor key_i;
                        temp_ctr                <= 0;
                        state                   <= ST_FINAL_FIRST;
                    end if;

                ----------------------------------------------------------------
                -- First step of finalization
                ----------------------------------------------------------------
                when ST_FINAL_FIRST =>
                    rnd_i                       <= rnd_o;
                    temp_ctr                    <= 6;
                    state                       <= ST_FINAL_SECOND;
                    flag                        <= '0';

                ----------------------------------------------------------------
                -- Second step of finalization: Generate the tag
                ----------------------------------------------------------------
                when ST_FINAL_SECOND => 
                    flag        <= '1';
                    o_tag_valid <= '1';
                    
                    if flag = '1' then 
                        temp_ctr    <= 0;
                        flag        <= '0';
                        o_tag       <= key_i(63 downto 0) xor rnd_o(63 downto 0);
                        state       <= ST_INIT;
                    else 
                        o_tag       <= key_i(127 downto 64) xor rnd_o(127 downto 64);
                    end if;

                ----------------------------------------------------------------
                -- Default case (should never reach here)
                ----------------------------------------------------------------
                when others => 
                    null;
            end case;
        end if;
    end process;
    
end Behavioral;
