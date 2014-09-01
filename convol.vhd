----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:01:28 05/22/2013 
-- Design Name: 
-- Module Name:    convol - Behavioral 
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

entity convol is
    Port ( 
				din : in  STD_LOGIC_VECTOR (7 downto 0);
				clk : in  STD_LOGIC;
				ce : in  STD_LOGIC;
				valid : out STD_LOGIC;
				-- d1 : in  STD_LOGIC_VECTOR (14 downto 0);
				-- d2 : in  STD_LOGIC_VECTOR (14 downto 0);
				-- d3 : in  STD_LOGIC_VECTOR (14 downto 0);
				-- d4 : in  STD_LOGIC_VECTOR (14 downto 0);
				-- q1 : out  STD_LOGIC_VECTOR (19 downto 0);
				-- q2 : out  STD_LOGIC_VECTOR (19 downto 0);
				-- q3 : out  STD_LOGIC_VECTOR (19 downto 0);
				-- q4 : out  STD_LOGIC_VECTOR (7 downto 0);
				q : out  STD_LOGIC_VECTOR (19 downto 0));
end convol;

architecture Behavioral of convol is

COMPONENT row_convol
PORT(
	 din : IN  std_logic_vector(7 downto 0);
	 clk : IN  std_logic;
	 ce : IN  std_logic;
	 valid : OUT  std_logic;
	q : OUT  std_logic_vector(14 downto 0)
	);
END COMPONENT;


COMPONENT line_buffer
	PORT(
		din : IN std_logic_vector(14 downto 0);
		ce : IN std_logic;
		ce_ram :IN STD_LOGIC;
		clk : IN std_logic;
		sclr : IN std_logic;          
		dout_1 : OUT std_logic_vector(14 downto 0);
		dout_2 : OUT std_logic_vector(14 downto 0);
		dout_3 : OUT std_logic_vector(14 downto 0);
		dout_4 : OUT std_logic_vector(14 downto 0);
		valid : OUT std_logic
		);
	END COMPONENT;

COMPONENT mua_14
  PORT (
    clk : IN STD_LOGIC;
    ce : IN STD_LOGIC;
    sclr : IN STD_LOGIC;
    a : IN STD_LOGIC_VECTOR(14 DOWNTO 0);
    b : IN STD_LOGIC_VECTOR(14 DOWNTO 0);
    c : IN STD_LOGIC_VECTOR(47 DOWNTO 0);
    pcin : IN STD_LOGIC_VECTOR(47 DOWNTO 0);
    subtract : IN STD_LOGIC;
    p : OUT STD_LOGIC_VECTOR(19 DOWNTO 0);
    pcout : OUT STD_LOGIC_VECTOR(47 DOWNTO 0)
  );
END COMPONENT ;

COMPONENT mua_c_14
    PORT(
         clk : IN  std_logic;
         ce : IN  std_logic;
         sclr : IN  std_logic;
         a : IN  std_logic_vector(14 downto 0);
         b : IN  std_logic_vector(14 downto 0);
         c : IN  std_logic_vector(14 downto 0);
         subtract : IN  std_logic;
         p : OUT  std_logic_vector(19 downto 0);
         pcout : OUT  std_logic_vector(47 downto 0)
        );
    END COMPONENT;

COMPONENT conv_div_2
	PORT (
	clk: in std_logic;
	ce: in std_logic;
	sclr: in std_logic;
	rfd: out std_logic;
	dividend: in std_logic_vector(19 downto 0);
	divisor: in std_logic_vector(7 downto 0);
	quotient: out std_logic_vector(19 downto 0);
	fractional: out std_logic_vector(7 downto 0)
	);
END COMPONENT;
	
signal lb_valid, lb_sclr, lb_ce, ram_ce, m_ce,  m_sclr, div_ce, div_sclr, conv_valid, rfd, row_ce, row_valid, sub, flag: std_logic;

signal reg11, reg12, reg21, reg31, reg32, reg33,reg34,reg35 : std_logic_vector(14 downto 0);
signal reg41, reg42, reg43, reg44, reg45, reg46, reg47, reg48, reg49, reg410, reg411,reg413: std_logic_vector(14 downto 0);
signal pcin1,pcin2,pcin3,c1,c2,c3, reg_pcin11, reg_pcin21 : std_logic_vector(47 downto 0);
signal p1,p2,p3,reg_p3, reg412 : std_logic_vector(19 downto 0);

signal row_line, img_line,line1,line2,line3,line4 : std_logic_vector(14 downto 0);
signal k1,k2 : std_logic_vector(14 downto 0);

signal div_in2, frac : std_logic_vector(7 downto 0);
signal div_in1, reg_out : std_logic_vector(19 downto 0);

begin

rowconv: row_convol PORT MAP (
          din => din,
          clk => clk,
          ce => ce,
          valid => row_valid,
          q => img_line
        );

l1: line_buffer PORT MAP(
		din => img_line,
		dout_1 => line1,
		dout_2 => line2,
		dout_3 => line3,
		dout_4 => line4,
		valid => lb_valid,
		ce => lb_ce,
		ce_ram => ram_ce,
		clk => clk,
		sclr => lb_sclr
);

