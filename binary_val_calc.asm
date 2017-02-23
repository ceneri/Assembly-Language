;Cesar Neri	
;ceneri@ucsc.edu
;CMPE12		Lab #3
;Section I 	TTh 2:00-4:00 pm
;TA: Chandrahas
;Due Date:	 October 22, 2016

;Binary Value Calculator

	

;Registers-----------

;R0 input output
;R1 Loop
;R2 Multivariable and conditional
;R3 Math
;R4 "
;R5 Pointer
;R7 PC

;LABELS--------------

;ENDGN	--	End Get Next (digit/char) Loop
;ENDM 	-- 	End of Multiplication Loop
;ENDB 	-- 	End of binary printing loop
;READY	--	Ready to Print Binary (DOne getting every digit)
;CLOSe	--	Print GOODBYE message and end
;STARTB	--	Start of "BINARY LOOP"


;Set origin
	.ORIG x3000

;Start
	START

;Clear all my Registers
	AND R0, R0, 0
	AND R1, R0, R0
	AND R2, R0, R0
	AND R3, R0, R0
	AND R4, R0, R0
	AND R5, R0, R0

;Print greeting message

	LEA R0, GREETING
	PUTS

;Label BEGGINING to repeat multiple calculations (Loop) & print MESSAGE

	BEGINNING LEA R0, MESSAGE
	PUTS

;Clear all variables

	AND R0, R0, 0
	ST R0, DIGIT
	ST R0, DNUM
	ST R0, FLAG
	ST R0, TEMP

;Get (first) input
	GETC
	OUT

;Store it in DIGIT (to be safe)
	ST R0, DIGIT

;Check if "X"

	LD R3, DIGIT				;Load input digit	
	LD R4, XCHAR				;Load equivalent of "X"	
	NOT R4, R4				;Get the inverse	
	ADD R4, R4, #1				;Add one
	
	ADD R2, R3, R4				;Add them, R2 == 0 if DIGIT == "X"

	BRz CLOSE 				;If R2 == 0 --> PRINT (meaning ending program)	

;Else Check if "-"

	LD R4, DIGIT				;Load input digit
	LD R3, DASH				;Load equivalent of "-"
	NOT R3, R3				;Get the inverse 
	ADD R3, R3, #1				;Add one

	ADD R2, R3, R4				;Add them, R2 == 0 if DIGIT == "-"

;If DIGIT != "-" --> ADDIT (meaning enter the first digit)

	BRnp ADDIT 

;Else If DIGIT == "-" Set flag equal to 1 and then Jump to GETNXT = GETC
	
	AND R2, R2, 0
	ADD R2, R2, #1				
	ST R2, FLAG

	BRnzp GETNXT

;ADDIT:	Store the digit in DNUM and proceed to GETC next character		
	
	ADDIT LD R3, OFFSET			;Substract offset to go from ASCII to digit decimal
	NOT R3, R3
	ADD R3, R3, #1

	ADD R0, R4, R3 				;Actual substraction
	
	ST R0, DNUM  				;Store in DNUM
				
;Beginning og "GetNextDigit" Loop

	GETNXT GETC
	OUT

;Store it in DIGIT (to be safe)
	ST R0, DIGIT

;Check if DIGIT == LF
	
	LD R3, DIGIT				;Load input digit
	LD R4, LFCHAR				;Load equivalent of LF
	NOT R4, R4				;Get the inverse
	ADD R4, R4, #1				;Add one

	
	ADD R2, R3, R4				;Add them, R2 == 0 if DIGIT == LF

;If DIGIT == LF (R2==0) then exit the Loop
	BRz ENDGN

;ELse substract the OFFSET from digit to go from ASCII to decimal

	LD R3, OFFSET				;Load offset in R3
	NOT R3, R3				;Get the inverse
	ADD R3, R3, #1				;Add one

	LD R4, DIGIT				;Load DIGIT (ASCII)

	ADD R0, R4, R3				;Add them (Substract offset)

	ST R0, DIGIT				;Safely store it in DIGIT (Now in decimal)		

