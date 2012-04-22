                                ;
                                ;ProDOS Directory Editor
                                ;
                                ;Copyright 1988 Christopher A. Mosher
                                ;
               lst   off



                                ;
                                ; Machine Language Relocator
                                ;
                                ; This program is installed in front
                                ; of a machine language program that
                                ; is to be relocated elsewhere in
                                ; memory before it is executed.
                                ; When run, it first moves length pages
                                ; from image to code, and then jmps to
                                ; code.

length         }     $1F
image          }     $2100
code           }     $A000

               org   $2000
               ldy   #length
               ldx   #0
rlda           lda   image,x
rsta           sta   code,x
               inx
               bne   rlda
               inc   rlda+2
               inc   rsta+2
               dey
               bne   rlda
               jmp   code
               ds    image-*



                                ; opcodes
inc            }     $1A        ; inc
dec            }     $3A        ; dec
phy            }     $5A        ; phy
ply            }     $7A        ; ply
jmp            }     $7C        ; jmp  ($FFFF,X)
bit            }     $24        ; bit  $FF
phx            }     $DA        ; phx
plx            }     $FA        ; plx

                                ; page $00 locations
curi           }     $80        ; cur inv ent
curpg          }     $81        ; beg. pg # of block of cur inv ent
maxpg          }     $82        ; beg. pg # of last dir block
curoff         }     $83        ; offset in offl of cur inv ent
invvt          }     $84        ; vtab of cur inv ent
topn           }     $85        ; number of entries above cur inv ent
date           }     $86        ; date ($86-$89)
vtab           }     $E0        ; line number for printing
invmask        }     $E1        ; inverse and mask
asto           }     $E2        ; storage register
asto2          }     $E3
asto3          }     $E4
htab           }     $E5        ; horizontal cursor position storage
bas            }     $F0        ; base address register for printing ($F0-$F1)
addr           }     $F2        ; address register ($F2-$F3)
curaddr        }     $F4        ; beg. address of cur inv ent ($F4-$F5)

                                ; page $03 locations
resetv         }     $03F2
reseteor       }     $A5

                                ; ProDOS system global page
mli            }     $BF00
quit           }     $65
read_block     }     $80
bitmap         }     $BF58
machid         }     $BF98
ibakver        }     $BFFC
kbakver        }     $00
iversion       }     $BFFD
kversion       }     $00

                                ; page $C0 locations
page1          }     $C054      ; RW: page1 (or main memory)
page2          }     $C055      ; RW: page2 (or auxiliary memory)
readkbd        }     $C000      ; R : read keyboard (sddddddd)
clearkbd       }     $C010      ; RW: clear keyboard strobe

etyentry       }     $C300

bufrpg         }     $08        ; page number of start of buffer



               org   code
               ldx   #$FF
               stx   invmask    ; initialize inverse and mask
               txs              ; initialize stack

               lda   #<reset    ; set reset vector
               sta   resetv
               lda   #>reset
               sta   resetv+1
               eor   #reseteor
               sta   resetv+2

               lda   #$FF       ; use up pages $A0-$BF
               sta   bitmap+$14
               sta   bitmap+$15
               sta   bitmap+$16
               sta   bitmap+$17

               lda   #kbakver   ; set version information
               sta   ibakver
               lda   #kversion
               sta   iversion

               lda   machid     ; turn on 80 column screen if available
               and   #%00000010
               bne   etysk1
               jmp   exit
etysk1         lda   #$92
               jsr   etyentry

               jsr   dsptitle
               jsr   ttlhome
               jmp   start



exit                            ; quit to ProDOS

               jsr   mli
               dfb   quit
               da    ex1
ex1            dfb   4,0,0,0,0,0,0



                                ; req'd: cout, (phy), (ply)
prmess                          ; print message
                                ; input:  message following jsr prmess
                                ;            terminated with $00
                                ;         bas: base address
                                ;         y:   htab (0 org)
                                ; output: message printed
                                ;         bas preserved
                                ;         y inc by number of chars printed
                                ;         a destroyed

               pla
               sta   pmlda+1
               pla
               sta   pmlda+2
               ldx   #1
pmlda          lda   $FFFF,x
               beq   pmsk1
               jsr   cout
               inx
               bne   pmlda
pmsk1          clc
               txa
               adc   pmlda+1
               sta   pmlda+1
               lda   #0
               adc   pmlda+2
               pha
               lda   pmlda+1
               pha
               rts



                                ; req'd: invmask, cout
cinvout                         ; output a to screen (character) inversed
                                ; input, output same as cout

               pha
               lda   #$7F       ; 0....... = inverse
               sta   invmask
               pla
               jsr   cout
               lda   #$FF       ; 1....... = normal
               sta   invmask
               rts



                                ; req'd: page2, page1, invmask, bas
                                ;        (phy), (ply), (bit)
cout                            ; output a register to screen (character)
                                ; input:  a  : value to be printed
                                ;         bas: base address
                                ;         y  : htab (0 org)
                                ; output: a destroyed
                                ;         bas preserved
                                ;         y incremented
                                ;         one character printed on the screen

               dfb   phy
               pha
               tya
               lsr
               bcc   cosk2
               sta   page1
               bcs   cosk3
cosk2          sta   page2
cosk3          tay
               pla
               ora   #$80       ; 10000000
               and   invmask    ; i1111111 where i = 0:inverse, i = 1:normal
               pha
               and   #$60       ; 01100000
               cmp   #$40       ; .10.....
               bne   cosk1
               pla
               and   #$BF       ; 10111111
               dfb   bit        ; absorb pla: bit #$68
cosk1          pla
               sta   (bas),y
               dfb   ply
               iny
               rts



                                ; req'd: invmask, aout
ainvout                         ; output a register to screen (value) inversed
                                ; input, output same as aout

               pha
               lda   #$7F       ; 0....... = inverse
               sta   invmask
               pla
               jsr   aout
               lda   #$FF       ; 1....... = normal
               sta   invmask
               rts



                                ; req'd: page2, page1, invmask, bas
                                ;        (phy), (ply)
aout                            ; output a register to screen (value)
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
               jsr   nibout
               pla
nibout         dfb   phy
               pha
               tya
               lsr
               bcc   aosk2
               sta   page1
               bcs   aosk3
aosk2          sta   page2
aosk3          tay
               pla
               and   #$0F       ; 0000....
               ora   #"0"       ; 1011....
               cmp   #"9"+1     ; see if A - F
               and   invmask    ; i1111111 where i = 0:inverse, i = 1:normal
               bcc   aosk1
               adc   #$06       ; add 7
               and   #$BF       ; .0......
aosk1          sta   (bas),y
               dfb   ply
               iny
               rts



                                ; req'd: page2, page1, bas
                                ;        (phy), (ply)
mout                            ; output a register to screen (mouse char)
                                ; input:  a  : mouse character to be printed
                                ;         bas: base address
                                ;         y  : htab (0 org)
                                ; output: a destroyed
                                ;         bas preserved
                                ;         y incremented
                                ;         one character printed on the screen

               dfb   phy
               pha
               tya
               lsr
               bcc   mosk2
               sta   page1
               bcs   mosk3
mosk2          sta   page2
mosk3          tay
               pla
               and   #$5F       ; 0.0.....
               ora   #$40       ; .1......
               sta   (bas),y
               dfb   ply
               iny
               rts



                                ; req'd: vtab, bas
bascalc                         ; text screen base address calculator (ROM)
                                ;
                                ; input:  vtab: line number (0 org)
                                ; output: bas: base address (lo hi)
                                ;         vtab preserved
                                ;         c = 0

                                ; a         c  bas (lo)  bas+1 (hi)
               lda   vtab       ; 000abcde  .  ........  ........
               lsr              ; 0000abcd  e  ........  ........
               and   #%00000011 ; 000000cd  e  ........  ........
               ora   #%00000100 ; 000001cd  e  ........  ........
               sta   bas+1      ; 000001cd  e  ........  000001cd
               lda   vtab       ; 000abcde  e  ........  000001cd
               and   #%00011000 ; 000ab000  e  ........  000001cd
               bcc   bcs1       ; 000ab000  e  ........  000001cd
               ora   #%10000000 ; 100ab000  0  ........  000001cd
