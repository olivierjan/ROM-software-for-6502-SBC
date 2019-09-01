;
; 6502/65C02/65816 Disassembler
;
; Copyright (C) 2012-2016 by Jeff Tranter <tranter@pobox.com>
;
; Licensed under the Apache License, Version 2.0 (the "License");
; you may not use this file except in compliance with the License.
; You may obtain a copy of the License at
;
;   http://www.apache.org/licenses/LICENSE-2.0
;
; Unless required by applicable law or agreed to in writing, software
; distributed under the License is distributed on an "AS IS" BASIS,
; WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
; See the License for the specific language governing permissions and
; limitations under the License.
;
; Revision History
; Version Date         Comments
; 0.0     25-Mar-2012  First version started
; 0.9     28-Mar-2012  First public beta version
; 1.0     03-Jul-2012  Added 65816 support

; *** ASSEMBLY TIME OPTIONS ***


; Define this if you want 65C02 instructions to be disassembled.
D65C02			    EQU 1


; Instructions. Match indexes into entries in table MNEMONICS1/MENMONICS2.
OP_INV			    EQU $00
OP_ADC			    EQU $01
OP_AND					EQU $02
OP_ASL					EQU $03
OP_BCC					EQU $04
OP_BCS					EQU $05
OP_BEQ					EQU $06
OP_BIT					EQU $07
OP_BMI					EQU $08
OP_BNE					EQU $09
OP_BPL					EQU $0A
OP_BRK					EQU $0B
OP_BVC					EQU $0C
OP_BVS					EQU $0D
OP_CLC					EQU $0E
OP_CLD					EQU $0F
OP_CLI					EQU $10
OP_CLV					EQU $11
OP_CMP					EQU $12
OP_CPX					EQU $13
OP_CPY					EQU $14
OP_DEC					EQU $15
OP_DEX					EQU $16
OP_DEY					EQU $17
OP_EOR					EQU $18
OP_INC					EQU $19
OP_INX					EQU $1A
OP_INY					EQU $1B
OP_JMP					EQU $1C
OP_JSR					EQU $1D
OP_LDA					EQU $1E
OP_LDX					EQU $1F
OP_LDY					EQU $20
OP_LSR					EQU $21
OP_NOP					EQU $22
OP_ORA					EQU $23
OP_PHA					EQU $24
OP_PHP					EQU $25
OP_PLA					EQU $26
OP_PLP					EQU $27
OP_ROL					EQU $28
OP_ROR					EQU $29
OP_RTI					EQU $2A
OP_RTS					EQU $2B
OP_SBC					EQU $2C
OP_SEC					EQU $2D
OP_SED					EQU $2E
OP_SEI					EQU $2F
OP_STA					EQU $30
OP_STX					EQU $31
OP_STY					EQU $32
OP_TAX					EQU $33
OP_TAY					EQU $34
OP_TSX					EQU $35
OP_TXA					EQU $36
OP_TXS					EQU $37
OP_TYA					EQU $38
OP_BBR					EQU $39 ; [65C02 only]
OP_BBS					EQU $3A ; [65C02 only]
OP_BRA					EQU $3B ; [65C02 only]
OP_PHX					EQU $3C ; [65C02 only]
OP_PHY					EQU $3D ; [65C02 only]
OP_PLX					EQU $3E ; [65C02 only]
OP_PLY					EQU $3F ; [65C02 only]
OP_RMB					EQU $40 ; [65C02 only]
OP_SMB					EQU $41 ; [65C02 only]
OP_STZ					EQU $42 ; [65C02 only]
OP_TRB					EQU $43 ; [65C02 only]
OP_TSB					EQU $44 ; [65C02 only]
OP_STP					EQU $45 ; [WDC 65C02 and 65816 only]
OP_WAI					EQU $46 ; [WDC 65C02 and 65816 only]
OP_BRL					EQU $47 ; [WDC 65816 only]
OP_COP					EQU $48 ; [WDC 65816 only]
OP_JML					EQU $49 ; [WDC 65816 only]
OP_JSL					EQU $4A ; [WDC 65816 only]
OP_MVN					EQU $4B ; [WDC 65816 only]
OP_MVP					EQU $4C ; [WDC 65816 only]
OP_PEA					EQU $4D ; [WDC 65816 only]
OP_PEI					EQU $4E ; [WDC 65816 only]
OP_PER					EQU $4F ; [WDC 65816 only]
OP_PHB					EQU $50 ; [WDC 65816 only]
OP_PHD					EQU $51 ; [WDC 65816 only]
OP_PHK					EQU $52 ; [WDC 65816 only]
OP_PLB					EQU $53 ; [WDC 65816 only]
OP_PLD					EQU $54 ; [WDC 65816 only]
OP_REP					EQU $56 ; [WDC 65816 only]
OP_RTL					EQU $57 ; [WDC 65816 only]
OP_SEP					EQU $58 ; [WDC 65816 only]
OP_TCD					EQU $59 ; [WDC 65816 only]
OP_TCS					EQU $5A ; [WDC 65816 only]
OP_TDC					EQU $5B ; [WDC 65816 only]
OP_TSC					EQU $5C ; [WDC 65816 only]
OP_TXY					EQU $5D ; [WDC 65816 only]
OP_TYX					EQU $5E ; [WDC 65816 only]
OP_WDM					EQU $5F ; [WDC 65816 only]
OP_XBA					EQU $60 ; [WDC 65816 only]
OP_XCE					EQU $61 ; [WDC 65816 only]

