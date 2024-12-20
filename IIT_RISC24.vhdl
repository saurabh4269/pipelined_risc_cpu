library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
entity IIT_RISC24 is
    port (
        clk:in std_logic;
        Instruction:out std_logic_vector(19 downto 0)
    );
end entity IIT_RISC24;
architecture rtl of IIT_RISC24 is


-- opcodes of all instruction
    constant OC_ADA : std_logic_vector(3 downto 0)	    :="0001";
	constant OC_ADC : std_logic_vector(3 downto 0)	    :="0001";
	constant OC_ADZ : std_logic_vector(3 downto 0)	    :="0001";
	constant OC_AWC  : std_logic_vector(3 downto 0)	    :="0001";
	constant OC_ACA   : std_logic_vector(3 downto 0)	:="0001";
	constant OC_ACC  : std_logic_vector(3 downto 0)	    :="0001";
	constant OC_ACZ   : std_logic_vector(3 downto 0) 	:="0001";
	constant OC_ACW  : std_logic_vector(3 downto 0)		:="0001";
	constant OC_ADI  : std_logic_vector(3 downto 0)	    :="0000";
	constant OC_NDU  : std_logic_vector(3 downto 0)	    :="0010";
	constant OC_NDC  : std_logic_vector(3 downto 0)	    :="0010";
    constant OC_NDZ : std_logic_vector(3 downto 0)	    :="0010";
	constant OC_NCU : std_logic_vector(3 downto 0)	    :="0010";
	constant OC_NCC : std_logic_vector(3 downto 0)	    :="0010";
	constant OC_NCZ  : std_logic_vector(3 downto 0)	    :="0010";
	constant OC_LLI  : std_logic_vector(3 downto 0)		:="0011";
	constant OC_LW   : std_logic_vector(3 downto 0)		:="0100";
	constant OC_SW   : std_logic_vector(3 downto 0)		:="0101";
	constant OC_LM   : std_logic_vector(3 downto 0)		:="0110";
	constant OC_SM  : std_logic_vector(3 downto 0)	    :="0111";
	constant OC_BEQ  : std_logic_vector(3 downto 0)	    :="1000";
	constant OC_BLT  : std_logic_vector(3 downto 0)	    :="1001";
    constant OC_BLE : std_logic_vector(3 downto 0)	    :="1010";
	constant OC_JAL : std_logic_vector(3 downto 0)	    :="1100";
	constant OC_JLR : std_logic_vector(3 downto 0)	    :="1101";
	constant OC_JRI  : std_logic_vector(3 downto 0)	    :="1111";

-------------------------components----------------------------------------------
 --------------------------Register File ----------------------

        component RF is 
            port(	
                rf_write:in std_logic;
                rf_a1:in std_logic_vector(2 downto 0); --A
                rf_a2:in std_logic_vector(2 downto 0); --B
                rf_a3:in std_logic_vector(2 downto 0); --D
                rf_d1:out std_logic_vector(15 downto 0);
                rf_d2:out std_logic_vector(15 downto 0);
                rf_d3:in std_logic_vector(15 downto 0);
                pc_in:in std_logic_vector(15 downto 0);
                pc_en:in std_logic;
                pc_out:out std_logic_vector(15 downto 0);
                clk:in std_logic
            );
        end component;

    -------------------------------------------------------------
    --------------------------ALU1---------------------------------------------

        component alu1 is 
            port(
                czcontrol: in std_logic_vector(1 downto 0);
                cpl : in std_logic;
                czin : in std_logic_vector(1 downto 0);
                opcode : in std_logic_vector(3 downto 0);
                a,b : in std_logic_vector(15 downto 0);
                aluout: out std_logic_vector(15 downto 0);
                czout: out std_logic_vector(1 downto 0)
            );
        end component;

        -------------------------------------------------------------------------
        -----------------------------ALU2------------------------------------

        component alu2 is 
            port(
		  a : in std_logic_vector(15 downto 0);
		  b : in std_logic_vector(15 downto 0);
		  clk : in std_logic;
		  alu2out : out std_logic_vector(15 downto 0)
            );
        end component ;

        -------------------------------------------------------------------------
        -----------------------------ALU3------------------------------------

        component alu3 is 
            port(
                a : in std_logic_vector(15 downto 0);
                b : in std_logic_vector(15 downto 0);
                alu3out : out std_logic_vector(15 downto 0)
            );
        end component;

        -------------------------------------------------------------------------
        -----------------------------instr_memory------------------------------------
        component instrMemory is
            port(
                ins_init: in std_logic; 
            pc_in : in std_logic_vector(15 downto 0);   -- mem_add   
            mem_io  : out std_logic_vector(15 downto 0)

            );
        end component;
        -------------------------------------------------------------------------
        -----------------------------PIPE1------------------------------------

        component pipe1 is 
            port(
                pc_in : in std_logic_vector(15 downto 0);
                mem_io : in std_logic_vector(15 downto 0);
                wr : in std_logic;
                data_out : out std_logic_vector(31 downto 0);
                clk : in std_logic
            );
        end component;

        -------------------------------------------------------------------------
        -----------------------------PIPE2------------------------------------
            component pipe2 is 
                port(
                    data_in : in std_logic_vector(31 downto 0);
                    wr : in std_logic;
                    data_out : out std_logic_vector(31 downto 0);
                    clk : in std_logic
                );
            end component;

        -------------------------------------------------------------------------
        -----------------------------PIPE3------------------------------------
            component pipe3 is 
                port(
                    data31_9 : in std_logic_vector(22 downto 0);
                    data8_0 : in std_logic_vector(8 downto 0);
                    data47_32 : in std_logic_vector(15 downto 0);
                    data63_48 : in std_logic_vector(15 downto 0);
                    wr : in std_logic;
                    data_out : out std_logic_vector(63 downto 0);
                    clk : in std_logic
                );
            end component;
        -------------------------------------------------------------------------
        -----------------------------PIPE4------------------------------------
            component pipe4 is 
                port(
                    data63_9  : in std_logic_vector(54 downto 0);            -- ins(15-9) + pc + dataA1 + dataA2
							 data8_0 : in std_logic_vector(8 downto 0);               -- these 9 bits are shifted and usd in LM
							 data79_64 : in std_logic_vector(15 downto 0);            -- alu output
							 data81_80 : in std_logic_vector(1 downto 0);             -- cz of alu1
							 data84_82 : in std_logic_vector(2 downto 0);             -- 3 bits used only in LM 
							 wr : in std_logic;
							 data_out : out std_logic_vector(84 downto 0);
							 clk : in std_logic

            );
            end component;
        -------------------------------------------------------------------------
        -----------------------------PIPE5------------------------------------
            component pipe5 is 
                port(
                    data81_0: in std_logic_vector(81 downto 0);
                    data97_82: in std_logic_vector(15 downto 0);
                    wr : in std_logic;
                    data100_98 : in std_logic_vector(2 downto 0);
                    data_out : out std_logic_vector(100 downto 0);
                    clk : in std_logic
                    );
            end component;
    ------------------------------------------------------------------------------
    ----------------------------memory data ------------------------------------
            component memory_d is
                port (  MW, CLK : in std_logic;
                        mem_add : in std_logic_vector(15 downto 0);   
                        mem_di  : in std_logic_vector(15 downto 0);   
                        mem_do  : out std_logic_vector(15 downto 0)
                    );  
                end component;
    ------------------------------------------------------------------------------
    ----------------------------zero extender 9------------------------------------
                component zero_ext9 is 
                port (in9 : in std_logic_vector(8 downto 0);   
                    out9  : out std_logic_vector(15 downto 0)); 
                end component;

    ------------------------------------------------------------------------------
    ----------------------------sign extender 9------------------------------------
                component sig_ext9 is 
                port (in9 : in std_logic_vector(8 downto 0);   
                    out9  : out std_logic_vector(15 downto 0));  
                end component;
    ------------------------------------------------------------------------------
    ----------------------------sign extender 6------------------------------------
                component sig_ext6 is        
                port (in6 : in std_logic_vector(5 downto 0);   
                out6  : out std_logic_vector(15 downto 0));  
                end component;
    ------------------------------------------------------------------------------
    ----------------------------1bit shifter------------------------------------
                component one_bit_shifter is 
                    port(
                        inp_bit_shifter : in std_logic_vector(8 downto 0);
                        out_bit_shifter : out std_logic_vector(8 downto 0)
                    );
                    end component;
    ------------------------------------------------------------------------------
    ----------------------------1 subtractor------------------------------------
            component one_subtractor is 
                port(
                    lm_on   : in std_logic; 
                    inp_sub : in std_logic_vector(2 downto 0);
                    out_sub : out std_logic_vector(2 downto 0)
                    );
            end component;
    ------------------------------------------------------------------------------
    ---------------------------- czregister ------------------------------------
    component czregister is 
    port(
        wr : in std_logic ;
            czrin: in std_logic_vector(1 downto 0);
            czrout:out std_logic_vector(1 downto 0)
    );
    end component;

