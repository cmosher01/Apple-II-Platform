count          }    $FF

               org  $2000
               ldy  #0
inkro          sty  count
               ldx  #7
shift          lsr  count
               lda  #$58
               rol
               sta  $0707,x
               dex
               bpl  shift
               ldx  #$FF
wait           dex
               bne  wait
               iny
               bne  inkro
               rts