; Addressing Modes. OPCODES1/OPCODES2 tables list these for each instruction. LENGTHS lists the instruction length for each addressing mode.
AM_IMPLICIT			                            EQU 1                   ; RTS
AM_INVALID			                              EQU 0                    ; example:
AM_ACCUMULATOR		                            EQU 2                ; ASL A
AM_IMMEDIATE			                            EQU 3                  ; LDA #$12
AM_ZEROPAGE					                        EQU 4                   ; LDA $12
AM_ZEROPAGE_Y					                      EQU 6                 ; LDA $12,Y
AM_ZEROPAGE_X					                      EQU 5                 ; LDA $12,X
AM_RELATIVE					                        EQU 7                   ; BNE $FD
AM_ABSOLUTE					                        EQU 8                   ; JSR $1234
AM_ABSOLUTE_X					                      EQU 9                 ; STA $1234,X
AM_ABSOLUTE_Y					                      EQU 10                ; STA $1234,Y
AM_INDIRECT					                        EQU 11                  ; JMP ($1234)
AM_INDEXED_INDIRECT					                EQU 12          ; LDA ($12,X)
AM_INDIRECT_INDEXED					                EQU 13          ; LDA ($12),Y
AM_INDIRECT_ZEROPAGE					                EQU 14         ; LDA ($12) [65C02 only]
AM_ABSOLUTE_INDEXED_INDIRECT					        EQU 15 ; JMP ($1234,X) [65C02 only]
AM_STACK_RELATIVE					                  EQU 16            ; LDA 3,S [65816 only]
AM_DIRECT_PAGE_INDIRECT_LONG					        EQU 17 ; LDA [$55] [65816 only]
AM_ABSOLUTE_LONG					                    EQU 18             ; LDA $02F000 [65816 only]
AM_STACK_RELATIVE_INDIRECT_INDEXED_WITH_Y		EQU 19 ; LDA (5,S),Y [65816 only]
AM_DIRECT_PAGE_INDIRECT_LONG_INDEXED_WITH_Y	EQU 20 ; LDA [$55],Y [65816 only]
AM_ABSOLUTE_LONG_INDEXED_WITH_X					    EQU 21 ; LDA $12D080,X [65816 only]
AM_BLOCK_MOVE					                      EQU 22                ; MVP 0,0 [65816 only]
AM_PROGRAM_COUNTER_RELATIVE_LONG					    EQU 23 ; BRL JMPLABEL [65816 only]
AM_ABSOLUTE_INDIRECT_LONG			              EQU 24    ; JMP [$2000] [65816 only]

; *** CODE ***

; Disassemble instruction at address ADDR (low) / ADDR+1 (high). On
; return ADDR/ADDR+1 points to next instruction so it can be called
; again.
DISASM
        LDX #0
        LDA (ADDR,X)          ; get instruction op code
        STA OPCODE
        BMI UPPER             ; if bit 7 set, in upper half of table
        ASL A                 ; double it since table is two bytes per entry
        TAX
        LDA OPCODES1,X        ; get the instruction type (e.g. OP_LDA)
        STA OP                ; store it
        INX
        LDA OPCODES1,X        ; get addressing mode
        STA AM                ; store it
        JMP AROUND
UPPER
        ASL A                 ; double it since table is two bytes per entry
        TAX
        LDA OPCODES2,X        ; get the instruction type (e.g. OP_LDA)
        STA OP                ; store it
        INX
        LDA OPCODES2,X        ; get addressing mode
        STA AM                ; store it
AROUND
        TAX                   ; put addressing mode in X
        LDA LENGTHS,X         ; get instruction length given addressing mode
        STA LEN               ; store it

; Handle 16-bit modes of 65816
; When M=0 (16-bit accumulator) the following instructions take an extra byte:
; 09 29 49 69 89 A9 C9 E9
; When X=0 (16-bit index) the following instructions take an extra byte:
; A0 A2 C0 E0

        LDA MBIT              ; Is M bit zero?
        BNE TRYX              ; If not, skip adjustment.
        LDA OPCODE            ; See if the opcode is one that needs to be adjusted
        CMP #$09
        BEQ ADJUST
        CMP #$29
        BEQ ADJUST
        CMP #$49
        BEQ ADJUST
        CMP #$69
        BEQ ADJUST
        CMP #$89
        BEQ ADJUST
        CMP #$A9
        BEQ ADJUST
        CMP #$C9
        BEQ ADJUST
        CMP #$E9
        BEQ ADJUST
        BNE TRYX
ADJUST
        INC LEN               ; Increment length by one
        JMP REPSEP

TRYX
        LDA XBIT              ; Is X bit zero?
        BNE REPSEP            ; If not, skip adjustment.
        LDA OPCODE            ; See if the opcode is one that needs to be adjusted
        CMP #$A0
        BEQ ADJUST
        CMP #$A2
        BEQ ADJUST
        CMP #$C0
        BEQ ADJUST
        CMP #$E0
        BEQ ADJUST

; Special check for REP and SEP instructions.
; These set or clear the M and X bits which change the length of some instructions.

REPSEP
        LDA OPCODE
        CMP #$C2              ; Is it REP?
        BNE TRYSEP
        LDY #1
        LDA (ADDR),Y          ; get operand
        EOR #$FF              ; Complement the bits
        AND #%00100000        ; Mask out M bit
        LSR                   ; Shift into bit 0
        LSR
        LSR
        LSR
        LSR
        STA MBIT              ; Store it
        LDA (ADDR),Y          ; get operand again
        EOR #$FF              ; Complement the bits
        AND #%00010000        ; Mask out X bit
        LSR                   ; Shift into bit 0
        LSR
        LSR
        LSR
        STA XBIT              ; Store it
        JMP PRADDR

TRYSEP
        CMP #$E2              ; Is it SEP?
        BNE PRADDR
        LDY #1
        LDA (ADDR),Y          ; get operand
        AND #%00100000        ; Mask out M bit
        LSR                   ; Shift into bit 0
        LSR
        LSR
        LSR
        LSR
        STA MBIT              ; Store it
        LDA (ADDR),Y          ; get operand again
        AND #%00010000        ; Mask out X bit
        LSR                   ; Shift into bit 0
        LSR
        LSR
        LSR
        STA XBIT              ; Store it

PRADDR
        LDX ADDR
        LDY ADDR+1
        JSR PrintAddress      ; print address
        LDX #3
        JSR PrintSpaces       ; then three spaces
        LDA OPCODE            ; get instruction op code
        JSR PrintByte         ; display the opcode byte
        JSR PrintSpace
        LDA LEN               ; how many bytes in the instruction?
        CMP #4
        BEQ FOUR
        CMP #3
        BEQ THREE
        CMP #2
        BEQ TWO
        LDX #5
        JSR PrintSpaces
        JMP ONE
TWO
        LDY #1
        LDA (ADDR),Y          ; get 1st operand byte
        JSR PrintByte         ; display it
        LDX #3
        JSR PrintSpaces
        JMP ONE
THREE
        LDY #1
        LDA (ADDR),Y          ; get 1st operand byte
        JSR PrintByte         ; display it
        JSR PrintSpace
        LDY #2
        LDA (ADDR),Y          ; get 2nd operand byte
        JSR PrintByte         ; display it
        JMP ONE
FOUR
        LDY #1
        LDA (ADDR),Y          ; get 1st operand byte
        JSR PrintByte         ; display it
        JSR PrintSpace
        LDY #2
        LDA (ADDR),Y          ; get 2nd operand byte
        JSR PrintByte         ; display it
        JSR PrintSpace
        LDY #3
        LDA (ADDR),Y          ; get 3nd operand byte
        JSR PrintByte         ; display it
        LDX #1
        BNE SPC
