                               ;
                               ; FSMon
                               ;
                               ; A Full Screen Memory Monitor for the
                               ; Apple //c.
                               ;
                               ; written by Christopher A. Mosher
                               ;
                               ; January 1988
                               ;
                               ;    This program monitors the memory of the
                               ; Apple //c computer.  It can display any
                               ; of the 144 kilobytes of RAM and ROM in the
                               ; //c.  It also allows any RAM location to be
                               ; changed.
                               ;    FSMon is a full-screen editor, displaying
                               ; one page of bytes (.25K) at a time.  It also
                               ; displays a disassembly listing, showing 18
                               ; instructions, starting at the memory location
                               ; of the cursor.
                               ;



                               ; new 65C02 opcodes
BRA            EQU  $80        ; BRA  $FFFF (offset)
PHY            EQU  $5A        ; PHY
PLY            EQU  $7A        ; PLY
PHX            EQU  $DA        ; PHX
PLX            EQU  $FA        ; PLX
BIT            EQU  $89        ; BIT  #$FF
JMP            EQU  $7C        ; JMP  ($FFFF,X)



                               ; page $00 locations
BAS            EQU  $FA        ; base address register for printing ($FA-$FB)
CURBAS         EQU  $FC        ; base address register for cursor ($FC-$FD)
ADDR           EQU  $FE        ; address register ($FE-$FF)



                               ; page $C0 locations
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



                               ; ROM locations
SET80          EQU  $CDBE
HOME           EQU  $FC58



                               ; global table
               ORG  $2000      ; starting address $2000
               JMP  INIT       ; FSMon entry point

CMDTBL                         ; command table (hex values come first)

               ASC  "0123456789ABCDEF"
               ASC  "IKJL"
               DFB  $8B,$8A,$88,$95 ; arrows (up, down, left, right)
               ASC  "UORM"
               DFB  $9B
               DFB  $00

JMPTBL                         ; address table for command routines

               DFB  <HEX,>HEX,<HEX,>HEX,<HEX,>HEX,<HEX,>HEX
               DFB  <HEX,>HEX,<HEX,>HEX,<HEX,>HEX,<HEX,>HEX
               DFB  <HEX,>HEX,<HEX,>HEX,<HEX,>HEX,<HEX,>HEX
               DFB  <HEX,>HEX,<HEX,>HEX,<HEX,>HEX,<HEX,>HEX
               DFB  <UP,>UP,<DOWN,>DOWN,<LEFT,>LEFT,<RIGHT,>RIGHT
               DFB  <UP,>UP,<DOWN,>DOWN,<LEFT,>LEFT,<RIGHT,>RIGHT
               DFB  <BEGIN,>BEGIN,<END,>END
               DFB  <RTOG,>RTOG,<MTOG,>MTOG
               DFB  <EXIT,>EXIT



                               ; disassembly tables (ROM)
MNEML
               HEX  1C8A1C235D8B1BA19D8A1D239D8B1DA1
               HEX  1C2919AE69A8192324531B23245319A1
               HEX  AD1A5B5BA5692424AEAEA8AD298A7C8B
               HEX  159C6D9CA569295384133411A56923A0

MNEMR
               HEX  D8625A48266294885444C8546844E894
               HEX  C4B4088474B4286E74F4CC4A72F2A48A
               HEX  06AAA2A2747474724468B232B2722272
               HEX  1A1A2626727288C8C4CA26484444A2C8

FMT1
               HEX  0F22FF33CB62FF730322FF33CB66FF77
               HEX  0F20FF33CB60FF700F22FF39CB66FF7D
               HEX  0B22FF33CBA6FF731122FF33CBA6FF87
               HEX  0122FF33CB60FF700122FF33CB60FF70
               HEX  24316578

FMT2
               HEX  00218182594D9192864A859D495A

CHAR2
               HEX  D900D8A4A400

CHAR1
               HEX  ACA9ACA3A8A4

OPTBL
               HEX  12141A1C32343A3C525A6472747A7C89
               HEX  929C9EB2D2F2FC

                               ; variables
MAINAUX        DFB  $00        ; main/auxiliary memory (R7: 0/1)
ROMRAM         DFB  $00        ; ROM/RAM memory (R7: 0/1)
DBANK          DFB  $00        ; $D000 bank 1/2 (R7: 0/1)

                               ; for MNEML
               HEX  8A8BA5AC00

