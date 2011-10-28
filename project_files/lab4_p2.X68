*-----------------------------------------------------------
* Program     : lab4_part2.x68
* Written by  : Group1, Luke Spicer
* Date        : 10/27/2011
* Description :	This program tests the interrupt on the ACIA_2
*  as well as the global 10Hz timer, interrupt routine and the
*  ring buffer used to store input from the ACIA_2.
*-----------------------------------------------------------
ACIAC_1 	EQU 	$8001		* Location of the ACIA1 6850 serial interface control reg.
ACIAD_1 	EQU 	$8003		* Location of the ACIA1 6850 serial interface data reg.
ESCP		EQU	$1B		* ASCII Value of Escape character
TDRE		EQU	1		* Transmitter data empty bit
		
		ORG	$4E00		* Starting location of code in RAM (required)
START		MOVE.L	#2,D1		* Task 2 of Trap #0 prints a Newline to the console
		TRAP	#0
		
		* Get and Print Start Time to Console
		LEA.L	TIME1,A4	* Load pointer to start time message into A4
		MOVE.B	#4,D1		* Task 4 of trap #0 prints string to console
		TRAP	#0
		CLR.L	D3		* Clear D3 before reading in Time
		MOVE.B	#19,D1		* Read in raw time into D3 with task 19 of Trap 0
		TRAP	#0
		BSR	TIMER		* Display start time
		
		* Clear the ACIA2 ring buffer
		MOVE.B	#20,D1		* Task 20 of Trap #0 clears the ring buffer
		TRAP	#0		* Ring buffer clear, start getting fresh input!
		
		* Echo Loop
ECHO		MOVE.B	#18,D1		* Check the ACIA2 ring buffer for new characters
		TRAP	#0		* task 18 of Trap #0 (result goes in D2)
		CMP.B	#0,D2		* Does returned character == 0 (NULL)?
		BEQ	ECHO		* If yes keep looping for new character
		CMP.B	#ESCP,D2	* Does returned character == escape character?
		BEQ	END_TST		* If yes, that means end the program
LOOP_TRAN	BTST	#TDRE,ACIAC_1	* Test the ACIAC_1 to see if we can transmit echo character
		BEQ	LOOP_TRAN	* Loop until we can echo the character
		MOVE.B	D2,ACIAD_1  	* Echo our received character on the ACIA_1 computer console
		BRA	ECHO		* Branch back to check if more characters are available in the ring buffer
		
		* Get and Print End Time to Console
END_TST		MOVE.L	#2,D1		* Task 2 of Trap #0 prints a Newline to the console
		TRAP	#0
		LEA.L	TIME2,A4	* Load pointer to start time message into A4
		MOVE.B	#4,D1		* Task 4 of trap #0 prints string to console
		TRAP	#0
		CLR.L	D3		* Clear D3 before reading in Time
		MOVE.B	#19,D1		* Read in raw time into D3 with task 19 of Trap 0
		TRAP	#0
		BSR	TIMER		* Display start time
		
		* End of Program
		TRAP	#15		* Return (End of Program)
		
***********************************		
*          SUBROUTINES            *
***********************************
		* TIMER Subroutine read global timer and prints the result
TIMER		DIVU.W	#600,D3		* Divide Time by 600 to get number of minutes
		MOVE.W  D3,MIN1		*
		SWAP	D3
		ANDI.L	#$0000FFFF,D3	* Clear upper word, we don't need it anymore
		DIVU.W	#10,D3		* Divide remainder by 10 to get seconds
		MOVE.W	D3,SEC1		* Quotient is the number of whole seconds
		SWAP	D3		* Remainder is swapped from upper word
		MOVE.W	D3,TEN		* is number of 10th of a second
		CLR.L	D3
		
		* Convert Time variables to Decimal
		
		MOVE.W	MIN1,D3		*
		DIVU.W	#10,D3		*
		MOVE.W	D3,MIN1		* 10s place of minutes		
		SWAP	D3		
		MOVE.W	D3,MIN2		* 1s place of minutes
		CLR.L	D3
		
		MOVE.W	SEC1,D3		*
		DIVU.W	#10,D3		*
		MOVE.W	D3,SEC1		* 10s place of minutes		
		SWAP	D3		
		MOVE.W	D3,SEC2		* 1s place of minutes
		
		* Convert Time Variables in Decimal to ASCII code
		ADDI.W	#'0',MIN1
		ADDI.W	#'0',MIN2
		ADDI.W	#'0',SEC1
		ADDI.W	#'0',SEC2
		ADDI.W	#'0',TEN
		
		MOVE.W	MIN1,D0		* Print 10s place of minutes
		MOVE.B	#1,D1
		TRAP	#0
		MOVE.W	MIN2,D0		* Print 1s place of minutes
		MOVE.B	#1,D1
		TRAP	#0
		MOVE.W	#':',D0		* Print ':'
		MOVE.B	#1,D1
		TRAP	#0
		MOVE.W	SEC1,D0		* Print 10s place of seconds
		MOVE.B	#1,D1
		TRAP	#0
		MOVE.W	SEC2,D0		* Print 1s place of seconds
		MOVE.B	#1,D1
		TRAP	#0
		MOVE.W	#'.',D0		* Print '.'
		MOVE.B	#1,D1
		TRAP	#0
		MOVE.W	TEN,D0		* Print 10th of a secod
		MOVE.B	#1,D1
		TRAP	#0
		MOVE.B	#2,D1		Print a new line
		TRAP	#0
		RTS

***************************************
*  Variable and String Declarations   *
***************************************
MIN1		DS.W	1
MIN2		DS.W	1
SEC1		DS.W	1
SEC2		DS.W	1
TEN		DS.W	1
isESCP		DS.B	1
TIME1		DC.B	'Start Time ',0
TIME2		DC.B	'End Time   ',0

		END	START

		
LOOP		MOVE.L	#18,D1		* ACIA_2 Bufffffcheck task
		TRAP	#0
		
		CMPI	#0,D2		Does D2 = 0? (this means no new character)
		BEQ	LOOP		If no new charachter, just keep looping
		
		MOVE	D2,D0		Load contents of D2 into D0
		MOVE.L	#1,D1		PUTCHAR task (D1 = 1)
		TRAP	#0
		CMPI.B	#$1B,D2		If the user hits escape (ESC)
		BNE	LOOP
		MOVE.B	#2,D1		Print a new line
		TRAP	#0
		
		TRAP	#15		* Return statement (Exception - End of Program)
		END	START
















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~8~
