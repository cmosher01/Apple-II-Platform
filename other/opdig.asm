addr           equ  $F0
op             equ  $F2
table          equ  $F3E8
aout           equ  $FDDA
cout           equ  $FDED



               org  $2000
               lda  $C08B
               lda  $C08B

               lda  #<table
               sta  addr
               lda  #>table
               sta  addr+1

loop           ldy  #0
               lda  (addr),y
               sta  op
               iny
               lda  (addr),y
               sta  op+1

               lda  addr+1
               jsr  aout
               lda  addr
               jsr  aout
               lda  #":"
               jsr  cout
               lda  op
               lsr
               lsr
               lsr
               ora  #$E0
               jsr  cout
               lda  op
               and  #$07       ; .....111
               asl  op+1
               rol
               asl  op+1
               rol
               ora  #$E0
               jsr  cout
               lda  op+1
               lsr
               lsr
               lsr
               ora  #$E0
               jsr  cout
               lda  #$A0
               jsr  cout
               lda  #$A0
               jsr  cout

w              bit  $C000
               bpl  w
               sta  $C010

               clc
               lda  addr
               adc  #1
               sta  addr
               lda  addr+1
               adc  #0
               sta  addr+1

               lda  addr
               cmp  #$CC
               beq  sk2
               jmp  loop
sk2            lda  addr+1
               cmp  #$F5
               beq  sk3
               jmp  loop
sk3            rts
