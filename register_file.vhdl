library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
entity RF is
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
end RF;

architecture reg_arc of RF is
	type typereg is array (0 to 7) of std_logic_vector(15 downto 0);    -- 	8 Registers of 16 bits each
	signal registers: typereg:= (others=>"0000000000000000");				-- initialized to 0
begin

	process(rf_write,rf_a1,rf_a2,rf_a3,rf_d3,clk,pc_en)
	begin
	   if(pc_en = '1' and rising_edge(clk)) then 
		  report "Devesh----------------->  :"&integer'image(to_integer(unsigned(pc_in)));
        registers(0)<=std_logic_vector(unsigned(pc_in));
		  end if;
	  
		
		if(rising_edge(clk) and rf_write = '1') then               ---- write only on falling edges when rf_write enabled
				case rf_a3 is
					when "001" =>
						report "reg1 when----------------->  :"&integer'image(to_integer(unsigned(registers(1))));
						registers(1)<=rf_d3;
					when "010" =>
					   report "reg2 when ----------------->  :"&integer'image(to_integer(unsigned(registers(2))));
						registers(2)<=rf_d3;
					when "011" =>
					   report "reg3 when----------------->  :"&integer'image(to_integer(unsigned(registers(3))));
						registers(3)<=rf_d3;
					when "100" =>
						registers(4)<=rf_d3;
					when "101" =>
						registers(5)<=rf_d3;
					when "110" =>
						registers(6)<=rf_d3;
					when "111" =>
						registers(7)<=rf_d3;
					when others =>
						null;
				end case; 

    end if;  
		report "reg1----------------->  :"&integer'image(to_integer(unsigned(registers(1))));
		report "reg2----------------->  :"&integer'image(to_integer(unsigned(registers(2))));
		report "reg3----------------->  :"&integer'image(to_integer(unsigned(registers(3))));
		report "reg4----------------->  :"&integer'image(to_integer(unsigned(registers(4))));
		report "reg5----------------->  :"&integer'image(to_integer(unsigned(registers(5))));
		       		
	end process;

		pc_out<=registers(0); 
	rf_d1<=registers(to_integer(unsigned(rf_a1)));     --001 means registers(1) and so on
	  rf_d2<=registers(to_integer(unsigned(rf_a2)));                     

end architecture;