cyc8           }    $5C        ;8 cycle instruction



               lda  #0
               sta  $0794
redo           inc  $0794
                               ;timing start
               ldx  #114
loop1          dfb  cyc8,0,0
               dfb  cyc8,0,0
               dfb  cyc8,0,0
               dfb  cyc8,0,0
               dfb  cyc8,0,0
               dfb  cyc8,0,0
               dfb  cyc8,0,0
               dfb  cyc8,0,0
               dfb  cyc8,0,0
               dfb  cyc8,0,0
               dfb  cyc8,0,0
               dfb  cyc8,0,0
               dfb  cyc8,0,0
               dfb  cyc8,0,0
               dfb  cyc8,0,0
               dfb  cyc8,0,0
               dfb  cyc8,0,0
               dfb  cyc8,0,0
               dex
               bne  loop1
               dfb  cyc8,0,0
               dfb  cyc8,0,0
               dfb  cyc8,0,0
               dfb  cyc8,0,0
               dfb  cyc8,0,0
               dfb  cyc8,0,0
                               ;timing end:17033
               bit  0
               bit  0
               nop
               jmp  redo