----------------------------------SIGNALS----------------------------------------
 -----------------------------------rf_signals-----------------------------------
    signal sig_pc_out : std_logic_vector(15 downto 0) := "0000000000000000";
    signal sig_rf_d1 : std_logic_vector(15 downto 0);
    signal sig_rf_d2 : std_logic_vector(15 downto 0);
    signal sig_rf_d3 : std_logic_vector(15 downto 0);
    signal sig_pc_in : std_logic_vector(15 downto 0);
    signal sig_rf_a1 : std_logic_vector(2 downto 0);
    signal sig_rf_a2 : std_logic_vector(2 downto 0);
    signal sig_rf_a3 : std_logic_vector(2 downto 0);
    signal sig_rf_write: std_logic;
    ----------------------------ALU2------------------------------------------------
    signal sig_alu2_C : std_logic_vector(15 downto 0);
    signal sig_alu2_B : std_logic_vector(15 downto 0);

    -----------------------------------pipe signals----------------------------------
    signal sig_mem_io : std_logic_vector(15 downto 0);


    signal sig_pipe1 : std_logic_vector(31 downto 0) := (others =>'0');
    signal wrp1 : std_logic := '1';

    signal sig_pipe2 : std_logic_vector( 31 downto 0) := (others =>'0');
    signal wrp2 : std_logic := '1';
       
        -- process for mux1
        signal sig8_0muxp2: std_logic_vector(8 downto 0);
        -- end
        -- process for mux2
        signal sig_data1p2: std_logic_vector(15 downto 0);
        -- end
        -- process for mux3
        signal sig_data2p2: std_logic_vector(15 downto 0);
		  signal sig31_9muxp2 : std_logic_vector(22 downto 0);
        -- end
        
    signal sig_pipe3 : std_logic_vector(63 downto 0) := (others =>'0');
  
    signal wrp3 : std_logic := '1';
        
        signal sig_alu1_p3 : std_logic_vector(15 downto 0);
       
        --component 1 subtractor
        signal sig_1b_sub : std_logic_vector(2 downto 0);
        --component 1 shifter
        signal sig_1bS : std_logic_vector(8 downto 0);
        --component sign extender
        signal  sigSE6_op3 : std_logic_vector(15 downto 0);
        signal  sigSE9_op3 : std_logic_vector(15 downto 0);
        --component alu
        signal sig_alu1_a: std_logic_vector(15 downto 0);
        signal sig_alu1_b : std_logic_vector(15 downto 0);
        signal sig_alu1_c : std_logic_vector(15 downto 0) := (others =>'0') ;
        --component zero extend
        signal  sigZE9_op3 : std_logic_vector(15 downto 0);

    signal sig_pipe4 : std_logic_vector(84 downto 0) := "0000000000000000000000000000000000000000000000000000000000000000000000000000000000111";
    signal wrp4 : std_logic := '1';
        
        --component memory
                signal sig_MW: std_logic;
                signal sig_mem_do : std_logic_vector(15 downto 0);
                signal sig_mem_di : std_logic_vector(15 downto 0);
        --component alu
            signal sig_alu5_b: std_logic_vector(15 downto 0);
            signal sig_alu5_c : std_logic_vector(15 downto 0);

    signal sig_pipe5 : std_logic_vector(100 downto 0) := "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000111";
    signal wrp5 : std_logic := '1';
        
        --component zero extend 9
        signal sigZE9_op5 : std_logic_vector(15 downto 0);
  
        --component alu3 
        signal sig_alu3_c : std_logic_vector(15 downto 0);
        --component alu4
        signal sig_alu4_c : std_logic_vector(15 downto 0);
       


        ---- alu3_mux 

        signal sig_alu3_bmux : std_logic_vector(15 downto 0);
		  signal sig8_0p3mux : std_logic_vector(8 downto 0);
      
        signal sigSE9_op5 : std_logic_vector(15 downto 0);
        signal sigSE6_op5 : std_logic_vector(15 downto 0);
  
        
    -----------------------------------czregister------------------------
    signal sig_czinp4: std_logic_vector(1 downto 0) := (others =>'0');
    signal sig_czout: std_logic_vector(1 downto 0) := (others =>'0');
    signal sig_cz_wr : std_logic;
   
    -----------------------------------subtractor ----------------------------------
    signal sig_sub_on : std_logic := '0';
	  signal sig_1b_sub_mux : std_logic_vector(2 downto 0);
