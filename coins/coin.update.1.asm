start
               lda  defs+0
               sta  addr
               lda  defs+1
               sta  addr+1
               ldy  #0
               lda  (addr),y
               sta  numcoins
               iny
               lda  (addr),y
               sta  numcoins+1
               lda  #0
               sta  coinnum
               sta  coinnum+1
               clc
               lda  addr
               adc  #2
               sta  coin
               lda  addr+1
               adc  #0
               sta  coin+1
               jsr  dspcoini
coinl          jsr  clrcoin
               jsr  dspcoin
refetch        jsr  fetch
               cmp  #$88       ; <left-arrow>
               bne  sc1
               jmp  prevcoin
sc1            cmp  #$8B       ; <up-arrow>
               bne  sc2
               jmp  prevcoin
sc2            cmp  #$8A       ; <down-arrow>
               bne  sc3
               jmp  nextcoin
sc3            cmp  #$95       ; <right-arrow>
               bne  sc4
               jmp  nextcoin
sc4            cmp  #$8D       ; <return>
               bne  sc5
               jmp  editcoin
sc5            cmp  #$C1       ; A
               bne  sc6
               jmp  addcoin
sc6            cmp  #$9B       ; <esc>
               bne  refetch
               jmp  exit



prevcoin       lda  coinnum
               bne  pcs1
               lda  coinnum+1
               beq  expc
pcs1           dec  coinnum
               lda  coinnum
               cmp  #$FF
               bne  pcs2
               dec  coinnum+1
pcs2           sec
               lda  coin
               sbc  #$B
               sta  coin
               lda  coin+1
               sbc  #0
               sta  coin+1
               jmp  coinl
expc           jmp  refetch



nextcoin       lda  numcoins+1
               cmp  coinnum+1
               blt  exnc
               bne  ncs1
               ldx  coinnum
               inx
               cpx  numcoins
               bge  exnc
ncs1           inc  coinnum
               bne  ncs2
               inc  coinnum+1
ncs2           clc
               lda  coin
               adc  #$B
               sta  coin
               lda  coin+1
               adc  #0
               sta  coin+1
               jmp  coinl
exnc           jmp  refetch



ecvt           hex  020506070A0D0E0F111411
echt           hex  0008080808080808070917
ecchr          hex  0000000000000000808080
eccnoff        hex  000102030704050608090A
cnoffav        hex  0102030502030506070809

editcoin       lda  #0
               sta  asto
editl          ldx  asto       ; ccpos
               lda  ecvt,x
               sta  vtab
               jsr  bc
               ldy  echt,x
               lda  ecchr,x
               bmi  ecs1
               lda  #"-"
               jsr  cout
               lda  #">"
               jsr  cout
               jmp  ecs2
ecs1           lda  #"<"
               jsr  cout
               lda  #"-"
               jsr  cout
ecs2           jsr  fetch
               cmp  #$88       ; <left-arrow>
               beq  ecsup
               cmp  #$8B       ; <up-arrow>
               beq  ecsup
               cmp  #$8A       ; <down-arrow>
               beq  ecsdw
               cmp  #$95       ; <right-arrow>
               beq  ecsdw
               cmp  #$8D       ; <return>
               beq  workfld
               cmp  #$9B       ; <esc>
               bne  ecs2
               jsr  clrec
               jmp  refetch

clrec          ldx  asto       ; clear edit cursor
               ldy  echt,x
               lda  #$A0
               jsr  cout
               lda  #$A0
               jsr  cout
               rts

ecsup          jsr  clrec
               dec  asto
               bpl  exeu
               lda  #$A
               sta  asto
exeu           jmp  editl

ecsdw          jsr  clrec
               ldx  asto
               cpx  #$A
               bne  ecds1
               ldx  #-1
ecds1          inx
               stx  asto
               jmp  editl

