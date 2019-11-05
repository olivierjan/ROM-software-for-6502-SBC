*------------------------------------------------------------------------------------------
*--                                                                                      --
*--                        Master file for ROM generation                                --
*--                                                                                      --
*------------------------------------------------------------------------------------------


ACIA6551            EQU     1 ;
ACIA6850            EQU     2 ;
ROMSTART            EQU     $C000 ; 
BASICSTART          EQU     $B000 ;
; MONITORSTART        EQU     $D900 ;
MONITORSTART        EQU     $C000 ; 
; BIOSSTART           EQU     $FD00 ;
SERIALSTART         EQU     $FE00 ;
VECTORSTART         EQU     $FFFA ;
ACIASTART           EQU     $A000 ;
ACIATYPE            EQU     ACIA6551 ;
STACKTOP 			EQU 	#$FF				; Stack goes up to 0x01FF
IRQVECTOR           EQU     $03F0
RAMBASE             EQU     $0400
RAMTOP              EQU     $9FFF
HAVEBASIC           EQU     1
HAVEMONITOR         EQU     1


                    DSK     JAVA1.bin
                    ORG     ROMSTART
                    TYP     $06
                    
                DO      HAVEBASIC
                    ORG     BASICSTART
                    PUT     BASIC/Basic.s
                FIN
                    
                DO      HAVEMONITOR
                    DS      MONITORSTART-*,$EA  ; Pad code with NOPs until next code
                    ORG     MONITORSTART
                    USE     MONITOR/jmon.Macs
                    PUT     MONITOR/jmon.s
                    PUT     MONITOR/disasm.s
                    PUT     MONITOR/memtest4.s
                    PUT     MONITOR/miniasm.s
                    PUT     MONITOR/trace.s
                    PUT     MONITOR/info.s
                    PUT     MONITOR/delay.s
                FIN
                
* Pb de retour chariot

                    DS      BIOSSTART-*+3,$EA     ; Pad code with NOPs until next code
                    ORG     BIOSSTART
                    PUT     BIOS/Init.s
                    DS      SERIALSTART-*,$EA   ; Pad code with NOPs until next code
                    ORG     SERIALSTART
                    PUT     BIOS/Serial.s
                    DS      VECTORSTART-*,$EA   ; Pad code with NOPs until next code
                    ORG     VECTORSTART
                    PUT     BIOS/Vectors.s
                    
                    
END


