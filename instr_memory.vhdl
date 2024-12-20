library std;
use std.standard.all;
library ieee;
use ieee.std_logic_1164.all; 
library ieee;
use ieee.numeric_std.all; 

--        ----------------------------------Instruction memory ----------------------
entity instrMemory is 
  port (ins_init: in std_logic; 
        pc_in : in std_logic_vector(15 downto 0);   -- mem_add   
        mem_io  : out std_logic_vector(15 downto 0));  
end entity; 
architecture membehave of instrMemory is 
	type RAM is array(0 to ((16)-1)) of std_logic_vector(15 downto 0);
	signal storage: RAM;
	begin
	process(ins_init,pc_in,storage) 
		begin 
			report "instr memory adddress:"&integer'image(to_integer(unsigned(pc_in)));
			if (ins_init = '1') then
			 	report "mem init in memory memory";
				storage(0) <= "0001001010011000"; -- ADA R1 = R2 + R3 =0
				storage(1) <= "0111010011001001"; -- sm  mem(0)
				storage(2) <= "0001010011101000"; -- ADA R2 = R3 + R5
				storage(3) <= "0000010011101100"; -- ADI R2 = R3 + 24
				storage(4) <= "0101010001000001"; -- SW R2 = 24 , mem_add = r1(0) + imm6(1), now storage(1) = 4;
				storage(5) <= "1100011001000010"; -- jal pc = pc + 2*imm9
				storage(6) <= "1000010000000100"; -- beq 				
				storage(7) <= "1000010000000100"; -- beq 
				storage(8) <="0000000001010010"; -- Adi  
				storage(9) <="0000000001010000"; -- Adi 
			end if;
	   end process;	
			mem_io <= storage(to_integer(unsigned(pc_in)));

		
	
end membehave;
	