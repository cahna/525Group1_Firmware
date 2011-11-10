*-----------------------------------------------------------
* Program     : lab5_part3.x68
* Written by  : Group1, Nick
* Date        : 11/10/2011
* Description :	This is a user program which handily solves
* a complicated equation.
*-----------------------------------------------------------

		ORG	$4E00		* Starting location of code in RAM (required)

START		MOVE.L	#2,D1		* Newline (Using task 2)
		TRAP	#0		* Newline

		LEA.L 	OUT1,A4         * Print Output "Solves Powers of 2"
		BSR	PRINT

                LEA.L   OUT2,A4         * Print Output " Returns 2^X "
                BSR     PRINT

                LEA.L   OUT3,A4         * Print Output " Enter X: "
                BSR     PRINT

                CLR.L   D0
                MOVE.L  #0,D1           * Get Character from User, result in D0
                TRAP    #0

                SUBI.L    #'0',D0
                CLR.L     D5
                MOVE.L    D0,D5
		FTWOTOX.L D5,FP0
		FMOVE.L	  FP0,D0

		LEA.L 	OUT4,A4
		MOVE.L	#4,D1    	* Prints null terminated string pointed to in A4
		TRAP	#0

		BSR	HEX2DEC         * Converts a longword in D0 to ACII and prints

		* End of Program
		TRAP	#15		* Return (End of Program)

***********************************
*          SUBROUTINES            *
***********************************
PRINT		MOVE.L	#4,D1    	* Prints null terminated string pointed to in A4
		TRAP	#0
		MOVE.L	#2,D1         	* Newline
		TRAP	#0
		RTS

		*Convert Hexidecimal result to Decimal
HEX2DEC		MOVE.W	#0,D7           * initialize looop
		MOVE.W 	#0,DONE
		LEA.L   DIG1,A0

LOOP		DIVU.W	#10,D0		* Divide by ten
		BNE	NOTDONE		* Check if quotient is zero
		MOVE.W	#1,DONE         * If zero then set the conversion done flag to 1
NOTDONE		SWAP	D0		* remainder was in upper word, now in lower
		MOVE.W	D0,(A0,D7.W)	* Store remainder
		SWAP    D0              * Put the quotient back in the lower word
		ANDI.L	#$0000FFFF,D0	* Clear remainder (quotient remains in lower word)
		ADDI.W	#2,D7
		CMPI.W	#1,DONE
		BNE	LOOP

		* Convert Time Variables in Decimal to ASCII code
		ADDI.W	#'0',DIG1
		ADDI.W	#'0',DIG2
		ADDI.W	#'0',DIG3
		ADDI.W	#'0',DIG4
		ADDI.W	#'0',DIG5

                SUBI.W  #2,D7
LOOOP		MOVE.W	(A0,D7.W),D0    * Start by grabbing Most Sig Dig
		MOVE.B	#1,D1           * Task 1 of Trap 0 is putchar
		TRAP	#0
		SUBI.W	#2,D7           * Decrement Index to get next MSD
		BMI	BYE             * When index is < 0, end
		BRA	LOOOP
BYE		RTS                     * Return from subroutine!

***********************************
*      Variable Declarations      *
***********************************
DONE		DS.W	1
DIG1		DS.W	1
DIG2		DS.W	1
DIG3		DS.W	1
DIG4		DS.W	1
DIG5		DS.W	1


* Debug Strings
OUT1		DC.B	'*** Solves Powers of 2 ***',0
OUT2		DC.B	' Returns 2^X ',0
OUT3            DC.B    ' Enter X: ',0
OUT4            DC.B    ' 2^X = ',0

		END	START