ONE
        LDX #4
SPC
        JSR PrintSpaces
        LDA OP                ; get the op code
        CMP #$55              ; Is it in the first half of the table?
        BMI LOWERM

        ASL A                 ; multiply by 2
        CLC
        ADC OP                ; add one more to multiply by 3 since table is three bytes per entry
        LDY #3                ; going to loop 3 times
        TAX                   ; save index into table
MNEM2
        LDA MNEMONICS2+1,X    ; print three chars of mnemonic
        JSR PrintChar
        INX
        DEY
        BNE MNEM2
        BEQ AMODE

LOWERM
        ASL A                 ; multiply by 2
        CLC
        ADC OP                ; add one more to multiply by 3 since table is three bytes per entry
        LDY #3                ; going to loop 3 times
        TAX                   ; save index into table
MNEM1
        LDA MNEMONICS1,X      ; print three chars of mnemonic
        JSR PrintChar
        INX
        DEY
        BNE MNEM1

; Display any operands based on addressing mode
AMODE
        LDA OP                ; is it RMB or SMB?
        CMP #OP_RMB
        BEQ DOMB
        CMP #OP_SMB
        BNE TRYBB
DOMB
        LDA OPCODE            ; get the op code
        AND #$70              ; Upper 3 bits is the bit number
        LSR
        LSR
        LSR
        LSR
        JSR PRHEX
        LDX #2
        JSR PrintSpaces
        JSR PrintDollar
        LDY #1
        LDA (ADDR),Y          ; get 1st operand byte (low address)
        JSR PrintByte         ; display it
        JMP DONEOPS
TRYBB
        LDA OP                ; is it BBR or BBS?
        CMP #OP_BBR
        BEQ DOBB
        CMP #OP_BBS
        BNE TRYIMP
DOBB                           ; handle special BBRn and BBSn instructions
        LDA OPCODE            ; get the op code
        AND #$70              ; Upper 3 bits is the bit number
        LSR
        LSR
        LSR
        LSR
        JSR PRHEX
        LDX #2
        JSR PrintSpaces
        JSR PrintDollar
        LDY #1
        LDA (ADDR),Y          ; get 1st operand byte (address)
        JSR PrintByte         ; display it
        ;LDA #','
        LDA #$2C
        JSR PrintChar
        JSR PrintDollar
      ; Handle relative addressing
      ; Destination address is Current address + relative (sign extended so upper byte is $00 or $FF) + 3
        LDY #2
        LDA (ADDR),Y          ; get 2nd operand byte (relative branch offset)
        STA RELAT               ; save low byte of offset
        BMI :NEG              ; if negative, need to sign extend
        LDA #0                ; high byte is zero
        BEQ :ADD
:NEG
        LDA #$FF              ; negative offset, high byte if $FF
:ADD
        STA RELAT+1             ; save offset high byte
        LDA ADDR              ; take adresss
        CLC
        ADC RELAT               ; add offset
        STA DEST              ; and store
        LDA ADDR+1            ; also high byte (including carry)
        ADC RELAT+1
        STA DEST+1
        LDA DEST              ; now need to add 3 more to the address
        CLC
        ADC #3
        STA DEST
        LDA DEST+1
        ADC #0                ; add any carry
        STA DEST+1
        JSR PrintByte         ; display high byte
        LDA DEST
        JSR PrintByte         ; display low byte
        JMP DONEOPS
TRYIMP
        LDA AM
        CMP #AM_IMPLICIT
        BNE TRYINV
        JMP DONEOPS           ; no operands
TRYINV
        CMP #AM_INVALID
        BNE TRYACC
        JMP DONEOPS           ; no operands
TRYACC
        LDX #3
        JSR PrintSpaces
        CMP #AM_ACCUMULATOR
        BNE TRYIMM
        LDA #'A'
        JSR PrintChar
        JMP DONEOPS
TRYIMM
        CMP #AM_IMMEDIATE
        BNE TRYZP
        LDA #'#'
        JSR PrintChar
        JSR PrintDollar
        LDA LEN               ; Operand could be 8 or 16-bits
        CMP #3                ; 16-bit?
        BEQ IM16              ; Branch if so, otherwise it is 8-bit
        LDY #1
        LDA (ADDR),Y          ; get 1st operand byte (low address)
        JSR PrintByte         ; display it
        JMP DONEOPS
IM16
        LDY #2
        LDA (ADDR),Y          ; get 2nd operand byte (high address)
        JSR PrintByte         ; display it
        LDY #1
        LDA (ADDR),Y          ; get 1st operand byte (low address)
        JSR PrintByte         ; display it
        JMP DONEOPS

TRYZP
        CMP #AM_ZEROPAGE
        BNE TRYZPX
        JSR PrintDollar
        LDY #1
        LDA (ADDR),Y          ; get 1st operand byte (low address)
        JSR PrintByte         ; display it
        JMP DONEOPS
TRYZPX
        CMP #AM_ZEROPAGE_X
        BNE TRYZPY
        LDY #1
        LDA (ADDR),Y          ; get 1st operand byte (address)
        JSR PrintDollar
        JSR PrintByte         ; display it
        JSR PrintCommaX
        JMP DONEOPS
TRYZPY
        CMP #AM_ZEROPAGE_Y
        BNE TRYREL
        LDY #1
        LDA (ADDR),Y          ; get 1st operand byte (address)
        JSR PrintDollar
        JSR PrintByte         ; display it
        JSR PrintCommaY
        JMP DONEOPS
TRYREL
        CMP #AM_RELATIVE
        BNE TRYABS
        JSR PrintDollar
      ; Handle relative addressing
      ; Destination address is Current address + relative (sign extended so upper byte is $00 or $FF) + 2
        LDY #1
        LDA (ADDR),Y          ; get 1st operand byte (relative branch offset)
        STA RELAT               ; save low byte of offset
        BMI NEG               ; if negative, need to sign extend
        LDA #0                ; high byte is zero
        BEQ ADD
NEG
        LDA #$FF              ; negative offset, high byte if $FF
ADD
        STA RELAT+1             ; save offset high byte
        LDA ADDR              ; take adresss
        CLC
        ADC RELAT               ; add offset
        STA DEST              ; and store
        LDA ADDR+1            ; also high byte (including carry)
        ADC RELAT+1
        STA DEST+1
        LDA DEST              ; now need to add 2 more to the address
        CLC
        ADC #2
        STA DEST
        LDA DEST+1
        ADC #0                ; add any carry
        STA DEST+1
        JSR PrintByte         ; display high byte
        LDA DEST
        JSR PrintByte         ; display low byte
        JMP DONEOPS
