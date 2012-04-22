                               ;
                               ; Block Zap
                               ; incorporating
                               ; The Monitor
                               ;
                               ; written by Christopher A. Mosher
                               ; February 1988
                               ;




               ORG  $2000



                               ; new 65C02 opcodes
BRA            EQU  $80        ; BRA  $FFFF (offset)
INA            EQU  $1A        ; INA
DEA            EQU  $3A        ; DEA
PHY            EQU  $5A        ; PHY
PLY            EQU  $7A        ; PLY
PHX            EQU  $DA        ; PHX
PLX            EQU  $FA        ; PLX
BIT            EQU  $89        ; BIT  #$FF
JMP            EQU  $7C        ; JMP  ($FFFF,X)



                               ; page $00 locations
BAS            EQU  $FA        ; base address register for printing (lo hi)
CURBAS         EQU  $FC        ; base address register for cursor (lo hi)
ADDR           EQU  $FE        ; address register (lo hi)



                               ; ROM locations
READKBD        EQU  $C000
STOR80OF       EQU  $C000
STOR80ON       EQU  $C001
RAMRDMN        EQU  $C002
RAMRDAX        EQU  $C003
RAMWTMN        EQU  $C004
RAMWTAX        EQU  $C005
ZPMN           EQU  $C008
ZPAX           EQU  $C009
CLEARKBD       EQU  $C010
PAGE2OF        EQU  $C054
PAGE2ON        EQU  $C055
SET80          EQU  $CDBE
HOME           EQU  $FC58



                               ; global table
ENTRY          JMP  INIT       ; entry point
BYTES          DS   $10        ; storage for bytes to be printed
VTAB           DFB  $00        ; line number for printing
CURY           DFB  $00        ; HTAB for cursor
INVMASK        DFB  $FF        ; inverse AND mask
ASTO           DFB  $00        ; storage register
CURBASST       DS   2          ; storage for CURBAS during main/aux xfer
MAINAUX        DFB  $00        ; main/auxiliary memory (R7: 0/1)
ROMRAM         DFB  $00        ; ROM/RAM memory (R7: 0/1)
DBANK          DFB  $00        ; $D000 bank 1/2 (R7: 0/1)



CMDTBL                         ; command table (hex values come first)

               ASC  "0123456789ABCDEF"
               ASC  "IKJL"
               DFB  $8B,$8A,$88,$95 ; arrows (udlr)
               ASC  "UOBM"
               ASC  "WR"
               DFB  $9B
               DFB  $00

JMPTBL                         ; jump table for commands

               DFB  <HEX,>HEX,<HEX,>HEX,<HEX,>HEX,<HEX,>HEX
               DFB  <HEX,>HEX,<HEX,>HEX,<HEX,>HEX,<HEX,>HEX
               DFB  <HEX,>HEX,<HEX,>HEX,<HEX,>HEX,<HEX,>HEX
               DFB  <HEX,>HEX,<HEX,>HEX,<HEX,>HEX,<HEX,>HEX
               DFB  <UP,>UP,<DOWN,>DOWN,<LEFT,>LEFT,<RIGHT,>RIGHT
               DFB  <UP,>UP,<DOWN,>DOWN,<LEFT,>LEFT,<RIGHT,>RIGHT
               DFB  <BEGIN,>BEGIN,<END,>END
               DFB  <BTOG,>BTOG,<MTOG,>MTOG
               DFB  <WRITE,>WRITE,<READ,>READ
               DFB  <EXIT,>EXIT



MAINLOOP                       ; the main loop of the Monitor

               JSR  CUROUT
               JSR  FETCH
               JSR  EXECUTE
               JMP  MAINLOOP



INIT                           ; initialize

               JSR  COPYAUX
               JSR  SET80
               JSR  HOME
               LDA  #$40
               STA  CURBAS
               LDA  #$00
               STA  CURBAS+1
               JSR  PRPAGE
               JSR  MEMSETH
               JSR  DSPMSET
               LDA  #0
               STA  CURY
               LDA  #8
               STA  VTAB
               JMP  MAINLOOP



CBTOADRS       SEC             ; ADDR := CURBAS - $40
               LDA  CURBAS
               SBC  #$40
               STA  ADDR
               LDA  CURBAS+1
               SBC  #0
               STA  ADDR+1
               RTS



CBTOADRA       CLC             ; ADDR := CURBAS + $40
               LDA  CURBAS
               ADC  #$40
               STA  ADDR
               LDA  CURBAS+1
               ADC  #0
               STA  ADDR+1
               RTS



