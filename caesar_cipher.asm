;Cesar Neri	
;ceneri@ucsc.edu
;CMPE12		Lab #4
;Section I 	TTh 2:00-4:00 pm
;TA: Chandrahas
;Due Date:	 November 6, 2016

;Caesar Cipher



;Origin
	.ORIG x3000

;Start
	START

;Clear Registers
	AND R0, R0, 0
	AND R1, R0, 0
	AND R2, R0, 0	
	AND R3, R0, 0
	AND R4, R0, 0
	AND R5, R0, 0

;Print Welcoming msg
	LD R0, WELCOMEPTR
	PUTS

;Program beginning
	BEGINNING

;Clear Variables
	AND R6, R6, 0
	ST R6, DIGIT
	ST R6, CHAR
	ST R6, CIPHER
	ST R6, FLAG

;Print First Instruction (Options)
	LD R0, INST1PTR	
	PUTS

;Get Character
	GETC
	OUT

;Store it memory
	ST R0, CHAR

;Check if == X
	LD R2, CHARX
	JSR SUB2F0 

	;IF so, jump tom end of program
	BRz END 

;Else check if == E
	LD R0, CHAR
	LD R2, CHARE
	JSR SUB2F0 
	
	;if CHAR != "E" go to ELSE1
	BRnp ELSE1
	
	;if CHAR == E leave FLAG unchanged just go to INS2
	BRnzp	INS2

;Else check if == D
	ELSE1 LD R0, CHAR
	LD R2, CHARD
	JSR SUB2F0 
	
	;if CHAR != "D" go to ELSE1
	BRnp ELSE2
	
	;if CHAR == E change FLAG and go to INS2

	;Set Flag to -1
	AND R0, R0, 0
	ADD R0, R0, #-1
	ST R0, FLAG

	;Go to Print Instruction 2
	BRnzp	INS2

;Else print error message and go back to beginning
	ELSE2 LD R0, ERRPTR
	PUTS
	BRnzp BEGINNING

;Print Second Instruction
	INS2 LD R0, INST2PTR	
	PUTS

;Get two characters from user and check that they are a number from 1 to 25

	;Get first digit
	GETC
	OUT

	;Substract the digit offset from ASCII value
	LD R2, OFFSET
	JSR SUB2F0

	;Store the first digit of the cipher
	ST R0, CIPHER

	;Get the second digit and store it in memory
	GETC
	OUT
	ST R0, DIGIT

	;Check if digit == "LF"
	LD R2, CHARLF
	JSR SUB2F0

	;If so jump to validation of cipher entered
	BRz VALIDATE

	;ELse add digit to cipher

	;First substract the offset and save it in memory again
	LD R0, DIGIT
	LD R2, OFFSET
	JSR SUB2F0

	ST R0, DIGIT

	;Then multiply cipher by 10 and add digit
	LD R0, CIPHER
	JSR TIMES10

	LD R2, DIGIT

	ADD R0, R0, R2

	;Store new CIPHER
	ST R0, CIPHER

	;Check 0 < CIPHER otherwise go to print error
	VALIDATE LD R0, CIPHER
	BRnz ERROR2

	;Check CIPHER < 26	otherwise go to print error
	LD R0, CIPHER
	LD R2, NUM26
	JSR SUB2F0

	BRzp ERROR2

	;If 0 < CIPHER < 26 continue to next instruction3
	BRnzp INS3 

	;Print error message and go back to getting input
	ERROR2 LD R0, ERRPTR
	PUTS

	BRnzp INS2 

;Print Third Instruction (Enter the String)
	INS3 LD R0, INST3PTR	
	PUTS