TRYABS
        CMP #AM_ABSOLUTE
        BNE TRYABSX
        JSR PrintDollar
        LDY #2
        LDA (ADDR),Y          ; get 2nd operand byte (high address)
        JSR PrintByte         ; display it
        LDY #1
        LDA (ADDR),Y          ; get 1st operand byte (low address)
        JSR PrintByte         ; display it
        JMP DONEOPS
TRYABSX
        CMP #AM_ABSOLUTE_X
        BNE TRYABSY
        JSR PrintDollar
        LDY #2
        LDA (ADDR),Y          ; get 2nd operand byte (high address)
        JSR PrintByte         ; display it
        LDY #1
        LDA (ADDR),Y          ; get 1st operand byte (low address)
        JSR PrintByte         ; display it
        JSR PrintCommaX
        JMP DONEOPS
TRYABSY
        CMP #AM_ABSOLUTE_Y
        BNE TRYIND
        JSR PrintDollar
        LDY #2
        LDA (ADDR),Y          ; get 2nd operand byte (high address)
        JSR PrintByte         ; display it
        LDY #1
        LDA (ADDR),Y          ; get 1st operand byte (low address)
        JSR PrintByte         ; display it
        JSR PrintCommaY
        JMP DONEOPS
TRYIND
        CMP #AM_INDIRECT
        BNE TRYINDXIND
        JSR PrintLParenDollar
        LDY #2
        LDA (ADDR),Y          ; get 2nd operand byte (high address)
        JSR PrintByte         ; display it
        LDY #1
        LDA (ADDR),Y          ; get 1st operand byte (low address)
        JSR PrintByte         ; display it
        JSR PrintRParen
        JMP DONEOPS

TRYINDXIND
        CMP #AM_INDEXED_INDIRECT
        BNE TRYINDINDX
        JSR PrintLParenDollar
        LDY #1
        LDA (ADDR),Y          ; get 1st operand byte (low address)
        JSR PrintByte         ; display it
        JSR PrintCommaX
        JSR PrintRParen
        JMP DONEOPS
TRYINDINDX
        CMP #AM_INDIRECT_INDEXED
        BNE TRYINDZ
        JSR PrintLParenDollar
        LDY #1
        LDA (ADDR),Y          ; get 1st operand byte (low address)
        JSR PrintByte         ; display it
        JSR PrintRParen
        JSR PrintCommaY
        JMP DONEOPS
TRYINDZ
        CMP #AM_INDIRECT_ZEROPAGE ; [65C02 only]
        BNE TRYABINDIND
        JSR PrintLParenDollar
        LDY #1
        LDA (ADDR),Y          ; get 1st operand byte (low address)
        JSR PrintByte         ; display it
        JSR PrintRParen
        JMP DONEOPS
TRYABINDIND
        CMP #AM_ABSOLUTE_INDEXED_INDIRECT ; [65C02 only]
        BNE TRYSTACKREL
        JSR PrintLParenDollar
        LDY #2
        LDA (ADDR),Y          ; get 2nd operand byte (high address)
        JSR PrintByte         ; display it
        LDY #1
        LDA (ADDR),Y          ; get 1st operand byte (low address)
        JSR PrintByte         ; display it
        JSR PrintCommaX
        JSR PrintRParen
        JMP DONEOPS

TRYSTACKREL
        CMP #AM_STACK_RELATIVE ; [WDC 65816 only]
        BNE TRYDPIL
        LDY #1
        LDA (ADDR),Y          ; get 1st operand byte (address)
        JSR PrintDollar
        JSR PrintByte         ; display it
        JSR PrintCommaS
        JMP DONEOPS

TRYDPIL
        CMP #AM_DIRECT_PAGE_INDIRECT_LONG ; [WDC 65816 only]
        BNE TRYABSLONG
        JSR PrintLBraceDollar
        LDY #1
        LDA (ADDR),Y          ; get 1st operand byte (low address)
        JSR PrintByte         ; display it
        JSR PrintRBrace
        JMP DONEOPS

TRYABSLONG
        CMP #AM_ABSOLUTE_LONG ; [WDC 65816 only]
        BNE SRIIY
        JSR PrintDollar
        LDY #3
        LDA (ADDR),Y          ; get 3nd operand byte (bank address)
        JSR PrintByte         ; display it
        LDY #2
        LDA (ADDR),Y          ; get 2nd operand byte (high address)
        JSR PrintByte         ; display it
        LDY #1
        LDA (ADDR),Y          ; get 1st operand byte (low address)
        JSR PrintByte         ; display it
        JMP DONEOPS

SRIIY
        CMP #AM_STACK_RELATIVE_INDIRECT_INDEXED_WITH_Y ; [WDC 65816 only]
        BNE DPILIY
        JSR PrintLParenDollar
        LDY #1
        LDA (ADDR),Y          ; get 1st operand byte (low address)
        JSR PrintByte         ; display it
        JSR PrintCommaS
        JSR PrintRParen
        JSR PrintCommaY
        JMP DONEOPS

DPILIY
        CMP #AM_DIRECT_PAGE_INDIRECT_LONG_INDEXED_WITH_Y ; [WDC 65816 only]
        BNE ALIX
        JSR PrintLBraceDollar
        LDY #1
        LDA (ADDR),Y          ; get 1st operand byte (low address)
        JSR PrintByte         ; display it
        JSR PrintRBrace
        JSR PrintCommaY
        JMP DONEOPS

ALIX
        CMP #AM_ABSOLUTE_LONG_INDEXED_WITH_X ; [WDC 65816 only]
        BNE BLOCKMOVE
        JSR PrintDollar
        LDY #3
        LDA (ADDR),Y          ; get 3nd operand byte (bank address)
        JSR PrintByte         ; display it
        LDY #2
        LDA (ADDR),Y          ; get 2nd operand byte (high address)
        JSR PrintByte         ; display it
        LDY #1
        LDA (ADDR),Y          ; get 1st operand byte (low address)
        JSR PrintByte         ; display it
        JSR PrintCommaX
        JMP DONEOPS

BLOCKMOVE
        CMP #AM_BLOCK_MOVE ; [WDC 65816 only]
        BNE PCRL
        JSR PrintDollar
        LDY #1
        LDA (ADDR),Y          ; get 1st operand byte
        JSR PrintByte         ; display it
        ;LDA #','
        LDA #$2C
        JSR PrintChar
        JSR PrintDollar
        LDY #2
        LDA (ADDR),Y          ; get 2nd operand byte
        JSR PrintByte         ; display it
        JMP DONEOPS

