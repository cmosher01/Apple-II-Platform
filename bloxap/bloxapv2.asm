                               ;
                               ; BloXap
                               ;
                               ; by Christopher A. Mosher
                               ;
                               ; April 1988
                               ;



                               ; new 65C02 opcodes
BRA            EQU  $80        ; BRA  $FFFF (offset)
PHY            EQU  $5A        ; PHY
PLY            EQU  $7A        ; PLY
PHX            EQU  $DA        ; PHX
PLX            EQU  $FA        ; PLX
BIT            EQU  $89        ; BIT  #$FF
JMP            EQU  $7C        ; JMP  ($FFFF,X)
STZ            EQU  $9E        ; STZ  $FFFF,X



                               ; page $00 locations
BAS            EQU  $FA        ; base address register for printing ($FA-$FB)
CURBAS         EQU  $FC        ; register for current base address ($FC-$FD)
ADDR           EQU  $FE        ; address register ($FE-$FF)



                               ; page $03 locations
RESETV         EQU  $03F2
RESETEOR       EQU  $A5



                               ; ProDOS global page
MLI            EQU  $BF00      ; machine language interface entry point
QUIT           EQU  $65
READ_BLOCK     EQU  $80
WRITE_BLOCK    EQU  $81
ERRNODEV       EQU  $28
ERRWP          EQU  $2B
BITMAP         EQU  $BF58
MACHID         EQU  $BF98
IBAKVER        EQU  $BFFC
IVERSION       EQU  $BFFD
KBAKVER        EQU  $00
KVERSION       EQU  $00



                               ; page $C0 locations
READKBD        EQU  $C000
FTYSTR         EQU  $C000
ETYSTR         EQU  $C001
FTYCOL         EQU  $C00C
ETYCOL         EQU  $C00D
PRMCS          EQU  $C00E
ALTCS          EQU  $C00F
CLEARKBD       EQU  $C010
ETYSTR?        EQU  $C018
PAGE2?         EQU  $C01C
ALTCS?         EQU  $C01E
ETYCOL?        EQU  $C01F
PAGE1          EQU  $C054
PAGE2          EQU  $C055



ETYENTRY       EQU  $C300



                               ; global table
               ORG  $2000      ; starting address $2000
BLOXAP         JMP  INIT       ; BloXap entry point



CMDTBL                         ; command table (hex values come first)

               ASC  "0123456789ABCDEF"
               ASC  "IKJL"
               DFB  $8B,$8A,$88,$95 ; arrows (up, down, left, right)
               ASC  "UORWTS=-+_.,><H?"
               DFB  $9B        ; <esc>
               DFB  $00



JMPTBL                         ; address table for command routines

               DFB  <HEX,>HEX,<HEX,>HEX,<HEX,>HEX,<HEX,>HEX
               DFB  <HEX,>HEX,<HEX,>HEX,<HEX,>HEX,<HEX,>HEX
               DFB  <HEX,>HEX,<HEX,>HEX,<HEX,>HEX,<HEX,>HEX
               DFB  <HEX,>HEX,<HEX,>HEX,<HEX,>HEX,<HEX,>HEX
               DFB  <UP,>UP,<DOWN,>DOWN,<LEFT,>LEFT,<RIGHT,>RIGHT
               DFB  <UP,>UP,<DOWN,>DOWN,<LEFT,>LEFT,<RIGHT,>RIGHT
               DFB  <BEGIN,>BEGIN,<END,>END
               DFB  <READ,>READ,<WRITE,>WRITE,<TEXT,>TEXT,<SLOT,>SLOT
               DFB  <INCBLOCK,>INCBLOCK,<DECBLOCK,>DECBLOCK
               DFB  <INCBLOCK,>INCBLOCK,<DECBLOCK,>DECBLOCK
               DFB  <INCBLOCK,>INCBLOCK,<DECBLOCK,>DECBLOCK
               DFB  <INCBLOCK,>INCBLOCK,<DECBLOCK,>DECBLOCK
               DFB  <HELP,>HELP,<SCAN,>SCAN
               DFB  <EXIT,>EXIT



PAGETBL                        ; table of pages to allocate to BloXap

               HEX             202122232425262728292A2B2C2D2E2F
               DFB  0



                               ; disassembly tables (ROM)

MNEML          HEX  1C8A1C235D8B1BA19D8A1D239D8B1DA1
               HEX  1C2919AE69A8192324531B23245319A1
               HEX  AD1A5B5BA5692424AEAEA8AD298A7C8B
               HEX  159C6D9CA569295384133411A56923A0
MNEMR          HEX  D8625A48266294885444C8546844E894
               HEX  C4B4088474B4286E74F4CC4A72F2A48A
               HEX  06AAA2A2747474724468B232B2722272
               HEX  1A1A2626727288C8C4CA26484444A2C8
FMT1           HEX  0F22FF33CB62FF730322FF33CB66FF77
               HEX  0F20FF33CB60FF700F22FF39CB66FF7D
               HEX  0B22FF33CBA6FF731122FF33CBA6FF87
               HEX  0122FF33CB60FF700122FF33CB60FF70
               HEX  24316578
FMT2           HEX  00218182594D9192864A859D495A
CHAR2          HEX  D900D8A4A400
CHAR1          HEX  ACA9ACA3A8A4
OPTBL          HEX  12141A1C32343A3C525A6472747A7C89
               HEX  929C9EB2D2F2FC



ASTO           DFB  $00        ; storage register
CURY           DFB  $00        ; HTAB for cursor
VTAB           DFB  $00        ; line number for printing



               HEX  8A8BA5AC00 ; for MNEML
INDEX          HEX  38FB37FB392136213AF8FA3BFAF92221
               HEX  3CFAFA3D3E3FFC00



                               ; variables
INVMASK        DFB  $FF        ; inverse AND mask
BYTES          DS   $10        ; storage for bytes to be printed



MAINLOOP                       ; the main loop of BloXap

               JSR  CUROUT     ; output the cursor
               JSR  DSPHELP    ; display the help command indicator
               JSR  DSPINS     ; display the block of instructions
               JSR  FETCH      ; fetch a keypress
               JSR  EXECUTE    ; execute a command
               DFB  BRA,MAINLOOP-*-1 ; repeat



IOSTO          DFB  $00        ; storage for I/O ROM swithes' status
                               ; status = 0000scat
                               ;    where
                               ;       s = 80Store   ETYSTR?
                               ;       c = 80Col     ETYCOL?
                               ;       a = AltChar   ALTCS?
                               ;       t = Page2     PAGE2?



               HEX  747476C600 ; for MNEMR



PARMLIST                       ; parameter list for MLI calls

               DFB  $03        ; 3 parameters
UNIT           DFB  $60        ; current unit number:
                               ;    dsss0000 where
                               ;             d   = drive (0,1)
                               ;             sss = slot  (1-7)
               DFB  $00,$08    ; address of data buffer
BLOCK          DFB  $00,$00    ; current block