comp1 : mua_c_14 port map(clk, m_ce,m_sclr,line1,k1,reg12,sub,p1,pcin1);
comp2 : mua_14   port map(clk, m_ce,m_sclr,reg21,k2,c1,reg_pcin11,sub,p2,pcin2);
comp3 : mua_14   port map(clk, m_ce,m_sclr,reg35,k1,c2,reg_pcin21,sub,p3,pcin3);

-- comp4 : add_20 port map(reg_p3,reg412,qout);

div : conv_div_2	port map (
		clk => clk,
		ce => div_ce,
		sclr => div_sclr,
		rfd => rfd,
		dividend => div_in1,
		divisor => div_in2,
		quotient => q,
		fractional => frac
		);

process(clk,ce,din)

variable start: integer range 0 to 63 := 0;
variable row: integer range 0 to 512 := 0;
variable col: integer range 0 to 320 := 0;


begin

if (ce = '0') then
	
	--row_valid <= '0';
	conv_valid <= '0';
	m_ce <= '0';
	m_sclr <= '1';
	lb_ce <= '0';
	lb_sclr <= '1';
	ram_ce <= '0';
	
	div_ce <= '0';
	div_sclr <= '1';
	sub <= '0';
	flag <= '0';
	
	row := 0;
	col := 0;
	start:=0;
	
--	q <= (others => '0');
--	q1 <= (others => '0');
--	q2 <= (others => '0');
--	q3 <= (others => '0');
--	q4 <= (others => '0');
--	qout <= (others => '0');
	
	-- p1 <= (others => '0');
	-- p2 <= (others => '0');
	-- p3 <= (others => '0');
	reg11 <= (others => '0');
	reg21 <= (others => '0');
	reg31 <= (others => '0');
	reg32 <= (others => '0');
	reg33 <= (others => '0');
	reg34 <= (others => '0');
	reg35 <= (others => '0');
	
	reg41 <= (others => '0');
	reg42 <= (others => '0');
	reg43 <= (others => '0');
	reg44 <= (others => '0');
	reg45 <= (others => '0');
	reg46 <= (others => '0');
	reg47 <= (others => '0');
	reg48 <= (others => '0');
	reg49 <= (others => '0');
	reg410 <= (others => '0');
	reg411 <= (others => '0');
	reg412 <= (others => '0');
	
	reg_out <= (others => '0');
	div_in1 <= (others => '0');
	div_in2 <= (others => '0');
	
	c1 <= (others => '0');
	c2 <= (others => '0');
	c3 <= (others => '0');
			
	k1 <= (others => '0');
	k2 <= (others => '0');
	
	reg_pcin21 <= (others => '0');
	reg_pcin11 <= (others => '0');
	reg_p3 <= (others => '0');

	-- img_line <= (others => '0');
	-- line1 <= (others => '0');
	-- line2 <= (others => '0');
	-- line3 <= (others => '0');
	-- line4 <= (others => '0');
	
elsif (rising_edge(clk) and ce = '1')then
		
	if(row_valid = '1') then
		
		--img_line <= row_line;
		lb_ce <= '1';
		lb_sclr <= '0';
		ram_ce <= '1';
	else
	
		ram_ce <= '0';	
	
	end if; 
	
	if(lb_valid='1' and flag = '0')then
			
			m_ce<='1';
			m_sclr <= '0';
			sub <= '0';
			
			div_ce <= '1';
			div_sclr <= '0';
			
			k1 <= std_logic_vector(to_unsigned(3,15));
			k2 <= std_logic_vector(to_unsigned(5,15));
			
			reg12 <= reg11;
			reg11 <= img_line;

			c1(19 downto 0) <= p1;
			c2(19 downto 0) <= p2;
			reg_p3 <= p3;
			
			--reg_pcin12<= reg_pcin11;
			reg_pcin11<= pcin1;
			reg_pcin21<= pcin2;
			
			reg21 <= line2;
			
			reg35 <= reg34;
			reg34 <= reg33;
			reg33 <= reg32;
			reg32 <= reg31;
			reg31 <= line3;
		

			reg412 <= "00000" & reg411;
			reg411 <= reg410;
			reg410 <= reg49;
			reg49 <= reg48;
			reg48 <= reg47;
			reg47 <= reg46;
			reg46 <= reg45;
			reg45 <= reg44;
			reg44 <= reg43;
			reg43 <= reg42;
			reg42 <= reg41;
			reg41 <= line4;

			-- q1 <= c2(19 downto 0);
			-- q2 (14 downto 0) <= reg35;
			-- q3 <= reg_p3;
			-- q4 <= reg412;

			
			div_in2 <= std_logic_vector(to_unsigned(169,8));
			reg_out <= std_logic_vector(unsigned(reg_p3) + unsigned(reg412));
			div_in1 <= reg_out;
--			q3 <= reg_out;
--			q4 <= div_in2;
--			q <= reg_q ;
			
			if(start<39)then
				start := start + 1;
			elsif(start=39)then
				valid <= '1';
					
				if(col<316)then
					col := col + 1;

				elsif (col = 316 and row<252)then

					col := 0;
					row := row + 1;
					valid <= '0';
					start := 36;


				elsif (col = 316 and row = 252)then

					col := 0;
					row := 0;
					--start := 0;
					valid<='0';
					flag <= '1';

				end if;
				
			end if;
	end if;
		
end if;

end process;
end Behavioral;

