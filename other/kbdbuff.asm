                               ;
                               ; Keyboard Buffer
                               ;
                               ; Copyright 1988 by Christopher A. Mosher
                               ;
                               ; Set up key press buffering routine.
                               ;



               org  $300
               sei
               lda  #$80
               sta  $05FA
               sta  $05FF
               sta  $06FF
               lda  $C0AA
               ora  #$0F
               sta  $C0AA
               cli
               rts
