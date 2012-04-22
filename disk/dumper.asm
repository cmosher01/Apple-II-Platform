resetv         equ  $03F2
reseteor       equ  $A5
mli            equ  $BF00
quit           equ  $65
ibakver        equ  $BFFC
iversion       equ  $BFFD
kbakver        equ  $00
kversion       equ  $00
readkbd        equ  $C000
clearkbd       equ  $C010
drvoff         equ  $C088
drvon          equ  $C089
drvrd          equ  $C08C
home           equ  $FC58
aout           equ  $FDDA



               org  $2000

               ldx  #$FF       ; init stack pointer
               txs

               lda  #<exit     ; set reset vector
               sta  resetv
               lda  #>exit
               sta  resetv+1
               eor  #reseteor
               sta  resetv+2

               lda  #kbakver   ; set version info
               sta  ibakver
               lda  #kversion
               sta  iversion

               jsr  home       ; Dumper
               ldx  #$60
               lda  drvon,x
               sta  clearkbd
waitdrd        lda  drvrd,x
               bpl  waitdrd
               jsr  aout
               lda  readkbd
               bpl  waitdrd
               lda  drvoff,x
               sta  clearkbd



exit                           ; exit Dumper

               jsr  mli
               dfb  quit
               dfb  <parms,>parms
parms          dfb  4
               dfb  0,0,0,0,0,0
