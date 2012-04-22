                               ;



                               ; opcodes
stz            equ  $9E        ; stz $FFFF,x



               org  $0400



entry

zeromem                        ; zero random access memory:
                               ;   main     : $0000-$03FF
                               ;              $0800-$BFFF
                               ;              $D000-$DFFF (bank 1)
                               ;              $D000-$DFFF (bank 2)
                               ;              $E000-$FFFF
                               ;   auxiliary: $0000-$03FF
                               ;              $0800-$BFFF
                               ;              $D000-$DFFF (bank 1)
                               ;              $D000-$DFFF (bank 2)
                               ;              $E000-$FFFF

               ldx  #0
               stx  zmstz+1
               stx  zmstz+2
zmstz          dfb  stz,$FF,$FF ; stz $FFFF,x (modified)
               inx
               bne  zmstz
               inc  zmstz+2
               lda  zmstz+2
               cmp  #$04
               bne  zmsk1
               lda  #$08
               sta  zmstz+2
               bne  zmstz
zmsk1          cmp  #$C0
               bne  zmstz
