*-----------------------------------------------------------
* Program     : lab4_part4a.x68
* Written by  : Group1, Luke Spicer
* Date        : 10/27/2011
* Description :	This program is the RAM test #1 (polled mode)
*		which does a repetative operation on memory locations
*		between $4500 and $4600 and echos user input in a polled
*		mode and displays the timestamp at the beginning and end of
*		the test!
*-----------------------------------------------------------
ACIAC_1 	EQU 	$8001		* Location of the ACIA1 6850 serial interface control reg.
ACIAD_1 	EQU 	$8003		* Location of the ACIA1 6850 serial interface data reg.
ESCP		EQU	$1B		* ASCII Value of Escape character
RDRF		EQU	0		* Receiver data full bit
TDRE		EQU	1		* Transmitter data empty bit
BSTART		EQU	$4500		* Start of 1k block for test dummy operations
BEND		EQU	$4600		* End of 1k block
MAXLOOP		EQU	$0100		* Amount of times to go through 1k block tests
BYTEOPS		EQU	$0088		* Number of types to operate on each byte in the block
		
		ORG	$4E00		* Starting location of code in RAM (required)
		
START		MOVE.L	#2,D1		* Newline (Using task 2)
		TRAP	#0		* Newline
		MOVE.W	#0,LOOPCNT
		
		* Get Start Time
		CLR.L	D3		* Clear D3 before reading in Time
		MOVE.B	#19,D1		* Read in raw time into D3 with task 19 of Trap 0
		TRAP	#0
		MOVE.W	D3,TSTART	* Store start time
		BSR	TIMER		* Display start time
		
		* Do processor/memory-intensive operations loop
TSTLOOP		*LEA.L	DST,A4		* 'Starting Test of 1kB block',0
		*BSR 	DEBUG
		CLR.L   D0		* Clear D0 because it will be getting operated on
		MOVE.L	#0,A1		* 
		MOVE.L	#0,A2		*
		MOVE.W	#BSTART,A1	* Load start of RAM Block
		MOVE.W	#RANDBIT,A2	* Load start of Random Bit Array
		MOVE.B	#0,BLKEND	* Set BLKEND flag false

PRCLOOP		CLR.L	D5		* Running count of byte op iterations
LT10		CLR.L	D0
		MOVE.B	(A1),D0		* Load Byte
		EOR.B	D0,(A2)		* Exclusive or byte from block with random bit pattern
		
		CLR.L	D0
		MOVE.B	(A1),D0		* Reload Byte
		ADD.B	(A2),D0		* Add byte from block with random bit pattern
			
		ADDI.W	#1,D5		* Increment iteration counter
		CMPI.W	#BYTEOPS,D5	* Have we done enough iterations?
		BLT	LT10		* If D5 is less than 10 loop back
			
		BSR	INCAS		* Increment address pointers for RAM block and Random bit array
		CMPI.B	#1,BLKEND	* Check to see if we've reached the end of the 1k block
		BNE	PRCLOOP		* Loop if we haven't reached the end of the 1k block
		
		*LEA.L	DCHAR,A4
		*BSR	DEBUG
		
		* Echo Loop
ECHO		MOVE.B	#18,D1		* Check the ACIA2 ring buffer for new characters
		TRAP	#0		* task 18 of Trap #0 (result goes in D2)
		CMP.B	#0,D2		* Does returned character == 0 (NULL)?
		BEQ	L1		* If yes, no characters to print continue to L1
		CMP.B	#ESCP,D2	* Does returned character == escape character?
		BEQ	END_TST		* If yes, that means end the program
LOOP_TRAN	BTST	#TDRE,ACIAC_1	* Test the ACIAC_1 to see if we can transmit echo character
		BEQ	LOOP_TRAN	* Loop until we can echo the character
		MOVE.B	D2,ACIAD_1  	* Echo our received character on the ACIA_1 computer console
		BRA	ECHO		* Branch back to check if more characters are available in the ring buffer
		
		* Check to see if we've looped enough times
L1		*LEA.L	DLENUF,A4
		*BSR 	DEBUG
		CMPI.W	#MAXLOOP,LOOPCNT
		BLT	TSTLOOP

		* Get End Time
END_TST		LEA.L	DEND,A4		
		BSR	DEBUG
		CLR.L	D3		* Clear D3 before reading in Time
		MOVE.B	#19,D1		* Read in raw time into D3 with task 19 of Trap 0
		TRAP	#0
		MOVE.W	D3,TEND		* Store end time

		MOVE.L	#2,D1		* Newline (Using Task 2)
		TRAP	#0		* Newline
		BSR	TIMER		* Display End Time
		
		* End of Program
		TRAP	#15		* Return (End of Program)
		
***********************************		
*          SUBROUTINES            *
***********************************
DEBUG		MOVE.L	#4,D1
		TRAP	#0
		MOVE.L	#2,D1		* Newline
		TRAP	#0
		RTS

INCAS		ADDA	#1,A1		* Increment A1 (Pointer for 1k block of mem)
		CMPA.W	#BEND,A1 	* Check to see if it is out of bounds
		BLT	OKA1
		MOVE.W	#BSTART,A1	* If out of bounds, reset to start location
		MOVE.B	#1,BLKEND	* Set BLKEND flag to true
		ADDI.W	#1,LOOPCNT	* Increment loop count
OKA1		ADDA	#1,A2		* Increment A2 (Pointer to random bit patterns array)
		MOVE.W	#RANDBIT,D0
		ADD.W	#8,D0
		CMPA.W	D0,A2		* Check to see if it is out of bounds
		BLT	OKA2
		MOVE.W	#RANDBIT,A2	* If out of bounds, reset to start location
OKA2		RTS

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

***********************************
*      Variable Declarations      *
***********************************
MIN1		DS.W	1
MIN2		DS.W	1
SEC1		DS.W	1
SEC2		DS.W	1
TEN		DS.W	1
isESCP		DS.B	1
TSTART		DC.W	1
TEND		DC.W	1
S_ITER		DC.W	1
E_ITER		DC.W	1
BLKEND		DC.B	0
LOOPCNT		DC.W	$0
RANDBIT		DC.B	$AC,$08,$12,$43,$11,$F0,$A1,$AA
ENDTEST		DC.B	'RAM TEST FINISHED',0
DIFF		DC.B	'Run time (End-Start): ',0

* Debug Strings
DCHAR		DC.B	'Checking for char',0
DLENUF		DC.B	'Checking to see if weve looped enough',0
DEND		DC.B	'END',0
ENDCHAR		DC.B	'End of POLL subroutine',0
DST		DC.B	'Starting Test of 1kB block',0
DLT10		DC.B	'Less than 10',0

		END	START
		
		



















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~8~
