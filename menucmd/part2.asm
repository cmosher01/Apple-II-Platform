                               ;
                               ; Menu Command
                               ;   part 2: the command handler
                               ;
                               ;
                               ; Christopher A. Mosher
                               ; February 1988
                               ;



               ORG  $8700



                               ; 65C02 op codes
BIT            EQU  $89        ; BIT #$FF
BRA            EQU  $80
INC            EQU  $1A        ; INC A
JMP            EQU  $7C        ; JMP ($FFFF,X)
PHY            EQU  $5A
PLY            EQU  $7A



                               ; page $00 locations
BAS            EQU  $FA        ; text screen base address ($FA-$FB)
ADDR2          EQU  $FC        ; address storage register ($FC-$FD)
ADDR           EQU  $FE        ; address storage register ($FE-$FF)



                               ; ProDOS System Global Page
MLI            EQU  $BF00      ; machine language interface
CREATE                         EQU $C0
DESTROY                        EQU $C1
RENAME                         EQU $C2
SET_FILE_INFO                  EQU $C3
GET_FILE_INFO                  EQU $C4
ONLINE                         EQU $C5
OPEN                           EQU $C8
READ                           EQU $CA
CLOSE                          EQU $CC



                               ; BASIC interpreter system global page
BIENTRY        EQU  $BE00      ; warmstart
PRINTERR       EQU  $BE0C      ; error message printer
ERIO           EQU  $08        ; i/o error
ERNOBUF        EQU  $0C        ; no buffers available
PBITS          EQU  $BE54      ; permitted bits for keyword parsing
CMDLIN         EQU  $BE6C      ; address of command line (lo hi)
TDIR           EQU  $0F        ; directory file type



                               ; page $C0 locations
READKBD        EQU  $C000
CLEARKBD       EQU  $C010
PAGE2OF        EQU  $C054
PAGE2ON        EQU  $C055



                               ; Monitor ROM locations
HOME           EQU  $FC58



                               ; Menu Command part 2

               CLD             ; identify to BASIC Interpreter System
               LDA  CMDLIN
               STA  MLDA+1
               LDA  CMDLIN+1
               STA  MLDA+2
               LDX  CMDTXT     ; length of command
MLDA           LDA  $FFFF,X
               CMP  CMDTXT,X
               BNE  NOTMINE
               DEX
               BNE  MLDA
               JSR  INIT
               JMP  MAINLOOP
NOTMINE        SEC             ; handle action if command is not mine
NXTCMD         JMP  $FFFF      ; link to next command handler
                               ; modified by part 1



INVMASK        DFB  $FF        ; inverse mask (i1111111 where i: 1:norm 0:inv)
VTAB           DFB  $00
HTAB           DFB  $00



CMDTXT                         ; text of command (0.......)
               DFB  $04        ; length
               ASC  'MENU'



NAMELIST       DS   $0961      ; list of filenames (big enough for 150 entries)
                               ; list of name entries terminated with $00
                               ; name entry:
                               ;   +$0/$E: name
                               ;   +$F   : type
NAMEOFF        DFB  $00        ; offset in NAMELIST of current displayed page
FILE           DFB  0          ; reference number of currently open file
ENTRLEN        DFB  $00
ENTRS          DFB  $00
ASTO           DFB  0



CMDTBL                         ; command table
               ASC             "RLDUSPX"
               DFB  0



JMPTBL                         ; jump table
               DFB  <RUN,>RUN,<LOAD,>LOAD
               DFB  <DELETE,>DELETE,<UNLOCK,>UNLOCK
               DFB  <SUBDIR,>SUBDIR,<PARDIR,>PARDIR
               DFB  <EXIT,>EXIT



MAINLOOP       JSR  CLRCMD
               LDA  PREFIX
               BEQ  MSK3
               JSR  GETFILES
               DFB  BRA,MSK4-*-1
MSK3           JSR  GETVOLS
MSK4           JSR  DSPNAMES
REFETCH        JSR  FETCH
               JSR  EXECUTE
               JMP  MAINLOOP



               DS   $9100-*
BUFR           DS   $0400      ; one kilobyte buffer



PREFIX                         ; prefix (initially empty)
               DFB  $00        ; length
               DS   $40



INIT                           ; initialization routine
                               ; input:  none
                               ; output: none

               JSR  HOME
               LDA  #0
               STA  PREFIX
               JSR  DSPCMDS
               RTS



