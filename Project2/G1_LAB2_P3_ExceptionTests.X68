*-----------------------------------------------------------
* Program    :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
		ORG	$4C00
START							* first instruction of program
TOP		LEA.L	INSTR(PC),A4	    * Print instructions
		MOVE.L	#4,D1
		TRAP	#0
		MOVE.L	#2,D1
		TRAP	#0
		LEA.L	E1(PC),A4	
		MOVE.L	#4,D1
		TRAP	#0
		MOVE.L	#2,D1
		TRAP	#0
		LEA.L	E2(PC),A4	
		MOVE.L	#4,D1
		TRAP	#0
		MOVE.L	#2,D1
		TRAP	#0
		LEA.L	E3(PC),A4	
		MOVE.L	#4,D1
		TRAP	#0
		MOVE.L	#2,D1
		TRAP	#0
		LEA.L	E4(PC),A4	
		MOVE.L	#4,D1
		TRAP	#0
		MOVE.L	#2,D1
		TRAP	#0
		LEA.L	E5(PC),A4	
		MOVE.L	#4,D1
		TRAP	#0
		MOVE.L	#2,D1
		TRAP	#0
		LEA.L	E6(PC),A4	
		MOVE.L	#4,D1
		TRAP	#0
		MOVE.L	#2,D1
		TRAP	#0
		LEA.L	E7(PC),A4	
		MOVE.L	#4,D1
		TRAP	#0
		MOVE.L	#2,D1
		TRAP	#0
		
		CLR.L	D0			* Clear D0 so it can take user input
		MOVE.L	#0,D1		* Get user input
		TRAP	#0
		SUBI	#$30,D0		* Convert ASCII number to integer value
		
		CMP.B	#1,D0
		BNE		NOT1
		MOVE.L	#17,D1		* FIBGEN task
		TRAP	#0
NOT1		CMP.B	#2,D0
		BNE		NOT2
		TRAP	#15			* Test trap 15
NOT2		CMP.B	#3,D0
		BNE		NOT3
		TRAP	#14			* Test trap 14
NOT3		CMP.B	#4,D0
		BNE		NOT4
		MOVE.W	#1,A4		* Test Address Error Exception
		MOVE.W	#3,(A4)
NOT4		CMP.B		#5,D0
		BNE		NOT5
		ILLEGAL				* Test illegal instruction exception
NOT5		CMP.B	#6,D0
		BNE		NOT6
		MOVE.L  #10,D3		* Move 5 into D3
		DIVU	#0,D3		* Divide 10 by the contents of D3 (which is 5)
		BRA		$1000		* Returns to command line
NOT6		CMP.B	#7,D0
		BNE		NOT7
		STOP	#2			* Test Privilege Viloation Exception
NOT7		MOVE.L	#2,D1
		TRAP	#0
		LEA.L	INV,A4		* Invalid input
		MOVE.L	#4,D1
		TRAP	#0
		MOVE.L	#2,D1		* Task 2
		TRAP	#0			* of Trap 0 Prints a newline
		MOVE.L	#2,D1		* Task 2
		TRAP	#0			* of Trap 0 Prints a newline
		BRA		TOP	

* Variables and Strings

INSTR	DC.B	'Which exception would you like to induce?',0
E1		DC.B	'1: Trap0 Task17 - Fibonacci task',0
E2		DC.B	'2: Trap15 - (Warm)',0
E3		DC.B	'3: Trap14 - (Breakpoint)',0
E4		DC.B	'4: Address Error',0
E5		DC.B	'5: Illegal Instruction',0
E6		DC.B	'6: Divide by 0',0
E7		DC.B	'7: Privilege Violation',0
INV		DC.B	'Invalid input... try that again',0
 
	END	START				* last line of source




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