PCRL
        CMP #AM_PROGRAM_COUNTER_RELATIVE_LONG ; [WDC 65816 only]
        BNE AIL
        JSR PrintDollar
      ; Handle relative addressing
      ; Destination address is current address + relative + 3
        LDY #1
        LDA (ADDR),Y          ; get 1st operand byte
        STA RELAT               ; save low byte of offset
        LDY #2
        LDA (ADDR),Y          ; get 2nd operand byte
        STA RELAT+1             ; save offset high byte
        LDA ADDR              ; take adresss
        CLC
        ADC RELAT               ; add offset
        STA DEST              ; and store
        LDA ADDR+1            ; also high byte (including carry)
        ADC RELAT+1
        STA DEST+1
        LDA DEST              ; now need to add 3 more to the address
        CLC
        ADC #3
        STA DEST
        LDA DEST+1
        ADC #0                ; add any carry
        STA DEST+1
        JSR PrintByte         ; display high byte
        LDA DEST
        JSR PrintByte         ; display low byte
        JMP DONEOPS

AIL
        CMP #AM_ABSOLUTE_INDIRECT_LONG ; [WDC 65816 only]
        BNE DONEOPS
        JSR PrintLBraceDollar
        LDY #2
        LDA (ADDR),Y          ; get 2nd operand byte (high address)
        JSR PrintByte         ; display it
        LDY #1
        LDA (ADDR),Y          ; get 1st operand byte (low address)
        JSR PrintByte         ; display it
        JSR PrintRBrace
        JMP DONEOPS

DONEOPS
        JSR PrintCR           ; print a final CR
        LDA ADDR              ; update address to next instruction
        CLC
        ADC LEN
        STA ADDR
        LDA ADDR+1
        ADC #0                ; to add carry
        STA ADDR+1
        RTS

; DATA

; Table of instruction strings. 3 bytes per table entry
MNEMONICS
MNEMONICS1    ENT
                        ASC '???' ; $00
                        ASC 'ADC' ; $01
                        ASC 'AND' ; $02
                        ASC 'ASL' ; $03
                        ASC 'BCC' ; $04
                        ASC 'BCS' ; $05
                        ASC 'BEQ' ; $06
                        ASC 'BIT' ; $07
                        ASC 'BMI' ; $08
                        ASC 'BNE' ; $09
                        ASC 'BPL' ; $0A
                        ASC 'BRK' ; $0B
                        ASC 'BVC' ; $0C
                        ASC 'BVS' ; $0D
                        ASC 'CLC' ; $0E
                        ASC 'CLD' ; $0F
                        ASC 'CLI' ; $10
                        ASC 'CLV' ; $11
                        ASC 'CMP' ; $12
                        ASC 'CPX' ; $13
                        ASC 'CPY' ; $14
                        ASC 'DEC' ; $15
                        ASC 'DEX' ; $16
                        ASC 'DEY' ; $17
                        ASC 'EOR' ; $18
                        ASC 'INC' ; $19
                        ASC 'INX' ; $1A
                        ASC 'INY' ; $1B
                        ASC 'JMP' ; $1C
                        ASC 'JSR' ; $1D
                        ASC 'LDA' ; $1E
                        ASC 'LDX' ; $1F
                        ASC 'LDY' ; $20
                        ASC 'LSR' ; $21
                        ASC 'NOP' ; $22
                        ASC 'ORA' ; $23
                        ASC 'PHA' ; $24
                        ASC 'PHP' ; $25
                        ASC 'PLA' ; $26
                        ASC 'PLP' ; $27
                        ASC 'ROL' ; $28
                        ASC 'ROR' ; $29
                        ASC 'RTI' ; $2A
                        ASC 'RTS' ; $2B
                        ASC 'SBC' ; $2C
                        ASC 'SEC' ; $2D
                        ASC 'SED' ; $2E
                        ASC 'SEI' ; $2F
                        ASC 'STA' ; $30
                        ASC 'STX' ; $31
                        ASC 'STY' ; $32
                        ASC 'TAX' ; $33
                        ASC 'TAY' ; $34
                        ASC 'TSX' ; $35
                        ASC 'TXA' ; $36
                        ASC 'TXS' ; $37
                        ASC 'TYA' ; $38
                        ASC 'BBR' ; $39 [65C02 only]
                        ASC 'BBS' ; $3A [65C02 only]
                        ASC 'BRA' ; $3B [65C02 only]
                        ASC 'PHX' ; $3C [65C02 only]
                        ASC 'PHY' ; $3D [65C02 only]
                        ASC 'PLX' ; $3E [65C02 only]
                        ASC 'PLY' ; $3F [65C02 only]
                        ASC 'RMB' ; $40 [65C02 only]
                        ASC 'SMB' ; $41 [65C02 only]
                        ASC 'STZ' ; $42 [65C02 only]
                        ASC 'TRB' ; $43 [65C02 only]
                        ASC 'TSB' ; $44 [65C02 only]
                        ASC 'STP' ; $45 [WDC 65C02 and 65816 only]
                        ASC 'WAI' ; $46 [WDC 65C02 and 65816 only]
                        ASC 'BRL' ; $47 [WDC 65816 only]
                        ASC 'COP' ; $48 [WDC 65816 only]
                        ASC 'JMP' ; $49 [WDC 65816 only]
                        ASC 'JSL' ; $4A [WDC 65816 only]
                        ASC 'MVN' ; $4B [WDC 65816 only]
                        ASC 'MVP' ; $4C [WDC 65816 only]
                        ASC 'PEA' ; $4D [WDC 65816 only]
                        ASC 'PEI' ; $4E [WDC 65816 only]
                        ASC 'PER' ; $4F [WDC 65816 only]
                        ASC 'PHB' ; $50 [WDC 65816 only]
                        ASC 'PHD' ; $51 [WDC 65816 only]
                        ASC 'PHK' ; $52 [WDC 65816 only]
                        ASC 'PLB' ; $53 [WDC 65816 only]
                        ASC 'PLD' ; $54 [WDC 65816 only]
MNEMONICS2
                        ASC '???' ; $55 Unused because index is $FF
                        ASC 'REP' ; $56 [WDC 65816 only]
                        ASC 'RTL' ; $57 [WDC 65816 only]
                        ASC 'SEP' ; $58 [WDC 65816 only]
                        ASC 'TCD' ; $59 [WDC 65816 only]
                        ASC 'TCS' ; $5A [WDC 65816 only]
                        ASC 'TDC' ; $5B [WDC 65816 only]
                        ASC 'TSC' ; $5C [WDC 65816 only]
                        ASC 'TXY' ; $5D [WDC 65816 only]
                        ASC 'TYX' ; $5E [WDC 65816 only]
                        ASC 'WDM' ; $5F [WDC 65816 only]
                        ASC 'XBA' ; $60 [WDC 65816 only]
                        ASC 'XCE' ; $61 [WDC 65816 only]