PRPAGE                         ; print a full screen of bytes ($0100)
                               ; input:  CURBAS: starting address + $40
                               ; output: the printed page
                               ;         ADDR destroyed
                               ;         VTAB destroyed

               LDA  #4
               STA  VTAB
               JSR  CBTOADRS
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
                               ; output: line is printed

               JSR  BASCALC    ; use VTAB to calculate BAS

               LDY  #$0F       ; store bytes to be printed
PRLLP1         LDA  (ADDR),Y
               STA  BYTES,Y
               DEY
               BPL  PRLLP1

               LDY  #0         ; print address: "hilo:"
               LDA  ADDR+1
               JSR  AOUT
               LDA  ADDR
               JSR  AOUT
               LDA  #":"
               JSR  COUT

               LDX  #0         ; output byte values
PRLLP2         LDA  BYTES,X
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
               BNE  PRLLP2

               LDA  #$A0       ; print two spaces
               JSR  COUT
               LDA  #$A0
               JSR  COUT

               LDX  #0         ; output characters
PRLLP3         LDA  BYTES,X
               JSR  COUT
               INX
               CPX  #$10
               BNE  PRLLP3

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



SCROLLUP                       ; scroll monitor window up
                               ; input:  none
                               ; output: window is scrolled up
                               ;         (bottom line not cleared)
                               ;         VTAB := 19

               LDA  #4
               STA  VTAB

SULP1          JSR  BASCALC
               LDA  BAS
               STA  SUSTA1+1
               STA  SUSTA2+1
               LDA  BAS+1
               STA  SUSTA1+2
               STA  SUSTA2+2

               INC  VTAB
               LDA  VTAB
               CMP  #20
               BNE  SUSK1
               DEC  VTAB
               RTS

SUSK1          JSR  BASCALC
               LDA  BAS
               STA  SULDA1+1
               STA  SULDA2+1
               LDA  BAS+1
               STA  SULDA1+2
               STA  SULDA2+2

               STA  PAGE2ON
               LDY  #29
SULDA1         LDA  $FFFF,Y
SUSTA1         STA  $FFFF,Y
               DEY
               BPL  SULDA1
               STA  PAGE2OF
               LDY  #29
SULDA2         LDA  $FFFF,Y
SUSTA2         STA  $FFFF,Y
               DEY
               BPL  SULDA2
               BMI  SULP1



SCROLLDW                       ; scroll monitor window down
                               ; input:  none
                               ; output: window is scrolled down
                               ;         (top line not cleared)
                               ;         VTAB := 4

               LDA  #19
               STA  VTAB

SDLP1          JSR  BASCALC
               LDA  BAS
               STA  SDSTA1+1
               STA  SDSTA2+1
               LDA  BAS+1
               STA  SDSTA1+2
               STA  SDSTA2+2

               DEC  VTAB
               LDA  VTAB
               CMP  #3
               BNE  SDSK1
               INC  VTAB
               RTS

SDSK1          JSR  BASCALC
               LDA  BAS
               STA  SDLDA1+1
               STA  SDLDA2+1
               LDA  BAS+1
               STA  SDLDA1+2
               STA  SDLDA2+2

               STA  PAGE2ON
               LDY  #29
SDLDA1         LDA  $FFFF,Y
SDSTA1         STA  $FFFF,Y
               DEY
               BPL  SDLDA1
               STA  PAGE2OF
               LDY  #29
SDLDA2         LDA  $FFFF,Y
SDSTA2         STA  $FFFF,Y
               DEY
               BPL  SDLDA2
               BMI  SDLP1



MEMSETH                        ; set memory switches ( >= $D000)
                               ; input:  ROMRAM, DBANK
                               ; output: memory switches set
               BIT  ROMRAM
               BPL  SROM
               BIT  DBANK
               BPL  SRAMD1
               LDA  $C083
               LDA  $C083
               RTS
SRAMD1         LDA  $C08B
               LDA  $C08B
               RTS
SROM           LDA  $C08A
               RTS



DSPMSET                        ; display memory settings
                               ; input:  MAINAUX, ROMRAM, DBANK
                               ; output: message printed on screen
                               ;         VTAB destroyed

               LDA  #21
               STA  VTAB
               JSR  BASCALC
               LDY  #43
               BIT  ROMRAM
               BPL  DMSK2
               BIT  DBANK
               BPL  DMSK1
               JSR  PRMESS
               ASC             "BSR (bank 2)"
               DFB  0
               BEQ  DMSK3