INIT                           ; initialize

               LDX  #$FF
               TXS
               LDA  #<BLOXAP
               STA  RESETV
               LDA  #>BLOXAP
               STA  RESETV+1
               EOR  #RESETEOR
               STA  RESETV+2
               LDA  #KBAKVER
               STA  IBAKVER
               LDA  #KVERSION
               STA  IVERSION
               JSR  ALLOCBX
               JSR  SET80
               JSR  DSPTITLE
               JSR  TLHOME
               JSR  DSPOFS
               JSR  ZEROBUFR
               LDA  #$00
               STA  CURBAS
               LDA  #$08
               STA  CURBAS+1
               JSR  PRPAGE
               JSR  DSPINS
               JSR  DSPSTMES
               LDA  #0
               STA  CURY
               LDA  #4
               STA  VTAB
               JMP  MAINLOOP



WARMUP                         ; warm up routine (do not start)
                               ; i: none
                               ; o: BloXap ready for
                               ;         JMP MAINLOOP
                               ;         VTAB preserved

               LDA  VTAB
               PHA
               JSR  TLHOME
               JSR  DSPOFS
               PLA
               PHA
               STA  VTAB
               JSR  RDSK1      ; PRPAGE calculating CURBAS with VTAB
               JSR  DSPINS
               JSR  DSPSTMES
               PLA
               STA  VTAB
               RTS



ALLOCBX                        ; allocate BloXap program in system memory map
                               ; i: PAGETBL
                               ; o: BITMAP marked appropriately

               LDX  #0
ABLP1          LDA  PAGETBL,X
               BEQ  EXAB
               DFB  PHX
               PHA             ; abcdefgh
               AND  #$07       ; 00000fgh
               TAY
               LDX  BITMASK,Y  ; get proper bit set in X
               PLA             ; abcdefgh
               LSR
               LSR
               LSR             ; 000abcde
               TAY
               TXA
               ORA  BITMAP,Y
               STA  BITMAP,Y
               DFB  PLX
               INX
               BNE  ABLP1
BITMASK        HEX             8040201008040201
EXAB           RTS



IOSAVE                         ; save I/O ROM switches
                               ; i: none
                               ; o: IOSTO

               LDA  #0         ; 00000000 .
               ROL  ETYSTR?    ; 00000000 s
               ROL             ; 0000000s 0
               ROL  ETYCOL?    ; 0000000s c
               ROL             ; 000000sc 0
               ROL  ALTCS?     ; 000000sc a
               ROL             ; 00000sca 0
               ROL  PAGE2?     ; 00000sca t
               ROL             ; 0000scat 0
               STA  IOSTO
               RTS



IORESTOR                       ; restore I/O ROM switches
                               ; i: IOSTO
                               ; o: switches set accordingly

               LDA  IOSTO      ; 0000scat
               LSR             ; 00000sca t
               BCC  IORSK1
               STA  PAGE2
               BCS  IORSK2
IORSK1         STA  PAGE1
IORSK2         LSR             ; 000000sc a
               BCC  IORSK3
               STA  ALTCS
               BCS  IORSK4
IORSK3         STA  PRMCS
IORSK4         LSR             ; 0000000s c
               BCC  IORSK5
               STA  ETYCOL
               BCS  IORSK6
IORSK5         STA  FTYCOL
IORSK6         LSR             ; 00000000 s
               BCC  IORSK7
               STA  ETYSTR
               BCS  IORSK8
IORSK7         STA  FTYSTR
IORSK8         RTS



SET80                          ; set eighty column screen
                               ; i: none
                               ; o: 80 column display enabled

               LDA  MACHID
               AND  #$02       ; ......1.  (80-column card)
               BNE  S8SK1
               JMP  EXIT
S8SK1          LDA  #$92
               JMP  ETYENTRY



ZEROBUFR                       ; zero block buffer
                               ; i: none
                               ; o: $0800-$0A01 zeroed

               LDX  #0
ZBLP           DFB  STZ,$00,$08 ; STZ $0800,X
               INX
               BNE  ZBLP
ZBLP2          DFB  STZ,$00,$09 ; STZ $0900,X
               INX
               BNE  ZBLP2
               DFB  STZ,$00,$0A
               DFB  STZ,$01,$0A
               RTS



PRPAGE                         ; print a full screen of bytes ($0100)
                               ; i: CURBAS: starting address
                               ; o: the printed page
                               ;         ADDR destroyed
                               ;         VTAB destroyed

               LDA  #4
               STA  VTAB
               LDA  CURBAS
               STA  ADDR
               LDA  CURBAS+1
               STA  ADDR+1
PRPLP1         JSR  PRLINE
               CLC
               LDA  ADDR
               ADC  #$10
               STA  ADDR
               LDA  ADDR+1
               ADC  #0
               STA  ADDR+1
               INC  VTAB
               LDA  VTAB
               CMP  #20
               BNE  PRPLP1
               RTS



PRLINE                         ; print a line of bytes
                               ; input : ADDR: address to start at (lo hi)
                               ;         VTAB: line number (0 org)
                               ; o: line is printed
               LDY  #0
               JSR  BASCALC    ; use VTAB to calculate BAS
               LDA  ADDR+1
               STA  PRLLDA1+2
               STA  PRLLDA2+2
               SEC
               SBC  #$08
               JSR  AOUT
               LDA  ADDR
               STA  PRLLDA1+1
               STA  PRLLDA2+1
               JSR  AOUT
               LDA  #":"
               JSR  COUT
               LDX  #0         ; output byte values
PRLLDA1        LDA  $FFFF,X
               JSR  AOUT
               TXA
               LSR
               BCC  PRLSK1
               LSR
               BCC  PRLSK1
               LDA  #$A0
               JSR  COUT
PRLSK1         INX
               CPX  #$10
               BNE  PRLLDA1
               LDA  #$A0       ; print two spaces
               JSR  COUT
               LDA  #$A0
               JSR  COUT
               LDX  #0         ; output characters
PRLLDA2        LDA  $FFFF,X
               JSR  COUT
               INX
               CPX  #$10
               BNE  PRLLDA2
               RTS



DSPTITLE                       ; display title
                               ; i: none
                               ; o: title displayed
                               ;         VTAB destroyed

               LDA  #0
               STA  VTAB
               JSR  BASCALC
               LDY  #0
               LDA  #$7F
               STA  INVMASK
               JSR  PRMESS
               ASC             "                                  "
               ASC             "B l o X a p"
               ASC             "                                   "
               DFB  0
               LDA  #$FF
               STA  INVMASK
               RTS



DSPOFS                         ; display offset addresses at top of page
                               ; i: none
                               ; o: hex numbers printed
                               ;         VTAB destroyed

               LDA  #3
               STA  VTAB
               JSR  BASCALC
               LDY  #5
               JSR  PRMESS
               ASC             "00010203 04050607 08090A0B 0C0D0E0F"
               ASC             "   "
               ASC             "0123456789ABCDEF"
               DFB  0
               RTS



DSPSTMES                       ; display status messages
                               ; i: none
                               ; o: messages displayed

               LDA  #21
               STA  VTAB
               JSR  BASCALC
               LDY  #0
               JSR  PRMESS
               ASC             "slot/drive:  /"
               DFB  0
               LDY  #12
               LDA  UNIT       ; dsss0000 .
               ASL             ; sss00000 d
               ASL             ; ss000000 s
               ROL             ; s000000s s
               ROL             ; 000000ss s
               ROL             ; 00000sss 0
               ORA  #$B0       ; 10110sss (ASCII)
               JSR  COUT
               INY
               LDA  UNIT       ; dsss0000
               BMI  DSSK1
               LDA  #$B1       ; 10110001 (ASCII) d = 0 (drive 1)
               BNE  DSSK2
