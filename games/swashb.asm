                               ;
                               ;Swashbuckler Enhancements for ProDOS
                               ;
                               ;Copyright 1988 by Christopher A. Mosher
                               ;
                               ;this is the first code in the SYS file
                               ;sets up memory, open files, begins
                               ;



scrnf          }    $1AFE
charf          }    $1AFF
mli            }    $BF00



               org  $2000
               ldx  #$FF
               txs

               lda  #$C2
               sta  $03F2
               lda  #$1A
               sta  $03F3
               eor  #$A5
               sta  $03F4

               ldy  #$18
               ldx  #0
rlda           lda  $2100,x
rsta           sta  $0800,x
               inx
               bne  rlda
               inc  rlda+2
               inc  rsta+2
               dey
               bne  rlda

               ldy  #$20
               ldx  #0
rlda1          lda  $3900,x
rsta1          sta  $6000,x
               inx
               bne  rlda1
               inc  rlda1+2
               inc  rsta1+2
               dey
               bne  rlda1

               ldx  #$18
rlda2          lda  $5900,x
               sta  $0303,x
               dex
               bpl  rlda2

               jsr  mli        ;set prefix
               dfb  $C5
               da   parm1
               bcs  error
               lda  bufr
               and  #$0F
               beq  error
               sta  bufr-1
               inc  bufr-1
               lda  #'/'
               sta  bufr
               jsr  mli
               dfb  $C6
               da   parm2
               bcc  s1
error          brk

s1                             ;open character and screen files
               jsr  mli
               dfb  $C8        ;open
               da   ocparms
               bcs  error
               lda  ocparms+5
               sta  charf

               jsr  mli
               dfb  $C8
               da   osparms
               bcs  error
               lda  osparms+5
               sta  scrnf

                               ;do some starting stuff and then do game
               jsr  $FE93      ;PR#0
               jsr  $FC58      ;home
               jsr  $ED34      ;fout (fix initial score display)
               jmp  $1AC2      ;entry point

ocparms        dfb  3
               da   cfname
               da   $BB00
               dfb  0

cfname         dfb  $F
               asc             'character.pairs'

osparms        dfb  3
               da   sfname
               da   $B700
               dfb  0

sfname         dfb  $7
               asc             'screens'

parm1          dfb  $2
               dfb  $60
               da   bufr
parm2          dfb  $1
               da   bufr-1
               dfb  $0
bufr