DMSK1          JSR  PRMESS
               ASC             "BSR (bank 1)"
               DFB  0
               BEQ  DMSK3
DMSK2          JSR  PRMESS
               ASC             "ROM         "
               DFB  0
DMSK3          INC  VTAB
               JSR  BASCALC
               LDY  #43
               BIT  MAINAUX
               BPL  DMSK4
               JSR  PRMESS
               ASC             "auxiliary"
               DFB  0
               BEQ  DMSK5
DMSK4          JSR  PRMESS
               ASC             "main     "
               DFB  0
DMSK5          RTS



BTOG                           ; toggle ROM/RAMDB1/RAMDB2

               LDA  #$80
               BIT  ROMRAM
               BPL  RSSK1
               BIT  DBANK
               BPL  RSSK2
               LDA  #$00
RSSK2          STA  DBANK
RSSK1          STA  ROMRAM
               JSR  MEMSETH
RPRPAGE        LDA  CURBAS     ; re-print page routine
               PHA
               LDA  CURBAS+1
               PHA
               LDA  VTAB
               PHA
               JSR  DSPMSET
               PLA
               PHA
               SEC
               SBC  #8
               ASL
               ASL
               ASL
               ASL
               STA  VTAB
               SEC
               LDA  CURBAS
               SBC  VTAB
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



MTOG                           ; toggle MAIN/AUX memory

               DFB  PLY        ; return address (only word on stack)
               DFB  PLX
               BIT  MAINAUX    ; see if in main or aux presently
               BPL  MTSK1      ; if in main then branch
               STA  RAMWTMN    ; if in aux then write to main (read aux)
               BMI  MTSK2
MTSK1          STA  RAMWTAX    ; (if in main then) write to aux (read main)
MTSK2          LDA  CURBAS
               STA  CURBASST
               LDA  CURBAS+1
               STA  CURBASST+1
               LDA  CURY
               STA  CURY
               LDA  VTAB
               STA  VTAB
               LDA  ROMRAM
               STA  ROMRAM
               LDA  DBANK
               STA  DBANK
               LDA  MAINAUX
               EOR  #$80       ; 1.......
               STA  MAINAUX
               BMI  MTSK3      ; if in main then branch
               STA  RAMRDMN    ; if in aux then read (and write) main
               STA  ZPMN       ; and use main pages $00 and $01
               BPL  MTSK4
MTSK3          STA  RAMRDAX    ; (if in main then) read (and write) aux
               STA  ZPAX       ; and use aux pages $00 and $01
MTSK4          LDA  CURBASST
               STA  CURBAS
               LDA  CURBASST+1
               STA  CURBAS+1
               DFB  PHX        ; return address
               DFB  PHY
               JMP  RPRPAGE



COPYAUX                        ; make a copy of the Monitor in auxiliary memory
                               ; input:  none
                               ; output: program copied
                               ;         80STORE switch turned on

               LDA  #$00
               STA  CALDA+1
               STA  CASTA+1
               LDA  #$20
               STA  CALDA+2
               STA  CASTA+2
               LDY  #0
COPYPAGE       STA  RAMWTAX
CALDA          LDA  $FFFF,Y
CASTA          STA  $FFFF,Y
               INY
               BNE  CALDA
               STA  RAMWTMN
               INC  CALDA+2
               INC  CASTA+2
               LDA  CALDA+2
               CMP  #$30
               BNE  COPYPAGE
               STA  STOR80ON
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
                               ;         on exit Z = 1

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
               LDA  #0
               RTS



CUROUT                         ; output cursor
                               ; input:  CURBAS: base byte address
                               ;         CURY:   offset byte in line
                               ;         VTAB:   line number
                               ; output: inverse cursor printed
                               ;         CURBAS, CURY, VTAB preserved

               JSR  BASCALC    ; calculate BAS from VTAB

               LDA  CURY       ; calculate Y for AINVOUT and push
               TAY
               LSR
               LSR
               STA  ASTO
               LDA  CURY
               ASL
               ADC  #5
               ADC  ASTO
               PHA

               LDA  (CURBAS),Y ; get byte and push (first pull Y for AINVOUT)
               DFB  PLY
               PHA

               JSR  AINVOUT    ; output inverse byte value

               CLC             ; calculate Y for CINVOUT
               LDA  #43
               ADC  CURY
               TAY

               PLA             ; get byte

               JSR  CINVOUT    ; output inverse character

               RTS