------------------------------------------port mapping-------------------------------
    begin

    ZE_9_1: zero_ext9 port map(
        in9 => sig_pipe3(8 downto 0),
        out9 =>sigZE9_op3
        ); 
    
    ZE_9_2: zero_ext9 port map(
        in9 => sig_pipe5(8 downto 0),
        out9 =>sigZE9_op5
        ); 
    SE_9_1: sig_ext9 port map (
        in9 => sig_pipe3(8 downto 0),
        out9 =>  sigSE9_op3
        );
    SE_9_2: sig_ext9 port map (
            in9 => sig_pipe5(8 downto 0),
            out9 =>  sigSE9_op5
        );
    SE_6_1:sig_ext6 port map(
        in6 => sig_pipe3(5 downto 0),
        out6 => sigSE6_op3
    );  

    SE_6_2:sig_ext6 port map(
        in6 => sig_pipe5(5 downto 0),  
        out6 => sigSE6_op5
    );  

    shifter:one_bit_shifter port map(
                inp_bit_shifter => sig_pipe3(8 downto 0),
                out_bit_shifter => sig_1bS
            );
    subtractor:one_subtractor port map(
        lm_on   => sig_sub_on,
        inp_sub => sig_pipe4(84 downto 82),
        out_sub => sig_1b_sub
        );
    czreg :czregister port map (
        wr => sig_cz_wr,
        czrin => sig_czinp4,
        czrout =>  sig_czout
    );
    Register_file: RF 
                port map(
                    rf_write=>sig_rf_write ,
                    rf_a1=> sig_rf_a1,
                    rf_a2=>sig_rf_a2,
                    rf_a3=>sig_rf_a3,
                    rf_d1=>sig_rf_d1,
                    rf_d2=>sig_rf_d2,
                    rf_d3=>sig_rf_d3,
                    pc_in=>sig_pc_in,
                    pc_en=>'1',
                    pc_out=>sig_pc_out,
                    clk=>clk

                ) ;
    Instruction_Memory: instrMemory
                port map(
                    ins_init=>'1' ,
                    pc_in=>sig_pc_out,
                    mem_io=>sig_mem_io
                    
                    ) ; 
    ALU_2: alu2
        port map(
            a=>sig_pc_out,
            b=>sig_alu2_B,
				clk=>clk,
            alu2out=>sig_alu2_C     
        );      
    ALU_1: alu1
        port map(
            czcontrol=>sig_pipe3(1 downto 0),
            cpl=>sig_pipe3(2),
            czin=>sig_czout,
            czout=>sig_czinp4,
            opcode=>sig_pipe3(15 downto 12),
            a=>sig_alu1_a,
            b=>sig_alu1_b,
            aluout=>sig_alu1_c
            
        );                                               
    Data_Memory: memory_d
                port map(
                    mem_add=>sig_pipe4(79 downto 64),
                    mem_di=>sig_mem_di,
                    mem_do=>sig_mem_do,
                    MW=>sig_MW,
                        clk=>clk
                );
    ALU_5 : alu2 
        port map(
            a=>sig_pipe4(79 downto 64),
            b=>sig_alu5_b,
				clk=>clk,
            alu2out=>sig_alu5_c
        );


        
    ALU_3: alu3
        port map(
            b=>sig_alu3_bmux,
            a=>sig_pipe5(31 downto 16),
            alu3out=>sig_alu3_c
        );
    ALU_4: alu3
        port map(
            b=>"0000000000000001",
            a=> sig_pipe5(31 downto 16),
            alu3out=>sig_alu4_c
        );

    PIPE_1: pipe1
        port map(
            pc_in=>sig_pc_out,
            mem_io=>sig_mem_io,
            wr=> wrp1,
            data_out=>sig_pipe1,
            clk=>clk
                    
        );
    PIPE_2: pipe2
        port map(
            data_in=>sig_pipe1,
            wr=> wrp2,
            data_out=>sig_pipe2,
            clk=>clk
                    
        );    
    PIPE_3: pipe3
        port map(
            data31_9=>sig31_9muxp2,
            data8_0=>sig8_0muxp2,
            data47_32=>sig_data1p2,
            data63_48=>sig_data2p2,
            wr=> wrp3,
            data_out=>sig_pipe3,
            clk=>clk
                    
        );  
    PIPE_4: pipe4
        port map(
            data63_9=>sig_pipe3(63 downto 9),
            data8_0=>sig8_0p3mux,
            data79_64=>sig_alu1_p3,
            data81_80=>sig_czinp4,
            data84_82=>sig_1b_sub_mux,
            wr=>wrp4,
            data_out=>sig_pipe4,
            clk=>clk
                    
        );   
    PIPE_5: pipe5
        port map(
            data81_0=>sig_pipe4(81 downto 0),
            data97_82=>sig_mem_do,
            data100_98 => sig_pipe4(84 downto 82),
            wr=> wrp5,
            data_out=>sig_pipe5,
            clk=>clk
        );   
        
-----below process starts subtractor for lm-sm ------

process(sig_pipe2,sig_pipe4, sig_pipe3)
begin

		 if(sig_pipe4(15 downto 12) = OC_LM and sig_pipe4(84 downto 82) /= "000" and sig_pipe3(15 downto 12) = OC_LM) then 
			report "pipe4 last bits subon ---->:"&integer'image(to_integer(unsigned(sig_pipe4(84 downto 82))));
         sig_sub_on <='1';
			
		 elsif((sig_pipe2(15 downto 12) = OC_SM or sig_pipe3(15 downto 12) = OC_SM) and sig_pipe5(100 downto 98) /= "000") then
		   sig_sub_on <='1';
		 else 
		  sig_sub_on <='0';
		 end if;

end process;

process(sig_1b_sub,sig_pipe3,sig_pipe2, sig_pipe4)
begin

       if(sig_pipe4(15 downto 12) = OC_LM and sig_pipe4(84 downto 82) /= "000" and sig_pipe3(15 downto 12) = OC_LM) then 
			report "sig_1b_sub---->:"&integer'image(to_integer(unsigned(sig_1b_sub)));
         sig_1b_sub_mux <= sig_1b_sub;
			
		 elsif((sig_pipe2(15 downto 12) = OC_SM or sig_pipe3(15 downto 12) = OC_SM) and sig_pipe5(100 downto 98) /= "000") then
		   sig_1b_sub_mux <= sig_1b_sub;
		 else 
		   report "pipe4 last bits subonmux ---->:"&integer'image(to_integer(unsigned(sig_pipe4(84 downto 82))));
		   sig_1b_sub_mux <= "111";
		 end if;
end process;

