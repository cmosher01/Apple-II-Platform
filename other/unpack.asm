                               ;
                               ;Packed 5-Bit Character Unpacker
                               ;
                               ;Copyright 1988 by Christopher A. Mosher
                               ;
               lst  off
chars          }    $F0        ;storage for 8 characters ($F0-$F7)
incr           }    $F8
char           }    $FC        ;storage for character (word)
addr           }    $FE        ;address register
staddr         }    $2000      ;address to start unpacking at

readkbd        }    $C000      ;sddddddd
clearkbd       }    $C010      ;clear s
cout           }    $FDED



               org  $0800
               lda  #1
               sta  incr
               lda  #<staddr
               sta  addr
               lda  #>staddr
               sta  addr+1     ;unpack 5 from this address
loop           jsr  unpack5
               jsr  prchars
               jsr  waitkey
               cmp  #$9B       ;<esc>
               bne  continue
               sta  clearkbd
               rts             ;exit
continue       clc
               lda  addr
               adc  incr
               sta  addr
               lda  addr+1
               adc  #0
               sta  addr+1
               jmp  loop



unpack5                        ;unpack 5 bytes (8 packed characters)
                               ;i: addr (starting address)
                               ;o: preserved: addr, incr
                               ;   destroyed: char
               ldx  #0         ;current 5-bit char within 5-byte block (0-7)
unloop         ldy  offtbl,x   ;offset from addr of first byte
               lda  (addr),y
               and  mask1tbl,x
               sta  char
               iny
               lda  (addr),y
               and  mask2tbl,x
               sta  char+1
               ldy  shfttbl,x
               jmp  entshl
shloop         lsr  char
               ror  char+1
               dey
entshl         bne  shloop
               lda  char+1
               ora  #%11000000 ;make ASCII: "@"-"_" ($C0-$DF)
               sta  chars,x
               inx
               cpx  #8
               bne  unloop
               rts



mask1tbl                       ;table of masks (first bytes)
                               ;in order of 5-bit chars within 5-byte block
                               ;5-bit-char byte-to-start-at
               dfb  %11111000  ;0  0
               dfb  %00000111  ;1  0
               dfb  %00111110  ;2  1
               dfb  %00000001  ;3  1
               dfb  %00001111  ;4  2
               dfb  %00000000  ;5  2
               dfb  %00000011  ;6  3
               dfb  %00000000  ;7  3

mask2tbl                       ;table of masks (second bytes)
               dfb  %00000000  ;0  0
               dfb  %11000000  ;1  0
               dfb  %00000000  ;2  1
               dfb  %11110000  ;3  1
               dfb  %10000000  ;4  2
               dfb  %01111100  ;5  2
               dfb  %11100000  ;6  3
               dfb  %00011111  ;7  3

offtbl         dfb  $0,$0,$1,$1,$2,$2,$3,$3

shfttbl                        ;number of bits to right-shift raw masked word
               dfb  $B,$6,$9,$4,$7,$2,$5,$0



waitkey        sta  clearkbd
wkloop         lda  readkbd
               bpl  wkloop
               rts



prchars                        ;print characters
                               ;i: chars
               ldx  #0
prcloop        lda  chars,x
               jsr  cout
               inx
               cpx  #8
               bne  prcloop
               lda  #$A0
               jsr  cout
               rts