MNEMONICSEND ; address of the end of the table

; Lengths of instructions given an addressing mode. Matches values of AM_*
; Assumes 65816 is in 8-bit mode.
LENGTHS
                        DB 1, 1, 1, 2, 2, 2, 2, 2, 3, 3, 3, 3, 2, 2, 2, 3, 2, 2, 4, 2, 2, 4, 3, 3, 3

; Opcodes. Listed in order. Defines the mnemonic and addressing mode.
; 2 bytes per table entry
OPCODES
OPCODES1        ENT
                        DB OP_BRK, AM_IMPLICIT           ; $00

                        DB OP_ORA, AM_INDEXED_INDIRECT   ; $01


                        DB OP_INV, AM_IMPLICIT           ; $02



                        DB OP_INV, AM_IMPLICIT           ; $03


                        DB OP_TSB, AM_ZEROPAGE           ; $04 [65C02 only]

                        DB OP_ORA, AM_ZEROPAGE           ; $05

                        DB OP_ASL, AM_ZEROPAGE           ; $06

                        DB OP_INV, AM_IMPLICIT           ; $07

                        DB OP_PHP, AM_IMPLICIT           ; $08

                        DB OP_ORA, AM_IMMEDIATE          ; $09

                        DB OP_ASL, AM_ACCUMULATOR        ; $0A

                        DB OP_INV, AM_IMPLICIT           ; $0B

                        DB OP_TSB, AM_ABSOLUTE           ; $0C [65C02 only]

                        DB OP_ORA, AM_ABSOLUTE           ; $0D

                        DB OP_ASL, AM_ABSOLUTE           ; $0E

                        DB OP_INV, AM_IMPLICIT           ; $0F

                        DB OP_BPL, AM_RELATIVE           ; $10

                        DB OP_ORA, AM_INDIRECT_INDEXED   ; $11

                        DB OP_ORA, AM_INDIRECT_ZEROPAGE  ; $12 [65C02 only]

                        DB OP_INV, AM_IMPLICIT           ; $12
                        DB OP_TRB, AM_ZEROPAGE           ; $14 [65C02 only]

                        DB OP_ORA, AM_ZEROPAGE_X         ; $15

                        DB OP_ASL, AM_ZEROPAGE_X         ; $16

                        DB OP_INV, AM_IMPLICIT           ; $17

                        DB OP_CLC, AM_IMPLICIT           ; $18

                        DB OP_ORA, AM_ABSOLUTE_Y         ; $19


                        DB OP_INC, AM_ACCUMULATOR        ; $1A [65C02 only]

                        DB OP_INV, AM_IMPLICIT           ; $1B

                        DB OP_TRB, AM_ABSOLUTE           ; $1C [65C02 only]

                        DB OP_ORA, AM_ABSOLUTE_X         ; $1D

                        DB OP_ASL, AM_ABSOLUTE_X         ; $1E

                        DB OP_INV, AM_IMPLICIT           ; $1F

                        DB OP_JSR, AM_ABSOLUTE           ; $20

                        DB OP_AND, AM_INDEXED_INDIRECT   ; $21

                        DB OP_JSR, AM_ABSOLUTE_LONG      ; $22

                        DB OP_AND, AM_STACK_RELATIVE     ; $23

                        DB OP_BIT, AM_ZEROPAGE           ; $24

                        DB OP_AND, AM_ZEROPAGE           ; $25

                        DB OP_ROL, AM_ZEROPAGE           ; $26


                        DB OP_INV, AM_IMPLICIT           ; $27

                        DB OP_PLP, AM_IMPLICIT           ; $28

                        DB OP_AND, AM_IMMEDIATE          ; $29

                        DB OP_ROL, AM_ACCUMULATOR        ; $2A

                        DB OP_INV, AM_IMPLICIT           ; $2B

                        DB OP_BIT, AM_ABSOLUTE           ; $2C

                        DB OP_AND, AM_ABSOLUTE           ; $2D

                        DB OP_ROL, AM_ABSOLUTE           ; $2E

                        DB OP_INV, AM_IMPLICIT           ; $2F

                        DB OP_BMI, AM_RELATIVE           ; $30

                        DB OP_AND, AM_INDIRECT_INDEXED   ; $31 [65C02 only]

                        DB OP_AND, AM_INDIRECT_ZEROPAGE  ; $32 [65C02 only]
                        DB OP_INV, AM_IMPLICIT           ; $33
                        DB OP_BIT, AM_ZEROPAGE_X         ; $34 [65C02 only]

                        DB OP_AND, AM_ZEROPAGE_X         ; $35

                        DB OP_ROL, AM_ZEROPAGE_X         ; $36

                        DB OP_INV, AM_IMPLICIT           ; $37

                        DB OP_SEC, AM_IMPLICIT           ; $38

                        DB OP_AND, AM_ABSOLUTE_Y         ; $39

                        DB OP_DEC, AM_ACCUMULATOR        ; $3A [65C02 only]

                        DB OP_INV, AM_IMPLICIT           ; $3B
                        DB OP_BIT, AM_ABSOLUTE_X         ; $3C [65C02 only]

                        DB OP_AND, AM_ABSOLUTE_X         ; $3D

                        DB OP_ROL, AM_ABSOLUTE_X         ; $3E

                        DB OP_INV, AM_IMPLICIT           ; $3F

                        DB OP_RTI, AM_IMPLICIT           ; $40

                        DB OP_EOR, AM_INDEXED_INDIRECT   ; $41

                        DB OP_INV, AM_IMPLICIT           ; $42
                        DB OP_INV, AM_IMPLICIT           ; $43
                        DB OP_INV, AM_IMPLICIT           ; $44

                        DB OP_EOR, AM_ZEROPAGE           ; $45

                        DB OP_LSR, AM_ZEROPAGE           ; $46

                        DB OP_INV, AM_IMPLICIT           ; $47

                        DB OP_PHA, AM_IMPLICIT           ; $48

                        DB OP_EOR, AM_IMMEDIATE          ; $49

                        DB OP_LSR, AM_ACCUMULATOR        ; $4A

                        DB OP_INV, AM_IMPLICIT           ; $4B

                        DB OP_JMP, AM_ABSOLUTE           ; $4C

                        DB OP_EOR, AM_ABSOLUTE           ; $4D

                        DB OP_LSR, AM_ABSOLUTE           ; $4E

                        DB OP_INV, AM_IMPLICIT           ; $4F

                        DB OP_BVC, AM_RELATIVE           ; $50

                        DB OP_EOR, AM_INDIRECT_INDEXED   ; $51

                        DB OP_EOR, AM_INDIRECT_ZEROPAGE  ; $52 [65C02 only]
                        DB OP_INV, AM_IMPLICIT           ; $4F
                        DB OP_INV, AM_IMPLICIT           ; $4F

                        DB OP_EOR, AM_ZEROPAGE_X         ; $55

                        DB OP_LSR, AM_ZEROPAGE_X         ; $56

                        DB OP_INV, AM_IMPLICIT           ; $57

                        DB OP_CLI, AM_IMPLICIT           ; $58

                        DB OP_EOR, AM_ABSOLUTE_Y         ; $59

                        DB OP_PHY, AM_IMPLICIT           ; $5A [65C02 only]

                        DB OP_INV, AM_IMPLICIT           ; $4F
                        DB OP_INV, AM_IMPLICIT           ; $4F

                        DB OP_EOR, AM_ABSOLUTE_X         ; $5D

                        DB OP_LSR, AM_ABSOLUTE_X         ; $5E

                        DB OP_INV, AM_IMPLICIT           ; $5F

                        DB OP_RTS, AM_IMPLICIT           ; $60

                        DB OP_ADC, AM_INDEXED_INDIRECT   ; $61

                        DB OP_INV, AM_IMPLICIT           ; $4F
                        DB OP_INV, AM_IMPLICIT           ; $4F

                        DB OP_STZ, AM_ZEROPAGE           ; $64 [65C02 only]

                        DB OP_ADC, AM_ZEROPAGE           ; $65

                        DB OP_ROR, AM_ZEROPAGE           ; $66

                        DB OP_INV, AM_IMPLICIT           ; $67

                        DB OP_PLA, AM_IMPLICIT           ; $68

                        DB OP_ADC, AM_IMMEDIATE          ; $69

                        DB OP_ROR, AM_ACCUMULATOR        ; $6A

                        DB OP_INV, AM_IMPLICIT           ; $4F

                        DB OP_JMP, AM_INDIRECT           ; $6C

                        DB OP_ADC, AM_ABSOLUTE           ; $6D

                        DB OP_ROR, AM_ABSOLUTE           ; $6E

                        DB OP_INV, AM_IMPLICIT           ; $6F

                        DB OP_BVS, AM_RELATIVE           ; $70

                        DB OP_ADC, AM_INDIRECT_INDEXED   ; $71

                        DB OP_ADC, AM_INDIRECT_ZEROPAGE  ; $72 [65C02 only]

                        DB OP_INV, AM_IMPLICIT           ; $4F
                        DB OP_STZ, AM_ZEROPAGE_X         ; $74 [65C02 only]

                        DB OP_ADC, AM_ZEROPAGE_X         ; $75

                        DB OP_ROR, AM_ZEROPAGE_X         ; $76

                        DB OP_INV, AM_IMPLICIT           ; $77

                        DB OP_SEI, AM_IMPLICIT           ; $78

                        DB OP_ADC, AM_ABSOLUTE_Y         ; $79

                        DB OP_PLY, AM_IMPLICIT           ; $7A [65C02 only]

                        DB OP_INV, AM_IMPLICIT           ; $4F
                        DB OP_JMP, AM_ABSOLUTE_INDEXED_INDIRECT ; $7C [65C02 only]

                        DB OP_ADC, AM_ABSOLUTE_X         ; $7D

                        DB OP_ROR, AM_ABSOLUTE_X         ; $7E

                        DB OP_INV, AM_IMPLICIT           ; $7F


