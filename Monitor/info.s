; Information Routines
;
; Copyright (C) 2012-2016 by Jeff Tranter <tranter@pobox.com>
;
; Licensed under the Apache License, Version 2.0 (the 'License');
; you may not use this file except in compliance with the License.
; You may obtain a copy of the License at
;
;   http://www.apache.org/licenses/LICENSE-2.0
;
; Unless required by applicable law or agreed to in writing, software
; distributed under the License is distributed on an 'AS IS' BASIS,
; WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
; See the License for the specific language governing permissions and
; limitations under the License.
;

; iNfo command
;
; Displays information such as: detected CPU type, clock speed,
;   range of RAM and ROM, detected peripheral cards. etc.
;
; Sample Output
;
;         Computer: Apple //c
;         CPU type: 65C02
;        CPU speed: 2.0 MHZ
;RAM detected from: $0000 TO $7FFF
;       NMI vector: $0F00
;     RESET vector: $FF00
;   IRQ/BRK vector: $0100
;         ACI card: NOT PRESENT
;       CFFA1 card: NOT PRESENT
;   MULTI I/O card: PRESENT
;        BASIC ROM: PRESENT
;     KRUSADER ROM: PRESENT
;       WOZMON ROM: PRESENT
;Slot ID Type
; 1   31 serial or parallel
; 2   31 serial or parallel
; 3   88 80 column card
; 4   20 joystick or mouse
; 5   -- empty or unknown
; 6   -- empty or unknown
; 7   9B Network or bus interface

Info
                JSR PrintChar           ; Echo command
                JSR PrintCR

                JSR Imprint             ; Display computer type
                ASC '         Computer: ',00
        


; Identify model of Apple computer. Algorithm is from Apple //c
; Reference Manual.
; ID1 EQU FBB3
; ID2 EQU FBC0
; if (ID1) EQU 38
;   then id EQU Apple II
; else if (ID1) EQU EA
;   then id EQU Apple II+
; else if (ID1) EQU 06
;   if (ID2) EQU EA
;     then id EQU Apple //e
;   else if (ID2) EQU 00
;     then id EQU Apple //c
; else
;   id EQU Unknown

ID1 EQU $FBB3
ID2 EQU $FBC0
                LDA ID1
                CMP #$38
                BNE Next1
                LDX #<TypeAppleIIString
                LDY #>TypeAppleIIString
                JMP PrintType
Next1
                CMP #$EA
                BNE Next2
                LDX #<TypeAppleIIplusString
                LDY #>TypeAppleIIplusString
                JMP PrintType
Next2
                CMP #$06
                BNE Unknown
                LDA ID2
                CMP #$EA
                BNE Next3
                LDX #<TypeAppleIIeString
                LDY #>TypeAppleIIeString
                JMP PrintType
Next3
                CMP #$00
                BNE Unknown
                LDX #<TypeAppleIIcString
                LDY #>TypeAppleIIcString
                JMP PrintType
Unknown
                LDX #<TypeAppleUnknown
                LDY #>TypeAppleUnknown


PrintType
                JSR PrintString
                JSR PrintCR

                JSR Imprint             ; Display CPU type
                ASC '         CPU type: ',00

                JSR CPUType
                CMP #1
                BNE :Try2
                LDX #<Type6502String
                LDY #>Type6502String
                JMP :PrintCPU
:Try2
                CMP #2
                BNE :Try3
                LDX #<Type65C02String
                LDY #>Type65C02String
                JMP :PrintCPU
:Try3
                CMP #3
                BNE :Invalid
                LDX #<Type65816String
                LDY #>Type65816String

:PrintCPU
                JSR PrintString
                JSR PrintCR

:Invalid

:SkipSpeed
                JSR Imprint           ; Print range of RAM
                ASC 'RAM detected from: $0000 to ', 00
                JSR PrintDollar
                JSR FindTopOfRAM
                JSR PrintAddress
                JSR PrintCR

                JSR Imprint           ; Print NMI vector address
                ASC '       NMI vector: $',00
                LDX $FFFA
                LDY $FFFB
                JSR PrintAddress
                JSR PrintCR
                JSR Imprint ; Print reset vector address
                ASC '     RESET vector: $',00
                LDX $FFFC
                LDY $FFFD
                JSR PrintAddress
                JSR PrintCR

                JSR Imprint   ; Print IRQ/BRK vector address
                ASC '   IRQ/BRK vector: $',00
                LDX $FFFE
                LDY $FFFF
                JSR PrintAddress
                JSR PrintCR



                JSR Imprint
                ASC '        BASIC ROM: ',00
                JSR BASICPresent
                JSR PrintPresent
                JSR PrintCR

                RTS