process(sig_pipe3 , sig_pipe4 , sig_pipe2,sig_1bS)
	begin
		if(sig_pipe3(15 downto 12) = OC_SM and sig_pipe5(100 downto 98) /= "000") then
			wrp1<='0';
			wrp2<='0';
			sig8_0muxp2 <= sig_1bS;
            sig31_9muxp2 <= sig_pipe3(31 downto 9);
		elsif(sig_pipe3(15 downto 12) = OC_LM and sig_pipe4(84 downto 82) /= "000") then
			wrp1<='0';
			wrp2<='0';
			sig8_0muxp2 <= sig_1bS;
            sig31_9muxp2 <= sig_pipe3(31 downto 9);
			
		else
		  sig8_0muxp2 <= sig_pipe2(8 downto 0);
        sig31_9muxp2 <= sig_pipe2(31 downto 9);
			wrp1<='1';
			wrp2<='1';
			wrp3<='1';
			wrp4<='1';
			wrp5<='1';
		end if;
end process;

--------------------------------------------Execute stage Process------------------------------------
 process(sig_pipe3, sigSE6_op3,sigSE9_op3)
 begin

 -------------------------------FOR ALU1 BOTH INPUT MUX-----------------------------------------------------------
    if(sig_pipe3(15 downto 12)=OC_ADI or sig_pipe3(15 downto 12)=OC_LW or sig_pipe3(15 downto 12)=OC_SW) then
	  report "pipe3 opcode---------->1 :"&integer'image(to_integer(unsigned(sig_pipe3(15 downto 12))));
	  report "pipe3 se6 o----------> 1 :"&integer'image(to_integer(unsigned(sigSE6_op3)));
	  report "imm6 pipe3 ----------> 1 :"&integer'image(to_integer(unsigned(sig_pipe3(5 downto 0))));
        sig_alu1_A <= sig_pipe3(47 downto 32);
        sig_alu1_B <= sigSE6_op3;
    elsif(sig_pipe3(15 downto 12) = OC_JRI) then
	 report "pipe3 opcode----------> 2 :"&integer'image(to_integer(unsigned(sig_pipe3(15 downto 12))));
        sig_alu1_A <= sig_pipe3(63 downto 48);
        sig_alu1_B <= sigSE9_op3;
    elsif(sig_pipe3(15 downto 12) = OC_LM or sig_pipe3(15 downto 12) = OC_SM) THEN
	 report "pipe3 opcode---------->3 :"&integer'image(to_integer(unsigned(sig_pipe3(15 downto 12))));
	
        sig_alu1_A <= sig_pipe3(63 downto 48);
        sig_alu1_B <= sig_pipe3(63 downto 48);
        --MAKE ALU1 DO AND OPERATIONHERE; ADD THIS IN ALU1;
    else 
	 report "----------> SIG pipe3 47 32 :"&integer'image(to_integer(unsigned(sig_pipe3(47 downto 32))));
		report "----------> SIG pipe3 63 48 :"&integer'image(to_integer(unsigned(sig_pipe3(63 downto 48))));
		report "----------> SIG ALU1_a :"&integer'image(to_integer(unsigned(sig_alu1_a)));
		report "----------> SIG ALU1_b :"&integer'image(to_integer(unsigned(sig_alu1_b)));
        sig_alu1_A <= sig_pipe3(47 downto 32);
        sig_alu1_B <= sig_pipe3(63 downto 48);
    end if;
	 end process;
 -----------------------------------------FOR PIPE 4 MUX----------------------------------------------------
 
 process( sig_pipe3 , sig_1bS, sig_pipe4,clk, sig_alu1_C, sig_alu5_C)
	begin
    if(sig_pipe4(15 downto 12)=OC_LM or sig_pipe4(15 downto 12)=OC_SM) then
        sig_alu1_p3<=sig_alu5_C;
    else
			report "----------> SIG ALU1_C :"&integer'image(to_integer(unsigned(sig_alu1_c)));
			report "----------> SIG ALU1_a :"&integer'image(to_integer(unsigned(sig_alu1_a)));
			report "----------> SIG ALU1_b :"&integer'image(to_integer(unsigned(sig_alu1_b)));
        sig_alu1_p3 <= sig_alu1_C;
    end if;
    
    if(sig_pipe3(15 downto 12) = OC_LM or sig_pipe3(15 downto 12) = OC_SM) then
        sig8_0p3mux <= sig_1bS;
    else
        sig8_0p3mux <= sig_pipe3(8 downto 0);
    end if;



    if(sig_pipe3(15 downto 12) = OC_ADA or sig_pipe3(15 downto 12) = OC_ADI or sig_pipe3(15 downto 12) = OC_NDU) then 
        sig_cz_wr <= '1';
    else 
        sig_cz_wr <= '0';
	 END IF;
    end process;

--------------------------------------------MEMORY ACCESS STAGE-----------------------------------------------------
 process(sig_pipe4)
 begin
    if(sig_pipe4(15 downto 12) = OC_SM) then
        sig_mem_di <= sig_pipe4(47 downto 32);
    else
        sig_mem_di <= sig_pipe4(63 downto 48);
    end if;

    if(sig_pipe4(15 downto 12) = OC_SW) then
        sig_MW <= '1';
    elsif(sig_pipe4(15 downto 12) = OC_SM) then
        sig_MW <= sig_pipe4(8);

    else
        sig_MW <= '0';
    end if;

    if(sig_pipe4(8) = '1') then
        sig_alu5_B <= "0000000000000001";
    else 
        sig_alu5_B <= "0000000000000000";
    end if;
    end process;

--------------------------------------------WRITE BACK STAGE----------------------------------------------
 process(sig_pipe5,sig_alu3_bmux, sig_pc_out,clk,sig_alu3_C,sig_alu2_C) 
 begin
 ---------------------------------FOR SIG_PC_IN----------------------------------------------------------
    if(sig_pipe5(15 downto 12)=OC_JRI) then
        sig_pc_in <= sig_pipe5(79 downto 64);
    elsif(sig_pipe5(15 downto 12)=OC_JLR) then
        sig_pc_in <= sig_pipe5(47 downto 32);
    elsif(sig_pipe5(15 downto 12)=OC_JAL) then
        sig_pc_in <= sig_alu3_C;
    elsif(sig_pipe5(15 downto 12)=OC_BEQ) then
        if(sig_pipe5(80) = '1' ) then
            sig_pc_in<=sig_alu3_C;
        else 
            sig_pc_in<=sig_alu2_C;      
        end if;
    elsif(sig_pipe5(15 downto 12)=OC_BLT) then
        if(sig_pipe5(81 downto 80) = "00") then
            sig_pc_in<=sig_alu3_C;
        else 
            sig_pc_in<=sig_alu2_C;
        end if;
    elsif (sig_pipe5(15 downto 12)=OC_BLE) then
        if(sig_pipe5(81 downto 80) = "00" or sig_pipe5(81 downto 80) = "01" ) then
            sig_pc_in <= sig_alu3_C;
        else 
            sig_pc_in<=sig_alu2_C;
        end if;
    else 
	 report "----------> SIG ALU2_C :"&integer'image(to_integer(unsigned(sig_alu2_c)));
	 report "----------> SIG pc_out :"&integer'image(to_integer(unsigned(sig_pc_out)));
        sig_pc_in <= sig_alu2_C;
    end if;
	 end process;
 -----------------------------------------SIG_RF_A3-------------------------------------------
 process(sig_pipe5)
 begin
    if(sig_pipe5(15 downto 12) = OC_LM) then
        sig_rf_a3 <= sig_pipe5(100 downto 98);
        
    else
        sig_rf_a3 <= sig_pipe5(11 downto 9);
    end if;