bcs1           sta   bas        ; e00ab000  0  e00ab000  000001cd
               asl              ; 00ab0000  e  e00ab000  000001cd
               asl              ; 0ab00000  0  e00ab000  000001cd
               ora   bas        ; eabab000  0  e00ab000  000001cd
               sta   bas        ; eabab000  0  eabab000  000001cd
               rts



                                ; req'd: waitkey
fetch                           ; fetch a command (uppercase)
                                ; input:  none
                                ; output: a: key pressed (a >= $80)

               jsr   waitkey
               cmp   #"a"
               bcc   exfet
               cmp   #"z"+1
               bcs   exfet
               and   #$DF       ; 11011111  capitalize a-z
exfet          rts



                                ; req'd: clearkbd, readkbd
waitkey                         ; wait for a keypress
                                ; input:  none
                                ; output: a: character (a >= $80)
                                ;         strobe cleared

               sta   clearkbd
wklp1          lda   readkbd
               bpl   wklp1
               sta   clearkbd
               rts



                                ; req'd: title, cout, invmask, vtab, bascalc
dsptitle                        ; display title
                                ; input:  title
                                ; output: title displayed (centered, inverted,
                                ;            on top line)

               lda   #0
               sta   vtab
               jsr   bascalc
               lda   #$7F
               sta   invmask
               ldy   #0
               ldx   #0
dtlp1          lda   title,x
               beq   dtsk1
               inx
               bne   dtlp1
dtsk1          stx   asto
               sec
               lda   #80
               sbc   asto
               cmp   #81
               bcs   exdt
               lsr
               beq   dtsk2
               sta   asto
dtlp3          lda   #$A0
               jsr   cout
               cpy   asto
               bne   dtlp3
dtsk2          ldx   #0
dtlp2          lda   title,x
               beq   dtsk3
               jsr   cout
               inx
               bne   dtlp2
dtlp4          lda   #$A0
               jsr   cout
dtsk3          cpy   #80
               bne   dtlp4
exdt           lda   #$FF
               sta   invmask
               rts



                                ; req'd: vtab, clrdown
home                            ; clear entire screen
                                ; input:  none
                                ; output: screen cleared
                                ;         vtab destroyed

               lda   #0
               sta   vtab
               beq   clrdown



                                ; req'd: vtab, clrdown
ttlhome                         ; clear screen except for title
                                ; input:  none
                                ; output: lines 1-23 cleared
                                ;         vtab destroyed

               lda   #1
               sta   vtab
                                ; fall through to clear down



                                ; req'd: bascalc, bas, vtab, page1, page2
clrdown                         ; clear screen down
                                ; input:  vtab: line to clear down from
                                ; output: screen cleared

               jsr   bascalc
               lda   bas
               sta   hmsta1+1
               sta   hmsta2+1
               lda   bas+1
               sta   hmsta1+2
               sta   hmsta2+2
               lda   #$A0
               sta   page2
               ldy   #0
hmsta1         sta   $FFFF,y
               iny
               cpy   #40
               bne   hmsta1
               sta   page1
               ldy   #0
hmsta2         sta   $FFFF,y
               iny
               cpy   #40
               bne   hmsta2
               inc   vtab
               lda   vtab
               cmp   #24
               bne   clrdown
               rts



title                           ; title to display on top line of screen
                                ; length must be 80 characters or less
                                ; terminated with $00

               asc              "P r o D O S   D i r e c t o r y   E d i t o r"
               dfb   $00



parms                           ;parameter list for mli calls
               dfb   $03
unit           dfb   $60
bufraddr       dfb   $00,$00
block          dfb   $02,$00



dirdims                         ;dimensions for file menu
               dfb   04         ;+$0: top
               dfb   19         ;+$1: bottom
               dfb   00         ;+$2: left
                                ;(all dimensions are 0 origin)



                                ;list of offsets of entries within each block
offln          dfb   0          ;number of entries in list (0 orig.) (max $0F)
offll          ds    $10        ;low bytes
offlh          ds    $10        ;high bytes



fieldtbl                        ;table of addresses of field names
               da    ststr,nlstr,namestr,typestr,kbstr,bustr,lenstr,crestr
               da    verstr,accstr,auxstr,modstr,hdrstr,resstr,elstr,ebstr
               da    fcstr,bmstr,bvstr,pbstr,penstr,pelstr

                                ;field names
ststr          asc              "storage type"
               dfb   0
nlstr          asc              "name length"
               dfb   0
namestr        asc              "name"
               dfb   0
typestr        asc              "type"
               dfb   0
kbstr          asc              "key block"
               dfb   0
bustr          asc              "blocks used"
               dfb   0
lenstr         asc              "length"
               dfb   0
crestr         asc              "creation"
               dfb   0
verstr         asc              "version --> minimum"
               dfb   0
accstr         asc              "access"
               dfb   0
auxstr         asc              "auxiliary"
               dfb   0
modstr         asc              "last modification"
               dfb   0
hdrstr         asc              "header block"
               dfb   0
resstr         asc              "reserved"
               dfb   0
elstr          asc              "entry length"
               dfb   0
ebstr          asc              "entries per block"
               dfb   0
fcstr          asc              "file count"
               dfb   0
bmstr          asc              "bit map block"
               dfb   0
bvstr          asc              "blocks per volume"
               dfb   0
pbstr          asc              "parent block"
               dfb   0
penstr         asc              "parent entry number"
               dfb   0
pelstr         asc              "parent entry length"
               dfb   0



                                ;lists of field strings
                                ;(files, vol hdrs, sub hdrs)
filflds        hex              000102030405060708090A0B0C
volflds        hex              0001020D0708090E0F101112
subflds        hex              0001020D0708090E0F10131415



                                ;list of field vtabs
                                ;(changed from rel to abs)
                                ;(corrsp to fieldtbl)
fvtoff         dfb   04         ;offset of field vtabs
fvt            hex              0001020405060708090A0B0C0D
               hex              050B0C0D0E0F0E0F10

                                ;list of field htabs
                                ;(len + 3)
                                ;(changed from rel to abs)