DSSK1          LDA  #$B2       ; 10110010 (ASCII) d = 1 (drive 2)
DSSK2          JSR  COUT
               INC  VTAB
               JSR  BASCALC
               LDY  #5
               JSR  PRMESS
               ASC             "block: $"
               DFB  0
               LDY  #13
               LDA  BLOCK+1
               JSR  AOUT
               LDA  BLOCK
               JSR  AOUT
               RTS



DSPHELP                        ; display the "H" help command indicator
                               ; i: none
                               ; o: message printed
                               ;         VTAB preserved

               LDA  VTAB
               PHA
               JSR  CLRHELP
               LDA  #21
               STA  VTAB
               JSR  BASCALC
               LDY  #43
               JSR  PRMESS
               ASC             "Press H for help."
               DFB  0
               PLA
               STA  VTAB
               RTS



CLRHELP                        ; clear help command indicator
                               ; i: none
                               ; o: message cleared
                               ;         VTAB preserved

               LDA  VTAB
               PHA
               LDA  #21
               STA  VTAB
DHLP2          JSR  BASCALC
               LDY  #43
DHLP1          LDA  #$A0
               JSR  COUT
               CPY  #80
               BNE  DHLP1
               INC  VTAB
               LDA  VTAB
               CMP  #24
               BNE  DHLP2
               PLA
               STA  VTAB
               RTS



DSPINS                         ; display the block of instructions
                               ; i: CURBAS, CURY
                               ; o: instructions displayed
                               ;         ADDR, BAS destroyed
                               ;         VTAB preserved

               LDA  VTAB
               PHA
               CLC
               LDA  CURBAS
               ADC  CURY
               STA  ADDR
               LDA  CURBAS+1
               ADC  #0
               STA  ADDR+1
               LDY  #62
               LDA  #4
               STA  VTAB
PISLP1         JSR  BASCALC
               JSR  PRINS
               INC  VTAB
               LDA  ADDR+1
               CMP  #$0A
               BEQ  PISSK1
               LDA  VTAB
               CMP  #20
               BNE  PISLP1
               BEQ  EXPIS
PISSK1         JSR  CLRINS
EXPIS          PLA
               STA  VTAB
               RTS



PRINS                          ; print one instruction (ROM)
                               ; i: ADDR: address of op code
                               ;         BAS : base address
                               ;         Y   : HTAB (0 org)
                               ; o: one instruction printed
                               ;         ADDR: incremented to first byte
                               ;               following the instruction
                               ;         BAS preserved
                               ;         Y preserved

               DFB  PHY
               SEC
               LDA  ADDR+1     ; print address: "hilo:"
               SBC  #$08
               JSR  AOUT
               LDA  ADDR
               JSR  AOUT
               LDA  #":"
               JSR  COUT
               DFB  PHY
               LDX  #0
               LDA  (ADDR,X)   ; get opcode
               TAY             ; save opcode
               LSR
               BCC  PISK1
               ROR
               BCS  PIER
               AND  #$87       ; 10000111
PISK1          LSR
               TAX
               LDA  FMT1,X
               BCC  PISK2
               LSR
               LSR
               LSR
               LSR
PISK2          AND  #$0F       ; ....1111
               BNE  PISK3
PIER           LDY  #$FC
               LDA  #0
PISK3          TAX
               LDA  FMT2,X
               STA  BYTES
               AND  #$03       ; ......11
               STA  BYTES+1
               STA  ASTO
               TYA
               LDX  #$16
PILP1          CMP  OPTBL,X
               BEQ  PISK4
               DEX
               BPL  PILP1
               BMI  PISK5
PISK4          LDA  INDEX,X
               LDY  #0
PISK5          BEQ  PISK6
               AND  #$8F       ; 1...1111
               TAX
               TYA
               LDY  #3
               CPX  #$8A
               BEQ  PISK7
PILP3          LSR
               BCC  PISK7
               LSR
PILP2          LSR
               ORA  #$20
               DEY
               BNE  PILP2
               INY
PISK7          DEY
               BNE  PILP3
PISK6          LDX  #3
               TAY
               LDA  MNEML,Y
               STA  BYTES+2
               LDA  MNEMR,Y
               STA  BYTES+3
PILP4          LDA  #0
               LDY  #5
PILP5          ASL  BYTES+3
               ROL  BYTES+2
               ROL
               DEY
               BNE  PILP5
               ADC  #$BF
               DFB  PLY
               JSR  COUT
               DFB  PHY
               DEX
               BNE  PILP4
               DFB  PLY
               INY
               DFB  PHY
               LDX  #6
PILP6          CPX  #3
               BEQ  PISK9
PILP7          ASL  BYTES
               BCC  PISK8
               DFB  PLY
               LDA  CHAR1-1,X
               JSR  COUT
               LDA  CHAR2-1,X
               BEQ  PISK8A
               JSR  COUT
PISK8A         DFB  PHY
PISK8          DEX
               BNE  PILP6
               DFB  PLY
               JMP  PISK13
PILP8          DEC  BYTES+1
               BMI  PILP7
               DFB  PLY
               JSR  AOUT
               DFB  PHY
PISK9          LDY  BYTES+1
               LDA  BYTES
               CMP  #$E8
               LDA  (ADDR),Y
               BCC  PILP8
               LDY  ADDR+1
               TAX
               BPL  PISK10
               DEY
PISK10         ADC  ADDR
               BCC  PISK11
               INY
PISK11         TAX
               INX
               BNE  PISK12
               INY
PISK12         SEC
               TYA
               SBC  #$08
               DFB  PLY
               JSR  AOUT
               TXA
               JSR  AOUT
PILP9          LDA  #$A0
               JSR  COUT
PISK13         CPY  #80
               BNE  PILP9
               INC  ASTO
               CLC
               LDA  ADDR
               ADC  ASTO
               STA  ADDR
               LDA  ADDR+1
               ADC  #0
               STA  ADDR+1
               DFB  PLY
               RTS



CLRINS                         ; clear instruction block (below VTAB)
                               ; i: VTAB: line to clear down from
                               ; o: lines cleared (col. 62-79)

               LDA  VTAB
               CMP  #20
               BEQ  EXCI
               JSR  BASCALC
               LDY  #62
CILP1          LDA  #$A0
               JSR  COUT
               CPY  #80
               BNE  CILP1
               INC  VTAB
               JMP  CLRINS
EXCI           RTS



