*------------------------------------------------------------------------------------------
*--                                                                                      --
*--                        Master file for ROM generation                                --
*--                                                                                      --
*------------------------------------------------------------------------------------------



ROMSTART            EQU     $B000 ; 
BASICSTART          EQU     $B000 ;
MONITORSTART        EQU     $D900 ;
BIOSSTART           EQU     $FD00 ;
ACIASTART           EQU     $A000 ;
ACIATYPE            EQU     ACIA6551 ;
;ACIATYPE           EQU     ACIA6850 ;
ROMNAME             EQU     OJROM.bin ;


                    DSK     ROMNAME
                    ORG     ROMSTART
                    TYP     $06
                    
                    DO BASICSTART
                    
                    ORG     BASICSTART
                    PUT     BASIC/Basic.s
                    
                    FIN
                    
                    DO MONITORSTART
                    
                    ORG     MONITORSTART
                    PUT     MONITOR/jmon.s
                    PUT     MONITOR/disasm.s
                    PUT     MONITOR/miniasm.s
                    PUT     MONITOR/trace.s
                    PUT     MONITOR/info.s
                    PUT     MONITOR/delay.s
                    
                    FIN
                    
                    ORG     BIOSSTART
                    PUT     BIOS/Init.s
                    PUT     BIOS/Serial.s
                    PUT     BIOS/Vectors.s
                    
                    
END


