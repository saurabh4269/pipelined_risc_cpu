library std;
use std.standard.all;
library ieee;
use ieee.std_logic_1164.all; 
library ieee;
use ieee.numeric_std.all;
 
entity memory_d is 
  port (MW, CLK : in std_logic;
  		
        mem_add : in std_logic_vector(15 downto 0);   
        mem_di  : in std_logic_vector(15 downto 0);   
        mem_do  : out std_logic_vector(15 downto 0));  
end entity; 

architecture membehave of memory_d is 
	type RAM is array(0 to ((16)-1)) of std_logic_vector(15 downto 0);
	signal storage: RAM := (	

		0 => "0000000000000000",
		1 => "0000000000000001", 
		2 => "0000000000000010",   
		3 => "0000000000000011", 
		4 => "0000000000000100", 
		5 => "0101010001000001", 
		6 => "1100011001000010", 
		7 => "1000010000000100", 				
		8 => "1000010000000100", 
		10 => "0000000001010010", 
		11 => "0000000001010000", 
		others=>(others=>'1'));

	
	begin
	process(CLK, mem_add, MW, storage) 
		begin
			report "memory data mem add :"&integer'image(to_integer(unsigned(mem_add)));
			if rising_edge(CLK) and MW = '1' then
				if(to_integer(unsigned(mem_add))>15) then 
					 report "do nothing eat 5 star ";
					else
					report "mw 1 mem_add in memory  :"&integer'image(to_integer(unsigned(mem_add)));
					storage(to_integer(unsigned(mem_add))) <= mem_di;
				 end if;
			end if;
			    report "MRD 1 mem_add in memory :"&integer'image(to_integer(unsigned(mem_add)));
				 if(to_integer(unsigned(mem_add))>15) then 
					 report "do nothing eat 5 star ";
					else
				     mem_do <= storage(to_integer(unsigned(mem_add)));
			     end if;
			     report "mem_add 0 in memory :"&integer'image(to_integer(unsigned(storage(0))));
				  report "mem_add 1 in memory :"&integer'image(to_integer(unsigned(storage(1))));
				  report "mem_add 2 in memory :"&integer'image(to_integer(unsigned(storage(2))));
				  report "mem_add 3 in memory :"&integer'image(to_integer(unsigned(storage(3))));
	end process;
end membehave;

