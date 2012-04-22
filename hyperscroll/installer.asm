                               ;
                               ;Hyper-text installer
                               ;
                               ;Copyright 1988 by Christopher A. Mosher
                               ;



ramramd2       }    $C083
romramd1       }    $C089
ramramd1       }    $C08B



               org  $2000



                               ;Copy ROM to BSR ($D000 bank 1)
               lda  romramd1
               lda  romramd1
               ldy  #0
lda1           lda  $D000,y
sta1           sta  $D000,y
               iny
               bne  lda1
               inc  lda1+2
               inc  sta1+2
               bne  lda1



                               ;Copy usehyper to BSR $F800
               ldy  #uhend-usehyper
movel          lda  usehyper,y
               sta  $F800,y
               dey
               bpl  movel



                               ;change JMP SCROLLUP to JMP USEHYPER
               lda  #0
               sta  $FC71
               lda  #$F8
               sta  $FC72



                               ;Copy Hyper-text to BSR ($D000 bank 2)
               lda  ramramd2
               lda  ramramd2
               ldx  #2
               ldy  #0
lda2           lda  prgend,y
sta2           sta  $D000,y
               iny
               bne  lda2
               inc  lda2+2
               inc  sta2+2
               dex
               bne  lda2



               lda  ramramd1   ;Switch in BSR ($D000 bank 1)
               lda  ramramd1
               rts             ;and we're done.



usehyper                       ;Routine to use Hyper-text in $D000 bank 2
                               ;(Moved to $F800)
               lda  ramramd2
               lda  ramramd2
               jsr  $D000
               lda  ramramd1
               lda  ramramd1
uhend          rts
prgend
