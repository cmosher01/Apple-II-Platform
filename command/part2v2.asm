                               ;
                               ;
                               ; Part Two.
                               ;
                               ; Christopher A. Mosher
                               ;



               ORG  $B000



                               ; Page $00 locations
TEMP           EQU  $FB        ; temporary register
ADDR           EQU  $FC        ; temporary address register (lo hi)
ADDR2          EQU  $FE        ; temporary address register (lo hi)

INPTBUFR       EQU  $0200      ; buffer for line of input

SOFTEV         EQU  $03F2      ; vector for reset (lo hi)
PWREDUP        EQU  $03F4      ; powered up determination byte

                               ; ProDOS System Global Page
                               ;
                               ; Jump vectors
                               ;
MLI            EQU  $BF00      ; Jump to machine language interface
JSPARE         EQU  $BF03      ; Jump to system death handler
DATETIME       EQU  $BF06      ; Jump to Date/Time routine
SYSERR         EQU  $BF09      ; Jump to system error handler
SYSDEATH       EQU  $BF0C      ; Jump to system death handler
SERR           EQU  $BF0F      ; System error number
                               ;
                               ; Device information
                               ;
                               ; Device driver address for device in:
                               ; slot  drive
DEVADR01       EQU  $BF10      ;   0
DEVADR11       EQU  $BF12      ;   1     1
DEVADR21       EQU  $BF14      ;   2     1
DEVADR31       EQU  $BF16      ;   3     1
DEVADR41       EQU  $BF18      ;   4     1
DEVADR51       EQU  $BF1A      ;   5     1
DEVADR61       EQU  $BF1C      ;   6     1
DEVADE71       EQU  $BF1E      ;   7     1
DEVADR02       EQU  $BF20      ;   0
DEVADR12       EQU  $BF22      ;   1     2
DEVADR22       EQU  $BF24      ;   2     2
DEVADR32       EQU  $BF26      ;   3     2    (/RAM)
DEVADR42       EQU  $BF28      ;   4     2
DEVADR52       EQU  $BF2A      ;   5     2
DEVADR62       EQU  $BF2C      ;   6     2
DEVADR72       EQU  $BF2E      ;   7     2
DEVNUM         EQU  $BF30      ; Slot and drive of last device (dsss....)
DEVCNT         EQU  $BF31      ; Count (minus 1) of active devices
DEVLST         EQU  $BF32      ; List of active devices (dsssiiii)
COPYRGHT       EQU  $BF40      ; Copyright notice
IRQXITX        EQU  $BF50      ; Call IRQ handler at $FFD8 (Main BSR)
TEMPIRQ        EQU  $BF56      ; Temporary storage for IRQ code
BITMAP         EQU  $BF58      ; Bit map of available memory (pages $00-$BF)
BUFFER1        EQU  $BF70      ; Open file 1 buffer address
BUFFER2        EQU  $BF72      ; Open file 2 buffer address
BUFFER3        EQU  $BF74      ; Open file 3 buffer address
BUFFER4        EQU  $BF76      ; Open file 4 buffer address
BUFFER5        EQU  $BF78      ; Open file 5 buffer address
BUFFER6        EQU  $BF7A      ; Open file 6 buffer address
BUFFER7        EQU  $BF7C      ; Open file 7 buffer address
BUFFER8        EQU  $BF7E      ; Open file 8 buffer address
                               ;
                               ; Interrupt information
                               ;
INTRUPT1       EQU  $BF80      ; Interrupt handler address (highest priority)
INTRUPT2       EQU  $BF82      ; Interrupt handler address
INTRUPT3       EQU  $BF84      ; Interrupt handler address
INTRUPT4       EQU  $BF86      ; Interrupt handler address (lowest priority)
INTAREG        EQU  $BF88      ; Storage for A register
INTXREG        EQU  $BF89      ; Storage for X register
INTYREG        EQU  $BF8A      ; Storege for Y register
INTSREG        EQU  $BF8B      ; Storage for S register
INTPREG        EQU  $BF8C      ; Storage for P register
INTBNKID       EQU  $BF8D      ; Bank identification byte
INTADDR        EQU  $BF8E      ; Interrupt return address
                               ;
                               ; General system information
                               ;
