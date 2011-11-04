*-----------------------------------------------------------
* Program    : testPrinter_Lab5_Part1.x68
* Written by : Group 1, Conor Heine
* Date       : 3 November 2011
* Description: Prints a message to the printer.
*-----------------------------------------------------------
NL	EQU		$0A				; ASCI value of New line 
CR	EQU		$0D				; ASCI value of Carriage return

	ORG		$4E00
START:
	
	MOVE.L	#0,A0			; A0 will hold the start of the string to be printed
	CLR.L	D0				; D0 will hold the length of the string to be printed
	
	* Tell the user we're about to calculate the string length
	LEA.L 	DCALC,A4
	BSR 	DEBUG
	
	* Calculate length of string to be printed
	MOVE.W	#PRNTSTR,A0		; Load the address of the first character of the string into A0
	BSR		CALCLEN			; Calculate the length of the string. Result will be in D0

	* Tell the user the string we're about to print
	LEA.L 	DPRNT,A4
	BSR 	DEBUG

	* Print that shizznit
	MOVE.B	#21,D1			; Task 21 of Trap 0 is LPWRITE
	TRAP	#0

	* Tell the user the string we're done printing
	LEA.L 	DDONE,A4
	BSR 	DEBUG

	TRAP	#15				; End of Program
	BRA		*
	
***************
* Subroutines *
***************
* Calculates the length of the string pointed to by A0
CALCLEN	EQU		*
		MOVE.W	A0,A1		; We will operate on A1 instead of A0
CMPNULL	CMPI.B	#0,(A1)+	; Are we at the end of the string? (Null-Terminated)
		BEQ		DONE
		ADDI.B	#1,D0		; Increment D0 (Counter of characters)
		BRA		CMPNULL
DONE	RTS

* Prints specified message
DEBUG 	MOVE.L 	#4,D1
		TRAP 	#0
		MOVE.L 	#2,D1 * Newline
		TRAP 	#0
		RTS
		
* Variables and Strings
DCALC	DC.B	'Calculating length of string...',0
DPRNT	DC.B	'About to print: '
PRNTSTR	DC.B	NL,CR,'HELLO 525 WORLD! Group 1 Rocks! We got the ancient Printer to Work!',NL,CR,'Newline printed',0
DDONE	DC.B	'DONE!',0

	END	START				; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