DSPCMDS                        ; display commands
                               ; input:  none
                               ; output: command window displayed

               LDA  #1
               STA  VTAB
               JSR  BASCALC
               LDY  #9
               JSR  PRMESS
               ASC             "R  run"
               DFB  0
               LDY  #29
               JSR  PRMESS
               ASC             "D  delete"
               DFB  0
               LDY  #48
               JSR  PRMESS
               ASC             "S  subdirectory"
               DFB  0
               LDY  #68
               JSR  PRMESS
               ASC             " "
               DFB  0
               LDA  #3
               STA  VTAB
               JSR  BASCALC
               LDY  #9
               JSR  PRMESS
               ASC             "L  load"
               DFB  0
               LDY  #29
               JSR  PRMESS
               ASC             "U  (un)lock"
               DFB  0
               LDY  #48
               JSR  PRMESS
               ASC             "P  parent directory"
               DFB  0
               LDY  #68
               JSR  PRMESS
               ASC             "X  exit"
               DFB  0
               RTS



GETVOLS                        ; get file names of all volumes on line
                               ; input:  none
                               ; output: NAMELIST, NAMEOFF

               JSR  RDVOLS
               LDA  #<BUFR
               STA  ADDR
               LDA  #>BUFR
               STA  ADDR+1
               LDA  #<NAMELIST
               STA  ADDR2
               LDA  #>NAMELIST
               STA  ADDR2+1
               LDA  #0
               STA  NAMEOFF
GVLP3          LDY  #0
               LDA  (ADDR),Y   ; identification byte
               BEQ  EXGV       ; if 0 then no more entries
               AND  #$0F       ; ....1111  length
               BEQ  GVSK1
               PHA
               TAY
               LDA  #$A0
GVLP2          STA  (ADDR2),Y
               INY
               CPY  #$0F
               BNE  GVLP2
               DFB  PLY
GVLP1          LDA  (ADDR),Y
               DEY
               STA  (ADDR2),Y
               BNE  GVLP1
               LDY  #$0F
               LDA  #TDIR
               STA  (ADDR2),Y
               CLC
               LDA  ADDR2
               ADC  #$10
               STA  ADDR2
               LDA  ADDR2+1
               ADC  #0
               STA  ADDR2+1
GVSK1          LDA  ADDR
               ADC  #$10
               STA  ADDR
               LDA  ADDR+1
               ADC  #0
               STA  ADDR+1
               DFB  BRA,GVLP3-*-1
EXGV           STA  (ADDR2),Y  ; indicate end of NAMELIST
               RTS



RDVOLS                         ; read volumes on line
                               ; input:  none
                               ; output: list of volumes in BUFR:
                               ;         list of zero or more VOL entries,
                               ;         terminated with $00
                               ;         VOL entry:
                               ;           +$0   : dsssllll where:
                               ;                             d    drive (0/1)
                               ;                             sss  slot
                               ;                             llll length
                               ;                                  if 0, error
                               ;                                  return code
                               ;                                  in +$1
                               ;           +$1/$F: volume name (no initial "/")
                               ;         or appropriate error handling

               JSR  MLI
               DFB  ONLINE
               DFB  <OLPARMS,>OLPARMS
               BCC  RVSK1
               LDA  #ERNOBUF
               JSR  PRINTERR
               JMP  BIENTRY
OLPARMS                        ; parameter list
               DFB  $02        ; 2 parameters
               DFB  $00        ; unit number ($00 = all)
               DFB  <BUFR,>BUFR ; buffer address
RVSK1          RTS



GETFILES                       ; get file names
                               ; input:  PREFIX
                               ; output: NAMELIST, NAMEOFF

               JSR  MLI
               DFB  OPEN
               DFB  <OPPARMS,>OPPARMS
               BCC  GFSK1
               LDA  #ERIO
               JSR  PRINTERR
               JMP  BIENTRY
OPPARMS        DFB  $03        ; 3 parameters
               DFB  <PREFIX,>PREFIX ; address of pathname
               DFB  <BUFR,>BUFR ; address of buffer
               DFB  $00        ; reference number
GFSK1          LDA  OPPARMS+5
               STA  FILE       ; reference number
               STA  RDPARMS+1
               JSR  MLI
               DFB  READ
               DFB  <RDPARMS,>RDPARMS
               BCC  GFSK2
               LDA  #ERIO
               JSR  PRINTERR
               JMP  BIENTRY
