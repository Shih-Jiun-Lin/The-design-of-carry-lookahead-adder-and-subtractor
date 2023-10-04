library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity carry_lookahead_adder is
	Port( 
		x: in std_logic_vector(3 downto 0);
      y: in std_logic_vector(3 downto 0);
      sel_x: in std_logic;
		sel_y: in std_logic;
      s: out std_logic_vector(3 downto 0);
      co: out std_logic;
		overflow: out std_logic;
		sign: out std_logic;
		sgd: out std_logic_vector(6 downto 0) --for resulut display with 7seg display
	);
end carry_lookahead_adder;

architecture behavioral of carry_lookahead_adder is

signal sum_temp, sum, y_final, x_final,  sum_display: std_logic_vector(3 downto 0) := "0000";
signal c : std_logic_vector(4 downto 0) := "00000"; --c4 for last carry(cout)
signal p : std_logic_vector(3 downto 0) := "0000"; 
signal g : std_logic_vector(3 downto 0) := "0000"; 

component seven_segement_decoder is
	port(
		data: in std_logic_vector(3 downto 0);
		display: out std_logic_vector(6 downto 0)
	);	
end component;

begin
	x_to_2s: process(x) --2's complement of data x
		begin
			if(sel_x='1') then
				x_final <= not(x) + sel_x;
			else
				x_final <= x;
			end if;
	end process; --2's complement of data y
	
	y_to_2s: process(y)
		begin
			if(sel_y='1') then
				y_final <= not(y) + sel_y;
			else
				y_final <= y;
			end if;
	end process;
	
	sum_temp <= x_final xor y_final; 
   g <= x_final and y_final; 
   p <= x_final or y_final; 
	c(0) <= '0';
	
   cla: process(c, p, g)
		begin
			clc: for i in 0 to 3 loop --carry lookahead circuits
				c(i+1) <= g(i) or (p(i) and c(i)); 
		end loop;
	end process;
	 
   co <= c(4); 
   sum <= sum_temp xor c(3 downto 0);
	s <= sum;
	overflow <= c(4) xor c(3);
	sign <= sum(3);
	
	sgd_num: seven_segement_decoder
		port map(
			data => sum_display,
			display => sgd
		);
end behavioral;