end process;
 -----------------------------------------SIG_RF_D3--------------------------------------------------------
 process(sig_rf_a3 , sig_pipe5,sigZE9_op5,sig_alu3_c)
 begin
    if(sig_pipe5(15 downto 12) = OC_LW  or sig_pipe5(15 downto 12) = OC_LM) then
        sig_rf_d3 <= sig_pipe5(97 downto 82); -- mem_dout 
    elsif(sig_pipe5(15 downto 12) = OC_LLI) then
        sig_rf_d3 <= sigZE9_op5;
    elsif(sig_pipe5(15 downto 12) = OC_JLR or sig_pipe5(15 downto 12) = OC_JAL) then
        sig_rf_d3 <= sig_alu4_c;
    else
		  report "----------> rf_d3 :"&integer'image(to_integer(unsigned(sig_pipe5(79 downto 64))));
        sig_rf_d3 <= sig_pipe5(79 downto 64);
    end if;
	end process;
 -------------------------------------ALU3B---------------------------------------------------------
 process(sigSE9_op5 , sigSE6_op5,sig_pipe5) 
 begin
    if(sig_pipe5(15 downto 12) = OC_JAL) then
        sig_alu3_bmux <= sigSE9_op5;
    else
        sig_alu3_bmux <= sigSE6_op5;
    end if;
end process;
 ------------------------------------------RF_WRITE (complete)------------------------------------------
 process(sig_pipe5)
 begin
    if(sig_pipe5(15 downto 12) = OC_ADA) then
        if(sig_pipe5(2 downto 0) = "010" or sig_pipe5(2 downto 0) = "110") then 
            if(sig_pipe5(81) = '1') then
                sig_rf_write <= '1';
            else
                sig_rf_write <= '0';
            end if;
        elsif(sig_pipe5(2 downto 0) = "001" or sig_pipe5(2 downto 0) = "101") then
            if(sig_pipe5(80) = '1') then
                sig_rf_write <= '1';
            else
                sig_rf_write <= '0';
            end if;
        else
            sig_rf_write <= '1';
        end if;
    elsif(sig_pipe5(15 downto 12) = OC_NDU) then
        if(sig_pipe5(2 downto 0) = "010" or sig_pipe5(2 downto 0) = "110") then 
            if(sig_pipe5(81) = '1') then
                sig_rf_write <= '1';
            else 
                sig_rf_write <= '0';
            end if;
        elsif(sig_pipe5(2 downto 0) = "001" or sig_pipe5(2 downto 0) = "101") then
            if(sig_pipe5(80) = '1') then
                sig_rf_write <= '1';
            else
                sig_rf_write <= '0';
            end if;
        else
            sig_rf_write <= '1';
        end if;
    elsif(sig_pipe5(15 downto 12) = OC_LLI or sig_pipe5(15 downto 12) = OC_LW or sig_pipe5(15 downto 12) = OC_JLR or sig_pipe5(15 downto 12) = OC_JAL) then
        sig_rf_write <= '1';
    elsif (sig_pipe5(15 downto 12) = OC_LM) then
        sig_rf_write <= sig_pipe5(8);
	 elsif (sig_pipe5(15 downto 12) = OC_ADI) then
        sig_rf_write <= '1';
    else
	 
        sig_rf_write <= '0';
    end if;
    end process;