workfld        lda  asto
               pha
               tax
               lda  eccnoff,x
               pha
               tay
               lda  (coin),y
               tax
               lda  cnoffav,y
               jsr  fldmenu
               pla
               bcs  wfs1
               tay
               txa
               sta  (coin),y
wfs1           jsr  ttlhome
               jsr  dspcoini
               jsr  dspcoin
               pla
               sta  asto
               jmp  editl



dspcoin                        ; display a coin definition
                               ; i: coin: coin addr
                               ; o: def displayed

               lda  #2         ; denom
               sta  vtab
               jsr  bc
               ldy  #0
               lda  (coin),y
               tax
               lda  #1
               ldy  #3
               jsr  prfld
               lda  #5         ; obv subj
               sta  vtab
               jsr  bc
               ldy  #1
               lda  (coin),y
               tax
               lda  #2
               ldy  #11
               jsr  prfld
               lda  #6         ; obv insc
               sta  vtab
               jsr  bc
               ldy  #2
               lda  (coin),y
               tax
               lda  #3
               ldy  #10
               jsr  prfld
               lda  #7         ; obv dsgn
               sta  vtab
               jsr  bc
               ldy  #11
               jsr  prmess
               asc             "by "
               dfb  0
               ldy  #3
               lda  (coin),y
               tax
               lda  #5
               ldy  #14
               jsr  prfld
               lda  #10        ; edge
               sta  vtab
               jsr  bc
               ldy  #7
               lda  (coin),y
               tax
               lda  #6
               ldy  #10
               jsr  prfld
               lda  #13        ; rev subj
               sta  vtab
               jsr  bc
               ldy  #4
               lda  (coin),y
               tax
               lda  #2
               ldy  #11
               jsr  prfld
               lda  #14        ; rev insc
               sta  vtab
               jsr  bc
               ldy  #5
               lda  (coin),y
               tax
               lda  #3
               ldy  #10
               jsr  prfld
               lda  #15        ; rev dsgn
               sta  vtab
               jsr  bc
               ldy  #11
               jsr  prmess
               asc             "by "
               dfb  0
               ldy  #6
               lda  (coin),y
               tax
               lda  #5
               ldy  #14
               jsr  prfld
               lda  #18        ; weight
               sta  vtab
               jsr  bc
               ldy  #8
               lda  (coin),y
               tax
               lda  #7
               ldy  #0
               jsr  prfld
               lda  #21        ; diameter
               sta  vtab
               jsr  bc
               ldy  #$9
               lda  (coin),y
               tax
               lda  #8
               ldy  #0
               jsr  prfld
               lda  #18        ; composition
               sta  vtab
               jsr  bc
               ldy  #$A
               lda  (coin),y
               tax
               lda  #9
               ldy  #13
               jsr  prfld
               rts



prfld                          ; print individual field
                               ; i: bas, y (scrn pos)
                               ;    a:
                               ;      0 coin (***)
                               ;      1 denomination
                               ;      2 subject
                               ;      3 inscription    13 fill in date,mm(***)
                               ;      4 inscription character
                               ;      5 designer
                               ;      6 edge
                               ;      7 weight         17 w/ . g
                               ;      8 diameter       18 w/ . mm
                               ;      9 composition    19 on one line only
                               ;      A metal
                               ;    x:which one from list
                               ; !don't print past col. 80!

               cmp  #$3
               bne  pfs1
               jmp  pfa3
pfs1           cmp  #$6
               bne  pfs2
               jmp  pfa6
pfs2           cmp  #$7
               bne  pfs3
               jmp  pfa7
pfs3           cmp  #$17
               bne  pfs4
               jmp  pfa17
pfs4           cmp  #$8
               bne  pfs5
               jmp  pfa8
pfs5           cmp  #$18
               bne  pfs6
               jmp  pfa18
pfs6           cmp  #$9
               bne  pfs7
               jmp  pfa9
pfs7           cmp  #$19
               bne  pfs8
               jmp  pfa9
pfs8           sty  htab       ; for a = 1,2,4,5,A
               jsr  getaddr
               ldy  htab
               jsr  prstr
