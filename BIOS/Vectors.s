*-------------------------------------------------------------------------------
*--
*--   Reset, IRQ and NMI Vectors definitions
*--   All points to RESET in the Init Routines for now
*--
*-------------------------------------------------------------------------------


          
          DA     RESET          ; NMI Vector
          DA     RESET          ; RESET Vector
          DA     IRQVECTOR      ; IRQ Vector