--------------------------------------------REGISTER FILE READ --------------------------------------
process(sig_rf_a1, sig_rf_a2,sig_pipe1, sig_pipe2, sig_pipe3, sig_pipe4 , sig_pipe5,sig_rf_d1,sig_alu1_c,sig_rf_d2)
    begin

 -----------------------------------------------RFDATA1 and RFDATA2 including forwarding---------------------------
    if((sig_pipe3(15 downto 12 )= OC_ADA) and (sig_pipe2(8 downto 6) = sig_pipe3(11 downto 9))) then  -- all three stage dependencies
        if(sig_pipe3(2 downto 0) = "000" or sig_pipe3(2 downto 0 ) = "011" or sig_pipe3(2 downto 0 ) = "100" or  sig_pipe3(2 downto 0 ) = "111") then 
            sig_data1p2 <= sig_alu1_c;
        elsif((sig_pipe3(2 downto 0) ="010" and sig_czout(1) ='1') or (sig_pipe3(2 downto 0) = "001" and sig_czout(0) = '1')) then 
            sig_data1p2 <= sig_alu1_c;
        elsif((sig_pipe3(2 downto 0)="110" and sig_czout(1)='1') or (sig_pipe3(2 downto 0)="101" and sig_czout(0)='1'))then	
            sig_data1p2 <= sig_alu1_c;
        else
            sig_data1p2 <= sig_rf_d1;
        end if;

    elsif(sig_pipe3(15 downto 12) = OC_NDU and (sig_pipe2(8 downto 6) = sig_pipe3(11 downto 9))) then 
        if(sig_pipe3(2 downto 0) = "000" or sig_pipe3(2 downto 0 ) = "100") then 
            sig_data1p2 <= sig_alu1_c;
        elsif((sig_pipe3(2 downto 0) ="010" and sig_czout(1) ='1') or (sig_pipe3(2 downto 0) = "001" and sig_czout(0) = '1')) then 
            sig_data1p2 <= sig_alu1_c;
        elsif((sig_pipe3(2 downto 0)="110" and sig_czout(1)='1') or (sig_pipe3(2 downto 0)="101" and sig_czout(0)='1'))then	
            sig_data1p2 <= sig_alu1_c;
        else
            sig_data1p2 <= sig_rf_d1;
        end if;
    elsif(sig_pipe3(15 downto 12) = OC_ADI and (sig_pipe2(8 downto 6) = sig_pipe3(11 downto 9))) then
    sig_data1p2 <= sig_alu1_c;	
	elsif(sig_pipe3(15 downto 12) = OC_LLI and sig_pipe2(8 downto 6) = sig_pipe3(11 downto 9)) then
		sig_data1p2 <= sigZE9_op3;
		
		
	elsif((sig_pipe3(15 downto 12) = OC_JAL or sig_pipe3(15 downto 12) = OC_JLR)and sig_pipe2(8 downto 6) = sig_pipe3(11 downto 9)) then
		sig_data1p2 <= std_logic_vector(unsigned(sig_pipe3(31 downto 16)) + 1);
	
  -----------------------------level 1---------------------------------
    elsif((sig_pipe4(15 downto 12 )= OC_ADA) and (sig_pipe2(8 downto 6) = sig_pipe4(11 downto 9))) then  -- all three stage dependencies
        if(sig_pipe4(2 downto 0) = "000" or sig_pipe4(2 downto 0 ) = "011" or sig_pipe4(2 downto 0 ) = "100" or  sig_pipe4(2 downto 0 ) = "111") then 
        sig_data1p2 <= sig_pipe4(79 downto 64);
        elsif((sig_pipe4(2 downto 0) ="010" and sig_pipe4(81) ='1') or (sig_pipe4(2 downto 0) = "001" and sig_pipe4(80) = '1')) then 
        sig_data1p2 <= sig_pipe4(79 downto 64);
        elsif((sig_pipe4(2 downto 0)="110" and sig_pipe4(81)='1') or (sig_pipe4(2 downto 0)="101" and sig_pipe4(80)='1'))then	
        sig_data1p2 <= sig_pipe4(79 downto 64);
        else
        sig_data1p2 <= sig_rf_d1;
        end if;

    elsif(sig_pipe4(15 downto 12) = OC_NDU and (sig_pipe2(8 downto 6) = sig_pipe4(11 downto 9))) then 
        if(sig_pipe4(2 downto 0) = "000" or sig_pipe4(2 downto 0 ) = "100") then 
        sig_data1p2 <= sig_pipe4(79 downto 64);
        elsif((sig_pipe4(2 downto 0) ="010" and sig_pipe4(81) ='1') or (sig_pipe4(2 downto 0) = "001" and sig_pipe4(80) = '1')) then 
        sig_data1p2 <= sig_pipe4(79 downto 64);
        elsif((sig_pipe4(2 downto 0)="110" and sig_pipe4(81)='1') or (sig_pipe4(2 downto 0)="101" and sig_pipe4(80)='1'))then	
        sig_data1p2 <= sig_pipe4(79 downto 64);
        else
        sig_data1p2 <= sig_rf_d1;
        end if;
    elsif(sig_pipe4(15 downto 12) = OC_ADI and (sig_pipe2(8 downto 6) = sig_pipe4(11 downto 9))) then
    sig_data1p2 <= sig_pipe4(79 downto 64);
    elsif(sig_pipe4(15 downto 12) = OC_LW and (sig_pipe2(8 downto 6) = sig_pipe4(11 downto 9))) then
    sig_data1p2 <= sig_mem_do;

    elsif(sig_pipe4(15 downto 12) = OC_LLI and sig_pipe2(8 downto 6) = sig_pipe4(11 downto 9)) then
		sig_data1p2 <= ("0000000" & sig_pipe4(8 downto 0));
		
		
		elsif((sig_pipe4(15 downto 12) = OC_JAL or sig_pipe4(15 downto 12) = OC_JLR)and sig_pipe2(8 downto 6) = sig_pipe4(11 downto 9)) then
		sig_data1p2 <= std_logic_vector(unsigned(sig_pipe4(31 downto 16)) + 1);
		elsif(sig_pipe4(15 downto 12) = OC_LW and sig_pipe2(8 downto 6) = sig_pipe4(11 downto 9)) then
		sig_data1p2 <= sig_mem_do;
   ---------------------level 2 data 1--------------------------------------------
    elsif((sig_pipe5(15 downto 12)= OC_ADA) and ((sig_pipe2(8 downto 6) = sig_pipe5(11 downto 9)))) then  -- all three stage dependencies
        if(sig_pipe5(2 downto 0) = "000" or sig_pipe5(2 downto 0 ) = "011" or sig_pipe5(2 downto 0 ) = "100" or  sig_pipe5(2 downto 0 ) = "111") then 
        sig_data1p2 <= sig_pipe5(79 downto 64);
        elsif((sig_pipe5(2 downto 0) ="010" and sig_pipe5(81) ='1') or (sig_pipe5(2 downto 0) = "001" and sig_pipe5(80) = '1')) then 
        sig_data1p2 <= sig_pipe5(79 downto 64);
        elsif((sig_pipe5(2 downto 0)="110" and sig_pipe5(81)='1') or (sig_pipe5(2 downto 0)="101" and sig_pipe5(80)='1'))then	
        sig_data1p2 <= sig_pipe5(79 downto 64);
        else
        sig_data1p2 <= sig_rf_d1;
        end if;
    elsif(sig_pipe5(15 downto 12) = OC_NDU and ((sig_pipe2(8 downto 6) = sig_pipe5(11 downto 9)))) then 		
        if(sig_pipe5(2 downto 0) = "000" or sig_pipe5(2 downto 0 ) = "100") then 
        sig_data1p2 <= sig_pipe5(79 downto 64);
        elsif((sig_pipe5(2 downto 0) ="010" and sig_pipe5(81) ='1') or (sig_pipe5(2 downto 0) = "001" and sig_pipe5(80) = '1')) then 
        sig_data1p2 <= sig_pipe5(79 downto 64);
        elsif((sig_pipe5(2 downto 0)="110" and sig_pipe5(81)='1') or (sig_pipe5(2 downto 0)="101" and sig_pipe5(80)='1'))then	
        sig_data1p2 <= sig_pipe5(79 downto 64);
        else
        sig_data1p2 <= sig_rf_d1;
        end if;
    elsif(sig_pipe5(15 downto 12) = OC_ADI and (sig_pipe2(8 downto 6) = sig_pipe5(11 downto 9))) then
    sig_data1p2 <= sig_pipe5(79 downto 64);	
    elsif(sig_pipe5(15 downto 12) = OC_LW and sig_pipe2(8 downto 6)= sig_pipe5(11 downto 9)) then
    sig_data1p2<= sig_pipe5(97 downto 82);
	 elsif(sig_pipe5(15 downto 12) = OC_LLI and sig_pipe2(8 downto 6) = sig_pipe5(11 downto 9)) then
		sig_data1p2 <= sigZE9_op5;
	elsif(sig_pipe5(15 downto 12) = OC_Lw and sig_pipe2(8 downto 6) = sig_pipe5(11 downto 9)) then
		sig_data1p2 <= sig_pipe5(97 downto 82);
		elsif((sig_pipe5(15 downto 12) = OC_JAL or sig_pipe5(15 downto 12) = OC_JLR)and sig_pipe2(8 downto 6) = sig_pipe5(11 downto 9)) then
		sig_data1p2 <= std_logic_vector(unsigned(sig_pipe5(31 downto 16)) + 1);
    else 
    sig_data1p2 <= sig_rf_d1;
    end if;
    ------------------For data2 --------------------------------------------------
    if((sig_pipe3(15 downto 12 )= OC_ADA) and ((sig_pipe2(5 downto 3) = sig_pipe3(11 downto 9)))) then  -- all three stage dependencies
        if(sig_pipe3(2 downto 0) = "000" or sig_pipe3(2 downto 0 ) = "011" or sig_pipe3(2 downto 0 ) = "100" or  sig_pipe3(2 downto 0 ) = "111") then 
            sig_data2p2 <= sig_alu1_c;
        elsif((sig_pipe3(2 downto 0) ="010" and sig_czout(1) ='1') or (sig_pipe3(2 downto 0) = "001" and sig_czout(0) = '1')) then 
            sig_data2p2 <= sig_alu1_c;
        elsif((sig_pipe3(2 downto 0)="110" and sig_czout(1)='1') or (sig_pipe3(2 downto 0)="101" and sig_czout(0)='1'))then	
            sig_data2p2 <= sig_alu1_c;
        else
            sig_data2p2 <= sig_rf_d2;
        end if;
    elsif(sig_pipe3(15 downto 12) = OC_NDU and ((sig_pipe2(5 downto 3) = sig_pipe3(11 downto 9)))) then 		
        if(sig_pipe3(2 downto 0) = "000" or sig_pipe3(2 downto 0 ) = "100") then 
            sig_data2p2 <= sig_alu1_c;
        elsif((sig_pipe3(2 downto 0) ="010" and sig_czout(1) ='1') or (sig_pipe3(2 downto 0) = "001" and sig_czout(0) = '1')) then 
            sig_data2p2 <= sig_alu1_c;
        elsif((sig_pipe3(2 downto 0)="110" and sig_czout(1)='1') or (sig_pipe3(2 downto 0)="101" and sig_czout(0)='1'))then	
            sig_data2p2 <= sig_alu1_c;
        else
            sig_data2p2 <= sig_rf_d2;
        end if;
    elsif(sig_pipe3(15 downto 12) = OC_ADI and (sig_pipe2(5 downto 3) = sig_pipe3(11 downto 9))) then
	 report "sig_alu1_c adi ------> :"&integer'image(to_integer(unsigned(sig_rf_d1)));
		sig_data2p2 <= sig_alu1_c;	
   elsif(sig_pipe3(15 downto 12) = OC_LLI and sig_pipe2(5 downto 3) = sig_pipe3(11 downto 9)) then
		sig_data2p2 <= sigZE9_op3;
	elsif((sig_pipe3(15 downto 12) = OC_JAL or sig_pipe3(15 downto 12) = OC_JLR)and sig_pipe2(5 downto 3) = sig_pipe3(11 downto 9)) then
		sig_data2p2 <= std_logic_vector(unsigned(sig_pipe3(31 downto 16)) + 1);
	
    --- level1 ----------------------

    elsif((sig_pipe4(15 downto 12 )= OC_ADA) and ((sig_pipe2(5 downto 3) = sig_pipe4(11 downto 9)))) then  -- all three stage dependencies
        if(sig_pipe4(2 downto 0) = "000" or sig_pipe4(2 downto 0 ) = "011" or sig_pipe4(2 downto 0 ) = "100" or  sig_pipe4(2 downto 0 ) = "111") then 
            sig_data2p2 <= sig_pipe4(79 downto 64);
        elsif((sig_pipe4(2 downto 0) ="010" and sig_pipe4(81) ='1') or (sig_pipe4(2 downto 0) = "001" and sig_pipe4(80) = '1')) then 
            sig_data2p2 <= sig_pipe4(79 downto 64);
        elsif((sig_pipe4(2 downto 0)="110" and sig_pipe4(81)='1') or (sig_pipe4(2 downto 0)="101" and sig_pipe4(80)='1'))then	
            sig_data2p2 <= sig_pipe4(79 downto 64);
        else
            sig_data2p2 <= sig_rf_d2;
        end if;


    elsif(sig_pipe4(15 downto 12) = OC_NDU and ((sig_pipe2(5 downto 3) = sig_pipe4(11 downto 9)))) then 		
        if(sig_pipe4(2 downto 0) = "000" or sig_pipe4(2 downto 0 ) = "100") then 
            sig_data2p2 <= sig_pipe4(79 downto 64);
        elsif((sig_pipe4(2 downto 0) ="010" and sig_pipe4(81) ='1') or (sig_pipe4(2 downto 0) = "001" and sig_pipe4(80) = '1')) then 
            sig_data2p2 <= sig_pipe4(79 downto 64);
        elsif((sig_pipe4(2 downto 0)="110" and sig_pipe4(81)='1') or (sig_pipe4(2 downto 0)="101" and sig_pipe4(80)='1'))then	
            sig_data2p2 <= sig_pipe4(79 downto 64);
        else
            sig_data2p2 <= sig_rf_d2;
        end if;
    elsif(sig_pipe4(15 downto 12) = OC_ADI and (sig_pipe2(5 downto 3) = sig_pipe4(11 downto 9))) then
    sig_data2p2 <= sig_pipe4(79 downto 64);	
    elsif(sig_pipe4(15 downto 12) = OC_LW and sig_pipe2(5 downto 3)= sig_pipe4(11 downto 9)) then
    sig_data2p2<= sig_mem_do;
   elsif(sig_pipe4(15 downto 12) = OC_LLI and sig_pipe2(5 downto 3) = sig_pipe4(11 downto 9)) then
		sig_data2p2 <= ("0000000" & sig_pipe4(8 downto 0));
	elsif(sig_pipe4(15 downto 12) = OC_LW and sig_pipe2(5 downto 3) = sig_pipe4(11 downto 9)) then
		sig_data2p2 <= sig_mem_do;
	elsif((sig_pipe4(15 downto 12) = OC_JAL or sig_pipe4(15 downto 12) = OC_JLR)and sig_pipe2(5 downto 3) = sig_pipe4(11 downto 9)) then
		sig_data2p2 <= std_logic_vector(unsigned(sig_pipe4(31 downto 16)) + 1);
    -----------------------------level2 data 2-------------------------------------------------
    elsif((sig_pipe5(15 downto 12)= OC_ADA) and ((sig_pipe2(5 downto 3) = sig_pipe5(11 downto 9)))) then  -- all three stage dependencies
        if(sig_pipe5(2 downto 0) = "000" or sig_pipe5(2 downto 0 ) = "011" or sig_pipe5(2 downto 0 ) = "100" or  sig_pipe5(2 downto 0 ) = "111") then 
            sig_data2p2 <= sig_pipe5(79 downto 64);
        elsif((sig_pipe5(2 downto 0) ="010" and sig_pipe5(81) ='1') or (sig_pipe5(2 downto 0) = "001" and sig_pipe5(80) = '1')) then 
            sig_data2p2 <= sig_pipe5(79 downto 64);
        elsif((sig_pipe5(2 downto 0)="110" and sig_pipe5(81)='1') or (sig_pipe5(2 downto 0)="101" and sig_pipe5(80)='1'))then	
            sig_data2p2 <= sig_pipe5(79 downto 64);
        else
            sig_data2p2 <= sig_rf_d2;
        end if;


    elsif(sig_pipe5(15 downto 12) = OC_NDU and ((sig_pipe2(5 downto 3) = sig_pipe5(11 downto 9)))) then 		
        if(sig_pipe5(2 downto 0) = "000" or sig_pipe5(2 downto 0 ) = "100") then 
            sig_data2p2 <= sig_pipe5(79 downto 64);
        elsif((sig_pipe5(2 downto 0) ="010" and sig_pipe5(81) ='1') or (sig_pipe5(2 downto 0) = "001" and sig_pipe5(80) = '1')) then 
            sig_data2p2 <= sig_pipe5(79 downto 64);
        elsif((sig_pipe5(2 downto 0)="110" and sig_pipe5(81)='1') or (sig_pipe5(2 downto 0)="101" and sig_pipe5(80)='1'))then	
            sig_data2p2 <= sig_pipe5(79 downto 64);
        else
            sig_data2p2 <= sig_rf_d2;
        end if;
    elsif(sig_pipe5(15 downto 12) = OC_ADI and (sig_pipe2(5 downto 3) = sig_pipe5(11 downto 9))) then
    sig_data2p2 <= sig_pipe5(79 downto 64);	
    elsif(sig_pipe5(15 downto 12) = OC_LW and sig_pipe2(5 downto 3)= sig_pipe5(11 downto 9)) then
    sig_data2p2<= sig_pipe5(97 downto 82);
	 elsif(sig_pipe5(15 downto 12) = OC_LLI and sig_pipe2(5 downto 3) = sig_pipe5(11 downto 9)) then
		sig_data2p2 <= sigZE9_op5;
	elsif(sig_pipe5(15 downto 12) = OC_Lw and sig_pipe2(8 downto 6) = sig_pipe5(11 downto 9)) then
		sig_data2p2 <= sig_pipe5(97 downto 82);
	elsif((sig_pipe4(15 downto 12) = OC_JAL or sig_pipe5(15 downto 12) = OC_JLR)and sig_pipe2(5 downto 3) = sig_pipe5(11 downto 9)) then
		sig_data2p2 <= std_logic_vector(unsigned(sig_pipe5(31 downto 16)) + 1);
    else 
    sig_data2p2 <= sig_rf_d2;
    end if;
	 end process;
    --------------------------------------------RFA1 and RFA2------------------------------------------
	 process(sig_pipe2, sig_pipe3, sig_1bS,sig_pipe4) 
	 begin
    if((sig_pipe2(15 downto 12) = OC_SM or sig_pipe3(15 downto 12) = OC_SM) and sig_pipe5(100 downto 98) /= "000") then
        sig_rf_a1 <= sig_pipe4(84 downto 82);
    else
        sig_rf_a1 <=sig_pipe2(8 downto 6) ;
    end if;

    if(sig_pipe2(15 downto 12) = OC_SW or sig_pipe2(15 downto 12) = OC_BEQ or sig_pipe2(15 downto 12) = OC_BLT or sig_pipe2(15 downto 12) = OC_BLE or sig_pipe2(15 downto 12) = OC_JRI) then
        sig_rf_a2 <= sig_pipe2(11 downto 9);
    else
        sig_rf_a2 <= sig_pipe2(5 downto 3);
    end if;  
    end process;