CUROUT                         ; output cursor
                               ; i: CURBAS: base byte address
                               ;         CURY:   offset byte in line
                               ;         VTAB:   line number
                               ; o: inverse cursor printed
                               ;         CURBAS, CURY, VTAB preserved

               LDA  VTAB
               PHA
               JSR  BASCALC    ; calculate BAS from VTAB
               LDY  #0
               SEC
               LDA  CURBAS+1
               SBC  #$08
               JSR  AINVOUT
               LDA  CURBAS
               JSR  AINVOUT
               LDA  CURY       ; calculate Y for AINVOUT (in A) and push
               TAY
               LSR
               LSR
               STA  ASTO
               TYA
               ASL
               ADC  #5
               ADC  ASTO
               PHA
               LDA  (CURBAS),Y ; get byte and push (first pl/ph Y for AINVOUT)
               DFB  PLY
               DFB  PHY
               PHA
               JSR  AINVOUT    ; output inverse byte value
               CLC             ; calculate Y for CINVOUT
               LDA  #43
               ADC  CURY
               TAY
               PLA             ; get byte
               JSR  CINVOUT    ; output inverse character
               LDA  #3
               STA  VTAB
               JSR  BASCALC
               DFB  PLY        ; get Y for AINVOUT from before
               LDA  CURY
               JSR  AINVOUT
               CLC             ; calculate Y for NIBOUT
               LDA  #43
               ADC  CURY
               TAY
               LDA  #$7F
               STA  INVMASK
               LDA  CURY
               JSR  NIBOUT
               LDA  #$FF
               STA  INVMASK
               PLA
               STA  VTAB
               RTS



CUROFF                         ; turn off cursor
                               ; i: CURBAS: base byte address
                               ;         CURY:   offset byte in line
                               ;         VTAB:   line number
                               ; o: inverse cursor removed
                               ;         CURBAS, CURY, VTAB preserved

               LDA  VTAB
               PHA
               JSR  BASCALC    ; calculate BAS from VTAB
               LDY  #0
               SEC
               LDA  CURBAS+1
               SBC  #$08
               JSR  AOUT
               LDA  CURBAS
               JSR  AOUT
               LDA  CURY       ; calculate Y for AOUT (in A) and push
               TAY
               LSR
               LSR
               STA  ASTO
               TYA
               ASL
               ADC  #5
               ADC  ASTO
               PHA
               LDA  (CURBAS),Y ; get byte and push (first pl/ph Y for AOUT)
               DFB  PLY
               DFB  PHY
               PHA
               JSR  AOUT       ; turn off inverse byte value
               CLC             ; calculate Y for CINVOUT
               LDA  #43
               ADC  CURY
               TAY
               PLA             ; get byte
               JSR  COUT       ; turn off inverse character
               LDA  #3
               STA  VTAB
               JSR  BASCALC
               DFB  PLY        ; get Y for AOUT from before
               LDA  CURY
               JSR  AOUT
               CLC             ; calculate Y for NIBOUT
               LDA  #43
               ADC  CURY
               TAY
               LDA  CURY
               JSR  NIBOUT
               PLA
               STA  VTAB
               RTS



SCROLLUP                       ; scroll monitor window up
                               ; i: none
                               ; o: window is scrolled up
                               ;         (bottom line not cleared)
                               ;         VTAB := 19

               STA  PAGE2
SULP1          LDY  #29
SULP2          LDA  $0680,Y
               STA  $0600,Y
               LDA  $0700,Y
               STA  $0680,Y
               LDA  $0780,Y
               STA  $0700,Y
               LDA  $0428,Y
               STA  $0780,Y
               LDA  $04A8,Y
               STA  $0428,Y
               LDA  $0528,Y
               STA  $04A8,Y
               LDA  $05A8,Y
               STA  $0528,Y
               LDA  $0628,Y
               STA  $05A8,Y
               LDA  $06A8,Y
               STA  $0628,Y
               LDA  $0728,Y
               STA  $06A8,Y
               LDA  $07A8,Y
               STA  $0728,Y
               LDA  $0450,Y
               STA  $07A8,Y
               LDA  $04D0,Y
               STA  $0450,Y
               LDA  $0550,Y
               STA  $04D0,Y
               LDA  $05D0,Y
               STA  $0550,Y
               DEY
               BPL  SULP2
               LDA  PAGE2?
               BPL  EXSU
               STA  PAGE1
               BMI  SULP1
EXSU           LDA  #19
               STA  VTAB
               RTS



SCROLLDW                       ; scroll monitor window down
                               ; i: none
                               ; o: window is scrolled down
                               ;         (top line not cleared)
                               ;         VTAB := 4

               STA  PAGE2
SDLP1          LDY  #29
SDLP2          LDA  $0550,Y
               STA  $05D0,Y
               LDA  $04D0,Y
               STA  $0550,Y
               LDA  $0450,Y
               STA  $04D0,Y
               LDA  $07A8,Y
               STA  $0450,Y
               LDA  $0728,Y
               STA  $07A8,Y
               LDA  $06A8,Y
               STA  $0728,Y
               LDA  $0628,Y
               STA  $06A8,Y
               LDA  $05A8,Y
               STA  $0628,Y
               LDA  $0528,Y
               STA  $05A8,Y
               LDA  $04A8,Y
               STA  $0528,Y
               LDA  $0428,Y
               STA  $04A8,Y
               LDA  $0780,Y
               STA  $0428,Y
               LDA  $0700,Y
               STA  $0780,Y
               LDA  $0680,Y
               STA  $0700,Y
               LDA  $0600,Y
               STA  $0680,Y
               DEY
               BPL  SDLP2
               LDA  PAGE2?
               BPL  EXSD
               STA  PAGE1
               BMI  SDLP1
EXSD           LDA  #4
               STA  VTAB
               RTS



GETBLOCK                       ; input block number
                               ; i: none
                               ; o: BLOCK
                               ;         ProDOS error message cleared
                               ;         VTAB destroyed

               LDA  #22
               STA  VTAB
               JSR  BASCALC
               LDY  #13
               LDA  BLOCK+1
               JSR  AINVOUT
GBLP2          JSR  FETCH
               LDX  #$0F
GBLP1          CMP  CMDTBL,X
               BEQ  GBSK2      ; if nibble, branch
               DEX
               BPL  GBLP1
               CMP  #$8D       ; <return>
               BNE  GBLP2
               LDA  BLOCK+1
               JMP  GBSK1
GBSK2          TXA
               ASL
               ASL
               ASL
               ASL
               STA  ASTO
               DEY
               DEY
               JSR  AINVOUT
GBLP4          JSR  FETCH
               LDX  #$0F
GBLP3          CMP  CMDTBL,X
               BEQ  GBSK3
               DEX
               BPL  GBLP3
               JMP  GBLP4
GBSK3          TXA
               ORA  ASTO
               DEY
               DEY
               STA  BLOCK+1
               JSR  AOUT
               LDA  BLOCK
               JSR  AINVOUT
GBLP6          JSR  FETCH
               LDX  #$0F
GBLP5          CMP  CMDTBL,X
               BEQ  GBSK4      ; if nibble, branch
               DEX
               BPL  GBLP5
               JMP  GBLP6
GBSK4          TXA
               ASL
               ASL
               ASL
               ASL
               STA  ASTO
               DEY
               DEY
               JSR  AINVOUT
GBLP8          JSR  FETCH
               LDX  #$0F
GBLP7          CMP  CMDTBL,X
               BEQ  GBSK5
               DEX
               BPL  GBLP7
               JMP  GBLP8
