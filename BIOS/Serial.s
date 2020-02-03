*-------------------------------------------------------------------------------
*--
*--   Serial Management routines
*--   Handle a 6850 ACIA by default, can switch  to 6551
*--
*-------------------------------------------------------------------------------

                


                DO    ACIATYPE = ACIA6551
TDREBIT         EQU   #%00010000     ; Transmit Data Register Empty bit
RDRFBIT         EQU   #%00001000     ; Receive Data Buffer Full bit
ACIAControlbits EQU   #%00011111     ; 1 stop, 8bits, 19200 bauds 
ACIACommandbits EQU   #%00001011     ;
ACIA_Control    EQU   ACIASTART + 3  ; Control Register Address
ACIA_Command    EQU   ACIASTART + 2  ; Command Register Address
ACIA_Status     EQU   ACIASTART + 1  ; Status Register Address
ACIA_Data       EQU   ACIASTART      ; TXDATA and RXDATA shares same address
                FIN
                
                DO    ACIATYPE = ACIA6850 
TDREBIT         EQU   #%00000010     ; Transmit Data Register Empty bit
RDRFBIT         EQU   #%00000001     ; Receive Data Buffer Full bit
ACIACONFIG      EQU   #%00010100     ; 8bit + 1 stop
ACIA_Control    EQU   ACIASTART + 0  ; Control and Status Register are at the
ACIA_Status     EQU   ACIASTART + 0  ; same base address
ACIA_Data       EQU   ACIASTART + 1  ; TXDATA and RXDATA also sharing address
                FIN

CTRLCCODE       EQU   #$03           ; Control-C ASCII Code


*-------------------------------------------------------------------------------
*-- BIOSCFGACIA Configure ACIA Speed, bits, etc
*-------------------------------------------------------------------------------

BIOSCFGACIA     ENT
                PHA                     ; Save accumulator

                DO    ACIATYPE = ACIA6551                
                LDA   ACIAControlbits   ; Load the configuration bit
                STA   ACIA_Control      ; Send configuration to ACIA
                LDA   ACIACommandbits   ;
                STA   ACIA_Command      ;
                FIN
                
                DO    ACIATYPE = ACIA6850
                LDA   ACIACONFIG    ; Load the configuration bit
                STA   ACIA_Control  ; Send configuration to ACIA
                FIN
                
                PLA                     ; Restore Accumulator
                RTS                     ; Job done, return

*-------------------------------------------------------------------------------
*-- BIOSCHOUT handle display of a character on Serial Output
*-- Character must be placed in Accumulator
*-------------------------------------------------------------------------------

BIOSCHOUT       ENT                 ; Global entry point
                PHA                 ; Save the character on the stack
; Due to bug in 6551, following code is commented out.
SERIALOUTBUSY   ;LDA   ACIA_Status   ; Get Status from ACIA
	            ;AND	  TDREBIT       ; Mask to keep only TDREBIT
	            ;CMP	  TDREBIT       ; Check if ACIA is available
	            ;BNE	  SERIALOUTBUSY ; If ACIA is not ready, check again
	            JSR   DELAY_6551
                PLA                 ; Restore Character from Stack
	            STA	  ACIA_Data     ; Actually send the character to ACIA
	            RTS                 ; Job done, return

*-------------------------------------------------------------------------------
*-- BIOSCHGET Retrieve character from ACIA Buffer
*-- Character,if any, will be placed in Accumulator
*-- Carry set if data has been retrieved, cleared if we got nothing
*-------------------------------------------------------------------------------

BIOSCHGET       ENT                 ; Global entry point
                LDA	  ACIA_Status   ; Get status from ACIA
	            AND	  RDRFBIT       ; Mask to keep only RDRFBIT
	            CMP	  RDRFBIT       ; Is there someting to read ?
	            BNE	  ACIAEMPTY     ; Nothing to read
	            LDA	  ACIA_Data     ; Acrually get data from ACIA
	            SEC		            ; Set Carry if we got somehing
	            RTS                 ; Job done, return
ACIAEMPTY       CLC                 ; We gor norhing, clear Carry
                RTS                 ; Job done, return

*-------------------------------------------------------------------------------
*-- BIOSCHISCTRLC Get a character and check if it s CTRL-C
*-- Character,if any, will be placed in Accumulator
*-- Carry set if data has been retrieved, cleared if we got nothing
*-------------------------------------------------------------------------------

BIOSCHISCTRLC   ENT                   ; Global entry point
                JSR   BIOSCHGET       ; Get a charachter
                BCC   NOTCTRLC        ; Carry clear, we didn't get anything
                CMP   CTRLCCODE       ; Check the ASCII code
                BNE   NOTCTRLC        ; We got somehing else
                SEC                   ; Control-C ! Set Carry and return.
                RTS                   ; Job done, return
NOTCTRLC        CLC                   ; Clear Carry, we got something else
                RTS                   ;Job done, return

; Delay routine to work around WDC 65C51 bug
; Taken from floodybust on 6502.org
; Latest WDC 65C51 has a bug - Xmit bit in status register is stuck on
; IRQ driven transmit is not possible as a result - interrupts are endlessly triggered
; Polled I/O mode also doesn't work as the Xmit bit is polled - delay routine is the only option
; The following delay routine kills time to allow W65C51 to complete a character transmit
; 0.523 milliseconds required loop time for 19,200 baud rate
; MINIDLY routine takes 524 clock cycles to complete - X Reg is used for the count loop
; Y Reg is loaded with the CPU clock rate in MHz (whole increments only) and used as a multiplier
;
DELAY_6551      PHY      ;Save Y Reg
                PHX      ;Save X Reg
DELAY_LOOP      LDY   #8   ;Get delay value (clock rate in MHz 2 clock cycles)
;
MINIDLY         LDX   #$68      ;Seed X reg
DELAY_1         DEX         ;Decrement low index
                BNE   DELAY_1   ;Loop back until done
;
                DEY         ;Decrease by one
                BNE   MINIDLY   ;Loop until done
                PLX         ;Restore X Reg
                PLY         ;Restore Y Reg
DELAY_DONE      RTS         ;Delay done, return
;