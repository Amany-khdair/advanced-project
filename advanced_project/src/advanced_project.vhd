--32 bit ALU
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.NUMERIC_STD.all; --a library that Provides vector arithmetic functions


entity ALU_32bit is
Port (
A, B : in STD_LOGIC_VECTOR(31 downto 0); --32_bit inputs
opcode : in STD_LOGIC_VECTOR(5 downto 0); --6_bit
Result : out STD_LOGIC_VECTOR(31 downto 0)); --32_bit output
end ALU_32bit;

architecture Behav of ALU_32bit is

signal n: std_logic_vector (31 downto 0);

begin

process(A,B,opcode)
begin

case(opcode) is
-- a + b
when "000001" => n<=A + B ;  

--  a - b 
when "000110" => n<=A - B ;

-- |a| (the absolute value of a) 
when "001101" => n<=std_logic_vector(abs(signed(A)));

-- -a   
when "001000" => n<=std_logic_vector(-(signed(A)));
  
-- max (a, b) (the maximum of a and b)  
when "000111" => 
if(A>B) then
n<=A ;
else
n<=B ;
end if;

-- min (a, b) (the minimum of a and b) 
when "000100" => 
if(A>B) then
n <= B ;
else
n<=A ;
end if;

 -- avg(a,b) (the average of a and b - the integer part only and remainder is ignored)
when "001011" => n<=std_logic_vector((signed(A)+signed(B))/2);
     
-- not a     
when "001111" => n<=not A ;

-- a or b
when "000011" => n<=A or B;   

-- a and b
when "000101" =>  n<=A and B;

-- a xor b 
when "000010" => n<=A xor B;
      
when others => n<=A + B ;
end case;
end process;

Result <= n; -- ALU out

end Behav;

---------------------the ALU testbench-----------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use IEEE.std_logic_unsigned.all;

ENTITY testbench IS
END testbench;

ARCHITECTURE test OF testbench IS

-- Component Declaration
COMPONENT ALU_32bit
PORT(
A : IN std_logic_vector(31 downto 0);
B : IN std_logic_vector(31 downto 0);
opcode : IN std_logic_vector(5 downto 0);
Result : OUT std_logic_vector(31 downto 0));
      
END COMPONENT;

signal A : std_logic_vector(31 downto 0) := (others => '0');
signal B : std_logic_vector(31 downto 0) := (others => '0');
signal Opcode : std_logic_vector(5 downto 0) := (others => '0');
signal Result : std_logic_vector(31 downto 0);

BEGIN

-- Instantiate the Unit Under Test (UUT)
uut: ALU_32bit PORT MAP (
A => A,
B => B,
opcode => opcode,
Result => Result
);

-- Stimulus process
stim_proc: process
begin
-- hold reset state for 100 ns.
A <= "00000000000000000000000000001000";
B <= "00000000000000000000000000000010";
  
opcode <= "000001";	--add a and b

wait for 100 ns;
opcode <= "000110";	--subtract a and b

wait for 100 ns;
opcode <= "001101";	 --absolute value for a

wait for 100 ns;
opcode <= "001000";  -- -a

wait for 100 ns;
opcode <= "000111";	 -- max(a,b)

wait for 100 ns;
opcode <= "000100";	 --min(a,b)

wait for 100 ns;
opcode <= "001011";	 --avg(a,b)

wait for 100 ns;
opcode <= "001111";	 -- not a

wait for 100 ns;
opcode <= "000101";	 -- a and b
  
wait for 100 ns;
opcode <= "000010";	 --a xor b 

wait for 100 ns;
opcode <= "000011";	 --a or b
  
end process;
END;	

------------------------the register file------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.NUMERIC_STD.all; --a library that Provides vector arithmetic functions	 

entity memory is
	port(address1,address2,address3 : in std_logic_vector (4 downto 0);	 
	input : in std_logic_vector (31 downto 0);
	clk	:in std_logic;
	opcode: in std_logic_vector (5 downto 0);
	output1,output2 : out std_logic_vector (31 downto 0));
  --output 1 produces the item within the register file that is address by address 1.  
  --output 2 produces the item within the register file that is address by address 2. 
  --input is used to supply a value that is written into the location addressed by address 3.
end entity memory;

architecture ram of memory is
type data is array (0 to 31) of std_logic_vector (31 downto 0);
signal ram_data: data :=(x"00000000",x"00003162",x"00002960",x"00006230",
x"000022EC",x"00002248",x"000024DC",x"00000BF0",
x"000012F2",x"00000D4E",x"0000305C",x"00000224",
x"000032FE",x"00000AF0",x"000032BC",x"000003BC",
x"00000892",x"00002E8A",x"00003DF8",x"00002E38",
x"0000303A",x"00000890",x"00000730",x"000036AC",
x"00002F16",x"00001152",x"00002F78",x"00002694",
x"0000221E",x"00002074",x"00000D5E",x"00000000"); 
begin  
	process(clk) 
	begin
	if (rising_edge(clk)) then
   output1 <= ram_data (conv_integer(address1));
   output2 <= ram_data (conv_integer(address2));
   ram_data (conv_integer(address3)) <= input; 
