                               ;
                               ; Gliding Through Page Two
                               ;
               org  $4000
               sta  $C057
               sta  $C055
               sta  $C052
               sta  $C050
restart        lda  #<relstart
               sta  0
               lda  #>relstart
               sta  1
               ldy  #relend-relstart
relstart       ldx  #relend-relstart
loop1          dfb  $B2,0      ; lda (0)
               sta  (0),y
               inc  0
               bne  skip1
               inc  1
               lda  1
               cmp  #$60
               beq  done
skip1          dex
               bne  loop1
               beq  relend
done           inc  relstart-1
               inc  relstart+1
               inc  done-1
               lda  done-1
               cmp  #$80
               beq  done2
               jmp  restart
done2          sta  $C054
               sta  $C051
               rts
relend
