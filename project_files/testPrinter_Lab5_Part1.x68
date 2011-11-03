*-----------------------------------------------------------
* Program    : testPrinter_Lab5_Part1.x68
* Written by : Group 1, Conor Heine
* Date       : 3 November 2011
* Description: Prints a message to the printer.
*-----------------------------------------------------------
	ORG		$4E00
START:
	
	MOVE.L	#0,A0			; A0 will hold the start of the string to be printed
	CLR.L	D0				; D0 will hold the length of the string to be printed

	* Calculate length of string to be printed
	MOVE.W	#PRNTSTR,A0		; Load the address of the first character of the string into A0
	JSR		CALCLEN			; Calculate the length of the string. Result will be in D0

	* Print that shizznit
	MOVE.B	#21,D1			; Task 21 of Trap 0 is LPWRITE
	TRAP	#0

	TRAP	#15				; End of Program
	BRA		*

* Calculates the length of the string pointed to by A0
CALCLEN	EQU		*
		MOVE.W	A0,A1		; We will operate on A1 instead of A0
CMPNULL	CMPI.B	#0,(A1)+	; Are we at the end of the string? (Null-Terminated)
		BEQ		DONE
		ADDI.B	#1,D0		; Increment D0 (Counter of characters)
		BRA		CMPNULL
DONE	RTS

* Variables and Strings
PRNTSTR	DC.B	'HELLO 525 WORLD!',0

	END	START				; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