;Get all the characters one by one and store them in the array.

	;R3 = Row = 0, R4 = Col = 0
	AND R3,R3, 0
	AND R4, R4, 0

	;int i = 199
	LD R1, NUM200
	ADD R1, R1, #-1

	;i > 0
	GETNXT BRnz DONEST

	;Get character
	GETC
	OUT
	ST R0, CHAR

	;Check if digit == "LF". If it is
	LD R2, CHARLF
	JSR SUB2F0

	;If so, exit loop 
	BRz DONEST

	;Else Store char in corresponding row, column
	LD R0, CHAR
	JSR STORE

	;Increment column (R4)
	ADD R4, R4, #1	

	;i--
	ADD R1, R1, #-1
	BRnzp GETNXT 

	;Set R0 = null and store it, then and go to Encrypt/Decrypt
	DONEST AND R0, R0, 0
	JSR STORE

;Begin Encrypting/Decripting Phase

	;R3 = Row = 0, R4 = Col = 0
	AND R3, R3, 0
	AND R4, R4, 0

	;Load next character in R0 based on column and row and store it
	LOADNXT JSR LOAD 
	ST R0, CHAR

	;Load it back (Redundant but also makes sure that R0 is last register used)
	LD R0, CHAR

	;IF R0 == NULL (end of string) go to DONEPH
	BRz DONEPH

	;Else if R0 != NULL
	
	;Check if FLAG < 0
	LD R0, FLAG

	;If flag is == -1 use decryption
	BRn USEDEC

	;Else use encryption
	LD R0, CHAR
	JSR ENCRYPT

	;Go to storeit (jump decryption)
	BRnzp STOREIT 

	;Use decryption
	USEDEC	LD R0, CHAR
	JSR DECRYPT 

	;Store encrypted/decrypted value
	STOREIT 

	;Increment row(R3) to go to second row
	ADD R3, R3, #1

	;Store in row/col
	JSR STORE

	;Decrement row (R3), Increment column (R4)
	ADD R3, R3, #-1
	ADD R4, R4, #1

	BRnzp LOADNXT

	;Encrypting/Decripting Phase
	DONEPH 
	
	;Store null on second row
	ADD R3, R3, #1
	JSR STORE
	
;Print results
	JSR PRINTARR

;Go back to beginning and strat all over
	BRnzp	BEGINNING

;END OF PROGRAM
	END

;Print Goodbye and HALT
	LD R0, GOODBYEPTR
	PUTS

	HALT

;Variables------------------------------------------------------------------------------------------------------------------------

	DIGIT		.FILL		0		;Digits entered by user
	CHAR		.FILL		0		;Original Char to encrypt/decrypt
	CIPHER		.FILL		0		
	FLAG		.FILL		0		;0 fo Encrypt, -1 for decrypt
	TCIPHER		.FILL		0		;Temporary cipher holder

	CHARX		.FILL		#88
	CHARE		.FILL		#69
	CHARD		.FILL		#68
	CHARLF		.FILL		#10
	OFFSET		.FILL		#48

	NUM26		.FILL		#26
	NUM64		.FILL		#64
	NUM91		.FILL		#91
	NUM96		.FILL		#96
	NUM123		.FILL		#123
	NUM200		.FILL		#200

	REG1		.FILL		0		;Contents of R1 when using subroutines
	REG2		.FILL		0		;Contents of R2 when using subroutines
	REG3		.FILL		0		;Contents of R3 when using subroutines
	REG4		.FILL		0		;Contents of R4 when using subroutines
	CALLINGA	.FILL		0		;Contents of R7 when using subroutines
	CALLINGA2	.FILL		0		;Contents of R7 when using subroutines

	ORIGINALPTR	.FILL		ORIGINAL

	WELCOMEPTR	.FILL		WELCOME
	INST1PTR	.FILL		INST1
	INST2PTR	.FILL		INST2
	INST3PTR	.FILL		INST3
	ERRPTR		.FILL		ERR
	ENCTAGPTR	.FILL		ENCTAG
	DECTAGPTR	.FILL		DECTAG
	GOODBYEPTR	.FILL		GOODBYE

;Subroutines -------------------------------------------------------------------------