INDX
               HEX  38FB37FB392136213AF8FA3BFAF92221
               HEX  3CFAFA3D3E3FFC00

                               ; variables
CURY           DFB  $00        ; HTAB for cursor
VTAB           DFB  $00        ; line number for printing
INVMASK        DFB  $FF        ; inverse AND mask
ASTO           DFB  $00        ; storage register
BYTES          DS   $10        ; storage for bytes to be printed



MAINLOOP                       ; the main loop of FSMon

               JSR  DSPINS     ; display the block of instructions
               JSR  CUROUT     ; output the cursor
               JSR  FETCH      ; fetch a keypress
               JSR  EXECUTE    ; execute a command
               DFB  BRA,MAINLOOP-*-1 ; repeat



                               ; for MNEMR
               HEX  00
               HEX  747476C600



INIT                           ; initialize

               JSR  COPYAUX
               JSR  SET80
               JSR  HOME
               LDA  #$40
               STA  CURBAS
               LDA  #$00
               STA  CURBAS+1
               JSR  PRPAGE
               JSR  MEMSET
               JSR  DSPMSET
               JSR  DSPOFS
               LDA  #0
               STA  CURY
               LDA  #8
               STA  VTAB
               JMP  MAINLOOP



COPYAUX                        ; make a copy of FSMon in auxiliary memory
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



MEMSET                         ; set memory switches ( >= $D000)
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
               LDY  #0
               BIT  MAINAUX
               BPL  DMSK4
               JSR  PRMESS
               ASC             "auxiliary "
               DFB  0
               DFB  BRA,DMSK5-*-1
DMSK4          JSR  PRMESS
               ASC             "main      "
               DFB  0
DMSK5          LDY  #10
               BIT  ROMRAM
               BPL  DMSK2
               BIT  DBANK
               BPL  DMSK1
               JSR  PRMESS
               ASC             "BSR (bank 2)"
               DFB  0
               DFB  BRA,DMSK3-*-1
DMSK1          JSR  PRMESS
               ASC             "BSR (bank 1)"
               DFB  0
               DFB  BRA,DMSK3-*-1
DMSK2          JSR  PRMESS
               ASC             "ROM         "
               DFB  0
DMSK3          RTS



DSPOFS                         ; display offset addresses at top of page
                               ; input:  none
                               ; output: hex numbers printed

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



DSPINS                         ; display the block of instructions
                               ; input:  CURBAS, CURY
                               ; output: instructions displayed
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
               LDA  VTAB
               CMP  #20
               BNE  PISLP1
               PLA
               STA  VTAB
               RTS



PRINS                          ; print one instruction
                               ; input:  ADDR: address of op code
                               ;         BAS : base address
                               ;         Y   : HTAB (0 org)
                               ; output: one instruction printed
                               ;         ADDR: incremented to first byte
                               ;               following the instruction
                               ;         BAS preserved
                               ;         Y preserved

               DFB  PHY
               LDA  ADDR+1     ; print address: "hilo:"
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
PISK4          LDA  INDX,X
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
PISK12         TYA
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
               DFB  BRA,EDSK2-*-1
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



RTOG                           ; toggle ROM/RAMDB1/RAMDB2

               LDA  #$80
               BIT  ROMRAM
               BPL  RSSK1
               BIT  DBANK
               BPL  RSSK2
               LDA  #$00
RSSK2          STA  DBANK
RSSK1          STA  ROMRAM
               JSR  MEMSET
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
               STA  BYTES
               LDA  CURBAS+1
               STA  BYTES+1
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
MTSK4          LDA  BYTES
               STA  CURBAS
               LDA  BYTES+1
               STA  CURBAS+1
               DFB  PHX        ; return address
               DFB  PHY
               JMP  RPRPAGE



EXIT                           ; exit FSMon

               JSR  CUROFF
               LDA  #$00
               STA  ROMRAM
               STA  DBANK
               JSR  MEMSET
               STA  STOR80OF
               PLA
               PLA
               STA  RAMRDMN
               STA  RAMWTMN
               STA  ZPMN
               RTS
