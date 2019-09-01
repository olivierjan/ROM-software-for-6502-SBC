*-------------------------------------------------------------------------------
*--
*--   Initialization Routines
*--   Immediately called at startup, will:
*--			1. Initialize stack
*--			2. Display Startup Message
*--                     3. Jump to Cold or Warm Start based on user input
*-------------------------------------------------------------------------------


						DSK		Init.bin
						ORG 		$FD00
						TYP 		$06

*-------------------------------------------------------------------------------
*-- External routine definition
*-------------------------------------------------------------------------------

BIOSCHOUT				EXT
BIOSCHGET				EXT
BIOSCFGACIA				EXT
BIOSCHISCTRLC				EXT


MONITOR					EQU			$D900				; Let s see later the Monitor
BASIC 					EQU			$B000           		; And Basic Entry points
STACKTOP 				EQU 			#$FF				; Stack goes up to 0x01FF

*-------------------------------------------------------------------------------
*-- Entry point : Reset Vector
*-------------------------------------------------------------------------------

RESET						ENT						; Declare Global
						LDX     	STACKTOP			; Load X with new top of stack value
						TXS						; Set the stack pointer

						JSR		BIOSCFGACIA			; Configure ACIA


INITVECTORS										; Store Vectors to I/O functions in RAM
						LDA #<BIOSCHISCTRLC		; Get first byte
						STA $0203				;
						LDA #>BIOSCHISCTRLC		; Get second byte
						STA $0204
						LDA #<BIOSCHGET
						STA $0205
						LDA #>BIOSCHGET
						STA $0206
						LDA #<BIOSCHOUT
						STA $0207
						LDA #>BIOSCHOUT
						STA $0208
						LDA $00
						STA $0209
						STA $020A
						STA $020B
						STA $020C

						LDY		#0				; Initialize counter
]LOOP						LDA 		STARTUPMESSAGE0,Y		; Get character at counter
						BEQ		MENU				; If we're done go get user choice
						JSR		BIOSCHOUT			; else display the character
						INY						; Move to next character
						BNE 		]LOOP

MENU						LDY		#0				; Initialize counter
]LOOP						LDA 		STARTUPMESSAGE1,Y		; Get character at counter
						BEQ		USERINPUT			; If we're done go get user choice
						JSR		BIOSCHOUT			; else display the character
						INY						; Move to next character
						BNE 		]LOOP

						
*-------------------------------------------------------------------------------
*-- Get and procrss user choice
*-------------------------------------------------------------------------------

USERINPUT				JSR			BIOSCHGET			; Read user input
						BCC 		USERINPUT			; Retry until we get something
						AND 		#$DF				; Convert to UPPER case
						CMP 		#'B'				; BASIC ?
						BEQ		GOBASIC 			; Let's go for BASIC
						CMP 		#'M'				; MONITOR ?
						BNE 		RESET 				; Something else ? Restart all...
						JMP 		MONITOR         		; Let's go !
GOBASIC 					JMP 		BASIC 				; Jump to BASIC entry point

STARTUPMESSAGE0			ASC 		'-----------------------',0D,0A,'---  OJ',27,'s SBC V0.1  ---',0D,0A,'-----------------------',00
STARTUPMESSAGE1			ASC 		0D,0A,0D,0A,'    1. [B]ASIC',0D,0A,'    2. [M]ONITOR',0D,0A,00