;Loads the char in array (Row R3, and Col R4) inside R0 
LOAD 
	;Store calling address
	ST R7, CALLINGA 

	;Save values of R2
	ST R2, REG2

	;Pointer to Base Address (Beginning of Array) 
	LD R2, ORIGINALPTR	

	;Multiply row times #of cols (200)
	AND R0, R0, 0
	ADD R0, R0, R3
	JSR TIMES200

	;Add (row times #of cols) to Base Address
	ADD R2, R2, R0
	
	;Add Column number
	ADD R2, R2, R4

	;Load in R0 corresponding address contents
	LDR R0, R2, #0

	;Restore R7 and R2
	LD R2, REG2
	LD R7, CALLINGA 

	;Return
	RET


;Stores the char R0 inside corresponding array address: (Row R3, and Col R4) 
STORE
	;Store calling address
	ST R7, CALLINGA 

	;Store char in R0
	ST R0, CHAR

	;Save values of R2
	ST R2, REG2

	;Pointer to Base Address (Beginning of Array) 
	LD R2, ORIGINALPTR

	;Multiply row times #of cols (200)
	AND R0, R0, 0
	ADD R0, R0, R3
	JSR TIMES200

	;Add (row times #of cols) to Base Address
	ADD R2, R2, R0
	
	;Add Column number
	ADD R2, R2, R4

	;Store in corresponding address, the contents of R0
	LD R0, CHAR
	STR R0, R2, #0

	;Restore R7
	LD R7, CALLINGA 

	;Return
	RET

;Encrypts the char inside R0 using cipher in memory, and returnsnew char value in R0
ENCRYPT	
	;Store calling address
	ST R7, CALLINGA 

	;Store char value to use multiple times
	ST R0, CHAR

	;Check 64 < char otherwise jump to store
	LD R2, NUM64
	NOT R2, R2
	ADD R2, R2, #1
	ADD R2, R2, R0

	BRnz LEAVEIT

	;Check char < 91, if so go to AlgA(char), otherwise check for [a...b]
	LD R2, NUM91
	NOT R2, R2
	ADD R2, R2, #1
	ADD R2, R2, R0
	
	BRn USEA
	
	;Check 96 < char otherwise jump to store	
	LD R2, NUM96
	NOT R2, R2
	ADD R2, R2, #1
	ADD R2, R2, R0

	BRnz LEAVEIT

	;Check char < 123, if so go to AlgA(char), otherwise go to store so do nothing
	LD R2, NUM123
	NOT R2, R2
	ADD R2, R2, #1
	ADD R2, R2, R0
	
	BRn USEB

	;Otherwise go to leave char as is
	BRnzp LEAVEIT

	;Use algorith A, should return new charvalue in R0
	USEA JSR ALGA

	;Go to return value
	BRnzp RETURN

	;Use algorith B, should return new char value in R0
	USEB JSR ALGB
	
	;Go to return value
	BRnzp RETURN
	
	;Leave char as is (Load original char value)
	LEAVEIT LD R0, CHAR

	;Return
	RETURN	

	;Restore R7
	LD R7, CALLINGA 

	;Return
	RET

;Decrypts the char inside R0 using cipher in memory, and returns new char value in R0
DECRYPT	
	;Store calling address
	ST R7, CALLINGA 

	;Store char value to use multiple times
	ST R0, CHAR

	;TCIPHER = CIPHER
	LD R0, CIPHER
	ST R0, TCIPHER

	;Change the cipher for decryption cipher = ( 26 - cipher )
	LD R0, NUM26
	LD R2, CIPHER
	NOT R2, R2
	ADD R2, R2, #1

	;new cipher value
	ADD R0, R0, R2

	;Update CIPHER
	ST R0, CIPHER

	;Restore R0 and continue like in encrypt
	LD R0, CHAR

	;Check 64 < char otherwise jump to store
	LD R2, NUM64
	NOT R2, R2
	ADD R2, R2, #1
	ADD R2, R2, R0

	BRnz LEAVEIT2

	;Check char < 91, if so go to AlgA(char), otherwise check for [a...b]
	LD R2, NUM91
	NOT R2, R2
	ADD R2, R2, #1
	ADD R2, R2, R0
	
	BRn USEA2
	
	;Check 96 < char otherwise jump to store	
	LD R2, NUM96
	NOT R2, R2
	ADD R2, R2, #1
	ADD R2, R2, R0

	BRnz LEAVEIT2

	;Check char < 123, if so go to AlgA(char), otherwise go to store so do nothing
	LD R2, NUM123
	NOT R2, R2
	ADD R2, R2, #1
	ADD R2, R2, R0
	
	BRn USEB2

	;Otherwise go to leave char as is
	BRnzp LEAVEIT2

	;Use algorith A, should return new charvalue in R0
	USEA2 JSR ALGA

	;Go to return value
	BRnzp RETURN2

	;Use algorith B, should return new char value in R0
	USEB2 JSR ALGB
	
	;Go to return value
	BRnzp RETURN2
	
	;Leave char as is (Load original char value)
	LEAVEIT2 LD R0, CHAR

	;Return
	RETURN2	

	;Restore CIPHER
	LD R2, TCIPHER
	ST R2, CIPHER

	;Restore R7
	LD R7, CALLINGA 

	;Return
	RET


;Print Array
PRINTARR	
	;Store calling address
	ST R7, CALLINGA2 

	;Store values of R3 and R4
	ST R3, REG3
	ST R4, REG4

	;Print enc_tag
	LD R0, ENCTAGPTR
	PUTS

	;Row = 0, Col = 0
	AND R3, R3, 0
	AND R4, R4, 0

	;Load 
	LOADCHAR JSR LOAD

	;Simple step to make R0 the last register worked on
	AND R0, R0, R0

	;Check if == NULL
	BRz GETDECTAG

	;Else print character, increment column and go back to load
	OUT
	ADD R4, R4, #1
	BRnzp  LOADCHAR

	;If null get next tag for decrypt and print it
	GETDECTAG LD R0, DECTAGPTR
	PUTS

	;Row = 1, Col = 0
	ADD R3, R3, #1
	AND R4, R4, 0

	;Load 
	LOADCHAR2 JSR LOAD

	;Simple step to make R0 the last register worked on
	AND R0, R0, R0

	;Check if == NULL
	BRz PRINTDONE

	;Else print character, increment column and go back to load
	OUT
	ADD R4, R4, #1
	BRnzp  LOADCHAR2

	;Restore registers and return
	PRINTDONE
	
	;Load values of R3 and R4
	LD R3, REG3
	LD R4, REG4

	;Restore R7
	LD R7, CALLINGA2 

	;Return
	RET

;Encrypts/Decrypts characters [A-Z], argument is the char in R0 (R0=>R0) and memory location cipher
ALGA
	;Store char to be used later
	ST R0, CHAR

	;Load CIPHER and number 90
	LD R2, CIPHER
	LD R0, NUM91
	ADD R0, R0, #-1

	;90 - CIPHER i.e. (R0 + (-R2))
	NOT R2, R2
	ADD R2, R2, #1
	ADD R2, R0, R2

	;Chek if char  is less than or equal to R2
	
	;Load char in  R0
	LD R0, CHAR

	;-R2
	NOT R2, R2
	ADD R2, R2, #1
	
	;Check if char <=  [ R2 = (90 - CIPHER) ]
	ADD R2, R2, R0

	;If so go to add cipher
	BRnz ADDCIPH

	;Else charv = char - (26 - Cipher)
	LD R2, CIPHER
	LD R0, NUM26

	;R2 = (26 - Cipher)
	NOT R2, R2
	ADD R2, R2, #1
	ADD R2, R0, R2

	;R0 = char - (26 - Cipher)
	LD R0, CHAR
	NOT R2, R2
	ADD R2, R2, #1
	ADD R0, R0, R2

	;Go to Done!
	BRnzp DONEA

	;char = char + CIPHER
	ADDCIPH 
		LD R2, CIPHER
		ADD R0, R0, R2
	
	;Return
	DONEA	RET

;Encrypts/Decrypts characters [a-z], argument is the char in R0 (R0=>R0) and memory location cipher
ALGB
	;Store char to be used later
	ST R0, CHAR

	;Load CIPHER and number 122
	LD R2, CIPHER
	LD R0, NUM123
	ADD R0, R0, #-1

	;122 - CIPHER i.e. (R0 + (-R2))
	NOT R2, R2
	ADD R2, R2, #1
	ADD R2, R0, R2

	;Chek if char  is less than or equal to R2
	
	;Load char in  R0
	LD R0, CHAR

	;-R2
	NOT R2, R2
	ADD R2, R2, #1
	
	;Check if char <=  [ R2 = (122 - CIPHER) ]
	ADD R2, R2, R0

	;If so go to add cipher
	BRnz ADDCIPH2

	;Else charv = char - (26 - Cipher)
	LD R2, CIPHER
	LD R0, NUM26

	;R2 = (26 - Cipher)
	NOT R2, R2
	ADD R2, R2, #1
	ADD R2, R0, R2

	;R0 = char - (26 - Cipher)
	LD R0, CHAR
	NOT R2, R2
	ADD R2, R2, #1
	ADD R0, R0, R2

	;Go to Done!
	BRnzp DONEB

	;char = char + CIPHER
	ADDCIPH2 
		LD R2, CIPHER
		ADD R0, R0, R2
	
	;Return
	DONEB	RET


;Substracts the value of R2 from R0, and result is stored in R0, It can later be used to check if R0 == 0 then is a match (R0, R2 => R0)
SUB2F0 	NOT R2, R2
	ADD R2, R2, #1
	ADD R0, R0, R2
	RET	

;Multiplies the value inside R0 times 10 (R0=>R0)
TIMES10	
	;Store char to be used later
	ST R1, REG1
	ST R2, REG2
	
	;Clear R2 and R1
	AND R2, R2, 0
	AND R1, R1, 0

	;Put value of R0 inside R2
	ADD R2, R2, R0

	;Clear R0
	AND R0, R0, 0

	;int i = 10
	ADD R1, R1, #10
	;i > 0
	LOOP10 BRnz EXIT10

	ADD R0, R0, R2

	;i--
	ADD R1, R1, #-1

	BRnzp LOOP10	

	;Restore R1 and R2 and return
	EXIT10 
	
	LD R1, REG1
	LD R2, REG2
	
	RET

;Multiplies the value inside R0 times 10 (R0=>R0)
TIMES200	
	;Store char to be used later
	ST R1, REG1
	ST R2, REG2
	
	;Clear R2
	AND R2, R2, 0

	;Put value of R0 inside R2
	ADD R2, R2, R0

	;Clear R0
	AND R0, R0, 0

	;int i = 10
	LD R1, NUM200
	;i > 0
	LOOP200 BRnz EXIT200

	ADD R0, R0, R2

	;i--
	ADD R1, R1, #-1

	BRnzp LOOP200

	;Restore R1 and R2 and return
	EXIT200
	
	LD R1, REG1
	LD R2, REG2	

	RET

	

;Strings---------------------------------------------------------------------------------------------------------------------------

	WELCOME		.STRINGZ	"Welcome to the Caesar Cipher Program"
	ERR		.STRINGZ	"\nInvalid input."
	INST1		.STRINGZ	"\nEnter (E) to Encrypt, (D) to Decrypt, or (X) to close program.\n"
	INST2		.STRINGZ	"\nEnter a Cipher Value betweeen 1 and 25\n"
	INST3		.STRINGZ	"\nEnter the String (Up to 200 characters).\n"
	ENCTAG		.STRINGZ	"<ENCRYPTED> "
	DECTAG		.STRINGZ	"\n<DECRYPTED> " 
	GOODBYE		.STRINGZ	"\nGoodbye!"

;Arrays-----------------------------------------------------------------------------------------------------------------------------

	ORIGINAL	.BLKW		400
	


.END


;&Copy Cesar Neri: November 2, 2016
