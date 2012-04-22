                               ;
                               ;Swashbuckler Enhancements for ProDOS
                               ;
                               ;Copyright 1988 by Christopher A. Mosher
                               ;
               lst  off
                               ;must set block 2B byte FA: jmp scorchek
                               ;sw.rel open files and saves charf & scrnf
                               ;



                               ;page $00 addresses
asto           }    $FF



                               ;Swashbuckler addresses
start          }    $1AC2      ;entry point
copyhrs        }    $1C80
init           }    $1CB7
game           }    $1800
fixscore       }    $1989
score          }    $09C0



                               ;ProDOS Global Page addresses
mli            }    $BF00
read           }    $CA
set_mark       }    $CE



               org  start      ;the main routine
               jsr  initload   ;load initial characters and screen
               jsr  init       ;initialize
               jsr  game       ;do one game
               jmp  start      ;restart



scrnf          dfb  0          ;screen file reference number
charf          dfb  0          ;character file reference number



scortbl                        ;score table
                               ;list of scores to load at ($10 length)
                               ;+$0 must be 0
                               ;others must be btwn 1 and 255
                               ;0 for others indicates no loading
                               ;each must be greter than the previous (but 0)
               dfb  0,10,20,30,40,50,60,70,80,90,100,110,120,130,140,150



chartbl                        ;table of character pairs used at scores
                               ;in scortbl
               dfb  0,1,2,3,1,4,5,6,1,5,6,7,7,7,7,7




scrntbl                        ;table of screens used at scores in scortbl
               dfb  0,0,1,1,2,2,2,2,2,2,1,1,2,2,2,2



scorchek                       ;check score and load character pair or screen
                               ;if necessary
                               ;i: score(>0), scortbl, chartbl, scrntbl
               lda  score+1
               bne  scx        ;if score > 255 then don't load anything
               lda  score
               ldx  #$F
scl            cmp  scortbl,x
               beq  scs1
               dex
               bne  scl        ;only check scortbl from +$F down to +$1
                               ;scortbl+$0 for initial load only; not used here
                               ;if score not found, then don't load anything
scx            jmp  fixscore   ;fix score, etc., and rts

scs1           txa
               pha             ;save offset
               lda  scrntbl,x  ;screen for this score (0-2)
               cmp  scrntbl-1,x
               beq  scs2       ;if same as last screen, then don't load screen
               jsr  loadscrn   ;load this screen

scs2           pla             ;offset
               tax
               lda  chartbl,x  ;character pair for this score (0-6)
               cmp  chartbl-1,x
               beq  scx        ;if same as last pair, then don't load charpair
               jsr  loadchar   ;load this score's character pair
               jmp  game+$D    ;re-enter with new characters




loadchar                       ;load a character pair
                               ;i: a (character pair number 0-6)
               jsr  getchar
               jmp  fixscore   ;fix score, etc., and rts



loadscrn                       ;load a screen
                               ;i: a (screen number 0-2)
               sta  $C055      ;page2
               jsr  getscrn
               jsr  copyhrs
               jmp  fixscore   ;fix score, etc., and rts



initload                       ;load initial character pair and screen
               lda  scrntbl
               jsr  getscrn
               lda  chartbl
                               ; fall through to getchar




getchar                        ;get a character pair from the disk
                               ;i: a (character pair number 0-6)
               tax
               lda  asto
               pha
               txa
               sta  asto
               asl
               adc  asto
               sta  asto
               asl
               adc  asto
               sta  asto
               asl
               adc  asto       ;multiply a by $1B (27 = 3 cubed)
                               ;answer: $00 <= a <= $A2
                               ;this is the high order byte of the offset
                               ;within the characters file of the pair
               sta  mparms+3
               pla
               sta  asto
               lda  charf      ;character file reference number
               sta  rparms+1
               sta  mparms+1
               lda  #$80
               sta  rparms+3
               lda  #$1B
               sta  rparms+5
               jmp  getfile



getscrn                        ;get a screen from the disk
                               ;i: a (screen number 0-2)
               asl
               asl
               asl
               asl
               asl             ;multiply a by $20 ($00 <= a <= $40)
               sta  mparms+3   ;offset within screens file of screen
               lda  scrnf      ;screen file reference number
               sta  rparms+1
               sta  mparms+1
               lda  #$20
               sta  rparms+3
               sta  rparms+5



getfile                        ;set mark and read data from file
               jsr  mli
               dfb  set_mark
               da   mparms
               bcs  error
               jsr  mli
               dfb  read
               da   rparms
               bcs  error
               rts



error          jmp  $FF59      ;fix



rparms         dfb  4          ;4 parameters for read
               dfb  0          ;reference number
               da   0          ;buffer address
               da   0          ;length (requested)
               da   0          ;length (actual)

mparms         dfb  2          ;2 parameters for set_mark
               dfb  0          ;reference number
               ds   3          ;offset