pf1s1          rts
                               ; for a = 3 "<insc-str>"
pfa3           lda  #$A2
               jsr  cout
               lda  #$3
               sty  htab
               jsr  getaddr
               ldy  htab
               jsr  pristr
               jmp  endquot
                               ; for a = 6 "<str><...>"
pfa6           lda  #$A2
               jsr  cout
               lda  #$6
               sty  htab
               jsr  getaddr
               ldy  htab
               jsr  prstr
endquot        cpy  #80
               beq  pf6s1
               lda  #$A2
               jsr  cout
pf6s1          rts
pfa7                           ; for a = 7  aa bbcc
               sty  htab
               jsr  getwtad
               ldy  #0
               lda  (addr),y
               ldy  htab
               jsr  aout
               iny
               cpy  #80
               bge  pf7s1
               sty  htab
               ldy  #1
               lda  (addr),y
               ldy  htab
               jsr  aout
               cpy  #80
               beq  pf7s1
               sty  htab
               ldy  #2
               lda  (addr),y
               ldy  htab
               jsr  aout
pf7s1          rts
pfa17                          ; for a = 17 aa.bbcc g
               sty  htab
               jsr  getwtad
               ldy  #0
               lda  (addr),y
               ldy  htab
               jsr  aout
               cpy  #80
               beq  pf17s1
               lda  #"."
               jsr  cout
               cpy  #80
               beq  pf17s1
               sty  htab
               ldy  #1
               lda  (addr),y
               ldy  htab
               jsr  aout
               cpy  #80
               beq  pf17s1
               sty  htab
               ldy  #2
               lda  (addr),y
               ldy  htab
               jsr  aout
               cpy  #80
               beq  pf17s1
               lda  #$A0
               jsr  cout
               cpy  #80
               beq  pf17s1
               lda  #"g"
               jsr  cout
pf17s1         rts
pfa8                           ; for a = 8  aa bb
               sty  htab
               jsr  getdmad
               ldy  #0
               lda  (addr),y
               ldy  htab
               jsr  aout
               iny
               cpy  #80
               beq  pf8s1
               sty  htab
               ldy  #1
               lda  (addr),y
               ldy  htab
               jsr  aout
pf8s1          rts
pfa18                          ; for a = 18 aa.bb mm
               sty  htab
               jsr  getdmad
               ldy  #0
               lda  (addr),y
               ldy  htab
               jsr  aout
               cpy  #80
               beq  pf18s1
               lda  #"."
               jsr  cout
               cpy  #80
               beq  pf18s1
               sty  htab
               ldy  #1
               lda  (addr),y
               ldy  htab
               jsr  aout
               cpy  #80
               beq  pf18s1
               lda  #$A0
               jsr  cout
               cpy  #80
               beq  pf18s1
               lda  #"m"
               jsr  cout
               cpy  #80
               beq  pf18s1
               lda  #"m"
               jsr  cout
pf18s1         rts
pfa9                           ; for a = 9,19
               asl
               asl
               asl
               pha             ; save (in bit 7) if vert or horz
               tya
               pha
               lda  #$9
               jsr  getaddr
               pla
               tay
               pla
               jsr  prcmpl
               rts



prcmpl                         ; print cmp list (clad, plat, core)
                               ; i: a (x....... horiz?)
                               ;    bas,y (scrn pos)
                               ;    (addr)--> start of list
               pha             ; save (in bit 7) if vert or horz
               sty  htab
               sty  htaborg
               ldy  #0
               lda  (addr),y
               iny
               cmp  #0
               beq  pf9s1      ; if no plat or clad, then branch
               sty  asto
               ldy  htab
               cmp  #1
               beq  pf9s2
               jsr  prmess
               asc             "plat: "
               dfb  0
               jmp  pf9s3
pf9s2          jsr  prmess
               asc             "clad: "
               dfb  0
