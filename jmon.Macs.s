; MACROS
;

; INCREMENT ADDRESS
INC_ADDRSC      MAC
                        INC ADDRS
                        BNE SKIP_HI
                        INC ADDRS+$01
SKIP_HI
                        LDA ENDMEM
                        CMP ADDRS
                        BNE EXIT2
                        LDA ENDMEM+$01
                        CMP ADDRS+$01
EXIT2
    EOM


; INITIALIZE ADDRESS WITH START
INI_ADDRS       MAC
                        LDA STARTMEM
                        STA ADDRS
                        LDA STARTMEM + $01
                        STA ADDRS + $01
    EOM




       
; SET TEST PATTERN
; only for tests 4 and 5 (address in address tests), make address High or Low
; equal to pattern
; test 4 is LSB of address
; test 5 is MSB of address
;
SET_PATRN       MAC
                        CPY        #4
                        BNE        TEST5
                        LDA        ADDRS
                        STA        TEST_PATRN
TEST5
                        CPY        #5
                        BNE        EXIT1
                        LDA        ADDRS+$01
                        STA        TEST_PATRN
EXIT1
    EOM