RDPARMS        DFB  $04        ; 4 parameters
               DFB  $00        ; reference number
               DFB  <NAMELIST,>NAMELIST ; address of data buffer
               DFB  $00,$08    ; requested length (blocks 2 thru 5)
               DFB  $00,$00    ; actual length
GFSK2          LDA  FILE
               STA  CLPARMS+1
               JSR  MLI
               DFB  CLOSE
               DFB  <CLPARMS,>CLPARMS
               BCC  GFSK1A
               LDA  #ERIO
               JSR  PRINTERR
               JMP  BIENTRY
CLPARMS        DFB  $01        ; 1 parameter
               DFB  $00        ; reference number
GFSK1A         LDA  #<NAMELIST
               STA  ADDR
               STA  ADDR2
               LDA  #>NAMELIST
               STA  ADDR+1
               STA  ADDR2+1

               LDY  #$23
               LDA  (ADDR),Y   ; length of each file descriptive entry
               STA  ENTRLEN
               LDY  #$25
               LDA  (ADDR),Y   ; file count (only one byte long, for now)
               BNE  GFSK3A
               LDY  #$FF
               BNE  GFEX
GFSK3A         STA  ENTRS
                               ; INY
                               ; LDA (ADDR),Y
                               ; STA ENTRS+1

               CLC
               LDA  ADDR
               ADC  #$2B       ; length of directory header
               STA  ADDR
               LDA  ADDR+1
               ADC  #0
               STA  ADDR+1

GFLP3          LDY  #0
               LDA  (ADDR),Y
               BEQ  GFSK3      ; if deleted entry then branch
               AND  #$0F       ; ....1111  length of filename
               PHA
               TAY
GFLP1          LDA  (ADDR),Y
               DEY
               STA  (ADDR2),Y
               BNE  GFLP1
               DFB  PLY
               LDA  #$A0
GFLP2          STA  (ADDR2),Y
               INY
               CPY  #$0F
               BNE  GFLP2
               INY
               LDA  (ADDR),Y   ; filetype
               DEY
               STA  (ADDR2),Y

               DEC  ENTRS
               BEQ  GFEX

               CLC
               LDA  ADDR2
               ADC  #$10
               STA  ADDR2
               LDA  ADDR2+1
               ADC  #0
               STA  ADDR2+1
GFSK3          CLC
               LDA  ADDR
               ADC  ENTRLEN
               STA  ADDR
               LDA  ADDR+1
               ADC  #0
               STA  ADDR+1
               DFB  BRA,GFLP3-*-1

GFEX           INY
               LDA  #0
               STA  (ADDR2),Y  ; terminating $00
               STA  NAMEOFF
               RTS



DSPNAMES                       ; display names
                               ; input:  NAMELIST, NAMEOFF
                               ; output: names displayed

               JSR  CLRNAMES
               JSR  DSPPRFX
                               ; ASTO     C A
               LDA  #0         ; ........ . 00000000
               STA  ASTO       ; 00000000 . 00000000
               LDA  NAMEOFF    ; 00000000 . abcdefgh
               ASL             ; 00000000 a bcdefgh0
               ROL  ASTO       ; 0000000a 0 bcdefgh0
               ASL             ; 0000000a b cdefgh00
               ROL  ASTO       ; 000000ab 0 cdefgh00
               ASL             ; 000000ab c defgh000
               ROL  ASTO       ; 00000abc 0 defgh000
               ASL             ; 00000abc d efgh0000
               ROL  ASTO       ; 0000abcd 0 efgh0000
               ADC  #<NAMELIST
               STA  ADDR
               LDA  ASTO
               ADC  #>NAMELIST
               STA  ADDR+1
               LDA  #"A"-1
               PHA
               LDA  #9
               STA  VTAB
               STA  ASTO
DNLP2          LDA  ASTO
               STA  HTAB
               JSR  BASCALC
               LDY  #0
               LDA  (ADDR),Y
               BEQ  EXDN
               LDY  HTAB
               PLA
               DFB  INC
               PHA
               JSR  CINVOUT
               LDA  #$A0
               JSR  COUT
               LDA  #$A0
               JSR  COUT
               STY  HTAB
               LDY  #0