pf9s3          sty  htab
               cpy  #80
               beq  pf9s5
               ldy  asto
               pla             ; vert or horz
               pha
               jsr  prcmp
               sty  asto
               pla
               pha
               bpl  pf9vert
                               ; horz
               ldy  htab
               cpy  #80
               beq  pf9s5
               lda  #";"
               jsr  cout
               lda  #$A0
               jsr  cout
               jmp  pf9s6
pf9vert                        ; vert
               ldy  htaborg
pf9s6          jsr  prmess
               asc             "core: "
               dfb  0
               sty  htab
               cpy  #80
               beq  pf9s5
               ldy  asto
pf9s1          pla
               jsr  prcmp
               rts
pf9s5          pla
               rts



getwtad                        ; get addr for weight
                               ; i: x (which one)
                               ; o: (addr)-->aa bb cc
                               ; dest: addr2

               clc
               lda  defs+$E
               adc  #1
               sta  addr
               lda  defs+$F
               adc  #0
               sta  addr+1
               txa
               sta  addr2
               asl
               php
               clc
               adc  addr2
               sta  addr2
               lda  #0
               adc  #0
               plp
               adc  #0
               sta  addr2+1
               clc
               lda  addr
               adc  addr2
               sta  addr
               lda  addr+1
               adc  addr2+1
               sta  addr+1
               rts



getdmad                        ; get addr for diameter
                               ; i: x (which one)
                               ; o: (addr)-->aa bb

               clc
               lda  defs+$10
               adc  #1
               sta  addr
               lda  defs+$11
               adc  #0
               sta  addr+1
               txa
               asl
               sta  addr2
               lda  #0
               adc  #0
               sta  addr2+1
               clc
               lda  addr
               adc  addr2
               sta  addr
               lda  addr+1
               adc  addr2+1
               sta  addr+1
               rts



getaddr                        ; i: a, x (as prfld)
                               ; o: addr
                               ; des: y, a, x
               asl
               tay
               clc
               lda  defs,y
               adc  #1
               sta  addr
               iny
               lda  defs,y
               adc  #0
               sta  addr+1
               txa
               asl
               tay
               lda  (addr),y
               tax
               iny
               lda  (addr),y
               sta  addr+1
               stx  addr
               rts



getfldsz                       ; get size of field
                               ; i: a (as prfld: 0-A)
                               ; o: a (size)
                               ;    for input a=0: output: x(lsb), a(msb)
                               ; dest: y, addr

               asl
               php
               tay
               lda  defs,y
               sta  addr
               iny
               lda  defs,y
               sta  addr+1
               ldy  #0
               lda  (addr),y
               plp
               bne  gfss1
               tax
               iny
               lda  (addr),y
gfss1          rts



prfnmt                         ; print fineness and metal
                               ; i: (addr),y --> ff ff mm
                               ;    bas, htab (0 <= htab <= 79)
                               ; o: pres: addr, bas
                               ;    inc: y, htab
                               ;    dest: asto, x

               iny
               lda  (addr),y
               pha
               dey
               ora  (addr),y
               bne  pfms1
               lda  #"1"
               bne  pfms2
pfms1          lda  #"0"
pfms2          sty  asto
               ldy  htab
               jsr  cout
               sty  htab
               cpy  #80
               beq  pfms4
               lda  #"."
               jsr  cout
               sty  htab
               cpy  #80
               beq  pfms4
               ldy  asto
               lda  (addr),y
               iny
               iny
               sty  asto
               ldy  htab
               jsr  aout
               sty  htab
               pla
               cpy  #80
               beq  pfms3
               jsr  aout
               sty  htab
               cpy  #80
               beq  pfms3
               lda  #$A0
               jsr  cout
               sty  htab
               cpy  #80
               beq  pfms3
               lda  addr+1
               pha
               lda  addr
               pha
               ldy  asto
               lda  (addr),y
               tax
               lda  #$A
               ldy  htab
               jsr  prfld
               sty  htab
               pla
               sta  addr
               pla
               sta  addr+1