; Determine type of CPU. Returns result in A.
; 1 - 6502, 2 - 65C02, 3 - 65816.
; Algorithm taken from Western Design Center programming manual.

CPUType
                SED           ; Trick with decimal mode used
                LDA #$99      ; Set negative flag
                CLC
                ADC #$01      ; Add 1 to get new accumulator value of 0
                BMI O2        ; 6502 does not clear negative flag so branch taken.

; 65C02 and 65816 clear negative flag in decimal mode

                CLC
                XCE           ; Valid on 65816, unimplemented NOP on 65C02
                BCC C02       ; On 65C02 carry will still be clear and branch will be taken.
                XCE           ; Switch back to emulation mode
                CLD
                LDA #3        ; 65816
                RTS
C02
                CLD
                LDA #2        ; 65C02
                RTS
O2
                CLD
                LDA #1        ; 6502
                RTS

; Based on the value in A, displays 'present' (1) or 'not present' (0).

PrintPresent
                CMP #0
                BNE :Present
                JSR Imprint
                ASC 'not ',00
:Present
                JSR Imprint
                ASC 'present',00
                RTS

; Determines top of installed RAM while trying not to corrupt any other
; program including this one. We assume RAM starts at 0. Returns top
; RAM address in X (low), Y (high).

LIMIT EQU $FFFF        ; Highest address we want to test
TOP   EQU $00          ; Holds current highest address of RAM (two bytes)

FindTopOfRAM

                LDA #<$0002         ; Store $0002 in TOP (don't want to change TOP)
                STA TOP
                LDA #>$0002
                STA TOP+1

:Loop
                LDY #0
                LDA (TOP),Y         ; Read current contents of (TOP)
                TAX                 ; Save in register so we can later restore it
                LDA #0              ; Write all zeroes to (TOP)
                STA (TOP),Y
                CMP (TOP),Y         ; Does it read back?
                BNE :TopFound       ; If not, top of memory found
                LDA #$FF            ; Write all ones to (TOP)
                STA (TOP),Y
                CMP (TOP),Y         ; Does it read back?
                BNE :TopFound       ; If not, top of memory found
                LDA #$AA            ; Write alternating bits to (TOP)
                STA (TOP),Y
                CMP (TOP),Y         ; Does it read back?
                BNE :TopFound       ; If not, top of memory found
                LDA #$55            ; Write alternating bits to (TOP)
                STA (TOP),Y
                CMP (TOP),Y         ; Does it read back?
                BNE :TopFound       ; If not, top of memory found

                TXA                 ; Write original data back to (TOP)
                STA (TOP),Y

                LDA TOP             ; Increment TOP (low,high)
                CLC
                ADC #1
                STA TOP
                LDA TOP+1
                ADC #0              ; Add any carry
                STA TOP+1

;  Are we testing in the range of this code (i.e. the same 256 byte
;  page)? If so, need to skip over it because otherwise the memory
;  test will collide with the code being executed when writing to it.

                LDA TOP+1           ; High byte of page
                CMP #>FindTopOfRAM  ; Same page as this code?
                BEQ :Skip
                CMP #>FindTopOfRAMEnd ; Same page as this code (code could cross two pages)
                BEQ :Skip
                BNE :NotUs
:Skip
                INC TOP+1           ; Skip over this page when testing

:NotUs

                LDA TOP+1           ; Did we reach LIMIT? (high byte)
                CMP #>LIMIT
                BNE :Loop           ; If not, keep looping
                LDA TOP             ; Did we reach LIMIT? (low byte)
                CMP #<LIMIT
                BNE :Loop           ; If not, keep looping

:TopFound
                TXA                 ; Write original data back to (TOP) just in case it is important
                STA (TOP),Y

FindTopOfRAMEnd            ; End of critical section we don't want to write to during testing

                LDA TOP             ; Decrement TOP by 1 to get last RAM address
                SEC
                SBC #1
                STA TOP
                LDA TOP+1
                SBC #0              ; Subtract any borrow
                STA TOP+1

                LDX TOP             ; Set top of RAM as TOP (X-low Y-high)
                LDY TOP+1

                RTS                 ; Return

; Measure CPU clock speed by sending characters out the serial port of
; a Multi I/O board and counting how many CPU cycles it takes. Returns
; value in A that is approximately CPU speed in MHz * 10.