DNLP1          LDA  (ADDR),Y
               DFB  PHY
               LDY  HTAB
               JSR  COUT
               STY  HTAB
               DFB  PLY
               INY
               CPY  #$0F
               BNE  DNLP1
               LDA  (ADDR),Y   ; type
               PHA
               LDY  HTAB
               LDA  #$A0
               JSR  COUT
               LDA  #$A0
               JSR  COUT
               PLA
               JSR  DSPTYPE
               CLC
               LDA  ADDR
               ADC  #$10
               STA  ADDR
               LDA  ADDR+1
               ADC  #0
               STA  ADDR+1
               INC  VTAB
               LDA  VTAB
               CMP  #24
               BNE  DNLP2
               LDA  #9
               STA  VTAB
               LDA  #48
               STA  ASTO
               BNE  DNLP2

EXDN           PLA
               RTS



CLRNAMES                       ; clear filename display section
                               ; input:  none
                               ; output: screen cleared from line 9 on

               LDA  #9
               STA  VTAB
CNLP2          JSR  CLRLIN
               INC  VTAB
               LDA  VTAB
               CMP  #24
               BNE  CNLP2
               RTS



CLRCMD                         ; clear command display section
                               ; input:  none
                               ; output: line 5 cleared

               LDA  #5
               STA  VTAB
               JMP  CLRLIN



CLRPRFX                        ; clear prefix display section
                               ; input:  none
                               ; output: line 7 cleared

               LDA  #7
               STA  VTAB
               JMP  CLRLIN



CLRLIN                         ; clear one line
                               ; input:  VTAB
                               ; output: line cleared

               JSR  BASCALC
               LDY  #0
               LDA  #$A0
CCLP1          JSR  COUT
               CPY  #40
               BNE  CCLP1
               RTS



DSPPRFX                        ; display prefix
                               ; input:  PREFIX
                               ; output: prefix printed (plus term. /)

               JSR  CLRPRFX
               LDY  #0
               LDA  PREFIX
               BEQ  DPSK1
               STA  ASTO
DPLP1          LDA  PREFIX+1,Y
               JSR  COUT
               CPY  ASTO
               BNE  DPLP1
DPSK1          LDA  #"/"
               JSR  COUT
               RTS



DSPTYPE                        ; display filetype
                               ; input:  A: filetype
                               ;         BAS: base address
                               ;         Y: HTAB (0 org)
                               ; output: three characters displayed
                               ;         BAS preserved
                               ;         Y incremented by 3
                               ;         A destroyed

               PHA
               LDA  #"$"
               JSR  COUT
               PLA
               JSR  AOUT
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
                               ; input:  A  : value to be printed
                               ;         BAS: base address
                               ;         Y  : HTAB (0 org)
                               ; output: A destroyed
                               ;         BAS preserved
                               ;         Y incremented
                               ;         one character printed on the screen

               DFB  PHY
               PHA
               TYA
               LSR
               BCC  COSK2
               STA  PAGE2OF
               BCS  COSK3
COSK2          STA  PAGE2ON
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



PRMESS                         ; print message
                               ; input:  message following JSR PRMESS
                               ;            terminated with $00
                               ;         BAS: base address
                               ;         Y:   HTAB (0 org)
                               ; output: message printed
                               ;         BAS preserved
                               ;         Y destroyed
                               ;         ADDR destroyed
                               ;         A destroyed

               PLA
               STA  ADDR
               PLA
               STA  ADDR+1
               LDX  #1
PMLP1          DFB  PHY
               TXA
               TAY
               LDA  (ADDR),Y
               BEQ  PMSK1
               DFB  PLY
               JSR  COUT
               INX
               BNE  PMLP1
PMSK1          DFB  PLY
               CLC
               TXA
               ADC  ADDR
               TAY
               LDA  #0
               ADC  ADDR+1
               PHA
               DFB  PHY
               RTS



BASCALC                        ; text screen base address calculator (ROM)
                               ; input:  VTAB: line number (0 org)
                               ; output: BAS:  base address (lo hi)

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



FETCH                          ; fetch a command
                               ; input:  none
                               ; output: A: key pressed (A >= $80)

               STA  CLEARKBD
WAITKEY        LDA  READKBD
               BPL  WAITKEY
               STA  CLEARKBD
               CMP  #"a"
               BCC  EXFET
               CMP  #"z"+1
               BCS  EXFET
               AND  #$DF       ; 11011111  capitalize a-z
EXFET          RTS