OPCODES2 ENT


                        DB OP_BRA, AM_RELATIVE           ; $80 [65C02 only]

                        DB OP_STA, AM_INDEXED_INDIRECT   ; $81

                        DB OP_INV, AM_IMPLICIT           ; $4F

                        DB OP_INV, AM_IMPLICIT           ; $4F

                        DB OP_STY, AM_ZEROPAGE           ; $84

                        DB OP_STA, AM_ZEROPAGE           ; $85

                        DB OP_STX, AM_ZEROPAGE           ; $86

                        DB OP_INV, AM_IMPLICIT           ; $87

                        DB OP_DEY, AM_IMPLICIT           ; $88

                        DB OP_BIT, AM_IMMEDIATE          ; $89 [65C02 only]

                        DB OP_TXA, AM_IMPLICIT           ; $8A

                        DB OP_INV, AM_IMPLICIT           ; $4F

                        DB OP_STY, AM_ABSOLUTE           ; $8C

                        DB OP_STA, AM_ABSOLUTE           ; $8D

                        DB OP_STX, AM_ABSOLUTE           ; $8E

                        DB OP_INV, AM_IMPLICIT           ; $8F

                        DB OP_BCC, AM_RELATIVE           ; $90

                        DB OP_STA, AM_INDIRECT_INDEXED   ; $91

                        DB OP_STA, AM_INDIRECT_ZEROPAGE  ; $92 [65C02 only]

                        DB OP_INV, AM_IMPLICIT           ; $4F
                        DB OP_STY, AM_ZEROPAGE_X         ; $94

                        DB OP_STA, AM_ZEROPAGE_X         ; $95

                        DB OP_STX, AM_ZEROPAGE_Y         ; $96

                        DB OP_INV, AM_IMPLICIT           ; $97

                        DB OP_TYA, AM_IMPLICIT           ; $98

                        DB OP_STA, AM_ABSOLUTE_Y         ; $99

                        DB OP_TXS, AM_IMPLICIT           ; $9A

                        DB OP_INV, AM_IMPLICIT           ; $4F
                        DB OP_STZ, AM_ABSOLUTE           ; $9C [65C02 only]

                        DB OP_STA, AM_ABSOLUTE_X         ; $9D

                        DB OP_STZ, AM_ABSOLUTE_X         ; $9E [65C02 only]

                        DB OP_INV, AM_IMPLICIT           ; $4F

                        DB OP_LDY, AM_IMMEDIATE          ; $A0

                        DB OP_LDA, AM_INDEXED_INDIRECT   ; $A1

                        DB OP_LDX, AM_IMMEDIATE          ; $A2

                        DB OP_INV, AM_IMPLICIT           ; $4F

                        DB OP_LDY, AM_ZEROPAGE           ; $A4

                        DB OP_LDA, AM_ZEROPAGE           ; $A5

                        DB OP_LDX, AM_ZEROPAGE           ; $A6

                        DB OP_LDA, AM_DIRECT_PAGE_INDIRECT_LONG ; $A7 [WDC 65816 only]

                        DB OP_TAY, AM_IMPLICIT           ; $A8

                        DB OP_LDA, AM_IMMEDIATE          ; $A9

                        DB OP_TAX, AM_IMPLICIT           ; $AA

                        DB OP_INV, AM_IMPLICIT           ; $4F

                        DB OP_LDY, AM_ABSOLUTE           ; $AC

                        DB OP_LDA, AM_ABSOLUTE           ; $AD

                        DB OP_LDX, AM_ABSOLUTE           ; $AE

                        DB OP_INV, AM_IMPLICIT           ; $4F

                        DB OP_BCS, AM_RELATIVE           ; $B0

                        DB OP_LDA, AM_INDIRECT_INDEXED   ; $B1

                        DB OP_LDA, AM_INDIRECT_ZEROPAGE  ; $B2 [65C02 only]
                        DB OP_INV, AM_IMPLICIT           ; $4F

                        DB OP_LDY, AM_ZEROPAGE_X         ; $B4

                        DB OP_LDA, AM_ZEROPAGE_X         ; $B5

                        DB OP_LDX, AM_ZEROPAGE_Y         ; $B6

                        DB OP_INV, AM_IMPLICIT           ; $B7

                        DB OP_CLV, AM_IMPLICIT           ; $B8

                        DB OP_LDA, AM_ABSOLUTE_Y         ; $B9

                        DB OP_TSX, AM_IMPLICIT           ; $BA

                        DB OP_INV, AM_IMPLICIT           ; $4F

                        DB OP_LDY, AM_ABSOLUTE_X         ; $BC

                        DB OP_LDA, AM_ABSOLUTE_X         ; $BD

                        DB OP_LDX, AM_ABSOLUTE_Y         ; $BE

                        DB OP_INV, AM_IMPLICIT           ; $BF

                        DB OP_CPY, AM_IMMEDIATE          ; $C0

                        DB OP_CMP, AM_INDEXED_INDIRECT   ; $C1

                        DB OP_INV, AM_IMPLICIT           ; $4F
                        DB OP_INV, AM_IMPLICIT           ; $4F

                        DB OP_CPY, AM_ZEROPAGE           ; $C4

                        DB OP_CMP, AM_ZEROPAGE           ; $C5

                        DB OP_DEC, AM_ZEROPAGE           ; $C6

                        DB OP_INV, AM_IMPLICIT           ; $C7

                        DB OP_INY, AM_IMPLICIT           ; $C8

                        DB OP_CMP, AM_IMMEDIATE          ; $C9

                        DB OP_DEX, AM_IMPLICIT           ; $CA

                        DB OP_WAI, AM_IMPLICIT           ; $CB [WDC 65C02 and 65816 only]

                        DB OP_CPY, AM_ABSOLUTE           ; $CC

                        DB OP_CMP, AM_ABSOLUTE           ; $CD

                        DB OP_DEC, AM_ABSOLUTE           ; $CE

                        DB OP_INV, AM_IMPLICIT           ; $CF

                        DB OP_BNE, AM_RELATIVE           ; $D0

                        DB OP_CMP, AM_INDIRECT_INDEXED   ; $D1

                        DB OP_CMP, AM_INDIRECT_ZEROPAGE  ; $D2 [65C02 only]

                        DB OP_INV, AM_IMPLICIT           ; $4F
                        DB OP_INV, AM_IMPLICIT           ; $4F

                        DB OP_CMP, AM_ZEROPAGE_X         ; $D5

                        DB OP_DEC, AM_ZEROPAGE_X         ; $D6

                        DB OP_INV, AM_IMPLICIT           ; $D7

                        DB OP_CLD, AM_IMPLICIT           ; $D8

                        DB OP_CMP, AM_ABSOLUTE_Y         ; $D9

                        DB OP_PHX, AM_IMPLICIT           ; $DA [65C02 only]

                        DB OP_STP, AM_IMPLICIT           ; $DB [WDC 65C02 and 65816 only]

                        DB OP_INV, AM_IMPLICIT           ; $4F

                        DB OP_CMP, AM_ABSOLUTE_X         ; $DD

                        DB OP_DEC, AM_ABSOLUTE_X         ; $DE

                        DB OP_INV, AM_IMPLICIT           ; $DF

                        DB OP_CPX, AM_IMMEDIATE          ; $E0

                        DB OP_SBC, AM_INDEXED_INDIRECT   ; $E1

                        DB OP_INV, AM_IMPLICIT           ; $4F

                        DB OP_INV, AM_IMPLICIT           ; $4F

                        DB OP_CPX, AM_ZEROPAGE           ; $E4

                        DB OP_SBC, AM_ZEROPAGE           ; $E5

                        DB OP_INC, AM_ZEROPAGE           ; $E6

                        DB OP_INV, AM_IMPLICIT           ; $E7

                        DB OP_INX, AM_IMPLICIT           ; $E8

                        DB OP_SBC, AM_IMMEDIATE          ; $E9

                        DB OP_NOP, AM_IMPLICIT           ; $EA

                        DB OP_INV, AM_IMPLICIT           ; $4F

                        DB OP_CPX, AM_ABSOLUTE           ; $EC

                        DB OP_SBC, AM_ABSOLUTE           ; $ED

                        DB OP_INC, AM_ABSOLUTE           ; $EE

                        DB OP_INV, AM_IMPLICIT           ; $EF

                        DB OP_BEQ, AM_RELATIVE           ; $F0

                        DB OP_SBC, AM_INDIRECT_INDEXED   ; $F1

                        DB OP_SBC, AM_INDIRECT_ZEROPAGE  ; $F2 [65C02 only]

                        DB OP_INV, AM_IMPLICIT           ; $4F
                        DB OP_INV, AM_IMPLICIT           ; $4F
                        DB OP_SBC, AM_ZEROPAGE_X         ; $F5

                        DB OP_INC, AM_ZEROPAGE_X         ; $F6

                        DB OP_INV, AM_IMPLICIT           ; $F7

                        DB OP_SED, AM_IMPLICIT           ; $F8

                        DB OP_SBC, AM_ABSOLUTE_Y         ; $F9

                        DB OP_PLX, AM_IMPLICIT           ; $FA [65C02 only]

                        DB OP_INV, AM_IMPLICIT           ; $4F
                        DB OP_INV, AM_IMPLICIT           ; $4F

                        DB OP_SBC, AM_ABSOLUTE_X         ; $FD

                        DB OP_INC, AM_ABSOLUTE_X         ; $FE

                        DB OP_INV, AM_IMPLICIT           ; $FF
