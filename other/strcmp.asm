                               ;
                               ; String Compare
                               ;
                               ; Copyright 1988 Christopher A. Mosher
                               ;
                               ;   This program compares two strings a, b
                               ; to see if a is a substring of b.
                               ;
                               ; input:  a, b (strings to compare)
                               ;         alen, blen (lengths of a and b)
                               ;           where alen <= blen
                               ; output: equal: 1 iff a is a substring of b
                               ;                0 otherwise
                               ;



                               ; Definition of Variables
ystor          }    $FB        ; storage for y
stop           }    $FC        ; stopping offset in b
equal          }    $FD        ; equal? (result)  (0, 1)
alen           }    $FE        ; length of a
blen           }    $FF        ; length of b
a              }    $200
b              }    $300



               org  $4000
               lda  #0
               sta  equal
               sec
               lda  blen
               sbc  alen
               sta  stop
               inc  stop

               ldy  #0
               ldx  #0
               lda  a,x
l1             cmp  b,y
               bne  l2
               sty  ystor
found2         inx
               cpx  alen
               bne  l3
               inc  equal
               rts
l3             iny
               lda  a,x
               cmp  b,y
               beq  found2
               ldx  #0
               lda  a,x
               ldy  ystor
l2             iny
               cpy  stop
               bcc  l1
               rts
