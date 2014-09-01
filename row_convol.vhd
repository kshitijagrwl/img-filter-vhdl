----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:01:28 05/22/2013 
-- Design Name: 
-- Module Name:    row_row_convol - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity row_convol is
    Port ( din : in  STD_LOGIC_VECTOR (7 downto 0);
				clk : in  STD_LOGIC;
				ce : in  STD_LOGIC;
				valid : out STD_LOGIC;
-- d1 : out  STD_LOGIC_VECTOR (11 downto 0);
-- d2 : out  STD_LOGIC_VECTOR (11 downto 0);
-- d3 : out  STD_LOGIC_VECTOR (12 downto 0);
-- d4 : out  STD_LOGIC_VECTOR (13 downto 0);
-- d5 : out  STD_LOGIC_VECTOR (14 downto 0);
				q : out  STD_LOGIC_VECTOR (14 downto 0));
end row_convol;

architecture Behavioral of row_convol is

COMPONENT mult_3
  PORT (
    clk : IN STD_LOGIC;
    a : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    ce : IN STD_LOGIC;
    p : OUT STD_LOGIC_VECTOR(10 DOWNTO 0)
  );
END COMPONENT;

COMPONENT mult_5
  PORT (
    clk : IN STD_LOGIC;
    a : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    ce : IN STD_LOGIC;
    p : OUT STD_LOGIC_VECTOR(10 DOWNTO 0)
  );
END COMPONENT;

COMPONENT add_11
  PORT (
    a : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
    b : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
    s : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
  );
END COMPONENT;

COMPONENT add_12
  PORT (
    a : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
    b : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
    s : OUT STD_LOGIC_VECTOR(12 DOWNTO 0)
  );
END COMPONENT;

COMPONENT add_13
  PORT (
    a : IN STD_LOGIC_VECTOR(12 DOWNTO 0);
    b : IN STD_LOGIC_VECTOR(12 DOWNTO 0);
    s : OUT STD_LOGIC_VECTOR(13 DOWNTO 0)
  );
END COMPONENT;

COMPONENT add_14
  PORT (
    a : IN STD_LOGIC_VECTOR(13 DOWNTO 0);
    b : IN STD_LOGIC_VECTOR(13 DOWNTO 0);
    s : OUT STD_LOGIC_VECTOR(14 DOWNTO 0)
  );
END COMPONENT;

signal m_ce, row_valid : std_logic;

signal img_line, line1, line2, line3, line4, line5, line6, line7 : std_logic_vector(7 downto 0);
signal reg_line1 : std_logic_vector(10 downto 0);
--signal reg_line5 : std_logic_vector(9 downto 0);

--signal m1 : std_logic_vector(9 downto 0);
signal m1, m2 : std_logic_vector(10 downto 0);

--signal line2  : std_logic_vector(9 downto 0);
signal reg21, reg22 : std_logic_vector(10 downto 0);
signal reg31, reg32, reg_a1, sum1	: std_logic_vector(11 downto 0);
signal reg23, reg24, reg25, reg_a2, sum2	: std_logic_vector(12 downto 0);
signal line8, reg_a3, sum3	: std_logic_vector(13 downto 0);
signal reg_a4, sum4	: std_logic_vector(14 downto 0);


begin

mu1: mult_3 port map(clk,line1,m_ce,m1);
mu2: mult_5 port map(clk,line2,m_ce,m2);

adder11 : add_11 port map(reg_line1,m1,sum1);
adder12 : add_12 port map(reg_a1,reg31,sum2);
adder13 : add_13 port map(reg_a2,reg24,sum3);
adder14 : add_14 port map(reg_a3,line8,sum4);



process(clk)

variable count: integer range 0 to 16 := 0;
variable col: integer range 0 to 320 := 0;

begin 


if (ce = '0') then
	
	q <= (others => '0');
	
	img_line <= (others => '0');
	line1 <= (others => '0');
	line2 <= (others => '0');
	line3 <= (others => '0');
	line4 <= (others => '0');
	line5 <= (others => '0');
	line6 <= (others => '0');
	line7 <= (others => '0');
	line8 <= (others => '0');

	reg_line1 <= (others => '0');
	reg32 <= (others => '0');
	reg31 <= (others => '0');
	reg24 <= (others => '0');
	reg23 <= (others => '0');
	reg22 <= (others => '0');
	reg21 <= (others => '0');
	
	reg_a1 <= (others => '0');
	reg_a2 <= (others => '0');
	reg_a3 <= (others => '0');
	reg_a4 <= (others => '0');
	
	col := 0;
	count := 0;
	m_ce <= '0';
	valid <= '0';
	
elsif (rising_edge(clk) and ce = '1')then
	
	img_line <= din;
	--valid <= row_valid;
--	d1 <= "0" & reg_line1;
--	d2 <= "0" & m1;
--	d3 <= "0" & reg31;
--	d4 <= "0" & reg24;
--	d5 <= "0" & line8;
	
	line8 <=  "000000" & line7;
	line7 <= line6;
	line6 <= line5;
	line5 <= line4;
	line4 <= line3;
	line3 <= line2;
	line2 <= line1;
	reg_line1 <= "000" & img_line;
	line1 <= img_line;
	
	--reg25 <= reg24;
	reg24 <= reg23; 
	reg23 <= "00" & reg22;
	reg22 <= reg21;	
	reg21 <= m1;
	
	--reg32 <= reg31;
	reg31 <= "0" & m2;
	
	q <= reg_a4;
	
	reg_a1 <= sum1;
	reg_a2 <= sum2;
	reg_a3 <= sum3;
	reg_a4 <= sum4;
	
	m_ce <= '1';
	
	if(count<10)then
	count := count + 1;
	
	elsif(count=10)then
	valid <= '1';
	col := col + 1;
		
		if(col=317)then 
		
		reg_a1 <= (others => '0');
		reg_a2 <= (others => '0');
		reg_a3 <= (others => '0');
		reg_a4 <= (others => '0');
		
		count:= 7;
		col:= 0;
		valid <= '0';
				
		end if;
	
	end if;
	
end if;

end process;
end Behavioral;