;Then multiply DNUm by 10 and add DIGIT

	LD R3, DNUM				;Load DNUM
	AND R4, R4, 0				;Clear R4 to 0

	AND R1, R1, 0
	ADD R1, R1, #10				;for int i = 10

	FORLOOP BRnz ENDM			;i > 0

	ADD R4, R4, R3				;Add DNUM itself (will be done 10 times to simulate multiplication)

	ADD R1, R1, #-1				;i--
	BRnzp FORLOOP

	ENDM LD R0, DIGIT			;Exit multiplication loop and load digit

	ADD R0, R0, R4				;Add digit to (DNUm * 10)

	ST R0, DNUM				;Store it back in DNUM

	BRnzp GETNXT				;Get the next character

;Exit Get Next Loop
;And check the flag

	ENDGN LD R2, FLAG			;Load flag to R2
	
	BRnz READY				;If FLAG < 0 Jump to READY

	LD R0, DNUM				;Else get the negative value, first load it to R0
	NOT R0, R0				;Invert it
	ADD R0, R0, #1				;Add one
		
	ST R0, DNUM				;And store it in DNUM just in case


;Rady to print binary value 
;But first print message

	READY LEA R0, BINMSG
	PUTS

	LD R4, DNUM				;Load DNUM

	LEA R5, MASK				;Load Pointer to mask

;Beginning of "MASKING Loop"

	AND R1, R1, #0
	ADD R1, R1, #15				;for int i = 16

	STRTB BRn ENDB				;i > 0

	ST R5, TEMP				;Store Mask address in TEMP (R5 is a pointer)
	LDI R3, TEMP				;Store in R3 TEMP->addres->content (The content of the address stored inside TEMP) (Actual mask)

;Masking
	
	LD R0, ZERO 				;Load "0" in R0 to print it

	AND R2, R3, R4				;Mask the corresponding bit

	BRz PRINT				;If MaskResult <= 0  go to PRINT (Print "0")

	LD R0, ONE				;Otherwise change output char to "1"
	
	PRINT OUT				;Print corresponding char

;Done printing this bit, now decrement count (R1) and increment Pointer (R5)

	ADD R5, R5, #1				;To get the next mask
	ADD R1, R1, #-1				;i--

	BRnzp STRTB				;Go back to beginning of "MASKING Loop"

;End of masking Loop

	ENDB BRnzp BEGINNING			;Go back to second message (BEGINNING of program) to repeat process if necessary
	
;Print closing message	
	CLOSE LEA R0, GOODBYE			;Load Goodbye/Closing Message
	PUTS
	
;Stop
	HALT

;Variables	
	DASH	.FILL	x002D			;"-"
	LFCHAR	.FILL	x000A			;LF
	XCHAR	.FILL	x0058			;"X"
	OFFSET	.FILL	x0030			;48

	DIGIT	.FILL	0			;Stores the current digit that is being worked on
	DNUM	.FILL	0			;Stores the complewte number entered by user in Decimal
	FLAG	.FILL	0			;0 if positive value is entered, 1 otherwise
	TEMP	.FILL	0			;Used to store temporary mask address



;Masks
	MASK	.FILL	x8000
		.FILL	x4000
		.FILL	x2000
		.FILL	x1000
		.FILL	x0800	
		.FILL	X0400
		.FILL	X0200
		.FILL	X0100	
		.FILL	X0080
		.FILL	X0040
		.FILL	X0020
		.FILL	X0010
		.FILL	X0008
		.FILL	X0004
		.FILL	X0002
		.FILL	X0001
		
		

;Strings
	GREETING	.STRINGZ	"Welcome to the binary number calculator!"
	MESSAGE		.STRINGZ	"\n\nEnter a number to print its binary equivalent or enter X(Uppercase) to exit.\n"
	BINMSG		.STRINGZ	"Here is its binary:\n"
	GOODBYE		.STRINGZ	"\nGood Bye!\n"

	ZERO		.STRINGZ	"0"
	ONE		.STRINGZ	"1"
;End
	.END 