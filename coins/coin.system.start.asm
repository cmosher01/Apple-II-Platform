               org  $2000
               ldx  #$FF
               stx  invmask    ; initialize inverse and mask
               txs             ; initialize stack

               lda  #<reset    ; set reset vector
               sta  resetv
               lda  #>reset
               sta  resetv+1
               eor  #reseteor
               sta  resetv+2

               lda  #$FF       ; use up pages $B0-$BF
               sta  bitmap+$16
               sta  bitmap+$17

               lda  #kbakver   ; set version information
               sta  ibakver
               lda  #kversion
               sta  iversion

               lda  machid     ; turn on 80 column screen if available
               and  #$02
               bne  reset
               jmp  exit
reset          lda  #$92
               jsr  etyentry

               jsr  dsptitle
               jsr  ttlhome
               jmp  start



exit                           ; quit to ProDOS

               jsr  mli
               dfb  quit
               dfb  <ex1,>ex1
ex1            dfb  0,0,0,0,0,0



                               ; req'd: cout, (phy), (ply)
prmess                         ; print message
                               ; input:  message following jsr prmess
                               ;            terminated with $00
                               ;         bas: base address
                               ;         y:   htab (0 org)
                               ; output: message printed
                               ;         bas preserved
                               ;         y inc by number of chars printed
                               ;         a destroyed

               pla
               sta  pmlda+1
               pla
               sta  pmlda+2
               ldx  #1
pmlda          lda  $FFFF,x
               beq  pmsk1
               jsr  cout
               inx
               bne  pmlda
pmsk1          clc
               txa
               adc  pmlda+1
               sta  pmlda+1
               lda  #0
               adc  pmlda+2
               pha
               lda  pmlda+1
               pha
               rts



                               ; req'd: invmask, cout
cinvout                        ; output a to screen (character) inversed
                               ; input, output same as cout

               pha
               lda  #$7F       ; 0....... = inverse
               sta  invmask
               pla
               jsr  cout
               lda  #$FF       ; 1....... = normal
               sta  invmask
               rts



                               ; req'd: page2, page1, invmask, bas
                               ;        (phy), (ply), (bit)
cout                           ; output a register to screen (character)
                               ; input:  a  : value to be printed
                               ;         bas: base address
                               ;         y  : htab (0 org)
                               ; output: a destroyed
                               ;         bas preserved
                               ;         y incremented
                               ;         one character printed on the screen

               dfb  phy
               pha
               tya
               lsr
               bcc  cosk2
               sta  page1
               bcs  cosk3
cosk2          sta  page2
cosk3          tay
               pla
               ora  #$80       ; 10000000
               and  invmask    ; i1111111 where i = 0:inverse, i = 1:normal
               pha
               and  #$60       ; 01100000
               cmp  #$40       ; .10.....
               bne  cosk1
               pla
               and  #$BF       ; 10111111
               dfb  bit        ; absorb pla: bit #$68
cosk1          pla
               sta  (bas),y
               dfb  ply
               iny
               rts



                               ; req'd: invmask, aout
ainvout                        ; output a register to screen (value) inversed
                               ; input, output same as aout

               pha
               lda  #$7F       ; 0....... = inverse
               sta  invmask
               pla
               jsr  aout
               lda  #$FF       ; 1....... = normal
               sta  invmask
               rts



                               ; req'd: page2, page1, invmask, bas
                               ;        (phy), (ply)
aout                           ; output a register to screen (value)
                               ; input:  a  : value to be printed
                               ;         bas: base address
                               ;         y  : htab (0 org)
                               ; output: a destroyed
                               ;         bas preserved
                               ;         y incremented by 2
                               ;         two characters printed on the screen

               pha
               lsr
               lsr
               lsr
               lsr
               jsr  nibout
               pla
nibout         dfb  phy
               pha
               tya
               lsr
               bcc  aosk2
               sta  page1
               bcs  aosk3
aosk2          sta  page2
aosk3          tay
               pla
               and  #$0F       ; 0000....
               ora  #"0"       ; 1011....
               cmp  #"9"+1     ; see if A - F
               and  invmask    ; i1111111 where i = 0:inverse, i = 1:normal
               bcc  aosk1
               adc  #$06       ; add 7
               and  #$BF       ; .0......
aosk1          sta  (bas),y
               dfb  ply
               iny
               rts



                               ; req'd: page2, page1, bas
                               ;        (phy), (ply)
mout                           ; output a register to screen (mouse char)
                               ; input:  a  : mouse character to be printed
                               ;         bas: base address
                               ;         y  : htab (0 org)
                               ; output: a destroyed
                               ;         bas preserved
                               ;         y incremented
                               ;         one character printed on the screen

               dfb  phy
               pha
               tya
               lsr
               bcc  mosk2
               sta  page1
               bcs  mosk3