CUROFF                         ; turn off cursor
                               ; input:  CURBAS: base byte address
                               ;         CURY:   offset byte in line
                               ;         VTAB:   line number
                               ; output: inverse cursor removed
                               ;         CURBAS, CURY, VTAB preserved

               JSR  BASCALC    ; calculate BAS from VTAB

               LDA  CURY       ; calculate Y for AINVOUT and push
               TAY
               LSR
               LSR
               STA  ASTO
               LDA  CURY
               ASL
               ADC  #5
               ADC  ASTO
               PHA

               LDA  (CURBAS),Y ; get byte and push (first pull Y for AINVOUT)
               DFB  PLY
               PHA

               JSR  AOUT       ; turn off inverse byte value

               CLC             ; calculate Y for CINVOUT
               LDA  #43
               ADC  CURY
               TAY

               PLA             ; get byte

               JSR  COUT       ; turn off inverse character

               RTS



PRINS                          ; print one instruction
                               ; input:  ADDR: address of op code
                               ;         BAS : base address
                               ;         Y   : HTAB (0 org)
                               ; output: one instruction printed
                               ;         BAS preserved
                               ;         Y preserved

               DFB  PHY

               LDA  ADDR+1     ; print address: "hilo: "
               JSR  AOUT
               LDA  ADDR
               JSR  AOUT
               LDA  #":"
               JSR  COUT
               LDA  #$A0
               JSR  COUT

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
NOTFND         RTS
FND            TXA
               ASL
               TAX
               DFB  JMP,<JMPTBL,>JMPTBL



HEX                            ; input a hexadecimal byte value
                               ; input:  X: from EXECUTE routine
                               ;         CURBAS, CURY, VTAB
                               ; output: two characters read; value stored in
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
               PLA
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
               CMP  #8
               BNE  UPSK1
               JSR  SCROLLDW
               JSR  UPSUB
               JSR  CBTOADRS
               JSR  PRLINE
               LDA  #8
               STA  VTAB
               RTS
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
               BNE  DOSK1
               JSR  SCROLLUP
               JSR  DWSUB
               JSR  CBTOADRA
               JSR  PRLINE
               LDA  #15
               STA  VTAB
               RTS
DOSK1          INC  VTAB
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
               LDA  #$0F
               STA  CURY
               JMP  UPINTERN
LFSK1          DEC  CURY
               RTS



RIGHT                          ; move cursor right
               JSR  CUROFF
               LDA  CURY
               CMP  #$0F
               BNE  RTSK1
               LDA  #0
               STA  CURY
               JMP  DWINTERN
RTSK1          INC  CURY
               RTS



BEGIN                          ; move to beginning of page or previous page
               JSR  CUROFF
               LDA  VTAB
               CMP  #8
               BNE  BGSK1
               LDA  CURY
               BNE  BGSK2
               DEC  CURBAS+1
               JSR  PRPAGE
               BEQ  BGSK2
BGSK1          SEC
               SBC  #8
               TAX
BGLP1          JSR  UPSUB
               DEX
               BNE  BGLP1
BGSK2          LDA  #8
               STA  VTAB
               LDA  #0
               STA  CURY
               RTS



END                            ; move to end of page or next page
               JSR  CUROFF
               LDA  VTAB
               CMP  #15
               BNE  EDSK1
               LDA  CURY
               CMP  #$0F
               BNE  EDSK2
               INC  CURBAS+1
               LDA  CURBAS+1
               PHA
               LDA  CURBAS
               PHA
               SEC
               SBC  #$70       ; $70 = $10*7 = $10*(VTAB-8) = $10*(15-8)
               STA  CURBAS
               LDA  CURBAS+1
               SBC  #0
               STA  CURBAS+1
               JSR  PRPAGE
               PLA
               STA  CURBAS
               PLA
               STA  CURBAS+1
               BNE  EDSK2
               BEQ  EDSK2
EDSK1          SEC
               LDA  #15
               SBC  VTAB
               TAX
EDLP1          JSR  DWSUB
               DEX
               BNE  EDLP1
EDSK2          LDA  #15
               STA  VTAB
               LDA  #$0F
               STA  CURY
               RTS



WRITE                          ; write block
               RTS



READ                           ; read block
               RTS



EXIT                           ; exit The Monitor

               LDA  #$00
               STA  ROMRAM
               STA  DBANK
               JSR  MEMSETH
               STA  STOR80OF
               PLA
               PLA
               STA  RAMRDMN
               STA  RAMWTMN
               STA  ZPMN
               RTS