GBSK5          TXA
               ORA  ASTO
               STA  BLOCK
GBSK1          DEY
               DEY
               JSR  AOUT
               JSR  CLRERR
               RTS



ERROR                          ; print ProDOS error message
                               ; i: A: error number
                               ; o: message printed
                               ;         VTAB preserved
                               ;         buffer zeroed

               STA  ASTO
               LDA  VTAB
               PHA
               LDA  #21
               STA  VTAB
               JSR  BASCALC
               LDY  #19
               LDA  ASTO
               CMP  #ERRNODEV
               BNE  ERSK1
               JSR  PRMESS
               ASC             "(no device connected)"
               DFB  0,BRA,ERSK3-*-1
ERSK1          CMP  #ERRWP
               BNE  ERSK2
               JSR  PRMESS
               ASC             "(write protected)"
               DFB  0,BRA,ERSK3-*-1
ERSK2          JSR  PRMESS
               ASC             "(input/output error)"
               DFB  0
ERSK3          JSR  ZEROBUFR
               PLA
               STA  VTAB
               RTS



CLRERR                         ; clear ProDOS error message
                               ; i: none
                               ; o: message cleared
                               ;         VTAB destroyed

               LDA  #21
               STA  VTAB
               JSR  BASCALC
               LDY  #19
CELP1          LDA  #$A0
               JSR  COUT
               CPY  #42
               BNE  CELP1
               RTS



HOME                           ; clear entire screen
                               ; i: none
                               ; o: screen cleared
                               ;         VTAB destroyed

               LDA  #0
               STA  VTAB
               LDX  #23
               BEQ  CLRDOWN



TLSTHOME                       ; clear screen except for title and status mess.
                               ; i: none
                               ; o: lines 3-19

               LDA  #1
               STA  VTAB
               LDX  #19
               BNE  CLRDOWN



TLHOME                         ; clear screen except for title
                               ; i: none
                               ; o: lines 1-23 cleared
                               ;         VTAB destroyed

               LDA  #1
               STA  VTAB
               LDX  #23
                               ; fall through to clear down



CLRDOWN                        ; clear screen down
                               ; i: VTAB: line to clear down from
                               ;          X: bottom-most line to clear
                               ; o: screen cleared

               JSR  BASCALC
               LDA  BAS
               STA  HMSTA1+1
               STA  HMSTA2+1
               LDA  BAS+1
               STA  HMSTA1+2
               STA  HMSTA2+2
               LDA  #$A0
               STA  PAGE2
               LDY  #0
HMSTA1         STA  $FFFF,Y
               INY
               CPY  #40
               BNE  HMSTA1
               STA  PAGE1
               LDY  #0
HMSTA2         STA  $FFFF,Y
               INY
               CPY  #40
               BNE  HMSTA2
               INC  VTAB
               CPX  VTAB
               BCS  CLRDOWN
               RTS



GETHEX                         ; get hex nibble
                               ; i: none
                               ; o: A: hex nibble ($00 - $0F)
                               ;            $10 = <return>
                               ;         X destroyed

               JSR  FETCH
               LDX  #$10
               CMP  #$8D       ; <return>
               BEQ  GHSK1
               DEX
GHLP1          CMP  CMDTBL,X
               BEQ  GHSK1      ; if nibble, branch
               DEX
               BPL  GHLP1
               BMI  GETHEX
GHSK1          TXA
               RTS



PRMESS                         ; print message
                               ; i: message following JSR PRMESS
                               ;            terminated with $00
                               ;         BAS: base address
                               ;         Y:   HTAB (0 org)
                               ; o: message printed
                               ;         BAS preserved
                               ;         Y destroyed
                               ;         A destroyed

               PLA
               STA  PMLDA+1
               PLA
               STA  PMLDA+2
               LDX  #1
PMLDA          LDA  $FFFF,X
               BEQ  PMSK1
               JSR  COUT
               INX
               BNE  PMLDA
PMSK1          CLC
               TXA
               ADC  PMLDA+1
               TAY
               LDA  #0
               ADC  PMLDA+2
               PHA
               DFB  PHY
               RTS



CINVOUT                        ; output A to screen (character) inversed
                               ; input, output same as COUT

               PHA
               LDA  #$7F       ; 01111111 = inverse
               STA  INVMASK
               PLA
               JSR  COUT
               LDA  #$FF       ; 11111111 = normal
               STA  INVMASK
               RTS



COUT                           ; output A register to screen (character)
                               ; i: A  : value to be printed
                               ;         BAS: base address
                               ;         Y  : HTAB (0 org)
                               ; o: A destroyed
                               ;         BAS preserved
                               ;         Y incremented
                               ;         one character printed on the screen

               DFB  PHY
               PHA
               TYA
               LSR
               BCC  COSK2
               STA  PAGE1
               BCS  COSK3
COSK2          STA  PAGE2
COSK3          TAY
               PLA
               ORA  #$80       ; 10000000
               AND  INVMASK    ; i1111111 where i = 0:inverse, i = 1:normal
               PHA
               AND  #$60       ; 01100000
               CMP  #$40       ; .10.....
               BNE  COSK1
               PLA
               AND  #$BF       ; 10111111
               DFB  BIT        ; absorb PLA
COSK1          PLA
               STA  (BAS),Y
               DFB  PLY
               INY
               RTS



AINVOUT                        ; output A register to screen (value) inversed
                               ; input, output same as AOUT

               PHA
               LDA  #$7F       ; 01111111 = inverse
               STA  INVMASK
               PLA
               JSR  AOUT
               LDA  #$FF       ; 11111111 = normal
               STA  INVMASK
               RTS



AOUT                           ; output A register to screen (value)
                               ; i: A  : value to be printed
                               ;         BAS: base address
                               ;         Y  : HTAB (0 org)
                               ; o: A destroyed
                               ;         BAS preserved
                               ;         Y incremented by 2
                               ;         two characters printed on the screen

               PHA
               LSR
               LSR
               LSR
               LSR
               JSR  NIBOUT
               PLA
NIBOUT         DFB  PHY
               PHA
               TYA
               LSR
               BCC  AOSK2
               STA  PAGE1
               BCS  AOSK3
AOSK2          STA  PAGE2
AOSK3          TAY
               PLA
               AND  #$0F       ; 00001111
               ORA  #"0"       ; 10110000
               CMP  #"9"+1     ; see if A - F
               AND  INVMASK    ; i1111111 where i = 0:inverse, i = 1:normal
               BCC  AOSK1
               ADC  #$06       ; add 7
               AND  #$BF       ; 10111111
AOSK1          STA  (BAS),Y
               DFB  PLY
               INY
               RTS



MOUT                           ; output A register to screen (mouse character)
                               ; i: A  : mouse character to be printed
                               ;         BAS: base address
                               ;         Y  : HTAB (0 org)
                               ; o: A destroyed
                               ;         BAS preserved
                               ;         Y incremented
                               ;         one character printed on the screen

               DFB  PHY
               PHA
               TYA
               LSR
               BCC  MOSK2
               STA  PAGE1
               BCS  MOSK3