-----------------------------------INSTRUCTION fecth------------------------------------
    process(sig_pipe1,sig_pipe2 , sig_pipe3 , sig_pipe4, sig_pipe5, sig_pc_out)

        begin
		  	 report "pipe1------> :"&integer'image(to_integer(unsigned(sig_pipe1)));
			 report "pipe2 ------> :"&integer'image(to_integer(unsigned(sig_pipe2)));
			 report "pipe3 ------->:"&integer'image(to_integer(unsigned(sig_pipe3)));
			 report "pipe4--------> :"&integer'image(to_integer(unsigned(sig_pipe4)));
			 report "pipe5 --------> :"&integer'image(to_integer(unsigned(sig_pipe5)));
			 
			 
			 
			 report "pipe4 last bits ---->:"&integer'image(to_integer(unsigned(sig_pipe4(84 downto 82))));
            if(sig_pipe3(15 downto 12) = OC_LW) then
                if( sig_pipe2(15 downto 12) = OC_ADA or sig_pipe2(15 downto 12) = OC_ADI or sig_pipe2(15 downto 12) = OC_NDU or sig_pipe2(15 downto 12) = OC_LW or sig_pipe2(15 downto 12) = OC_SW or sig_pipe2(15 downto 12) = OC_BEQ or sig_pipe2(15 downto 12) = OC_BLT or sig_pipe2(15 downto 12) = OC_BLE or sig_pipe2(15 downto 12) = OC_JLR) then 
                    if(sig_pipe2(8 downto 6) = sig_pipe3(11 downto 9)) then 
                        sig_alu2_B <= "0000000000000000";
                    else 
                        sig_alu2_B <= "0000000000000001";
                    end if;
                elsif(sig_pipe2(15 downto 12) = OC_ADA or sig_pipe2(15 downto 12) = OC_NDU) then 
                    if(sig_pipe2(5 downto 3) = sig_pipe3(11 downto 9)) then 
                        sig_alu2_B <= "0000000000000000";
                    else
                        sig_alu2_B <= "0000000000000001";
                    end if;
                else 
                    sig_alu2_B <= "0000000000000001";
                end if;

          

			   elsif(sig_pipe3(15 downto 12) = OC_SM and sig_pipe5(100 downto 98) /= "000") then
					 sig_alu2_B <= "0000000000000000";
				elsif(sig_pipe3(15 downto 12)= OC_LM and sig_pipe4(84 downto 82) /= "000") then
					 sig_alu2_B <= "0000000000000000";
					
				else
					
                sig_alu2_B <= "0000000000000001";
		
				end if;	
					 
 
    end process;
	 Instruction(3 downto 0) <= sig_pipe1(15 downto 12);
	Instruction(7 downto 4) <= sig_pipe2(15 downto 12);
	Instruction(11 downto 8) <= sig_pipe3(15 downto 12);
	Instruction(15 downto 12) <= sig_pipe4(15 downto 12);
	Instruction(19 downto 16) <= sig_pipe5(15 downto 12);
 end architecture rtl ;