                               ;
                               ;The Command Interpreter System.
                               ;Part One.  The Relocator
                               ;
                               ;Copyright April 1988
                               ;
                               ;by Christopher A. Mosher
                               ;



image          equ  $2100      ;image address of Part Two
code           equ  $A000      ;destination address of Part Two
length         equ  $05        ;length of Part Two (pages)



               org  $2000
               ldx  #length    ;relocate Part Two
               ldy  #0
rlda           lda  image,y    ;(self-modified)
rsta           sta  code,y     ;(self-modified)
               iny
               bne  rlda
               inc  rlda+2
               inc  rsta+2
               dex
               bne  rlda
               jmp  code       ;execute Part Two