MOSK2          STA  PAGE2
MOSK3          TAY
               PLA
               AND  #$5F
               ORA  #$40
               STA  (BAS),Y
               DFB  PLY
               INY
               RTS



BASCALC                        ; text screen base address calculator (ROM)
                               ; i: VTAB: line number (0 org)
                               ; o: BAS:  base address (lo hi)

               LDA  VTAB
               LSR
               AND  #3
               ORA  #4
               STA  BAS+1
               LDA  VTAB
               AND  #$18
               BCC  BCS1
               ADC  #$7F
BCS1           STA  BAS
               ASL
               ASL
               ORA  BAS
               STA  BAS
               RTS



FETCH                          ; fetch a command (uppercase)
                               ; i: none
                               ; o: A: key pressed (A >= $80)

               JSR  WAITKEY
               CMP  #"a"
               BCC  EXFET
               CMP  #"z"+1
               BCS  EXFET
               AND  #$DF       ; 11011111  capitalize a-z
EXFET          RTS



WAITKEY                        ; wait for a keypress
                               ; i: none
                               ; o: A:character (A >= $80)
                               ;         strobe cleared

               STA  CLEARKBD
WKLP1          LDA  READKBD
               BPL  WKLP1
               STA  CLEARKBD
               RTS



EXECUTE                        ; execute a command
                               ; i: A: keypress (A >= $80)
                               ; o: command executed

               STA  ASTO
               LDX  #0
SRCHTBL        LDA  CMDTBL,X
               BEQ  NOTFND
               CMP  ASTO
               BEQ  FND
               INX
               BNE  SRCHTBL
NOTFND         RTS
FND            TXA
               ASL
               TAX
               DFB  JMP,<JMPTBL,>JMPTBL



HEX                            ; input a hexadecimal byte value
                               ; i: X: from EXECUTE routine
                               ;         CURBAS, CURY, VTAB
                               ; o: two characters read; value stored in
                               ;         memory; if second digit is invalid,
                               ;         then original value is restored, and
                               ;         value is executed as a command

               LDY  CURY
               LDA  (CURBAS),Y
               PHA             ; store old value
               TXA
               LSR             ; hex are first in CMDTBL
               STA  (CURBAS),Y
               PHA             ; store new most-significant nibble
               JSR  CUROUT
               JSR  FETCH      ; get next nibble (or command)
               LDY  CURY
               LDX  #$0F
HXLP1          CMP  CMDTBL,X
               BEQ  HXSK1      ; if nibble, branch
               DEX
               BPL  HXLP1
               TAX             ; if command, restore old value and execute
               PLA             ; forget most-significant nibble
               PLA
               STA  (CURBAS),Y
               TXA
               JMP  EXECUTE
HXSK1          STX  ASTO
               PLA             ; get most-significant nibble
               ASL
               ASL
               ASL
               ASL
               ORA  ASTO
               STA  (CURBAS),Y
               PLA             ; ignore old value
               JMP  RIGHT



UP                             ; move cursor up
               JSR  CUROFF
UPINTERN       LDA  VTAB
               CMP  #9
               BCS  UPSK1
               LDA  CURBAS+1
               CMP  #$08
               BNE  UPSK2
               LDA  CURBAS
               BEQ  EXUP
               CMP  #$50
               BCC  UPSK1
UPSK2          JSR  SCROLLDW
               JSR  UPSUB
               SEC
               LDA  CURBAS
               SBC  #$40
               STA  ADDR
               LDA  CURBAS+1
               SBC  #0
               STA  ADDR+1
               JSR  PRLINE
               LDA  #8
               STA  VTAB
EXUP           RTS
UPSK1          DEC  VTAB
UPSUB          SEC
               LDA  CURBAS
               SBC  #$10
               STA  CURBAS
               LDA  CURBAS+1
               SBC  #0
               STA  CURBAS+1
               RTS



DOWN                           ; move cursor down
               JSR  CUROFF
DWINTERN       LDA  VTAB
               CMP  #15
               BCC  DWSK1
               LDA  CURBAS+1
               CMP  #$09
               BNE  DWSK2
               LDA  CURBAS
               CMP  #$F0
               BEQ  EXDW
               CMP  #$B0
               BCS  DWSK1
DWSK2          JSR  SCROLLUP
               JSR  DWSUB
               CLC
               LDA  CURBAS
               ADC  #$40
               STA  ADDR
               LDA  CURBAS+1
               ADC  #0
               STA  ADDR+1
               JSR  PRLINE
               LDA  #15
               STA  VTAB
EXDW           RTS
DWSK1          INC  VTAB
DWSUB          CLC
               LDA  CURBAS
               ADC  #$10
               STA  CURBAS
               LDA  CURBAS+1
               ADC  #0
               STA  CURBAS+1
               RTS



LEFT                           ; move cursor left
               JSR  CUROFF
               LDA  CURY
               BNE  LFSK1
               LDA  VTAB
               CMP  #4
               BEQ  EXLF
               LDA  #$0F
               STA  CURY
               JMP  UPINTERN
LFSK1          DEC  CURY
EXLF           RTS



RIGHT                          ; move cursor right
               JSR  CUROFF
               LDA  CURY
               CMP  #$0F
               BNE  RTSK1
               LDA  VTAB
               CMP  #19
               BEQ  EXRT
               LDA  #0
               STA  CURY
               JMP  DWINTERN
RTSK1          INC  CURY
EXRT           RTS



BEGIN                          ; move to beginning of block
               JSR  CUROFF
               LDA  #$00
               STA  CURBAS
               LDA  #$08
               STA  CURBAS+1
               JSR  PRPAGE
               LDA  #4
               STA  VTAB
               LDY  #0
               STY  CURY
               RTS



END                            ; move to end of block
               JSR  CUROFF
               LDA  #$00
               STA  CURBAS
               LDA  #$09
               STA  CURBAS+1
               JSR  PRPAGE
               LDA  #$F0
               STA  CURBAS
               LDA  #19
               STA  VTAB
               LDY  #$0F
               STY  CURY
               RTS



READ                           ; read

               JSR  CUROFF
               JSR  CLRHELP
               LDA  VTAB
               PHA
               JSR  GETBLOCK   ; get block number
               PLA
               STA  VTAB
RDINTERN       JSR  MLI
               DFB  READ_BLOCK
               DFB  <PARMLIST,>PARMLIST
               BCC  RDSK1
               JSR  ERROR
RDSK1          LDA  CURBAS     ; i: VTAB, CURBAS
               PHA             ; o: print page of bytes
               LDA  CURBAS+1
               PHA
               LDA  VTAB
               PHA
               SEC
               SBC  #4
               ASL
               ASL
               ASL
               ASL
               STA  ASTO
               SEC
               LDA  CURBAS
               SBC  ASTO
               STA  CURBAS
               LDA  CURBAS+1
               SBC  #0
               STA  CURBAS+1
               JSR  PRPAGE
               PLA
               STA  VTAB
               PLA
               STA  CURBAS+1
               PLA
               STA  CURBAS
               RTS



WRITE                          ; write

               JSR  CUROFF
               JSR  CLRHELP
               LDA  VTAB
               PHA
               JSR  GETBLOCK   ; get block number
               PLA
               STA  VTAB
               JSR  MLI
               DFB  WRITE_BLOCK
               DFB  <PARMLIST,>PARMLIST
               BCC  EXWR
               JSR  ERROR