DATE           EQU  $BF90      ; Date (yyyyyyym mmmddddd)
TIME           EQU  $BF92      ; Time (...hhhhh .mmmmmm.)
LEVEL          EQU  $BF94      ; Current file level
BUBIT          EQU  $BF95      ; Backup bit
SPARE1         EQU  $BF96      ; (Spare)
MACHID         EQU  $BF98      ; Machine identification byte:
                               ; value    meaning        _
                               ; 00..0... ][              |
                               ; 01..0... ][plus          |
                               ; 10..0... //e             |
                               ; 11..0... III emulation   |_  Type of
                               ; 00..1...                 |   Apple
                               ; 01..1...                 |
                               ; 10..1... //c             |
                               ; 11..1...                _|
                               ; ..00.... (unused)        |
                               ; ..01.... 48K             |_  Amount of
                               ; ..10.... 64K             |   RAM available
                               ; ..11.... 128K           _|
                               ; .....x.. (reserved)
                               ; ......x. 80 column card flag
                               ; .......x Clock flag
SLTBYT         EQU  $BF99      ; Slot ROM map
PFIXPTR        EQU  $BF9A      ; Prefix flag
MLIACTV        EQU  $BF9B      ; MLI active flag
CMDADR         EQU  $BF9C      ; Last MLI call return address
SAVEX          EQU  $BF9E      ; Storage for X register for MLI calls
SAVEY          EQU  $BF9F      ; Storage for Y register for MLI calls
                               ;
                               ; Bank switched RAM routines
                               ;
EXIT           EQU  $BFA0      ; Exit routine (Main BSR)
EXIT1          EQU  $BFAA      ; Exit routine (Main BSR)
EXIT2          EQU  $BFB5      ; Exit routine (Main BSR)
MLIENT1        EQU  $BFB7      ; MLI entry
                               ;
                               ; Interrupt routines
                               ;
IRQXIT         EQU  $BFD0      ; IRQ interrupt exit routine
IRQXIT1        EQU  $BFDF      ; IRQ interrupt exit routine
IRQXIT2        EQU  $BFE2      ; IRQ interrupt exit routine
ROMXIT         EQU  $BFE7      ; Exit routine
IRQENT         EQU  $BFEB      ; IRQ interrupt entry
                               ;
                               ; Data
                               ;
BNKBYT1        EQU  $BFF4      ; Storage for $E000
BNKBYT2        EQU  $BFF5      ; Storage for $D000
JDEATH         EQU  $BFF6      ; Jump to system death handler (Main BSR)
                               ;
                               ; Version information
                               ;
IBAKVER        EQU  $BFFC      ; Minimum version of Kernel for interpreter
IVERSION       EQU  $BFFD      ; Version number of interpreter
KBAKVER        EQU  $BFFE      ; Minimum version of compatible Kernel
KVERSION       EQU  $BFFF      ; Version number of Kernel
VERSION        EQU  $01        ; Version number of ProDOS Kernel used for
                               ;   this interpreter system
BAKVER         EQU  $00        ; Minimum ProDOS Kernel version number that
                               ;   is compatible with this interpreter system

                               ; Slot ROM locations
SET80          EQU  $CDBE      ; set up 80 columns
HOOKUP         EQU  $CE20      ; set up 80 column hooks
BOOT           EQU  $C600      ; boot disk in slot 6

                               ; Applesoft BASIC locations
BASIC          EQU  $E000      ; entry point

                               ; Monitor ROM locations
INIT           EQU  $FB2F      ; initialize screen
HOME           EQU  $FC58      ; home screen
SETKBD         EQU  $FE89      ; initialize input as slot 0
SETVID         EQU  $FE93      ; initialize output as slot 0
GETLN1         EQU  $FD6F      ; get line of input (no prompt)
PRBYTE         EQU  $FDDA      ; print A in hexadecimal
COUT           EQU  $FDED      ; standard character output subroutine
MONITOR        EQU  $FF69      ; monitor entry point

                               ; MLI routines
ALLOC_INT                      EQU $40
DEALLOC_INT                    EQU $41
QUIT                           EQU $65
READ_BLOCK                     EQU $80
WRITE_BLOCK                    EQU $81
GET_TIME                       EQU $82
CREATE                         EQU $C0
DESTROY                        EQU $C1
RENAME                         EQU $C2
SET_FILE_INFO                  EQU $C3
GET_FILE_INFO                  EQU $C4
ONLINE                         EQU $C5
SET_PREFIX                     EQU $C6
GET_PREFIX                     EQU $C7
OPEN                           EQU $C8
NEWLINE                        EQU $C9
READ                           EQU $CA
WRITE                          EQU $CB
CLOSE                          EQU $CC
FLUSH                          EQU $CD
SET_MARK                       EQU $CE
GET_MARK                       EQU $CF
SET_EOF                        EQU $D0
GET_EOF                        EQU $D1
SET_BUF                        EQU $D2
GET_BUF                        EQU $D3



CMDTBL         EQU  $A000      ; command table



                               ; Global Table
COLDENTR       JMP  COMSYS     ; cold entry point
WARMENTR       JMP  MAINLOOP   ; warm entry point
RESETENT       JMP  RESET      ; reset handler entry point
                               ;
FRSTPAG        DFB  >COLDENTR  ; first page used by system
LASTPAG        DFB  >LAST-1    ; last page used by system
                               ;
PROMPT                         ; prompt string (maximum length, 8 bytes)
                               ; (terminated with 0)
               ASC             "$ "
               DFB  $00        ;
               DS   $06        ; filler
                               ;
COMTBL         DS   $02        ; address of start of command table for SRCHTBL
EDCOMTBL       DS   $02        ; address of end of command table for SRCHTBL
                               ;
DATABUF        DFB  $00,$20    ; address of data buffer for command directory
                               ;
PTHAD                          ; address of default pathname
               DFB  <PTH,>PTH
                               ;
INPTHAD                        ; address of current input pathname
               DFB  <INPTH,>INPTH
                               ;
OTPTHAD                        ; address of current output pathname
               DFB  <OTPTH,>OTPTH
                               ;
PARMS                          ; parameter list for MLI calls
               DS   $20        ; maximum of $20 bytes
                               ;
MLIPTH                         ; storage for pathname for MLI calls
               DS   $40        ; maximum of $40 bytes
                               ;
CMDDIRFL       DFB  $00        ; command directory file reference number
                               ;
               ASC             "Command System"
               ASC             "Christopher A. Mosher"



ENDGLB         DS   $B100-ENDGLB
KBUF           DFB  $00        ; one kilobyte buffer MUST BE PAGE-ALLIGNED !!!
               DS   $03FF



PTH                            ; current default pathname
                               ; (maximum length, $3F bytes)
                               ; (terminated with 0)
                               ; (initially commands subdirectory)
               ASC             "/command/commands"
               DFB  $00
               DS   $2E



INPTH                          ; current input pathname
                               ; (maximum length, $3F bytes)
                               ; (terminated with 0)
                               ; (initially the keyboard)
               ASC             "/keyboard"
               DFB  $00
               DS   $36



OTPTH                          ; current output pathname
                               ; (maximum length, $3F bytes)
                               ; (terminated with 0)
                               ; (initially the screen)
               ASC             "/screen"
               DFB  $00
               DS   $38



COMSYS                         ; Command interpreter system

               LDA  MLI        ; insure ProDOS is active
               CMP  #$4C
               BEQ  INITSTK
               JMP  BOOT

INITSTK        LDX  #$FF       ; initialize stack
               TXS

               LDA  #<RESETENT ; initialize reset vector
               STA  SOFTEV
               LDA  #>RESETENT
               STA  SOFTEV+1
               EOR  #$A5
               STA  PWREDUP

               SEC             ; allocate interpreter in system memory map
               LDA  LASTPAG
               SBC  FRSTPAG
               TAX
               INX
               LDA  FRSTPAG
               JSR  ALLOCPGS
               BCC  INITVER
               JMP  BOOT

INITVER        LDA  #VERSION   ; initialize version numbers
               STA  IVERSION
               LDA  #BAKVER
               STA  IBAKVER

               JSR  SETKBD     ; initialize screen
               JSR  SETVID
               JSR  INIT
               JSR  HOME
               JSR  CHKSET80

               JSR  PRTAPL     ; print initial message
               JSR  PRINT
               ASC             "Professional Disk Operating System."
               HEX             8D
               ASC             "Command System."
               HEX             8D8D00

                               ; start processing
               JSR  READCMDS   ; read command filenames from disk
                               ; JSR INITCOM ; execute initial command file
MAINLOOP       JSR  GETCOM     ; get a command
               JSR  PROCCOM    ; process the command
               JMP  MAINLOOP



                               ;
                               ; Allocate memory pages.
                               ; input : A: starting page number
                               ;         X: length (pages)
                               ;
                               ; output: C: set  : page already allocated
                               ;            clear: successfully allocated
                               ;
ALLOCPGS       CLC
ALP1           DEX
               BMI  EXAPGS
               DFB  $DA        ; PHX
               PHA
               JSR  ALLOCPG
               PLA
               DFB  $1A        ; INA
               DFB  $FA        ; PLX
               BCC  ALP1
EXAPGS         RTS
ALLOCPG        PHA             ; abcdefgh (bit map)
               AND  #7         ; 00000fgh (number of bit in byte)
               TAY
               LDX  MASK,Y
               PLA             ; abcdefg
               LSR             ; 0abcdefg
               LSR             ; 00abcdef
               LSR             ; 000abcde (number of byte in bitmap table)
               TAY
               TXA
               AND  BITMAP,Y
               BNE  ERAPG
               TXA
               ORA  BITMAP,Y
               STA  BITMAP,Y
               CLC
               DFB  $89        ; BIT absorbs SEC
ERAPG          SEC
               RTS
MASK           HEX             8040201008040201



CHKSET80                       ; Set 80 column text screen if available.
               LDA  MACHID
               LSR
               LSR
               BCC  ERS80
               JSR  HOOKUP
               JSR  SET80
               JSR  HOME
ERS80          RTS



PRTAPL                         ; Print machine type and RAM size.
               LDA  #$08
               BIT  MACHID
               BEQ  PASK1
               BPL  UNKNOWN
               BVS  UNKNOWN
               JSR  PRINT
               ASC             "Apple //c with "
               DFB             0
               JMP  PRTMEM
PASK1          BPL  ERPA
               BVS  A3
               JSR  PRINT
               ASC             "Apple //e with "
               DFB             0
               LDA  #0
               BEQ  PRTMEM
A3             JSR  PRINT
               ASC             "Apple III emulation with "
               DFB             0
               LDA  #0
               JSR  PRTMEM
UNKNOWN        JSR  PRINT
               ASC             "Unknown type of machine with "
               DFB             0
               LDA  #0
               BEQ  PRTMEM
ERPA           JSR  PRINT
               ASC             "Incompatible type of machine."
               DFB             0
               JMP  BOOT
PRTMEM         LDA  MACHID
               ASL
               ASL
               ASL
               BCC  M48
               ASL
               BCS  M128
               JSR  PRINT
               ASC             "64"
               DFB             0
               LDA  #0
               BEQ  PRTRST
M48            JSR  PRINT
               ASC             "48"
               DFB             0
               LDA  #0
               BEQ  PRTRST
M128           JSR  PRINT
               ASC             "128"
               DFB             0
PRTRST         JSR  PRINT
               ASC             " kilobytes of random access memory."
               HEX             8D00
               RTS



PRINT          PLA
               STA  ADDR
               PLA
               STA  ADDR+1
               LDY  #$01
PRL1           LDA  (ADDR),Y
               BEQ  PRS1
               JSR  COUT
               INY
               BNE  PRL1
PRS1           CLC
               TYA
               ADC  ADDR
               TAY
               LDA  #$00
               ADC  ADDR+1
               PHA
               DFB  $FA        ; PHY
               RTS



RESET                          ; Handle reset button press.
               JSR  SETKBD
               JSR  SETVID
               JSR  INIT
               JSR  HOME
               JSR  CHKSET80
               JMP  MAINLOOP



COMFILE                        ; execute command file
               RTS



PRTPROM                        ; print prompt
               LDY  #0
PPLP1          LDA  PROMPT,Y
               BEQ  EXPP
               JSR  COUT
               INY
               BNE  PPLP1
EXPP           RTS



GETCOM                         ; get a command
               JSR  INPTH?
               ASC             "/keyboard"
               DFB  $00
               BCS  GETKBD
               BRK             ; get from file
GETKBD         JSR  PRTPROM
               JSR  GETLN1
               RTS



PROCCOM                        ; process the command
                               ; input : INPTBUFR: command string terminated
                               ;                   with $8D or $0D
                               ; output: none

               JSR  DOWNCASE   ; downcase command string
               LDA  #<MAINCT
               STA  COMTBL
               LDA  #>MAINCT
               STA  COMTBL+1
               LDA  #<EDMAINCT
               STA  EDCOMTBL
               LDA  #>EDMAINCT
               STA  EDCOMTBL+1
               JSR  SRCHTBL    ; search the command table MAINCT
               JSR  SRCHFIL    ; search for pathname (and execute)
               JSR  PRINT
               ASC             "Unknown command."
               HEX             8D00
               RTS

DOWNCASE                       ; downcase the input buffer
               LDY  #0
DCLP1          LDA  INPTBUFR,Y
               BEQ  EXDC
               AND  #$80       ; high bit on
               CMP  #$C1
               BCC  DCSK1
               CMP  #$DB
               BCS  DCSK1
               AND  #$20       ; downcase
               STA  INPTBUFR,Y
DCSK1          INY
               BNE  DCLP1
EXDC           RTS

SRCHTBL                        ; search for command in table (and execute)
                               ; input : INPTBUFR: command string, terminated
                               ;                   with $8D, and same case as
                               ;                   entries in command table
                               ;         COMTBL  : address (lo hi) of command
                               ;                   table
                               ;         EDCOMTBL: address (lo hi) of end of
                               ;                   command table
                               ; output: if command found, then executed,
                               ;         otherwise return
               LDX  COMTBL
               LDY  COMTBL+1
STLP2          CPX  EDCOMTBL
               BNE  STSK2
               CPY  EDCOMTBL+1
               BEQ  EXST
STSK2          STX  ADDR
               STY  ADDR+1
               LDY  #2
               LDX  #$FF
               LDA  (ADDR),Y   ; number of required bytes for match
               CLC
               ADC  #3
               STA  TEMP       ; offset of last req. byte
STLP1          INY
               INX
               CPY  TEMP       ; last req. byte
               BEQ  CHKREST
               LDA  INPTBUFR,X
               CMP  (ADDR),Y
               BNE  NXTENTR
               CMP  #$8D
               BEQ  NXTENTR
               BNE  STLP1
CHKREST        LDA  INPTBUFR,X
               CMP  #$8D
               BEQ  FNDENTR
               CMP  (ADDR),Y
               BNE  NXTENTR
               INY
               INX
               BNE  CHKREST
NXTENTR        LDA  (ADDR),Y
               BEQ  STSK1
               INY
               BNE  NXTENTR
STSK1          INY
               CLC
               TYA
               ADC  ADDR
               TAX
               LDA  #0
               ADC  ADDR+1
               TAY
               BCC  STLP2      ; BRA
FNDENTR        LDY  #0
               LDA  (ADDR),Y
               STA  TEMP
               INY
               LDA  (ADDR),Y
               STA  ADDR+1
               LDA  TEMP
               STA  ADDR
               JMP  (ADDR)
EXST           RTS

SRCHFIL                        ; search for pathname (and execute)
               RTS



DIRECT                         ; directory command
               RTS



READCMDS                       ; read command filenames from disk
               LDA  #3         ; 3 parameters
               STA  PARMS
               LDA  #<MLIPTH   ; address of pathname
               STA  PARMS+1
               LDA  #>MLIPTH
               STA  PARMS+2
               LDX  #0         ; pathname
MOVEPTH        LDA  PTH,X
               BEQ  STORLEN
               STA  MLIPTH+1,X
               INX
               BNE  MOVEPTH
STORLEN        STX  MLIPTH
               LDA  #<KBUF     ; must be $00 (page-alligned)
               STA  PARMS+3
               LDA  #>KBUF
               STA  PARMS+4
               JSR  MLI        ; open command directory
               DFB  OPEN
               DFB  <PARMS,>PARMS
               BCC  RDCMSK1    ; if no error
               BRK             ; if cannot open
RDCMSK1        LDA  PARMS+5    ; reference number
               STA  CMDDIRFL   ; command directory file (reference number)
               LDA  #0
               STA  RDBLKS     ; number of blocks read
               LDA  #$04       ; 4 parameters
               STA  PARMS
               LDA  CMDDIRFL   ; command directory file
               STA  PARMS+1
               LDA  DATABUF    ; address of data buffer
               STA  ADDR
               STA  PARMS+2
               LDA  DATABUF+1
               STA  ADDR+1
               STA  PARMS+3
               LDA  #$00       ; length (1 block, or $0200 bytes)
               STA  PARMS+4
               LDA  #$02
               STA  PARMS+5
RDCMLP1        JSR  MLI        ; read 1 block from command directory file
               DFB  READ
               DFB  <PARMS,>PARMS
               BCC  RDCMSK2    ; if no error
               BRK             ; if error
RDCMSK2        INC  RDBLKS     ; number of blocks read
               LDA  DATABUF+2  ; ptr to next block (lo)
               BNE  RDCMSK3
               LDA  DATABUF+3  ; ptr to next block (hi)
               BEQ  SETUPCMD
RDCMSK3        INC  DATABUF+1  ; increment data buffer address (hi)
               INC  DATABUF+1
               LDA  DATABUF
               STA  PARMS+2
               LDA  DATABUF+1
               STA  PARMS+3
               BNE  RDCMLP1
SETUPCMD                       ; set up command table
               LDX  RDBLKS     ; number of blocks read
               TXY
RDCMLP2        DEY
               BEQ  RDCMSK4
               DEC  DATABUF+1
               DEC  DATABUF+1
               BNE  RDCMLP2





INITCOM                        ; execute initial command file
                               ; input : INITADDR: address of filename
               LDY  #0
               LDA  #<INITADDR
               STA  ADDR
               LDA  #>INITADDR
               STA  ADDR+1
ICLP1          LDA  (ADDR),Y
               BEQ  ICSK1
               STA  INPTBUFR,Y
               INY
               BNE  ICLP1
ICSK1          LDA  #$8D
               STA  INPTBUFR,Y
               JSR  SRCHFIL
               RTS             ; if not found, just return



INPTH?                         ; check current input pathname
                               ; input : string following JSR INPTH?
                               ;         INPTHAD: address of current
                               ;                  input pathname
                               ; output: C: set  : equal
                               ;            clear: not equal
               PLA
               STA  ADDR
               PLA
               STA  ADDR+1
               CLC
               LDA  ADDR
               ADC  #1
               STA  ADDR
               LDA  ADDR+1
               ADC  #0
               STA  ADDR+1
               LDA  INPTHAD
               STA  ADDR2
               LDA  INPTHAD+1
               STA  ADDR2+1
               LDY  #0
SDLP1          LDA  (ADDR),Y
               CMP  (ADDR2),Y
               BNE  ERSD
               CMP  #0
               BEQ  EXSD
               INY
               BNE  SDLP1
ERSD           CLC
               ROR  TEMP
               BPL  EXSD2      ; BRA
EXSD           SEC
               ROR  TEMP
EXSD2          LDA  (ADDR),Y
               BEQ  SDSK1
               INY
               BNE  EXSD2
SDSK1          CLC
               TYA
               ADC  ADDR
               STA  ADDR
               LDA  #0
               ADC  ADDR+1
               PHA
               LDA  ADDR
               PHA
               ROL  TEMP
               RTS



LAST                           ; last address used (plus one)