fhtoff         dfb   20         ;offset of field htabs
fht            hex              0F0E07070C0E090B16090C140F
               hex              0B0F140D10140F1616

                                ;list of vtabs to clear
                                ;(changed from rel to abs)
                                ;(all other vtabs btwn 0 & 10
                                ; don't change from fil/vol/sub)
                                ;term 00
vtc            hex              040506070B0C0D0E0F1000



fixvtht                         ;change fvt, fht, vtc from rel to abs
               ldx   #$15       ;field number
               clc
fxlp1          lda   fvt,x
               adc   fvtoff     ;vtab offset
               sta   fvt,x
               dex
               bpl   fxlp1
               ldx   #$15
               clc
fxlp2          lda   fht,x
               adc   fhtoff
               sta   fht,x
               dex
               bpl   fxlp2
               ldx   #0
               clc
fxlp3          lda   vtc,x
               beq   fxsk1
               adc   fvtoff
               sta   vtc,x
               inx
               bne   fxlp3
fxsk1          rts



monthtbl                        ;table of addresses of months ($0 - $F)
               da    0,jan,feb,mar,apr,may,jun,jul,aug,sep,oct,nov,dcm,0,0,0

                                ;months
jan            asc              "January"
               dfb   0
feb            asc              "February"
               dfb   0
mar            asc              "March"
               dfb   0
apr            asc              "April"
               dfb   0
may            asc              "May"
               dfb   0
jun            asc              "June"
               dfb   0
jul            asc              "July"
               dfb   0
aug            asc              "August"
               dfb   0
sep            asc              "September"
               dfb   0
oct            asc              "October"
               dfb   0
nov            asc              "November"
               dfb   0
dcm            asc              "December"
               dfb   0



typntbl                         ;table of file type numbers (term $00)
               hex              0104060F191A1B
               hex              EFF0F1F2F3F4F5F6F7F8
               hex              FAFBFCFDFEFF
               hex              0203050708090A0B0C1011
               hex              12131415
               dfb   0

typstbl                         ;table of file type strings (corrsp. typntbl)
               asc              "BADTXTBINDIRADBAWPASP"
               asc              "PASCMDUS1US2US3US4US5US6US7US8"
               asc              "INTIVRBASVARRELSYS"
               asc              "PCDPTXPDAFNTFOTBA3DA3WPFSOSRPDRPI"
               asc              "AFDAFMAFRSCL"



sttbl                           ;table of addresses of storage types ($0 - $F)
               da    delst,seedst,sapst,trest
               da    0,0,0,0,0,0,0,0,0
               da    subst,subhst,volhst

                                ;storage types
delst          asc              "deleted"
               dfb   0
seedst         asc              "seedling"
               dfb   0
sapst          asc              "sapling"
               dfb   0
trest          asc              "tree"
               dfb   0
subst          asc              "subdirectory"
               dfb   0
subhst         asc              "header (subdirectory)"
               dfb   0
volhst         asc              "header (volume directory)"
               dfb   0
start          jsr   fixvtht
warmstrt       jsr   dspslot
               jsr   slot
               jsr   vgetdir
               jmp   filemenu



reset                           ;reset handler

               jmp   $FF59
               lda   #$92
               jsr   etyentry
               jsr   dsptitle
               jsr   ttlhome
               jmp   warmstrt



error                           ;print ProDOS error message
                                ;i: a: ProDOS error number
                                ;o: message printed

               pha
               lda   #23
               sta   vtab
               jsr   bascalc
               ldy   #0
               pla
               cmp   #$28
               bne   ers1
               jsr   prmess
               asc              "no device connected"
               dfb   0
               rts
ers1           jsr   prmess
               asc              "input/output error"
               dfb   0
               rts



clrerr                          ;clear error message
                                ;i: none
                                ;o: line 23 cleared

               lda   #23
               sta   vtab
               jsr   bascalc
               ldy   #0
celp1          lda   #$A0
               jsr   cout
               cpy   #40
               bne   celp1
               rts



clrmid                          ;clear middle section of screen
                                ;i: none
                                ;o: lines 1 - 21 cleared

               lda   #1
               sta   vtab
cmlp2          jsr   bascalc
               ldy   #0
cmlp1          lda   #$A0
               jsr   cout
               cpy   #80
               bne   cmlp1
               inc   vtab
               lda   vtab
               cmp   #22
               bne   cmlp2
               rts



clrflds                         ;clear specific fields display
                                ;i: vtc, entdims
                                ;o: vtc lines cleared

               ldx   #0
cflp2          lda   vtc,x
               beq   excf
               sta   vtab
               jsr   bascalc
               ldy   fhtoff     ;htab offset
cflp1          lda   #$A0
               jsr   cout
               cpy   #80
               bne   cflp1
               inx
               bne   cflp2
excf           rts



dspslot                         ;display slot
                                ;i: unit
                                ;o: message displayed

               lda   #22
               sta   vtab
               jsr   bascalc
               ldy   #0
               jsr   prmess
               asc              "slot/drive:  /"
               dfb   0
               ldy   #12
               lda   unit       ;dsss0000 .
               asl              ;sss00000 d
               asl              ;ss000000 s
               rol              ;s000000s s
               rol              ;000000ss s
               rol              ;00000sss 0
               ora   #$B0       ;10110sss (ASCII)
               jsr   cout
               iny
               lda   unit       ;dsss0000
               bmi   dss1
               lda   #"1"
               bne   dss2
dss1           lda   #"2"
dss2           jsr   cout
               rts



vgetdir                         ;get directory and verify as ProDOS
                                ;i: unit, block
                                ;o: directory in buffer, offl, maxpg
               jsr   getdir
               bcc   vdx        ;branch if is ProDOS (offl set up)
               jsr   ttlhome
               lda   #8
               sta   vtab
               jsr   bascalc
               ldy   #0
               jsr   prmess
               asc              "This doesn't look like a ProDOS directory."
               dfb   0
               jsr   waitkey
vdx            rts



getdir                          ;get directory
                                ;i: unit, block
                                ;o: directory in buffer
                                ;   offl, maxpg
                                ;if c set, then error (offl not output)
               jsr   clrerr
               jsr   readdir
               bcs   gder       ;error

               lda   bufraddr+1
               sta   maxpg
               lda   #bufrpg
               sta   addr+1

               ldy   #0         ;check ptr to previous block
               lda   (addr),y
               iny
               ora   (addr),y
               bne   gder       ;if not $0000 then not ProDOS dir

               ldy   #4         ;check storage type of dir header
               lda   (addr),y
               cmp   #$E0
               blt   gder       ;if not $E or $F then not ProDOS dir

               ldy   #$23       ;check entry length
               lda   (addr),y
               sta   asto       ;save it
               cmp   #$27
               bne   gder       ;if not $27 then not ProDOS dir

               iny              ;check entries per block
               lda   (addr),y
               cmp   #$D
               bne   gder       ;if not $D then not ProDOS dir

               jsr   setoffl    ;set up offset list
               clc
               rts

gder           sec
               rts              ;error (exit with carry set)



setoffl                         ;set up offset list
                                ;i: asto (entry length), a (entries per block)
                                ;o: offln, offl
               tax
               dex
               stx   offln
               ldy   #0
               lda   #4
               sta   offll,y
               sta   addr
               lda   #0
               sta   offlh,y
               sta   addr+1
               clc
gdlp1          iny
               lda   addr
               adc   asto       ;(carry already clear)
               sta   addr
               sta   offll,y
               lda   addr+1
               adc   #0         ;(clears carry)
               sta   addr+1
               sta   offlh,y
               dex
               bne   gdlp1
               rts



readdir                         ;read directory
                                ;i: unit, block
                                ;o: C: "an error occured"
                                ;   if C:     A: ProDOS error number
                                ;   if not C: directory blocks in buffer
                                ;             buffer begins page bufrpg
                                ;verifies as ProDOS
               lda   #0
               sta   bufraddr
               sta   addr
               lda   #bufrpg
               sta   bufraddr+1
               sta   addr+1
rdlp1          jsr   mli
               dfb   read_block
               da    parms
               bcs   exrd
               ldy   #$02
               lda   (addr),y
               sta   block
               php              ;remember if equal
               iny
               lda   (addr),y
               sta   block+1
               bne   rds2
               plp
               bne   rds3
exrd           rts              ;(with c clear or set from mli read_block)
rds2           plp
rds3           lda   bufraddr+1
               adc   #02        ;(carry clear from mli read_block)
               sta   bufraddr+1
               sta   addr+1
               bne   rdlp1      ;bra



filemenu                        ;display file menu
                                ;i: directory in buffer
                                ;   dirdims, offl, maxpg
                                ;o: menu displayed, commands executed

               clc
               lda   dirdims    ;top
               adc   dirdims+1  ;bottom
               lsr
               sta   invvt
               sec
               sbc   dirdims
               sta   topn
               lda   #0         ;set current values for file 0 (dir. header)
               sta   curi
               sta   curoff
               lda   #bufrpg
               sta   curpg
fmdsp          jsr   dspfwin    ;display file window
               jsr   entrysub   ;subroutine performed for each file
fmfet          jsr   fetch
               jmp   fmexec     ;routines can return to fmdsp or fmfet



dspfwin                         ;display file window
                                ;i: curi, curpg, curoff
                                ;o: files displayed

               lda   curi
               cmp   topn
               bcs   dws1       ;if curi >= topn (norm top), then branch
               sec
               lda   invvt
               sbc   curi
               dfb   dec
               sta   vtab
               jsr   bascalc
               ldy   dirdims+2  ;left
               tya
               clc
               adc   #$0F
               sta   asto
dwlp5          lda   #$A0
               jsr   cout
               cpy   asto
               bne   dwlp5
               inc   vtab
               ldx   #0
               ldy   #bufrpg
               bne   dwlp4      ;bra
dws1           lda   dirdims    ;top
               sta   vtab
               lda   #0
               sta   asto       ;number of blocks earlier for top file
               ldy   curpg
               lda   curoff
               sbc   topn
               tax
               bcs   dwlp4      ;if topn <= curoff, then branch
dwlp1          inc   asto
               adc   offln
               dfb   inc
               clc
               bmi   dwlp1      ;if didn't add enough, add more
               tax              ;offset in offl for top file
               asl   asto       ;calc number to subtract from curpg
               sec
               lda   curpg
               sbc   asto
               tay
dwlp4          jsr   dspflin
               cpx   offln
               bne   dws6
               ldx   #$FF
               cpy   maxpg
               bne   dws4
               inc   vtab
               jsr   bascalc
               lda   dirdims+1  ;bottom
               cmp   vtab
               bcc   exdw
               lda   dirdims+2  ;left
               tay
               adc   #$0E       ;add $F
               sta   asto
dwlp6          lda   #$A0
               jsr   cout
               cpy   asto
               bne   dwlp6
               beq   exdw
dws4           iny
               iny
dws6           inx
               inc   vtab
               lda   dirdims+1  ;bottom
               cmp   vtab
               bcs   dwlp4
exdw           rts



dspflin                         ;display file line
                                ;i: x: curoff for file to display
                                ;   y: curpg for file to display
                                ;   vtab, offl
                                ;o: one line displayed
                                ;all inputs preserved

               dfb   phx
               dfb   phy
               lda   offll,x
               sta   dwlda1+1
               sta   dwlda2+1
               clc
               tya
               adc   offlh,x
               sta   dwlda1+2
               sta   dwlda2+2
               lda   vtab
               cmp   invvt
               php              ;remember if inv
               bne   dws3
               lda   #$7F
               sta   invmask
dws3           jsr   bascalc
               ldy   dirdims+2  ;left
               ldx   #0
dwlda1         lda   $FFFF,x    ;storage type/name length
               and   #$0F       ;....1111
               beq   dwlp3
               sta   asto       ;length (offset of last letter from (addr))
dwlp2          inx
dwlda2         lda   $FFFF,x
               jsr   cout
               cpx   asto
               bne   dwlp2
               beq   dws5
dwlp3          lda   #$A0
               jsr   cout
               inx
dws5           cpx   #$0F
               bne   dwlp3
               plp              ;recall if inv
               bne   dws2
               lda   #$FF
               sta   invmask
dws2           dfb   ply
               dfb   plx
               rts



fmexec                          ;execute routine for filemenu commands
                                ;i: A: keypress
                                ;o: command executed

               cmp   #$88       ;<left-arrow>
               bne   fms1
               jsr   fmup
               jmp   fmdsp
fms1           cmp   #$8B       ;<up-arrow>
               bne   fms2
               jsr   fmup
               jmp   fmdsp
fms2           cmp   #$95       ;<right-arrow>
               bne   fms3
               jsr   fmdw
               jmp   fmdsp
fms3           cmp   #$8A       ;<down-arrow>
               bne   fms4
               jsr   fmdw
               jmp   fmdsp
fms4           cmp   #"S"
               bne   fms5
               jsr   slot
               jsr   vgetdir
               jmp   filemenu
fms5           cmp   #$9B       ;<esc>
               bne   fms6
               jmp   exit
fms6           cmp   #"C"
               bne   fms7
               jsr   clrmid
               lda   #2
               sta   block
               lda   #0
               sta   block+1
               jsr   vgetdir
               jmp   filemenu
fms7           cmp   #","
               bne   fms8
               jsr   superdir
               jsr   clrmid
               jsr   vgetdir
               jmp   filemenu
fms8           cmp   #"."
               bne   fms9
               jsr   subdir
               jsr   clrmid
               jsr   vgetdir
               jmp   filemenu
fms9           cmp   #$8D       ;<return>
               bne   fms10
               jsr   edit
               jmp   fmfet
fms10
               jmp   fmfet



fmup           lda   curi
               bne   fus2
               jmp   fmfet
fus2           dec   curi
               lda   curoff
               bne   fus1
               dec   curpg
               dec   curpg
               lda   offln
               dfb   inc
fus1           dfb   dec
               sta   curoff
               rts



fmdw           lda   curoff
               cmp   offln
               bne   fds1
               lda   curpg
               cmp   maxpg
               bne   fds2
               jmp   fmfet
fds2           inc   curpg
               inc   curpg
               lda   #$FF
fds1           dfb   inc
               sta   curoff
               inc   curi
               rts



superdir       lda   #0
               sta   addr
               lda   #bufrpg
               sta   addr+1
               ldy   #$4
               lda   (addr),y
               and   #$F0
               cmp   #$E0
               beq   spds1
               jmp   fmfet
spds1          ldy   #$27
               lda   (addr),y   ;superdir pointer
               sta   block
               iny
               lda   (addr),y
               sta   block+1
               rts



subdir
               ldy   #0
               lda   (curaddr),y
               and   #$F0
               cmp   #$D0
               beq   sbds1
               jmp   fmfet
sbds1          ldy   #$11
               lda   (curaddr),y ;key block pointer
               sta   block
               iny
               lda   (curaddr),y
               sta   block+1
               rts



edit                            ;edit command
                                ;i: curpg, curoff, curi
                                ;use curoff and curpg to calc curaddr
               ldx   curoff
               lda   offll,x
               sta   curaddr
               clc
               lda   curpg
               adc   offlh,x
               sta   curaddr+1

               lda   #0
               sta   asto       ;current field number

edl            jsr   ecout      ;output edit cursor
edrefet        jsr   fetch
               cmp   #$88       ;<left>
               bne   eds1
               jsr   ecup
               jmp   edl
eds1           cmp   #$8B       ;<up>
               bne   eds2
               jsr   ecup
               jmp   edl
eds2           cmp   #$8A       ;<down>
               bne   eds3
               jsr   ecdw
               jmp   edl
eds3           cmp   #$95       ;<right>
               bne   eds4
               jsr   ecdw
               jmp   edl
eds4           cmp   #$8D       ;<return>
               bne   eds5
               lda   asto
               pha
               jsr   workfld
               pla
               sta   asto
               jmp   edrefet
eds5           cmp   #$9B       ;<esc>
               bne   edrefet
               jsr   ecoff
               rts



ecdw                            ;move edit cursor down
                                ;i: asto (ec), curi, curaddr
               jsr   ecoff
               inc   asto
               lda   curi
               bne   ecds1
               ldy   #0
               lda   (curaddr),y ;st/nl
               and   #%11110000
               cmp   #%11110000
               bne   ecds1
               lda   asto
               cmp   #$0C
               blt   exed
               bge   ecds3
ecds1          lda   asto
               cmp   #$0D
               blt   exed
ecds3          lda   #0
               sta   asto
exed           rts



ecup                            ;move edit cursor up
                                ;i: asto (ec), curi, curaddr
               jsr   ecoff
               dec   asto
               bpl   exeu
               lda   curi
               bne   ecus1
               ldy   #0
               lda   (curaddr),y ;st/nl
               and   #%11110000
               cmp   #%11110000
               bne   ecus1
               lda   #$0B
               bne   ecus2
ecus1          lda   #$0C
ecus2          sta   asto
exeu           rts



ecout                           ;output edit cursor
               lda   #%01111111
               sta   invmask



ecoff                           ;turn off edit cursor (also used by ecout)
                                ;i: asto (current field #), curi, curaddr
               ldx   asto
               lda   curi
               bne   ecos1
               ldy   #0
               lda   (curaddr),y ;st/nl
               and   #%11110000
               cmp   #%11110000
               bne   ecos2
               lda   volflds,x
               jmp   ecos3
ecos2          lda   subflds,x
               jmp   ecos3
ecos1          lda   filflds,x
ecos3          tax
               lda   fvt,x
               sta   vtab
               jsr   bascalc
               txa
               asl
               tax
               lda   fieldtbl,x
               sta   addr
               inx
               lda   fieldtbl,x
               sta   addr+1
               ldy   fhtoff
               jsr   prstr
               lda   #%11111111
               sta   invmask
               rts



workfld                         ;work on a field
                                ;i: a (fld #), curi, curaddr
                                ;o: dest: asto
               tax
               lda   curi
               bne   wfs1
               ldy   #0
               lda   (curaddr),y ;st/nl
               and   #%11110000
               cmp   #%11110000
               bne   wfs2
               lda   volflds,x
               jmp   wfs3
wfs2           lda   subflds,x
               jmp   wfs3
wfs1           lda   filflds,x
wfs3           tax
               asl
               adc   #<wftbl
               sta   wfj+1
               lda   #0
               adc   #>wftbl
               sta   wfj+2
wfj            jmp   ($FFFF)    ;execute proper work routine:

wftbl          da    wfst,wfnl,wfnam,wftyp,wfkb,wfbu,wflen,wfcre,wfver,wfacc
               da    wfaux,wfmod,wfhdb,wfres,wfenl,wfepb,wfflc,wfbit,wfbpv
               da    wfpbk,wfpen,wfpel



                                ;the work routines
                                ;i: curaddr, x (fld #)

                                ;$xx
wfenl
               ldy   #$1F
               bne   wf0
wfepb
               ldy   #$20
               bne   wf0
wfpen
               ldy   #$25
               bne   wf0
wfpel
               ldy   #$26
wf0            tya
               pha
               lda   (curaddr),y
               ldy   fht,x
               iny
               jsr   gethex1
               pla
               tay
               lda   asto
               sta   (curaddr),y
               rts

                                ;$xxxx
wfkb
               ldy   #$11
               jmp   wf1
wfbu
               ldy   #$13
               jmp   wf1
wfaux
               ldy   #$1F
               jmp   wf1
wfflc
               ldy   #$21
               jmp   wf1
wfbit
wfpbk
               ldy   #$23
               jmp   wf1
wfhdb
wfbpv
               ldy   #$25
wf1            tya
               pha
               lda   (curaddr),y
               sta   asto2
               iny
               lda   (curaddr),y
               sta   asto
               ldy   fht,x
               iny
               jsr   gethex2
               pla
               tay
               lda   asto2
               sta   (curaddr),y
               iny
               lda   asto
               sta   (curaddr),y
               rts

                                ;$xxxxxx
wflen          ldy   #$15
               lda   (curaddr),y
               sta   asto3
               iny
               lda   (curaddr),y
               sta   asto2
               iny
               lda   (curaddr),y
               sta   asto
               ldy   fht,x
               iny
               jsr   gethex3
               ldy   #$15
               lda   asto3
               sta   (curaddr),y
               iny
               lda   asto2
               sta   (curaddr),y
               iny
               lda   asto
               sta   (curaddr),y
               rts

                                ;xxxxxxxxxxxxxxxx
wfres
               lda   fht,x
               sta   asto       ;orig htab
               sta   htab       ;current htab
               clc
               adc   #$E        ;max htab
               sta   asto3
               ldy   #$10       ;orig offset
               sty   asto2      ;current offset

wf3dsp         jsr   wf3cout    ;output cursor
wf3fet         jsr   fetch
wf3exe         cmp   #$8D       ;<return>
               bne   wf3s2
wf3s3          jmp   wf3coff    ;turn off cursor and exit
wf3s2          cmp   #$9B       ;<esc>
               beq   wf3s3
               cmp   #$88       ;<left>
               bne   wf3s4
               jsr   wf3coff
               dec   htab
               dec   htab
               dec   asto2
               lda   asto2
               cmp   #$10
               blt   wf3s6
               jmp   wf3dsp
wf3s6          lda   #$17
               sta   asto2
               lda   asto3
               sta   htab
               jmp   wf3dsp
wf3s4          cmp   #$95       ;<right>
               bne   wf3s5
wf3rt          jsr   wf3coff
               inc   htab
               inc   htab
               inc   asto2
               lda   asto2
               cmp   #$18
               bge   wf3s7
               jmp   wf3dsp
wf3s7          lda   #$10
               sta   asto2
               lda   asto
               sta   htab
               jmp   wf3dsp
wf3s5          cmp   #"0"
               bge   wf3s8
               jmp   wf3fet
wf3s8          cmp   #"9"+1
               blt   wf3s1
               cmp   #"F"+1
               blt   wf3s9
               jmp   wf3fet
wf3s9          cmp   #"A"
               bge   wf3s10
               jmp   wf3fet
wf3s10         sbc   #7
wf3s1          asl
               asl
               asl
               asl              ;move to high order nibble
               ldy   asto2
               sta   (curaddr),y
               jsr   wf3cout
               jsr   fetch
               cmp   #"0"
               blt   wf3s11
               cmp   #"9"+1
               blt   wf3s12
               cmp   #"F"+1
               bge   wf3s11
               cmp   #"A"
               bge   wf3s13
wf3s11         jmp   wf3exe
wf3s13         sbc   #7
wf3s12         ldy   asto2
               and   #%00001111
               ora   (curaddr),y
               sta   (curaddr),y
               jmp   wf3rt

wf3cout                         ;output cursor for wf3
                                ;i: htab, asto2
               lda   #%01111111
               sta   invmask
wf3coff                         ;turn off cursor for wf3
               ldy   asto2
               lda   (curaddr),y
               ldy   htab
               jsr   aout
               lda   #%11111111
               sta   invmask
               rts

                                ;xx --> xx
wfver
               txa
               pha
               ldy   #$1C
               lda   (curaddr),y
               ldy   fht,x
               jsr   gethex1
               ldy   #$1C
               lda   asto
               sta   (curaddr),y
               iny
               pla
               tax
               lda   fht,x
               clc
               adc   #7
               tax
               lda   (curaddr),y
               pha
               txa
               tay
               pla
               jsr   gethex1
               ldy   #$1D
               lda   asto
               sta   (curaddr),y
               rts

                                ;$xxxx $xxxx <date/time>
wfcre
wfmod

                                ;$x <storagetype>
wfst
               ldy   #0
               lda   (curaddr),y
               lsr
               lsr
               lsr
               lsr
               sta   asto       ;current storage type (low order nibble)
               ldy   fht,x
               sty   htab
               lda   #%10000000
               sta   asto2      ;invert nibble in wf6out
wf6dsp         ldy   htab
               jsr   wf6out
wf6fet         jsr   fetch
               cmp   #$88       ;<left>
               bne   wf6s1
wf6lf          lda   asto
               sbc   #1
               and   #%00001111 ;so that dec to $FF becomes $0F
               sta   asto
               jmp   wf6dsp
wf6s1          cmp   #$95       ;<right>
               bne   wf6s2
wf6rt          lda   asto
               adc   #0         ;add 1
               and   #%00001111 ;so that inc to $10 becomes $00
               sta   asto
               jmp   wf6dsp
wf6s2          cmp   #$8B       ;<up>
               beq   wf6rt
               cmp   #$8A       ;<down>
               beq   wf6lf
               cmp   #$8D       ;<return>
               bne   wf6s5
               lda   asto
               asl
               asl
               asl
               asl
               sta   asto2
               ldy   #0
               lda   (curaddr),y
               and   #%00001111 ;name length
               ora   asto2      ;ssssnnnn
               sta   (curaddr),y
wf6x           ldy   htab
               lda   #0
               sta   asto2
               jmp   wf6out
wf6s5          cmp   #$9B       ;<esc>
               bne   wf6s6
               ldy   #0
               lda   (curaddr),y
               lsr
               lsr
               lsr
               lsr
               sta   asto
               jmp   wf6x
wf6s7          jmp   wf6fet
wf6s6          cmp   #"0"
               blt   wf6s7
               cmp   #"F"+1
               bge   wf6s7
               cmp   #"9"+1
               blt   wf6s8
               cmp   #"A"
               blt   wf6s7
               sbc   #7
wf6s8          and   #%00001111
               sta   asto
               jmp   wf6dsp

wf6out                          ;output $x  <storagetype>
                                ;i: asto (st. typ: low nibble), bas,y
                                ;   asto2 (x.......: invert nibble?)
               lda   #"$"
               jsr   cout
               lda   asto2
               bpl   wf6os1
               lda   #%01111111
               sta   invmask
wf6os1         lda   asto
               jsr   nibout
               lda   #$FF
               sta   invmask
               iny
               iny
               lda   asto
               asl
               tax
               lda   sttbl,x
               php
               sta   addr
               inx
               lda   sttbl,x
               bne   wf6os2
               plp
               bne   wf6os3
               beq   wf6os4     ;don't print st if addr is 0
wf6os2         plp
wf6os3         sta   addr+1
               jsr   prstr
wf6os4         lda   #$A0
               jsr   cout
               cpy   #80
               blt   wf6os4
               rts

                                ;$x (w/ underline for name)
wfnl

                                ;ccccccccccccccc  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
wfnam

                                ;$xx <filetype>
wftyp

                                ;$xx  dnb000wr
wfacc
               ldy   #$1E
               lda   (curaddr),y
               sta   asto       ;current access code
               lda   fht,x
               sta   htab       ;htab of beginning of field
               lda   #%10000000
               sta   asto2      ;current cursor mask
wf10dsp        jsr   wf10out
wf10fet        jsr   fetch
               cmp   #"1"
               bne   wf10s1
wf10s3         lda   asto2
               ora   asto       ;turn on bit
               sta   asto
               jmp   wf10rt
wf10s1         cmp   #"0"
               bne   wf10s2
wf10s4         lda   asto2
               eor   #%11111111
               and   asto       ;turn off bit
               sta   asto
               jmp   wf10rt
wf10s2         cmp   #$8B       ;<up>
               beq   wf10s3
               cmp   #$8A       ;<down>
               beq   wf10s4
               cmp   #$A0       ;<space>
               bne   wf10s8
               lda   asto2
               eor   asto       ;negate bit
               sta   asto
               jmp   wf10dsp
wf10s8         cmp   #$88       ;<left>
               bne   wf10s5
               lda   asto2
               asl
               adc   #0
               sta   asto2
               jmp   wf10dsp
wf10s5         cmp   #$95       ;<right>
               bne   wf10s6
wf10rt         lda   asto2
               lsr
               bne   wf10s5a
               ror
wf10s5a        sta   asto2
               jmp   wf10dsp
wf10s6         cmp   #$8D       ;<return>
               bne   wf10s7
               ldy   #$1E
               lda   asto
               sta   (curaddr),y
wf10x          lda   #0
               sta   asto2
               jmp   wf10out
wf10s7         cmp   #$9B       ;<esc>
               bne   wf10s9
               ldy   #$1E
               lda   (curaddr),y
               sta   asto
               jmp   wf10x
wf10s9         jmp   wf10fet

wf10cds0       asc              "dnb000rw"
wf10cds1       asc              "DNB111RW"
wf10out                         ;output "$xx  dnb000wr" (w/ caps, inv cursor)
                                ;i: asto (access code), asto2 (cc mask),htab,bas
                                ;o: pres: asto,-2,htab dest:asto3,y,x
               ldy   htab
               lda   #"$"
               jsr   cout
               lda   asto
               jsr   aout
               iny
               iny
               ldx   #0
               lda   #%10000000
               sta   asto3      ;current bit
wf10ol         lda   asto2
               and   asto3
               beq   wf10os1    ;if cursor's not on this bit then don't invert
               lda   #%01111111 ;inverse
               sta   invmask
wf10os1        lda   asto
               and   asto3
               beq   wf10os2    ;if this bit is off
               lda   wf10cds1,x
               bne   wf10os3
wf10os2        lda   wf10cds0,x
wf10os3        jsr   cout
               lda   #$FF
               sta   invmask
               inx
               lsr   asto3
               bne   wf10ol
               rts



gethex1                         ;get 1 hex byte
                                ;i: bas, y (scrn pos);a (starting value)
                                ;o: asto
               pha
               sta   asto
               sty   htab
               lda   #%01111111
               sta   invmask
gh1dsp         lda   asto
               ldy   htab
               jsr   aout
gh1fet         jsr   fetch
               cmp   #$8D       ;<return>
               beq   exgh1
               cmp   #$9B       ;<esc>
               beq   gh1esc
               cmp   #$FF       ;<delete>
               bne   gh1s
               lsr   asto
               lsr   asto
               lsr   asto
               lsr   asto
               jmp   gh1dsp
gh1esc         pla
               sta   asto
               dfb   bit        ;absorb pla
exgh1          pla
               lda   #$FF
               sta   invmask
               lda   asto
               ldy   htab
               jsr   aout
               rts
gh1s           cmp   #"0"
               blt   gh1fet
               cmp   #"9"+1
               blt   gh1s1
               cmp   #"A"
               blt   gh1fet
               cmp   #"F"+1
               bge   gh1fet
               sbc   #6         ;sub 7
gh1s1          asl
               asl
               asl
               asl              ;forget high nibble
               asl
               rol   asto
               asl
               rol   asto
               asl
               rol   asto
               asl
               rol   asto
               jmp   gh1dsp



gethex2                         ;get 2 hex bytes
                                ;i: bas, y (scrn pos);asto,-2 (starting value)
                                ;o: asto, asto2
               lda   asto
               pha              ;save asto for end
               lda   asto2
               pha              ;save asto2 for end
               sty   htab       ;htab := starting htab
               lda   #%01111111 ;inverse
               sta   invmask
gh2dsp         lda   asto
               ldy   htab
               jsr   aout
               lda   asto2
               jsr   aout
gh2fet         jsr   fetch
               cmp   #$8D       ;<return>
               beq   exgh2
               cmp   #$9B       ;<esc>
               beq   gh2esc
               cmp   #$FF       ;<delete>
               bne   gh2s
               lsr   asto
               ror   asto2
               lsr   asto
               ror   asto2
               lsr   asto
               ror   asto2
               lsr   asto
               ror   asto2
               jmp   gh2dsp
gh2esc         pla
               sta   asto2
               pla
               sta   asto
               dfb   $2C        ;bit abs (absorb pla pla)
exgh2          pla
               pla
               lda   #$FF
               sta   invmask
               lda   asto
               ldy   htab
               jsr   aout
               lda   asto2
               jsr   aout
               rts
gh2s           cmp   #"0"
               blt   gh2fet
               cmp   #"9"+1
               blt   gh2s1
               cmp   #"A"
               blt   gh2fet
               cmp   #"F"+1
               bge   gh2fet
               sbc   #6         ;sub 7
gh2s1          asl
               asl
               asl
               asl              ;forget high nibble
               asl
               rol   asto2
               rol   asto
               asl
               rol   asto2
               rol   asto
               asl
               rol   asto2
               rol   asto
               asl
               rol   asto2
               rol   asto
               jmp   gh2dsp



gethex3                         ;get 3 hex bytes
                                ;i: bas, y (scrn pos);asto,-2,-3(start value)
                                ;o: asto, asto2, asto3
               lda   asto
               pha              ;save asto for end
               lda   asto2
               pha              ;save asto2 for end
               lda   asto3
               pha
               sty   htab       ;htab := starting htab
               lda   #%01111111 ;inverse
               sta   invmask
gh3dsp         lda   asto
               ldy   htab
               jsr   aout
               lda   asto2
               jsr   aout
               lda   asto3
               jsr   aout
gh3fet         jsr   fetch
               cmp   #$8D       ;<return>
               beq   exgh3
               cmp   #$9B       ;<esc>
               beq   gh3esc
               cmp   #$FF       ;<delete>
               bne   gh3s
               lsr   asto
               ror   asto2
               ror   asto3
               lsr   asto
               ror   asto2
               ror   asto3
               lsr   asto
               ror   asto2
               ror   asto3
               lsr   asto
               ror   asto2
               ror   asto3
               jmp   gh3dsp
gh3esc         pla
               sta   asto3
               pla
               sta   asto2
               pla
               sta   asto
               jmp   gh3s2
exgh3          pla
               pla
               pla
gh3s2          lda   #$FF
               sta   invmask
               lda   asto
               ldy   htab
               jsr   aout
               lda   asto2
               jsr   aout
               lda   asto3
               jsr   aout
               rts
gh3s           cmp   #"0"
               blt   gh3fet
               cmp   #"9"+1
               blt   gh3s1
               cmp   #"A"
               blt   gh3fet
               cmp   #"F"+1
               bge   gh3fet
               sbc   #6         ;sub 7
gh3s1          asl
               asl
               asl
               asl              ;forget high nibble
               asl
               rol   asto3
               rol   asto2
               rol   asto
               asl
               rol   asto3
               rol   asto2
               rol   asto
               asl
               rol   asto3
               rol   asto2
               rol   asto
               asl
               rol   asto3
               rol   asto2
               rol   asto
               jmp   gh3dsp



entrysub                        ;subroutine performed for each file in menu
                                ;i: curi, curpg, curoff

               ldx   curoff
               lda   offll,x
               sta   curaddr
               clc
               lda   curpg
               adc   offlh,x
               sta   curaddr+1
               lda   curi
               bne   ess2
               ldy   #0
               lda   (curaddr),y ;storage type/name length
               and   #$F0       ;1111....
               cmp   #$F0       ;volume directory header
               bne   ess1
               jsr   prvolfs    ;print volume fields
               jsr   dspvf
               rts
ess1           jsr   prsubfs    ;print sub fields
               jsr   dspsf
               rts
ess2           jsr   prfilfs    ;print file fields
               jsr   dspff
               rts



prfilfs        cmp   #1         ;if not first entry, then don't reprint fields
               bne   pfs1
               jsr   clrflds
               lda   #0
               sta   asto       ;current offset in filflds
pflp1          ldx   asto
               lda   filflds,x  ;field #
               tax
               lda   fvt,x      ;field vtab
               sta   vtab
               jsr   bascalc
               txa              ;field #
               asl
               tax
               lda   fieldtbl,x
               sta   addr
               inx
               lda   fieldtbl,x
               sta   addr+1
               ldy   fhtoff
               jsr   prstr
               lda   #":"
               jsr   cout
               inc   asto
               lda   asto
               cmp   #$0D       ;number of fields in filflds
               bne   pflp1
pfs1           rts



prvolfs        jsr   clrflds
               lda   #0
               sta   asto
pvlp1          ldx   asto
               lda   volflds,x  ;field #
               tax
               lda   fvt,x      ;field vtab
               sta   vtab
               jsr   bascalc
               txa              ;field #
               asl
               tax
               lda   fieldtbl,x
               sta   addr
               inx
               lda   fieldtbl,x
               sta   addr+1
               ldy   fhtoff     ;htab offset
               jsr   prstr
               lda   #":"
               jsr   cout
               inc   asto
               lda   asto
               cmp   #$0C
               bne   pvlp1
               rts



prsubfs        jsr   clrflds
               lda   #0
               sta   asto
pslp1          ldx   asto
               lda   subflds,x  ;field #
               tax
               lda   fvt,x      ;field vtab
               sta   vtab
               jsr   bascalc
               txa              ;field #
               asl
               tax
               lda   fieldtbl,x
               sta   addr
               inx
               lda   fieldtbl,x
               sta   addr+1
               ldy   fhtoff     ;htab offset
               jsr   prstr
               lda   #":"
               jsr   cout
               inc   asto
               lda   asto
               cmp   #$0D
               bne   pslp1
               rts



dspff                           ;display file fields

               jsr   dspfsa
               jsr   dspfsb
               jsr   dspfsc
               jsr   dspfsd
               rts



dspvf                           ;display volume fields

               jsr   dspfsa
               jsr   dspfse
               jsr   dspfsc
               jsr   dspfsf
               jsr   dspfsg
               rts



dspsf                           ;display sub fields

               jsr   dspfsa
               jsr   dspfse
               jsr   dspfsc
               jsr   dspfsf
               jsr   dspfsh
               rts



setfpos                         ;set field cursor position
                                ;i: x: field #
                                ;o: bas, a: htab

               lda   fvt,x
               sta   vtab
               jsr   bascalc
               lda   fht,x
               rts



dspfsa                          ;display field section a

               ldy   #0         ;st
               lda   (curaddr),y
               pha              ;save for nl
               lsr
               lsr
               lsr
               lsr              ;....ssss
               sta   asto
               ldx   #0
               jsr   setfpos
               tay
               lda   #0
               sta   asto2      ;don't invert nibble
               jsr   wf6out
               jmp   xxxxxx     ;old stuff:
               lda   #"$"
               jsr   cout
               sty   asto
               ldy   #0
               lda   (curaddr),y ;st/nl
               pha              ;save for nl
               and   #%11110000 ;st
               lsr
               lsr
               lsr              ;...ssss. (st*2) for tbl
               pha              ;save st*2
               lsr              ;....ssss
               ldy   asto
               jsr   nibout
               lda   #$A0
               jsr   cout
               lda   #$A0
               jsr   cout
               pla              ;st*2
               tax
               lda   sttbl,x
               php
               sta   addr
               inx
               lda   sttbl,x
               bne   sts1
               plp
               bne   sts2
               beq   stlp1      ;don't print st if addr is 0
sts1           plp
sts2           sta   addr+1
               jsr   prstr
stlp1          lda   #$A0
               jsr   cout
               cpy   #80
               bne   stlp1
xxxxxx
                                ;nl
               ldx   #1
               jsr   setfpos
               tay
               lda   #"$"
               jsr   cout
               pla              ;st/nl
               and   #%00001111 ;nl
               jsr   nibout
                                ;name
               ldx   #2
               jsr   setfpos
               tay
               pha              ;save
               lda   curaddr
               sta   namelda+1
               sta   namelda2+1
               lda   curaddr+1
               sta   namelda+2
               sta   namelda2+2
               ldx   #1         ;special self-mod routine for name (use x indx)
namelda        lda   $FFFF,x
               jsr   cout
               inx
               cpx   #$10
               bne   namelda
               iny
               iny
               ldx   #1
namelda2       lda   $FFFF,x
               jsr   aout
               inx
               cpx   #$10
               bne   namelda2
                                ;name underline
               inc   vtab
               jsr   bascalc
               ldy   #0
               lda   (curaddr),y
               and   #$0F       ;nl
               sta   asto
               pla              ;htab
               tay
               ldx   asto
               beq   names1
namelp1        lda   #"L"
               jsr   mout       ;high underline
               dex
               bne   namelp1
names1         sec
               lda   #$0F
               sbc   asto
               beq   names2
               tax
namelp2        lda   #$A0
               jsr   cout
               dex
               bne   namelp2
names2         rts



hexbtout                        ;output hex byte ("$FF")
                                ;i: x, y
                                ;o: message

               lda   (curaddr),y
               pha
               jsr   setfpos
               tay
               lda   #"$"
               jsr   cout
               pla
               jsr   aout
               rts



hexwdout                        ;output hex word ("$FFFF")
                                ;i: y: for lda (curaddr),y
                                ;   x: fldstr #
                                ;o: message

               lda   (curaddr),y
               pha
               iny
               jsr   hexbtout
               pla
               jsr   aout
               rts



dspfsb                          ;display field section b

               ldy   #$10
               lda   (curaddr),y
               sta   asto
               ldx   #3
               jsr   hexbtout
               iny
               iny
               tya
               pha
               ldx   #0
tplp1          lda   typntbl,x
               beq   tps1
               inx
               cmp   asto
               bne   tplp1
               dex
               stx   asto
               txa
               asl
               clc
               adc   asto
               tax
               pla
               tay
               lda   typstbl,x
               jsr   cout
               inx
               lda   typstbl,x
               jsr   cout
               inx
               lda   typstbl,x
               bne   tps2
tps1           pla
               tay
               lda   #$A0
               jsr   cout
               lda   #$A0
               jsr   cout
               lda   #$A0
tps2           jsr   cout
               ldy   #$11       ;kb
               ldx   #4
               jsr   hexwdout
               ldy   #$13       ;bu
               ldx   #5
               jsr   hexwdout
               ldy   #$15       ;len
               lda   (curaddr),y ;lowest order of three bytes
               pha
               iny
               ldx   #6
               jsr   hexwdout
               pla
               jsr   aout
               rts



hextodec                        ;hex to dec convert
                                ;i: asto (hex)
                                ;o: addr (dec) (lo, hi)

               sed
               ldx   #7
               lda   #0
               sta   addr
               sta   addr+1
hdlp1          asl   asto
               lda   addr
               adc   addr
               sta   addr
               lda   addr+1
               adc   addr+1
               sta   addr+1
               dex
               bpl   hdlp1
               cld
               rts



dspdate                         ;display date
                                ;i: bas, y, date
                                ;o: date printed

               lsr   date+1
               lda   date
               ror
               lsr
               lsr
               lsr
               lsr
               bne   dds1
               jmp   ddx        ;if no month, then don't print anything
dds1           asl
               tax
               lda   monthtbl,x
               sta   addr
               inx
               lda   monthtbl,x
               sta   addr+1
               jsr   prstr
               lda   #$A0
               jsr   cout
               lda   date
               and   #%00011111
               sta   asto
               jsr   hextodec
               lda   addr
               lsr
               lsr
               lsr
               lsr
               beq   dds1a
               jsr   nibout
dds1a          lda   addr
               jsr   nibout
               lda   #","
               jsr   cout
               lda   #$A0
               jsr   cout
               lda   date+1
               sta   asto
               jsr   hextodec
               sed
               clc
               lda   addr+1
               adc   #$19       ;1900 (offset year)
               cld
               jsr   aout
               lda   addr
               jsr   aout
               lda   #$A0
               jsr   cout
               lda   date+3
               sta   asto
               jsr   hextodec
               lda   addr
               jsr   aout
               lda   #":"
               jsr   cout
               lda   date+2
               sta   asto
               jsr   hextodec
               lda   addr
               jsr   aout
ddx            lda   #$A0
               jsr   cout
               cpy   #80
               bne   ddx
               rts



dsphxdt                         ;display hex and date
                                ;i: x, y
                                ;o: hex & date printed

               lda   (curaddr),y
               sta   date
               iny
               lda   (curaddr),y
               sta   date+1
               iny
               lda   (curaddr),y
               sta   date+2
               iny
               lda   (curaddr),y
               sta   date+3
               jsr   setfpos
               tay
               lda   #"$"
               jsr   cout
               lda   date+1
               jsr   aout
               lda   date
               jsr   aout
               lda   #$A0
               jsr   cout
               lda   #"$"
               jsr   cout
               lda   date+3
               jsr   aout
               lda   date+2
               jsr   aout
               iny
               iny
               jsr   dspdate
               rts



dspfsc                          ;display field section c

               ldy   #$18
               ldx   #7
               jsr   dsphxdt
               ldy   #$1D       ;min
               lda   (curaddr),y
               pha
               dey
               lda   (curaddr),y ;ver
               pha
               ldx   #8
               jsr   setfpos
               tay
               pla
               jsr   aout
               lda   #$A0
               jsr   cout
               lda   #"-"
               jsr   cout
               lda   #"-"
               jsr   cout
               lda   #">"
               jsr   cout
               lda   #$A0
               jsr   cout
               pla
               jsr   aout
               ldy   #$1E
               lda   (curaddr),y ;acc
               sta   asto
               ldx   #9
               jsr   setfpos
               sta   htab
               lda   #0
               sta   asto2      ;no cursor here
               jsr   wf10out
               rts



dspfsd                          ;display field section d

               ldy   #$1F
               ldx   #$A
               jsr   hexwdout
               ldy   #$21
               ldx   #$B
               jsr   dsphxdt
               ldy   #$25
               ldx   #$C
               jsr   hexwdout
               rts



dspfse                          ;display field section e

               ldy   #$17
rvlp1          lda   (curaddr),y
               pha
               dey
               cpy   #$F
               bne   rvlp1
               ldx   #$D
               jsr   setfpos
               tay
               ldx   #8
rvlp2          pla
               jsr   aout
               dex
               bne   rvlp2
               rts



dspfsf                          ;display field section f

               ldy   #$1F
               ldx   #$E
               jsr   hexbtout
               ldy   #$20
               ldx   #$F
               jsr   hexbtout
               ldy   #$21
               ldx   #$10
               jsr   hexwdout
               rts



dspfsg                          ;display field section g

               ldy   #$23
               ldx   #$11
               jsr   hexwdout
               ldy   #$25
               ldx   #$12
               jsr   hexwdout
               rts



dspfsh                          ;display field section h

               ldy   #$23
               ldx   #$13
               jsr   hexwdout
               ldy   #$25
               ldx   #$14
               jsr   hexbtout
               ldy   #$26
               ldx   #$15
               jsr   hexbtout
               rts



slot                            ;change slot/drive
                                ;i: unit
                                ;o: unit, block := 2

               jsr   clrmid
               lda   #22
               sta   vtab
               jsr   bascalc
               ldy   #12
               lda   unit       ;dsss0000 .
               asl              ;sss00000 d
               asl              ;ss000000 s
               rol              ;s000000s s
               rol              ;000000ss s
               rol              ;00000sss 0
               ora   #$B0       ;10110sss (ASCII)
               sta   asto
               jsr   cinvout
sllp1          jsr   waitkey
               cmp   #$8D       ;<return>
               beq   exsl
               cmp   #"1"
               bcc   sllp1
               cmp   #"7"+1
               bcs   sllp1
               sta   asto       ;10110sss (ASCII)
               asl              ;0110sss0
               asl              ;110sss00
               asl              ;10sss000
               asl              ;0sss0000
               asl              ;sss00000
               asl   unit       ;sss00000 d sss00000
               ror              ;dsss0000 0 sss00000
               sta   unit
exsl           lda   asto
               dey
               jsr   cout
               lda   unit       ;dsss0000
               bmi   sls1
               lda   #"1"       ;10110001 (ASCII) d = 0 (drive 1)
               bne   sls2
sls1           lda   #"2"       ;10110010 (ASCII) d = 1 (drive 2)
sls2           iny
               sta   asto       ;101100dD (ASCII)
               jsr   cinvout
drlp1          jsr   waitkey
               cmp   #$8D       ;<return>
               beq   exdr
               cmp   #"1"
               bcc   drlp1
               cmp   #"2"+1
               bcs   drlp1
               sta   asto       ;101100dD 0 dsss0000
               asl   unit       ;101100dD d sss00000
               lsr              ;0101100d D sss00000
               lsr              ;00101100 d sss00000
               ror   unit       ;00101100 0 dsss0000
exdr           lda   asto
               dey
               jsr   cout
               lda   #2
               sta   block
               lda   #0
               sta   block+1
               rts



prstr                           ;print string
                                ;i: addr: address of beg of string
                                ;   y: htab (0 orig)
                                ;   bas
                                ;o: message printed
                                ;   y: incremented by length of str

               lda   addr
               sta   pslp+1
               lda   addr+1
               sta   pslp+2
               ldx   #0
pslp           lda   $FFFF,x
               beq   pss
               jsr   cout
               inx
               bne   pslp
pss            rts
