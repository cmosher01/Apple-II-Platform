                               ;
                               ; Coin Inventory (Update)
                               ;
                               ; Copyright 1988 by Christopher A. Mosher
                               ;
               lst  off



               put  COIN.SYSTEM.EQUATES
               put  COIN.UPDATE.START
               put  COIN.UPDATE.1
               put  COIN.UPDATE.2



getadent                       ; get and add entry
                               ; i: asto ($1-$6, $17-$19, or $A)
                               ;    asto2 (current x value)
                               ;    size (original field size)
                               ; o: new entry input and added
                               ;    asto2 (new entry # to start at)
                               ;    <esc> press handled
                               ;    dest: asto, x, y, a
                               ;          (size becomes incorrect because
                               ;          it isn't changed)

               lda  #11        ; clear existing "->"
               sta  vtab
               jsr  bc
               ldy  #0
               lda  #$A0
               jsr  cout
               lda  #$A0
               jsr  cout

               lda  #22
               sta  vtab
               jsr  bc         ; vtab 22
               ldy  #0         ; htab 0

               lda  asto       ; $1-$6, $17-$19, or $A
               and  #$0F       ; make $1 <= a <= $A

               asl             ; (clears c)
               adc  #<gatbl
               sta  gaj+1
               lda  #0
               adc  #>gatbl
               sta  gaj+2
gaj            jmp  ($FFFF)    ; jmp to gatbl + 2*a

gatbl          da   0,ga1,ga2,ga3,ga4,ga5,ga6,ga7,ga8,ga9,gaA



                               ; the "get and add" routines: $1-$A
                               ; i: vtab (bas) = 22, htab (y) = 0
                               ;    size
                               ; o: asto2 (new x)
                               ; if <esc> is pressed during entry,
                               ;   do not add anything to data, and
                               ;   set asto2 := size (original)
                               ; exit with rts

ga1                            ; denomination
               jsr  prmess
               asc             "-> Enter a new denomination: "
               dfb  0
               ldx  #74        ; max col
               lda  #0
               jsr  instr
               lda  inbufr
               beq  g1s        ; if string is 0 bytes long, then don't add it
               lda  #$1
               jsr  addentry   ; add entry
               lda  size       ; old size
               sta  asto2      ; becomes new x
g1s            rts

ga2                            ; subject
               jsr  prmess
               asc             "-> Enter a new subject: "
               dfb  0
               ldx  #74        ; max col
               lda  #0
               jsr  instr
               lda  inbufr
               beq  g2s        ; if string is 0 bytes long, then don't add it
               lda  #$2
               jsr  addentry   ; add entry
               lda  size       ; old size
               sta  asto2      ; becomes new x
g2s            rts

ga3                            ; inscription (***)
               jsr  prmess
               asc             "-> Enter a new inscription: "
               dfb  $A2
               dfb  0
                               ;
                               ; jsr ininsc ; get inscription
                               ;
               jsr  waitkey    ; XXX
               lda  #0         ; XXX to avoid adding for now
               beq  g3s        ; if inscrstring is 0 bytes long, then don't add
                               ; jsr addinsc ; add inscription entry
               lda  size
               sta  asto2
g3s            rts

ga4                            ; inscription character
               jsr  prmess
               asc             "-> Enter a new inscription phrase: "
               dfb  $A2
               dfb  0
               ldx  #74        ; max col
               lda  #$80       ; display quotes around input string
               jsr  instr
               lda  inbufr
               beq  g4s        ; if string is 0 bytes long, then don't add it
               lda  #$4
               jsr  addentry   ; add entry
               lda  size       ; old size
               sta  asto2      ; becomes new x
g4s            rts

ga5                            ; designer
               jsr  prmess
               asc             "-> Enter a new designer: "
               dfb  0
               ldx  #74        ; max col
               lda  #0
               jsr  instr
               lda  inbufr
               beq  g5s        ; if string is 0 bytes long, then don't add it
               lda  #$5
               jsr  addentry   ; add entry
               lda  size       ; old size
               sta  asto2      ; becomes new x
g5s            rts

ga6                            ; edge
               jsr  prmess
               asc             "-> Enter a new inscription for an edge: "
               dfb  $A2
               dfb  0
               ldx  #74        ; max col
               lda  #$80       ; display quotes around input string
               jsr  instr
               lda  inbufr
               beq  g6s        ; if string is 0 bytes long, then don't add it
               lda  #$6
               jsr  addentry   ; add entry
               lda  size       ; old size
               sta  asto2      ; becomes new x
g6s            rts

ga7                            ; weight
               jsr  prmess
               asc             "-> Enter a new weight: "
               dfb  0
               lda  asto2
               pha             ; save asto2
               jsr  inwt
               lda  asto
               ora  asto2
               ora  asto3
               bne  g7s        ; if wt <> 0 then add it
               pla             ; original x value
               sta  asto2      ; keep original x value
               rts             ; don't add data
g7s            pla             ; forget original asto2
               jsr  addwt      ; add weight to data
               lda  size       ; original size
               sta  asto2      ; new x value
               rts

ga8                            ; diameter
               jsr  prmess
               asc             "-> Enter a new diameter: "
               dfb  0
               lda  asto2
               pha             ; save asto2
               jsr  indm
               lda  asto
               ora  asto2
               bne  g8s        ; if dm <> 0 then add it
               pla             ; original x value
               sta  asto2      ; keep original x value
               rts             ; don't add data
g8s            pla             ; forget original asto2
               jsr  adddm      ; add diameter to data
               lda  size       ; original size
               sta  asto2      ; new x value
               rts

ga9                            ; composition (***)
               jsr  incmp      ; get composition list
               bcs  g9s        ; if comp is null, then don't add
                               ; jsr addcmp ; add composition entry
               lda  size
               sta  asto2
g9s            rts

gaA                            ; metal
               jsr  prmess
               asc             "-> Enter a new metal: "
               dfb  0
               ldx  #74        ; max col
               lda  #0
               jsr  instr
               lda  inbufr
               beq  gAs        ; if string is 0 bytes long, then don't add it
               lda  #$A
               jsr  addentry   ; add entry
               lda  size       ; old size
               sta  asto2      ; becomes new x
gAs            rts



scrollup                       ; scroll lines 4-19 up, cols. 2-79

               sta  page2
               sec
sul1           ldy  #39
sul2           lda  $0680,y
               sta  $0600,y
               lda  $0700,y
               sta  $0680,y
               lda  $0780,y
               sta  $0700,y
               lda  $0428,y
               sta  $0780,y
               lda  $04A8,y
               sta  $0428,y
               lda  $0528,y
               sta  $04A8,y
               lda  $05A8,y
               sta  $0528,y
               lda  $0628,y
               sta  $05A8,y
               lda  $06A8,y
               sta  $0628,y
               lda  $0728,y
               sta  $06A8,y
               lda  $07A8,y
               sta  $0728,y
               lda  $0450,y
               sta  $07A8,y
               lda  $04D0,y
               sta  $0450,y
               lda  $0550,y
               sta  $04D0,y
               lda  $05D0,y
               sta  $0550,y
               dey
               bne  sul2
               bcc  exsu
               clc
               sta  page1
               bcc  sul1
exsu           rts



scrolldw                       ; scroll lines 4-19 down, cols. 2-79

               sta  page2
               sec
sdl1           ldy  #39
sdl2           lda  $0550,y
               sta  $05D0,y
               lda  $04D0,y
               sta  $0550,y
               lda  $0450,y
               sta  $04D0,y
               lda  $07A8,y
               sta  $0450,y
               lda  $0728,y
               sta  $07A8,y
               lda  $06A8,y
               sta  $0728,y
               lda  $0628,y
               sta  $06A8,y
               lda  $05A8,y
               sta  $0628,y
               lda  $0528,y
               sta  $05A8,y
               lda  $04A8,y
               sta  $0528,y
               lda  $0428,y
               sta  $04A8,y
               lda  $0780,y
               sta  $0428,y
               lda  $0700,y
               sta  $0780,y
               lda  $0680,y
               sta  $0700,y
               lda  $0600,y
               sta  $0680,y
               dey
               bne  sdl2
               bcc  exsd
               clc
               sta  page1
               bcc  sdl1
exsd           rts



instr                          ; input a string
                               ; i: vtab (<=22),  y (<=x)
                               ;    x (last col. to display  <=78)
                               ;    a (x....... display quotes?)
                               ; o: inbufr (string of ASCII $A0-$FE, term. w/0)
                               ;    in len = 256, then not term
                               ; dest: asto, asto3
                               ; pres: asto2
                               ;
                               ; cmds:
                               ;   ASCII key           function
                               ;   A0-FE <space>-~     enter character
                               ;   88    <left-arrow>  back
                               ;   95    <right-arrow> scan
                               ;   FF    <delete>      delete
                               ;   8D    <return>      done
                               ;   9B    <esc>         quit (empty inbufr)

               pha             ; save quote status
               lda  #0
               sta  asto       ; len
               sty  htab
               inx
               stx  htaborg
               sec
               txa
               sbc  htab
               sta  asto3      ; field width
               ldx  #0         ; ccpos in inbufr
               jsr  curout
               pla
               pha
               bpl  inrefet
               lda  #$A2       ; "
               jsr  cout
               dey
inrefet        jsr  waitkey
               cmp  #$88
               bne  inss1
               jmp  inback
inss1          cmp  #$95
               bne  inss3
               jmp  inscan
inss3          cmp  #$FF
               bne  inss4
               jmp  indel
inss4          cmp  #$8D
               bne  inss5
               jmp  inret
inss5          cmp  #$9B
               bne  inss6
               jmp  inesc
inss6          cmp  #$A0
               blt  inrefet

               sta  inbufr,x
               inx
               inc  asto
               cpy  htaborg
               blt  inchs1
               jsr  scrinlf
               ldy  htaborg
               dey
               jsr  cout
               jmp  inrefet
inchs1         jsr  cout
               jsr  curout
               pla
               pha
               bpl  inss2
               lda  #$A2       ; "
               jsr  cout
               dey
inss2          jmp  inrefet


inback
inscan
               jmp  inrefet
indel
               cpx  #0
               beq  inds1
               dex
               dec  asto
               cpx  asto3
               blt  inds2
               tya
               pha
               jsr  scrinrt
               sec
               txa
               pha
               sbc  asto3
               tax
               lda  inbufr,x
               ldy  htab
               jsr  cout
               pla
               tax
               pla
               tay
               jmp  inrefet
inds2          dey
               lda  #$A0
               jsr  cout
               dey
               jsr  curout
               pla
               pha
               bpl  inds1
               lda  #$A2       ; "
               jsr  cout
               lda  #$A0
               jsr  cout
               dey
               dey
inds1          jmp  inrefet


inesc          ldx  #0
inret          lda  #0
               sta  inbufr,x
               pla             ; forget quote status
               rts

curout                         ; output cursor of instr
                               ; i: bas,y
                               ; o: dsp mouse L cursor
                               ;    pres: bas,y
               inc  vtab
               jsr  bc
               dey
               lda  #$A0
               jsr  cout
               lda  #"L"
               jsr  mout
               lda  #$A0
               jsr  cout
               dey
               dey
               dec  vtab
               jsr  bc
               rts

scrinlf                        ; scroll input window left
                               ; i: htab, htaborg (as instr)
                               ; o: pres: bas, x, a

               pha
               txa
               pha
               ldy  htab
sill1          jsr  mchrlf
               iny
               cpy  htaborg
               bne  sill1
               pla
               tax
               pla
               rts

mchrlf                         ; move chr left
                               ; i: bas, y (pos to move chr into)
                               ; o: pres: y, bas

               tya
               pha
               lsr
               tay
               bcc  mcls1
               sta  page2
               iny
               lda  (bas),y
               sta  page1
               dey
mcls2          sta  (bas),y
               pla
               tay
               rts
mcls1          sta  page1
               lda  (bas),y
               sta  page2
               bne  mcls2

scrinrt                        ; scroll input window right
                               ; i: htab, htaborg (as instr)
                               ; o: pres: bas, x, a

               pha
               txa
               pha
               ldy  htaborg
               dey
sirl1          jsr  mchrrt
               dey
               cpy  htab
               bne  sirl1
               pla
               tax
               pla
               rts

mchrrt                         ; move chr right
                               ; i: bas, y (pos to move chr into)
                               ; o: pres: bas, y

               tya
               pha
               lsr
               tay
               bcs  mcrs1
               sta  page1
               dey
               lda  (bas),y
               sta  page2
               iny
mcrs2          sta  (bas),y
               pla
               tay
               rts
mcrs1          sta  page2
               lda  (bas),y
               sta  page1
               bne  mcrs2



incmp                          ; input a composition list
                               ; i: none
                               ; o: if c clr: inbufr (comp list)
                               ;              a (length)
                               ;    c set if <esc> pressed
                               ; dest: asto,
                               ; pres: asto2
               lda  asto2
               pha             ; save asto2
               jsr  ttlhome
               lda  #2
               sta  vtab
               jsr  bc
               ldy  #0
               jsr  prmess
               asc             "Enter a new composition:"
               dfb  0
               lda  #6
               sta  vtab
               jsr  bc
               ldy  #2
               jsr  prmess
               asc             "Number of metals:"
               dfb  0
               lda  #9
               sta  vtab
               jsr  bc
               ldy  #2
               jsr  prmess
               asc             "composition:"
               dfb  0
               lda  #4
               sta  vtab
               jsr  bc
               ldy  #2
               jsr  prmess
               asc             "Clad, plating, or none?          <- (C, P, N)"
               dfb  0

icrefet1       jsr  fetch
               cmp  #"C"
               bne  ics1
               ldy  #27
               jsr  prmess
               asc             "Clad                "
               dfb  0
               lda  #6
               sta  vtab
               jsr  bc
               ldy  #20
               jsr  prmess
               asc             "clad:"
               dfb  0
               inc  vtab
               jsr  bc
               ldy  #20
               jsr  prmess
               asc             "core:"
               dfb  0
               lda  #1
               bne  ics3
ics1           cmp  #"P"
               bne  ics2
               ldy  #27
               jsr  prmess
               asc             "Plating             "
               dfb  0
               lda  #6
               sta  vtab
               jsr  bc
               ldy  #20
               jsr  prmess
               asc             "plat:"
               dfb  0
               inc  vtab
               jsr  bc
               ldy  #20
               jsr  prmess
               asc             "core:"
               dfb  0
               lda  #2
               bne  ics3
ics2           cmp  #"N"
               beq  ics4
               jmp  icrefet1
ics4           ldy  #27
               jsr  prmess
               asc             "None                "
               dfb  0
               lda  #0
ics3           sta  inbufr
               lda  #6
               sta  vtab
               jsr  bc
               ldy  #35
               jsr  prmess
               asc             "<- (1- )"
               dfb  0
               lda  #0
               cmp  inbufr
               adc  #5         ; none,clad,plat -> 6,5,5
               ora  #$B0       ; ASCII
               sta  asto
               inc  asto
               and  #$0F
               ldy  #41
               jsr  nibout
icrefet2       jsr  waitkey
               cmp  #"1"
               blt  icrefet2
               cmp  asto
               bge  icrefet2
               and  #$0F
               sta  inbufr+1
               ldy  #27
               jsr  nibout
               jsr  esce

               lda  inbufr
               bne  ics8
               lda  inbufr+1
               asl
               adc  inbufr+1
               adc  #2
               sta  asto
               jmp  ics5
ics8           inc  vtab
               jsr  bc
               lda  inbufr+1
               cmp  #5
               bne  ics6
               lda  #1
               bne  ics7
ics6           ldy  #35
               jsr  prmess
               asc             "<- (1- )"
               dfb  0
               sec
               lda  #6
               sbc  inbufr+1
               ora  #$B0       ; ASCII
               sta  asto
               inc  asto
               and  #$0F
               ldy  #41
               jsr  nibout
icrefet3       jsr  waitkey
               cmp  #"1"
               blt  icrefet3
               cmp  asto
               bge  icrefet3
               and  #$0F
ics7           pha
               lda  inbufr+1
               asl
               adc  inbufr+1
               adc  #2
               tay
               pla
               sta  inbufr,y
               sty  asto
               ldy  #27
               jsr  nibout
               jsr  esce

ics5           ldy  #2
               lda  #0
icl1           sta  inbufr,y
               iny
               cpy  asto
               blt  icl1

               lda  inbufr
               beq  ics9
               lda  inbufr,y
               asl
               adc  inbufr,y
               adc  asto
               adc  #1
               sta  asto
               iny
               lda  #0
icl2           sta  inbufr,y
               iny
               cpy  asto
               blt  icl2

ics9           lda  #10
               sta  vtab
               jsr  bc
               lda  #<inbufr
               sta  addr
               lda  #>inbufr
               sta  addr+1
               ldy  #4
               lda  #0
               jsr  prcmpl

               lda  #2
               sta  htab
               lda  inbufr
               beq  ics10
               lda  #10
               sta  vtab
               jsr  bc
               ldy  #8
               lda  #$A0
               jsr  cout
               clc
               lda  vtab
               adc  inbufr+1
               sta  vtab
               jsr  bc
               ldy  #8
               lda  #$A0
               jsr  cout
               lda  #8
               sta  htab
ics10
               lda  #10
               sta  vtab
               jsr  bc
               ldy  htab
               lda  #"-"
               jsr  cout
               lda  #">"
               jsr  cout
icrefet3       jsr  waitkey
               cmp  #$8D
               bne  ics11
ics11          cmp  #$88       ; left
               bne  ics12
ics12          cmp  #$8B       ; up
               bne  ics13
ics13          cmp  #$8A       ; down
               bne  ics14
ics14          cmp  #$95       ; right
               bne  icrefet3
               brk

               pla
               sta  asto2
               rts



               rts



addentry                       ; add inbufr to data block
                               ; i: a (as prfld: 1,2,4,5,6,A)
                               ; o: data moved, all addresses fixed
                               ;    dest: addr, addr2, addr3, asto, asto2

               tax             ; save orig a in x
               jsr  getblen
               clc
               tya
               adc  #3         ; 3 bytes: term. 00 in bufr, and new address
               sta  addr3
               pha
               lda  #0
               adc  #0
               sta  addr3+1    ; addr3 = length of buffer + 3
               pha             ; save addr3 'til the end (to fix addr blocks)

               txa             ; get orig a from x
               pha             ; save orig a
               adc  #1         ; (c clr from prev adc)
               asl             ; (clears c)
               tay
               lda  defs,y
               sta  addr
               pha
               adc  addr3
               sta  defs,y
               iny
               lda  defs,y
               sta  addr+1     ; (addr)-->end of data block+1
               pha             ; save addr for after moveup
               adc  addr3+1
               sta  defs,y     ; inc first following address by (len+3)
               jmp  ades1      ; enter loop

adel1          clc             ; loop to inc each address in main list by len+3
               lda  defs,y
               adc  addr3
               sta  defs,y
               iny
               lda  defs,y
               adc  addr3+1
               sta  defs,y
ades1          iny
               cpy  #$16
               blt  adel1
               cpy  #$18       ; y = $18 iff orig a = $A (last data block)
               beq  ades2
               clc
               lda  defs+$16   ; (defs+$16)-->lastbyte
               sta  addr2
               adc  addr3
               sta  addr3
               sta  defs+$16
               lda  defs+$17
               sta  addr2+1    ; (addr2)-->lastbyte
               adc  addr3+1
               sta  addr3+1    ; (addr3)-->lastbyte+(len+3) (new lastbyte)
               sta  defs+$17   ; (defs+$16)-->new lastbyte
               jsr  moveup

ades2          pla
               sta  addr2+1
               pla
               sta  addr2      ; (addr2)-->end of data block+1
               pla
               sta  asto       ; orig a (used twice later)
               clc
               lda  addr2
               adc  #2
               sta  addr3
               pha             ; save (see note below)
               lda  addr2+1
               adc  #0
               sta  addr3+1
               pha             ; save (see note below)
                               ; (addr3)-->the last byte of the dest. address
                               ;           range for moveup; it is (addr2)+2,
                               ;           which is where addr2's extra byte
                               ;           will end up; it is also where the
                               ;           new string will start (so save it)
               lda  asto       ; orig a
               asl             ; clears c
               tay
               lda  defs,y
               sta  addr
               iny
               lda  defs,y
               sta  addr+1     ; (addr)-->start of block (# of entries)
               ldy  #0
               lda  (addr),y
               tax
               inx             ; inc # of entries
               txa
               sta  (addr),y   ; save new #-of-entries byte

               lda  addr
               adc  #1         ; (c clr from prev adc)
               sta  addr
               lda  addr+1
               adc  #0         ; (clears c for initial loop entry)
               sta  addr+1     ; (addr)--> first address in table
               jmp  ades3      ; enter loop

adel3          lda  (addr),y
               adc  #2
               sta  (addr),y
               iny
               lda  (addr),y
               adc  #0
               sta  (addr),y   ; fix address in table (+2)
               dey             ; back to 0
               lda  addr
               adc  #2         ; (c clear from previous adc)
               sta  addr
               lda  addr+1
               adc  #0
               sta  addr+1     ; (addr)-->next address (or start of data)
ades3          dex
               bne  adel3      ; fix next address

               lda  addr       ; (addr)--> start of data in block
               pha             ; save addr, because it points to the first byte
               lda  addr+1     ; following the existing address table, which is
               pha             ; where the new address will go

               jsr  moveup     ; moves one extra byte: (addr2)-->
                               ; (but that's okay)
               pla
               sta  addr+1
               pla
               sta  addr       ; (addr)-->new address at end of table
               pla
               ldy  #1
               sta  (addr),y
               sta  addr3+1
               pla
               dey
               sta  (addr),y   ; (new address)-->new string space(pulled addr3)
               sta  addr3
               dey             ; cancel out initial iny
adel2          iny             ; go ahead and copy the buffer (finally!)
               lda  inbufr,y
               sta  (addr3),y
               bne  adel2      ; if byte stored is 00, then we're done

               pla
               sta  addr2+1
               pla
               sta  addr2      ; addr2 = len+3 (from beginning)
               ldx  asto       ; orig a
               inx
               txa
               asl
               tay
               bne  ades4
adel4          cpy  #$E
               bne  ades5
               ldy  #$12
ades5          lda  defs,y
               sta  addr
               iny
               lda  defs,y
               sta  addr+1
               sty  asto2
               jsr  incadb
               ldy  asto2
               iny
ades4          cpy  #$16
               bne  adel4
               rts



addwt                          ; add weight entry
                               ; i: asto, asto2, asto3 (weight)
                               ; o: data moved, all addresses fixed
               lda  asto3
               pha
               lda  asto2
               pha
               lda  asto
               pha

               lda  defs+$10
               sta  addr
               lda  defs+$11
               sta  addr+1
               clc
               lda  defs+$16
               sta  addr2
               adc  #3
               sta  addr3
               lda  defs+$17
               sta  addr2+1
               adc  #0
               sta  addr3+1
               jsr  moveup

               clc
               lda  defs+$E
               sta  addr
               lda  defs+$F
               sta  addr+1
               ldy  #0
               lda  (addr),y
               adc  #1
               sta  (addr),y

               lda  defs+$10
               sta  addr
               adc  #3
               sta  defs+$10
               lda  defs+$11
               sta  addr+1
               adc  #0
               sta  defs+$11
               pla
               sta  (addr),y
               iny
               pla
               sta  (addr),y
               iny
               pla
               sta  (addr),y

               lda  #3
               sta  addr2
               lda  #0
               sta  addr2+1
               ldy  #$12
awl1           clc
               lda  defs,y
               adc  #3
               sta  addr
               sta  defs,y
               iny
               lda  defs,y
               adc  #0
               sta  addr+1
               sta  defs,y
               iny
               sty  asto2
               jsr  incadb
               ldy  asto2
               cpy  #$17
               blt  awl1
               rts



adddm                          ; add diameter entry
                               ; i: asto, asto2, (diameter)
                               ; o: data moved, all addresses fixed
               lda  asto2      ; save values
               pha
               lda  asto
               pha

               lda  defs+$12   ; move up rest of data
               sta  addr
               lda  defs+$13
               sta  addr+1
               clc
               lda  defs+$16
               sta  addr2
               adc  #2
               sta  addr3
               lda  defs+$17
               sta  addr2+1
               adc  #0
               sta  addr3+1
               jsr  moveup

               clc             ; inc number of diameters
               lda  defs+$10
               sta  addr
               lda  defs+$11
               sta  addr+1
               ldy  #0
               lda  (addr),y
               adc  #1
               sta  (addr),y

               lda  defs+$12   ; store the new diam
               sta  addr
               lda  defs+$13
               sta  addr+1
               pla
               sta  (addr),y
               iny
               pla
               sta  (addr),y

               lda  #2         ; add 2 to each address in following data blocks
               sta  addr2
               lda  #0
               sta  addr2+1
               ldy  #$12
adl1           clc
               lda  defs,y
               adc  #2
               sta  addr
               sta  defs,y
               iny
               lda  defs,y
               adc  #0
               sta  addr+1
               sta  defs,y
               iny
               cpy  #$18
               beq  ads1
               sty  asto2
               jsr  incadb
               ldy  asto2
               bne  adl1
ads1           rts



getblen                        ; get inbufr length
                               ; i: inbufr
                               ; o: y (length: 1 org. not incl. term. 00)
                               ;             = 0 org. incl. term. 00)
               ldy  #-1
gbll1          iny
               lda  inbufr,y
               bne  gbll1
               rts



                               ; shift a (bit 7) into asto,-2,-3
                               ; i: a, asto, asto2, asto3
                               ; o: asto, asto2, asto3
slasto         mac
               asl
               rol  asto3
               rol  asto2
               rol  asto
               eom
                               ; shift asto,-2,-3 right
                               ; i: asto, asto2, asto3
                               ; o: asto, asto2, asto3
srasto         mac
               lsr  asto
               ror  asto2
               ror  asto3
               eom



inwt                           ; input weight
                               ; i: bas, y
                               ; o: asto, asto2, asto3
                               ;    aa.bbcc
               sty  htab
               jsr  prmess
               asc             "  .     g"
               dfb  0
               lda  #0
               sta  asto
               sta  asto2
               sta  asto3
inwdsp         ldy  htab
               jsr  dsp2p4
inwfet         jsr  waitkey
               cmp  #$8D       ; <return>
               beq  exinw
               cmp  #$9B       ; <esc>
               beq  inwesc
               cmp  #$FF       ; <delete>
               bne  inws
               pmc  srasto
               pmc  srasto
               pmc  srasto
               pmc  srasto
               jmp  inwdsp
inwesc         lda  #0
               sta  asto
               sta  asto2
               sta  asto3
exinw          rts
inws           cmp  #"0"
               blt  inwfet
               cmp  #"9"+1
               bge  inwfet
               asl
               asl
               asl
               asl             ; forget high nibble
               pmc  slasto
               pmc  slasto
               pmc  slasto
               pmc  slasto
               jmp  inwdsp



                               ; shift a (bit 7) into asto,-2
                               ; i: a, asto, asto2
                               ; o: asto, asto2
slasto2        mac
               asl
               rol  asto2
               rol  asto
               eom
                               ; shift asto,-2 right
                               ; i: asto, asto2
                               ; o: asto, asto2
srasto2        mac
               lsr  asto
               ror  asto2
               eom



indm                           ; input diameter
                               ; i: bas, y
                               ; o: asto, asto2
                               ;    aa.bb
               sty  htab
               jsr  prmess
               asc             "  .   mm"
               dfb  0
               lda  #0
               sta  asto
               sta  asto2
inddsp         ldy  htab
               jsr  dsp2p2
indfet         jsr  waitkey
               cmp  #$8D       ; <return>
               beq  exind
               cmp  #$9B       ; <esc>
               beq  indesc
               cmp  #$FF       ; <delete>
               bne  indms
               pmc  srasto2
               pmc  srasto2
               pmc  srasto2
               pmc  srasto2
               jmp  inddsp
indesc         lda  #0
               sta  asto
               sta  asto2
exind          rts
indms          cmp  #"0"
               blt  indfet
               cmp  #"9"+1
               bge  indfet
               asl
               asl
               asl
               asl             ; forget high nibble
               pmc  slasto2
               pmc  slasto2
               pmc  slasto2
               pmc  slasto2
               jmp  inddsp



dsp2p2                         ; dsp "aa bb"
                               ; i: asto, asto2
               lda  asto
               jsr  aout
               iny
               lda  asto2
               jsr  aout
               rts



dsp2p4                         ; dsp "aa bbcc"
                               ; i: asto, asto2, asto3
               jsr  dsp2p2
               lda  asto3
               jsr  aout
               rts



               sav  CU