EXECUTE                        ; execute a command
                               ; input:  A: keypress (A >= $80)
                               ; output: command executed

               STA  ASTO
               LDX  #0
SRCHTBL        LDA  CMDTBL,X
               BEQ  NOTFND
               CMP  ASTO
               BEQ  FND
               INX
               BNE  SRCHTBL
NOTFND         PLA
               PLA
               JMP  REFETCH
FND            TXA
               ASL
               TAX
               DFB  JMP,<JMPTBL,>JMPTBL



AOUT                           ; output A register to screen (value)
                               ; input:  A  : value to be printed
                               ;         BAS: base address
                               ;         Y  : HTAB (0 org)
                               ; output: A destroyed
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
               STA  PAGE2OF
               BCS  AOSK3
AOSK2          STA  PAGE2ON
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



RUN                            ; Run command handler

               LDA  #5
               STA  VTAB
               JSR  BASCALC
               LDY  #0
               JSR  PRMESS
               ASC             "RUN "
               DFB  0
               JSR  FETCH
               PLA
               PLA
               JMP  $FF69
               RTS



LOAD                           ; Load command handler

               LDA  #5
               STA  VTAB
               JSR  BASCALC
               LDY  #0
               JSR  PRMESS
               ASC             "LOAD "
               DFB  0
               JSR  FETCH
               RTS



DELETE                         ; Delete command handler

               RTS



UNLOCK                         ; (Un)Lock command handler

               RTS



SUBDIR                         ; Subdirectory command handler


               LDA  #5
               STA  VTAB
               JSR  BASCALC
               LDY  #0
               JSR  PRMESS
               ASC             "SUBDIRECTORY"
               DFB  0
                               ; ASTO     C A
               LDA  #0         ; ........ . 00000000
               STA  ASTO       ; 00000000 . 00000000
               LDA  NAMEOFF    ; 00000000 . abcdefgh
               ASL             ; 00000000 a bcdefgh0
               ROL  ASTO       ; 0000000a 0 bcdefgh0
               ASL             ; 0000000a b cdefgh00
               ROL  ASTO       ; 000000ab 0 cdefgh00
               ASL             ; 000000ab c defgh000
               ROL  ASTO       ; 00000abc 0 defgh000
               ASL             ; 00000abc d efgh0000
               ROL  ASTO       ; 0000abcd 0 efgh0000
               ADC  #<NAMELIST
               STA  ADDR
               LDA  ASTO
               ADC  #>NAMELIST
               STA  ADDR+1
               LDA  #0
               STA  ASTO
SBLP1          JSR  FETCH
               SEC
               SBC  #"A"       ; 00000000 . abcdefgh
               BCC  SBLP1
               CMP  #$1E
               BCS  SBLP1
               ASL             ; 00000000 a bcdefgh0
               ROL  ASTO       ; 0000000a 0 bcdefgh0
               ASL             ; 0000000a b cdefgh00
               ROL  ASTO       ; 000000ab 0 cdefgh00
               ASL             ; 000000ab c defgh000
               ROL  ASTO       ; 00000abc 0 defgh000
               ASL             ; 00000abc d efgh0000
               ROL  ASTO       ; 0000abcd 0 efgh0000
               ADC  ADDR
               STA  ADDR
               LDA  ASTO
               ADC  ADDR+1
               STA  ADDR+1
               LDY  #$0F
               LDA  (ADDR),Y   ; filetype
               CMP  #TDIR
               BNE  SDSK1
               LDX  PREFIX
               LDY  #0
               LDA  #'/'
SDLP2          STA  PREFIX+1,X
               LDA  (ADDR),Y
               INX
               INY
               AND  #$7F       ; 01111111
               CMP  #$20
               BNE  SDLP2
               STX  PREFIX
SDSK1          RTS



PARDIR                         ; Parent Directory command handler

               LDA  #5
               STA  VTAB
               JSR  BASCALC
               LDY  #0
               JSR  PRMESS
               ASC             "PARENT DIRECTORY"
               DFB  0
               LDX  PREFIX
               BEQ  PDEX
PDLP1          LDA  PREFIX,X
               CMP  #'/'
               BEQ  PDSK1
               DEX
               BNE  PDLP1
PDSK1          DEX
               STX  PREFIX
PDEX           RTS



EXIT           PLA
               PLA
               LDA  #0
               STA  PBITS
               CLC
               RTS
