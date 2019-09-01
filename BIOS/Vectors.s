*-------------------------------------------------------------------------------
*--
*--   Reset, IRQ and NMI Vectors definitions
*--   All points to RESET in the Init Routines for now
*--
*-------------------------------------------------------------------------------



          DSK	  Vectors.bin
          ORG     $FFFA
          TYP     $06

RESET     EXT                   ; Define External reference to RESET.
          DA     RESET          ; NMI Vector
          DA     RESET          ; RESET Vector
          DA     $03F0          ; IRQ Vector


END