pfms3          ldy  asto
               iny
               rts
pfms4          pla             ; abend for when y = 80
               ldy  asto
               iny
               iny
               iny
               rts



prcmp                          ; print one composition list
                               ; i: (addr),y --> # metals
                               ;    bas, htab (0 <= htab <= 79)
                               ;    a: x....... print horizontally
                               ; o: pres: addr, (h: bas, vtab) (v: htab)
                               ;    inc: y,     (h: htab)      (v: bas, vtab)
                               ;    dest: asto, asto2, x

               asl
               lda  (addr),y
               sta  asto2
               iny
               bcs  prchorz
                               ; vertical
               lda  htab
prcl1          pha
               jsr  prfnmt
               inc  vtab
               jsr  bc
               pla
               sta  htab
               dec  asto2
               bne  prcl1
               rts
                               ; horizontal
prchorz        jsr  prfnmt
               sty  asto
               dec  asto2
               beq  prcs1
               ldy  htab
               cpy  #80
               beq  prcs2
               lda  #","
               jsr  cout
               sty  htab
               cpy  #80
               beq  prcs2
               lda  #$A0
               jsr  cout
               sty  htab
               cpy  #80
               beq  prcs2
               ldy  asto
               jmp  prchorz
prcs2          ldy  asto
               jmp  prcs4
prcl3          iny
               iny
               iny
prcs4          dec  asto2
               bpl  prcl3
prcs1          rts



dspcoini                       ; init screen for dspcoin

               lda  #3
               sta  vtab
               jsr  bc
               jsr  prundl
               lda  #6
               sta  vtab
               jsr  bc
               ldy  #0
               jsr  prmess
               asc             "obverse"
               dfb  0
               lda  #8
               sta  vtab
               jsr  bc
               jsr  prundl
               lda  #10
               sta  vtab
               jsr  bc
               ldy  #0
               jsr  prmess
               asc             "edge"
               dfb  0
               lda  #11
               sta  vtab
               jsr  bc
               jsr  prundl
               lda  #14
               sta  vtab
               jsr  bc
               ldy  #0
               jsr  prmess
               asc             "reverse"
               dfb  0
               lda  #16
               sta  vtab
               jsr  bc
               jsr  prundl
               lda  #17
               sta  vtab
               jsr  bc
               ldy  #0
               jsr  prmess
               asc             "weight     composition"
               dfb  0
               inc  vtab
               jsr  bc
               ldy  #2
               lda  #"."
               jsr  cout
               ldy  #8
               lda  #"g"
               jsr  cout
               lda  #20
               sta  vtab
               jsr  bc
               ldy  #0
               jsr  prmess
               asc             "diameter"
               dfb  0
               inc  vtab
               jsr  bc
               ldy  #2
               lda  #"."
               jsr  cout
               ldy  #6
               lda  #"m"
               jsr  cout
               lda  #"m"
               jsr  cout
               rts



prundl                         ; print underline
                               ; i: bas
                               ; o: vtab, bas pres.

               ldy  #0
pull1          lda  #"_"
               jsr  cout
               cpy  #80
               bne  pull1
               rts



clrcoin                        ; clear coin definition display
                               ; i: none
                               ; o: none

               lda  #2
               sta  vtab
               jsr  bc
               ldy  #0
               jsr  esce
               ldx  #0
ccl1           lda  ccvt,x
               beq  excc
               sta  vtab
               jsr  bc
               ldy  #11
               jsr  esce
               inx
               bne  ccl1
ccvt           dfb  5,6,7,10,13,14,15,18,19,20,21,22,23,00
excc           rts



esce                           ; clear to end of line
                               ; i: bas, y (htab to clear from)
                               ; o: line cleared

               lda  #$A0
               jsr  cout
               cpy  #80
               bne  esce
               rts