EXWR           RTS



TEXT                           ; text entry

               LDA  VTAB
               PHA
               JSR  CLRHELP
               LDA  #21
               STA  VTAB
               JSR  BASCALC
               LDY  #43
               JSR  PRMESS
               ASC             "Text entry mode."
               DFB  0
               INC  VTAB
               JSR  BASCALC
               LDY  #46
               JSR  PRMESS
               ASC             "<control>-A    toggle ascii: high"
               DFB  0
               INC  VTAB
               JSR  BASCALC
               LDY  #46
               JSR  PRMESS
               ASC             "<return>       exit text mode"
               DFB  0
               LDA  #4
               STA  VTAB
               JSR  CLRINS
               PLA
               STA  VTAB
               LDA  #$FF
               STA  TXSKTX+1
TXLP1          JSR  CUROUT
               JSR  WAITKEY
               CMP  #$FF       ; <delete>
               BEQ  TXSKLF
               CMP  #$A0       ; text
               BCS  TXSKTX
               CMP  #$8B       ; <up arrow>
               BEQ  TXSKUP
               CMP  #$8A       ; <down arrow>
               BEQ  TXSKDW
               CMP  #$88       ; <left arrow>
               BEQ  TXSKLF
               CMP  #$95       ; <right arrow>
               BEQ  TXSKRT
               CMP  #$8D       ; <return>
               BEQ  EXTX
               CMP  #$9B       ; <esc>
               BEQ  EXTX
               CMP  #$81       ; <control>-A
               BEQ  TXSKAS
               BNE  TXLP1
TXSKTX         AND  #$FF       ; mod by TXSKAS: $7F: low ASC.; $FF: high ASC.
               LDY  CURY
               STA  (CURBAS),Y
               JSR  RIGHT
               DFB  BRA,TXLP1-*-1
TXSKUP         JSR  UP
               DFB  BRA,TXLP1-*-1
TXSKDW         JSR  DOWN
               DFB  BRA,TXLP1-*-1
TXSKLF         JSR  LEFT
               DFB  BRA,TXLP1-*-1
TXSKRT         JSR  RIGHT
               DFB  BRA,TXLP1-*-1
TXSKAS         LDA  VTAB
               PHA
               LDA  #22
               STA  VTAB
               JSR  BASCALC
               LDY  #75
               LDA  TXSKTX+1   ; AND mask for high/low ASCII
               BPL  TXSK1
               JSR  PRMESS
               ASC             "low "
               DFB  0
               LDA  #$7F
               BNE  TXSK2
TXSK1          JSR  PRMESS
               ASC             "high"
               DFB  0
               LDA  #$FF
TXSK2          STA  TXSKTX+1
               PLA
               STA  VTAB
               DFB  BRA,TXLP1-*-1
EXTX
               RTS



SLOT                           ; change slot/drive

               JSR  CUROFF
               JSR  CLRHELP
               LDA  VTAB
               PHA
               LDA  #21
               STA  VTAB
               JSR  BASCALC
               LDY  #12
               LDA  UNIT       ; dsss0000 .
               ASL             ; sss00000 d
               ASL             ; ss000000 s
               ROL             ; s000000s s
               ROL             ; 000000ss s
               ROL             ; 00000sss 0
               ORA  #$B0       ; 10110sss (ASCII)
               STA  ASTO
               JSR  CINVOUT
SLLP1          JSR  WAITKEY
               CMP  #$8D       ; <return>
               BEQ  EXSL
               CMP  #"1"
               BCC  SLLP1
               CMP  #"7"+1
               BCS  SLLP1
               STA  ASTO       ; 10110sss (ASCII)
               ASL             ; 0110sss0
               ASL             ; 110sss00
               ASL             ; 10sss000
               ASL             ; 0sss0000
               ASL             ; sss00000
               ASL  UNIT       ; sss00000 d sss00000
               ROR             ; dsss0000 0 sss00000
               STA  UNIT
EXSL           LDA  ASTO
               DEY
               JSR  COUT
               LDA  UNIT       ; dsss0000
               BMI  SLSK1
               LDA  #$B1       ; 10110001 (ASCII) d = 0 (drive 1)
               BNE  SLSK2
SLSK1          LDA  #$B2       ; 10110010 (ASCII) d = 1 (drive 2)
SLSK2          INY
               STA  ASTO       ; 101100dD (ASCII)
               JSR  CINVOUT
DRLP1          JSR  WAITKEY
               CMP  #$8D       ; <return>
               BEQ  EXDR
               CMP  #"1"
               BCC  DRLP1
               CMP  #"2"+1
               BCS  DRLP1
               STA  ASTO       ; 101100dD 0 dsss0000
               ASL  UNIT       ; 101100dD d sss00000
               LSR             ; 0101100d D sss00000
               LSR             ; 00101100 d sss00000
               ROR  UNIT       ; 00101100 0 dsss0000
EXDR           LDA  ASTO
               DEY
               JSR  COUT
               JSR  CLRERR
               PLA
               STA  VTAB
               RTS



INCBLOCK                       ; increment block number

               JSR  CUROFF
               INC  BLOCK
               BNE  IBSK1
               INC  BLOCK+1
IBSK1          LDA  VTAB
               PHA
               LDA  #22
               STA  VTAB
               JSR  BASCALC
               LDY  #13
               LDA  BLOCK+1
               JSR  AOUT
               LDA  BLOCK
               JSR  AOUT
               JSR  CLRERR
               PLA
               STA  VTAB
               JMP  RDINTERN



DECBLOCK                       ; decrement block number

               JSR  CUROFF
               DEC  BLOCK
               LDA  BLOCK
               CMP  #$FF
               BNE  DBSK1
               DEC  BLOCK+1
DBSK1          JMP  IBSK1