end if; 
end process;
end architecture ram ;			

---------------------------------part 2--------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL; 

entity register_32bit is
port(machine_instruction: in std_logic_vector(31 downto 0);
opcode : out std_logic_vector(5 downto 0); 	
clk :in std_logic;
address1,address2,address3 : out std_logic_vector(4 downto 0));

end entity register_32bit;

architecture behaviour of register_32bit is	
signal op : std_logic_vector(5 downto 0);
signal x: std_logic;
begin
	enablee:entity work.enable(en) port map(op,x);
	opcode(5 downto 0) <= machine_instruction(31 downto 26);
	address1 (4 downto 0) <= machine_instruction(25 downto 21);
	address2 (4 downto 0) <= machine_instruction(20 downto 16);
	address3 (4 downto 0) <= machine_instruction(15 downto 11);
end;
-----------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity enable is
	port(opcode :in std_logic_vector(5 downto 0);
	x: out std_logic);
end entity enable;

architecture en of enable is 	 
signal op: std_logic_vector(5 downto 0);
begin
	op <= opcode;
	 
x <= '1' when op = "000001"
else '1' when op = "000110"
else '1' when op = "001101"
else '1' when op = "001000"
else '1' when op = "000111"
else '1' when op = "000100"
else '1' when op = "001011"
else '1' when op = "001111"
else '1' when op = "000101"
else '1' when op = "000010" 
else '1' when op = "000011" 	
else '0';

  end;
-----------system---------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL; 

entity system is
	port(machine_instruction: in std_logic_vector(31 downto 0);
	clk : in std_logic;
	Result : out std_logic);
	
end;

architecture sys of system is 
signal address1,address2,address3 : std_logic_vector(4 downto 0);
signal output1,output2,input : std_logic_vector(31 downto 0);
signal opcode : std_logic_vector(5 downto 0);


begin
	alu: entity work.ALU_32bit(Behav) port map (output1,output2,opcode,input);
	register1: entity work.register_32bit(behaviour) port map(machine_instruction,opcode,clk,address1,address2,address3);
	rom: entity work.memory(ram) port map (address1,address2,address3,input,clk,opcode,output1,output2);
			
end;

----------------------------system testbench-------------------------------------------		  
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL; 

entity testbenchh is
end entity testbenchh;

architecture test of testbenchh is
signal machine_instruction : std_logic_vector(31 downto 0);
signal clk : std_logic;

begin
	system1: entity work.system(sys) port map(machine_instruction, clk);
	clk <= not clk after 50 ns;
--	 opcode <= "000111";	 -- max(a,b)
--	 address1 address2 address0
	machine_instruction <="00011100001000100000000000000000";
	machine_instruction <="00011100000000110000000000000000";
	machine_instruction <="00011100000001000000000000000000";
	machine_instruction <="00011100000001010000000000000000";
	machine_instruction <="00011100000001100000000000000000";
	machine_instruction <="00011100000001110000000000000000";
	machine_instruction <="00011100000010000000000000000000";
	machine_instruction <="00011100000010010000000000000000"; 
	machine_instruction <="00011100000010100000000000000000";
	machine_instruction <="00011100000010110000000000000000";
	machine_instruction <="00011100000011000000000000000000"; 
	machine_instruction <="00011100000011010000000000000000";  
	machine_instruction <="00011100000011100000000000000000";   
	machine_instruction <="00011100000011110000000000000000"; 
	machine_instruction <="00011100000100000000000000000000";
	machine_instruction <="00011100000100010000000000000000";  
	machine_instruction <="00011100000100100000000000000000";
	machine_instruction <="00011100000100110000000000000000";  
	machine_instruction <="00011100000101000000000000000000";
	machine_instruction <="00011100000101010000000000000000"; 
	machine_instruction <="00011100000101100000000000000000";  
	machine_instruction <="00011100000101110000000000000000"; 
	machine_instruction <="00011100000110000000000000000000";
	machine_instruction <="00011100000110010000000000000000";   
	machine_instruction <="00011100000110100000000000000000";  
	machine_instruction <="00011100000110110000000000000000";  
	machine_instruction <="00011100000111000000000000000000";
	machine_instruction <="00011100000111010000000000000000";  
	machine_instruction <="00011100000111100000000000000000";  
	machine_instruction <="00011100000111110000000000000000";  
end;