pristr                         ; print inscr string
                               ; i: addr, y, bas
                               ; o: string printed

               sty  asto2
               ldy  #0
               lda  (addr),y
               sta  asto       ; length
               inc  asto
               ldy  asto2
               lda  addr
               sta  pil+1
               lda  addr+1
               sta  pil+2
               ldx  #1
pil            lda  $FFFF,x
               bmi  pis1
               stx  asto2
               tax
               lda  #4
               jsr  prfld
               ldx  asto2
               bne  pis2       ; branch always
pis1           jsr  cout
pis2           cpy  #80
               beq  expi
               inx
               cpx  asto
               bne  pil
expi           rts



prstr                          ; print string
                               ; i: addr, bas, y
                               ; o: str printed
                               ;    y inc by length of str

               lda  addr
               sta  psl+1
               lda  addr+1
               sta  psl+2
               ldx  #0
psl            lda  $FFFF,x
               beq  pss
               jsr  cout
               inx
               cpy  #80
               bne  psl
pss            rts



moveupB                        ; move block up $B bytes
                               ; i: addr: start
                               ;    addr2: end
               clc
               lda  addr2
               adc  #$B
               sta  addr3
               lda  addr2+1
               adc  #0
               sta  addr3+1
                               ; fall through to moveup



moveup                         ; move block up
                               ; i: addr-addr2 ---> -addr3
               ldy  #0
mul1           lda  (addr2),y
               sta  (addr3),y
               ldx  addr2
               bne  mus1
               dec  addr2+1
mus1           cpx  addr
               beq  mus2
mul2           dec  addr2
               lda  addr3
               bne  mus3
               dec  addr3+1
mus3           dec  addr3
               jmp  mul1
mus2           lda  addr2+1
               cpx  #0
               bne  mus4
               adc  #0         ; add 1
mus4           cmp  addr+1
               bne  mul2
               rts



incadb                         ; inc address block by addr2
                               ; i: (addr)--> len byte starting block
                               ;    addr2 (number to add to each address
                               ;          in block)
               ldy  #0
               lda  (addr),y
               beq  exiab
               asl
               sta  asto
               inc  asto
               iny
iabl1          clc
               lda  (addr),y
               adc  addr2
               sta  (addr),y
               iny
               lda  (addr),y
               adc  addr2+1
               sta  (addr),y
               iny
               cpy  asto
               bne  iabl1
exiab          rts



addcoin        lda  defs+$2
               sta  addr
               lda  defs+$3
               sta  addr+1
               lda  defs+$16
               sta  addr2
               lda  defs+$17
               sta  addr2+1
               jsr  moveupB

               ldy  #$A
acl1           lda  (coin),y
               sta  (addr),y
               dey
               bpl  acl1

               lda  addr
               sta  coin
               lda  addr+1
               sta  coin+1

               lda  defs
               sta  addr
               lda  defs+1
               sta  addr+1
               clc
               ldy  #0
               lda  (addr),y
               adc  #1
               sta  (addr),y
               iny
               lda  (addr),y
               adc  #0
               sta  (addr),y

               ldx  #2
acl2           clc
               lda  defs,x
               adc  #$B
               sta  defs,x
               inx
               lda  defs,x
               adc  #0
               sta  defs,x
               inx
               cpx  #$18
               bne  acl2

               lda  #$B
               sta  addr2
               lda  #0
               sta  addr2+1
               ldx  #7
acl3           lda  abti,x
               asl
               tay
               lda  defs,y
               sta  addr
               iny
               lda  defs,y
               sta  addr+1
               jsr  incadb
               dex
               bpl  acl3
               bmi  acs1
abti           hex  010203040506090A

acs1           lda  defs
               sta  addr
               lda  defs+1
               sta  addr+1
               sec
               ldy  #0
               lda  (addr),y
               sta  numcoins
               sbc  #1
               sta  coinnum
               iny
               lda  (addr),y
               sta  numcoins+1
               sbc  #0
               sta  coinnum+1
               jmp  coinl