mosk2          sta  page2
mosk3          tay
               pla
               and  #$5F       ; 0.0.....
               ora  #$40       ; .1......
               sta  (bas),y
               dfb  ply
               iny
               rts



                               ; req'd: vtab, bas
bascalc                        ; text screen base address calculator (ROM)
                               ;
                               ; input:  vtab: line number (0 org)
                               ; output: bas: base address (lo hi)
                               ;         vtab preserved
                               ;         c = 0

                               ; a         c  bas (lo)  bas+1 (hi)
               lda  vtab       ; 000abcde  .  ........  ........
               lsr             ; 0000abcd  e  ........  ........
               and  #3         ; 000000cd  e  ........  ........
               ora  #4         ; 000001cd  e  ........  ........
               sta  bas+1      ; 000001cd  e  ........  000001cd
               lda  vtab       ; 000abcde  e  ........  000001cd
               and  #$18       ; 000ab000  e  ........  000001cd
               bcc  bcs1       ; 000ab000  e  ........  000001cd
               adc  #$7F       ; 100ab000  0  ........  000001cd
bcs1           sta  bas        ; e00ab000  0  e00ab000  000001cd
               asl             ; 00ab0000  e  e00ab000  000001cd
               asl             ; 0ab00000  0  e00ab000  000001cd
               ora  bas        ; eabab000  0  e00ab000  000001cd
               sta  bas        ; eabab000  0  eabab000  000001cd
               rts



                               ; req'd: waitkey
fetch                          ; fetch a command (uppercase)
                               ; input:  none
                               ; output: a: key pressed (a >= $80)

               jsr  waitkey
               cmp  #"a"
               bcc  exfet
               cmp  #"z"+1
               bcs  exfet
               and  #$DF       ; 11011111  capitalize a-z
exfet          rts



                               ; req'd: clearkbd, readkbd
waitkey                        ; wait for a keypress
                               ; input:  none
                               ; output: a: character (a >= $80)
                               ;         strobe cleared

               sta  clearkbd
wklp1          lda  readkbd
               bpl  wklp1
               sta  clearkbd
               rts



                               ; req'd: title, cout, invmask, vtab, bascalc
dsptitle                       ; display title
                               ; input:  title
                               ; output: title displayed (centered, inverted,
                               ;            on top line)

               lda  #0
               sta  vtab
               jsr  bascalc
               lda  #$7F
               sta  invmask
               ldy  #0
               ldx  #0
dtlp1          lda  title,x
               beq  dtsk1
               inx
               bne  dtlp1
dtsk1          stx  asto
               sec
               lda  #80
               sbc  asto
               cmp  #81
               bcs  exdt
               lsr
               beq  dtsk2
               sta  asto
dtlp3          lda  #$A0
               jsr  cout
               cpy  asto
               bne  dtlp3
dtsk2          ldx  #0
dtlp2          lda  title,x
               beq  dtsk3
               jsr  cout
               inx
               bne  dtlp2
dtlp4          lda  #$A0
               jsr  cout
dtsk3          cpy  #80
               bne  dtlp4
exdt           lda  #$FF
               sta  invmask
               rts



                               ; req'd: vtab, clrdown
home                           ; clear entire screen
                               ; input:  none
                               ; output: screen cleared
                               ;         vtab destroyed

               lda  #0
               sta  vtab
               beq  clrdown



                               ; req'd: vtab, clrdown
ttlhome                        ; clear screen except for title
                               ; input:  none
                               ; output: lines 1-23 cleared
                               ;         vtab destroyed

               lda  #1
               sta  vtab
                               ; fall through to clear down



                               ; req'd: bascalc, bas, vtab, page1, page2
clrdown                        ; clear screen down
                               ; input:  vtab: line to clear down from
                               ; output: screen cleared

               jsr  bascalc
               lda  bas
               sta  hmsta1+1
               sta  hmsta2+1
               lda  bas+1
               sta  hmsta1+2
               sta  hmsta2+2
               lda  #$A0
               sta  page2
               ldy  #0
hmsta1         sta  $FFFF,y
               iny
               cpy  #40
               bne  hmsta1
               sta  page1
               ldy  #0
hmsta2         sta  $FFFF,y
               iny
               cpy  #40
               bne  hmsta2
               inc  vtab
               lda  vtab
               cmp  #24
               bne  clrdown
               rts



title                          ; title to display on top line of screen
                               ; length must be 80 characters or less
                               ; terminated with $00

               asc             "C o i n   I n v e n t o r y"
               dfb  $00