HELP                           ; help

               LDA  VTAB
               PHA
               JSR  TLHOME
               LDA  #3         ; VTAB 3
               STA  VTAB
               JSR  BASCALC
               LDY  #0
               JSR  PRMESS
               ASC             "The following commands are available:"
               DFB  0
               LDA  #5         ; VTAB 5
               STA  VTAB
               JSR  BASCALC
               LDY  #4
               JSR  PRMESS
               ASC             "Cursor movement."
               DFB  0
               LDY  #40
               JSR  PRMESS
               ASC             "Input/output."
               DFB  0
               INC  VTAB       ; VTAB 6
               JSR  BASCALC
               LDY  #4
               JSR  PRMESS
               ASC             "I    up"
               DFB  0
               LDY  #6
               LDA  #"K"
               JSR  MOUT
               LDY  #40
               JSR  PRMESS
               ASC             "R        read block"
               DFB  0
               INC  VTAB       ; VTAB 7
               JSR  BASCALC
               LDY  #4
               JSR  PRMESS
               ASC             "K    down"
               DFB  0
               LDY  #6
               LDA  #"J"
               JSR  MOUT
               LDY  #40
               JSR  PRMESS
               ASC             "W        write block"
               DFB  0
               INC  VTAB       ; VTAB 8
               JSR  BASCALC
               LDY  #4
               JSR  PRMESS
               ASC             "J    left"
               DFB  0
               LDY  #6
               LDA  #"H"
               JSR  MOUT
               LDY  #40
               JSR  PRMESS
               ASC             "= + . >  read next block"
               DFB  0
               INC  VTAB       ; VTAB 9
               JSR  BASCALC
               LDY  #4
               JSR  PRMESS
               ASC             "L    right"
               DFB  0
               LDY  #6
               LDA  #"U"
               JSR  MOUT
               LDY  #40
               JSR  PRMESS
               ASC             "- _ , <  read previous block"
               DFB  0
               INC  VTAB       ; VTAB 10
               JSR  BASCALC
               LDY  #4
               JSR  PRMESS
               ASC             "U    beginning"
               DFB  0
               LDY  #40
               JSR  PRMESS
               ASC             "S        change slot/drive"
               DFB  0
               INC  VTAB       ; VTAB 11
               JSR  BASCALC
               LDY  #4
               JSR  PRMESS
               ASC             "O    end"
               DFB  0
               LDA  #13        ; VTAB 13
               STA  VTAB
               JSR  BASCALC
               LDY  #4
               JSR  PRMESS
               ASC             "Editing."
               DFB  0
               LDY  #40
               JSR  PRMESS
               ASC             "Other."
               DFB  0
               INC  VTAB       ; VTAB 14
               JSR  BASCALC
               LDY  #4
               JSR  PRMESS
               ASC             "0-9, A-F  hexadecimal"
               DFB  0
               LDY  #40
               JSR  PRMESS
               ASC             "<esc>  exit BloXap"
               DFB  0
               INC  VTAB       ; VTAB 15
               JSR  BASCALC
               LDY  #4
               JSR  PRMESS
               ASC             "T         text"
               DFB  0
               LDY  #40
               JSR  PRMESS
               ASC             "H      display this help screen"
               DFB  0
               INC  VTAB       ; VTAB 16
               JSR  BASCALC
               LDY  #40
               JSR  PRMESS
               ASC             "?      scan for bytes"
               DFB  0
               LDA  #23        ; VTAB 23
               STA  VTAB
               JSR  BASCALC
               LDY  #27
               JSR  PRMESS
               ASC             "Press any key to continue."
               DFB  0
               JSR  WAITKEY
               PLA
               STA  VTAB
               JMP  WARMUP     ; exit through WARMUP



SCAN                           ; scan for bytes

               LDA  VTAB
               PHA
               JSR  CUROFF
               JSR  CLRHELP
               JSR  TLSTHOME
               LDA  #21
               STA  VTAB
               JSR  BASCALC
               LDY  #43
               JSR  PRMESS
               ASC             "Scan for specified bytes."
               DFB  0
               LDA  #4
               STA  VTAB
               JSR  BASCALC
               LDY  #5
               JSR  PRMESS
               ASC             "Specify <t>ext or <h>exadecimal?"
               DFB  0
SCLP1          JSR  FETCH
               CMP  #"T"
               BNE  SCSK3
               JMP  SCSKT
SCSK3          CMP  #"H"
               BNE  SCLP1
               LDY  #5
               JSR  PRMESS
               ASC             "Enter hex:                      "
               DFB  0
               LDA  #6
               STA  VTAB
               JSR  BASCALC
               LDA  #0
               STA  ASTO
SCLP6          CLC
               LDA  ASTO
               TAY
               LSR
               LSR
               STA  ASTO
               TYA
               ASL
               ADC  #5
               ADC  ASTO
               STY  ASTO
               TAY
               LDA  #$A0
               JSR  CINVOUT
               LDA  #$A0
               JSR  CINVOUT
               JSR  GETHEX
               CMP  #$10       ; <return>
               BEQ  SCSK1
               ASL
               ASL
               ASL
               ASL
               LDX  ASTO
               STA  BYTES,X
               DEY
               DEY
               JSR  AINVOUT
               JSR  GETHEX
               LDX  ASTO
               ORA  BYTES,X
               STA  BYTES,X
               DEY
               DEY
               PHA
               JSR  AOUT
               CLC
               LDA  #43
               ADC  ASTO
               TAY
               PLA
               JSR  COUT
               INC  ASTO
               LDA  ASTO
               CMP  #$10
               BNE  SCLP6
               JMP  SCSKS
SCSK1          DEY
               DEY
               LDA  #$A0
               JSR  COUT
               LDA  #$A0
               JSR  COUT
               BNE  SCSKS

SCSKT
               LDY  #5
               JSR  PRMESS
               ASC             "Enter text:                     "
               DFB  0
               LDA  #6
               STA  VTAB
               JSR  BASCALC
               LDA  #0
               STA  ASTO
SCLP7          CLC
               LDA  ASTO
               ADC  #43
               TAY
               LDA  #$A0
               JSR  CINVOUT
               JSR  WAITKEY
               CMP  #$8D
               BEQ  SCSK2
               LDX  ASTO
               STA  BYTES,X
               DEY
               JSR  COUT
               LDA  ASTO
               TAX
               TAY
               LSR
               LSR
               STA  ASTO
               TYA
               ASL
               ADC  #5
               ADC  ASTO
               TAY
               LDA  BYTES,X
               STX  ASTO
               JSR  AOUT
               INC  ASTO
               LDA  ASTO
               CMP  #$10
               BNE  SCLP7
SCSK2          DEY
               LDA  #$A0
               JSR  COUT
SCSKS
               LDA  ASTO
               BEQ  EXSC
               DEC  ASTO
               JSR  MLI
               DFB  READ_BLOCK
               DFB  <PARMLIST,>PARMLIST
               BCC  SCSK4
               JSR  ERROR
SCSK4
               LDX  ASTO
               CLC
               LDA  CURBAS
               ADC  CURY
               STA  SCLDA+1
               LDA  CURBAS+1
               ADC  #0
               STA  SCLDA+2
               LDA  #22
               STA  VTAB
               JSR  BASCALC
SCLP2          LDX  #0
SCLDA          LDA  $FFFF,X
               CMP  BYTES,X
               BEQ  SCSK5
               INC  SCLDA+1
               BNE  SCLDA
               INC  SCLDA+2
               LDA  SCLDA+2
               CMP  #$0A       ; past $09FF *** FIX cross-block scan ***
               BNE  SCLDA
               INC  BLOCK
               BNE  SCSK6
               INC  BLOCK+1
SCSK6          LDY  #13
               LDA  BLOCK+1
               JSR  AOUT
               LDA  BLOCK
               JSR  AOUT
               LDA  #0
               STA  SCLDA+1
               LDA  #$08
               STA  SCLDA+2
               BNE  SCLP2
SCSK5
               INX
               CPX  #$10
               BNE  SCLDA
                               ; found bytes!

EXSC
               PLA
               STA  VTAB
               RTS



EXIT                           ; exit BloXap

               PLA
               PLA
               LDA  #$15
               JSR  ETYENTRY
               JSR  MLI
               DFB  QUIT
               DFB  <EX1,>EX1
EX1            DFB  4
               DFB  0,0,0,0,0,0
