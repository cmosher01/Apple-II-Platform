********************************************************
* Hyper-fast self-mod 40-80 columns text screen scroll *
*                          By                          *
*             Mark Foerster, June 13, 1988             *
*                                                      *
*            Up-down revision, July 7, 1988            *
*                                                      *
*             40-80 revision, July 12, 1988            *
********************************************************
               LST  OFF



WNDLFT         EQU  $20
WNDWDTH        EQU  $21
WNDTOP         EQU  $22
WNDBTM         EQU  $23
BASL           EQU  $28
BASH           EQU  $29
INVFLG         EQU  $32
VFACTV         EQU  $67B
RD80VID        EQU  $C01F
PAGE2OFF       EQU  $C054
PAGE2ON        EQU  $C055
BASCALC        EQU  $FBC1



               ORG  $2000

               TXA             ;\_
               PHA             ;/  Save X register
               LDX  #$FF       ;Downscroll
               BNE  SAVBAS     ;Always taken

               TXA             ;\_
               PHA             ;/  Save X register
               LDX  #0         ;Upscroll
SAVBAS         LDA  BASL       ;Save text screen base address
               PHA
               LDA  BASH
               PHA

               CPX  UPDOWN     ;Last scroll direction same?
               BNE  INISHLZ    ;=> No, reinitialize
               LDY  WNDTOP     ;\_
               CPY  OLDTOP     ;/ Change in top?
               BNE  INISHLZ    ;=> Yes, reinitialize
               LDA  WNDLFT
               BIT  RD80VID    ;80 columns on?
               BPL  OFF80      ;=> No
               LSR
OFF80          CMP  OLDLFT     ;Change in left margin?
               BNE  INISHLZ    ;=> Yes, reinitialize
               LDA  WNDBTM
               CMP  OLDBTM     ;Change in bottom?
               BNE  INISHLZ    ;=> Yes, reinitialize
               BIT  RD80VID
               BPL  GOGOGO     ;=> 40 cols, SCROLL IT!
               LDY  WNDWDTH
               CPY  OLDWDTH
               BNE  DODAT80    ;=> Reinit the 80 cols mar cntl
               LDA  WNDLFT
               CMP  OLD80LFT
               BEQ  GOGOGO
DODAT80        JSR  DATA80
GOGOGO         JMP  SCROLL     ;WINDOW PARAMETERS UNCHANGED!



DATA80         LDA  WNDWDTH
               STA  OLDWDTH
               LSR
               TAY
               TAX
               LDA  WNDLFT
               STA  OLD80LFT
               LSR
               LDA  #$10       ;BPL opcode
               BCC  BOATH
               LDA  #$D0       ;BNE opcode
BOATH          STA  BRBLNK
               ORA  #$20       ;Convert to opposite branch
               STA  BRCOPY
               LDA  WNDWDTH    ;Width again
               ROL             ;Combine carry w/ 0 bit of accum
               AND  #3         ;Isolate those two bits (1=w, 0=l)
               CMP  #3
               BEQ  NODEK
               CMP  #0
               BNE  DEKMAIN
               DEY             ;Aux Y index
DEKMAIN        DEX             ;Main Y index
NODEK          STY  AUXY
               STX  MAINY
               LSR             ;Transfer l.mar odd/even
               ROR             ;bit to hi bit
               BPL  PSTOR      ;=> Width=1 not a concern
               LDX  WNDWDTH
               DEX
               BEQ  PSTOR
               EOR  #$80       ;Width<>1, mark it
PSTOR          STA  PASSCTL
               RTS



INISHLZ        STX  UPDOWN
               BIT  RD80VID
               BPL  NSHLZ
               JSR  DATA80
NSHLZ          LDA  WNDBTM
               CLC
               SBC  WNDTOP     ;= # of lines in window (0 to 23)
               ASL             ;*2  \
               STA  COPYSTRT   ;save |_
               ASL             ;*4   |  Mult. # of lines by 6
               ADC  COPYSTRT   ;=6  /
               STA  COPYSTRT   ;Save actual # of lines * 6
               LDA  #23*6+1    ;Max lines (Carry clear from ADC above)
               SBC  COPYSTRT   ;Max lines - actual lines = How far into bank
                               ;of self mod LDA-STA instrs. is the start of the
                               ;used LDA-STA pairs
               TAX             ;Offset for self-mod initialization

               LDY  WNDTOP     ;\
               STY  OLDTOP     ; |
               LDY  WNDBTM     ; |
               STY  OLDBTM     ; |
               LDA  WNDLFT     ; |- Save window parameters
               BIT  RD80VID    ; |
               BPL  FORTY      ; |
               LSR             ; |
FORTY          STA  OLDLFT     ;/

               TXA             ;Restore A contents
               CMP  #23*6      ;Would be null scroll?
               BLT  CALCSTRT   ;=> No, will scroll

               LDA  #<BLANKLN  ;Null scroll: set (COPYSTRT)--> BLANKLN
               STA  COPYSTRT
               LDA  #>BLANKLN
               STA  COPYSTRT+1
               BNE  CLCPAIRS   ;Always taken

CALCSTRT       LDY  #>SLFMOD   ;\
               CLC             ; |
               ADC  #<SLFMOD   ; |
               BCC  STOR       ; |- Add entry pt. offset to actual address of
               INY             ; |  base of LDA-STA pairs for looping
STOR           STY  COPYSTRT+1 ; |
               STA  COPYSTRT   ;/

CLCPAIRS       LDA  WNDTOP
               BIT  UPDOWN     ;Scroll up or down?
               BPL  UP         ;=> Scroll up
               LDY  WNDBTM
               DEY
               TYA
UP             JSR  BASCALC
               ADC  OLDLFT
               LDY  BASH
               JMP  STAY1ST

LOADINIT       STA  SLFMOD-5,X ;\ lo
               PHA             ; |
               TYA             ; |- LDA of a load-store pair
               STA  SLFMOD-4,X ; |hi
               PLA             ;/
STAY1ST        CPX  #23*6      ;End of initializing?
               BEQ  SETBLNK    ;=> mostly, initialize bottom line clearing
               STA  SLFMOD+4,X ;\ lo
               PHA             ; |
               TYA             ; |- STA of a load-store pair
               STA  SLFMOD+5,X ; |hi
               PLA             ;/
               BIT  UPDOWN     ;Move address up or down?
                               ;(addr up for downscroll, vice-versa)
               BPL  DOWN       ;DOWN YOU FOOL!
               CPY  #4
               BNE  REGUP
               CMP  #$80
               BCS  REGUP
                               ;Crossing thirds move up
               SBC  #$A7       ;Subtracts A8
               LDY  #7
               BNE  ADVANCE    ;Always taken
REGUP          EOR  #$80
               BPL  ADVANCE
               DEY
               BNE  ADVANCE    ;Always taken

                               ;Moving address down (upscroll)
DOWN           CPY  #7
               BCC  REGDOWN
               CMP  #$80
               BCC  REGDOWN
                               ;Crossing thirds move down
               ADC  #$A7       ; ADD #$A8
               LDY  #4
               BNE  ADVANCE    ;Always taken
REGDOWN        EOR  #$80
               BMI  ADVANCE
               INY

ADVANCE        PHA             ;Save l.b. of address
               TXA             ;\
               CLC             ; |_
               ADC  #6         ; | Increment X by six
               TAX             ;/
               PLA             ;Recover l.b. of address
               BCC  LOADINIT   ;Always taken

SETBLNK        STA  CLEARIT+1
               STY  CLEARIT+2



SCROLL         BIT  RD80VID
               BPL  SCROL4
               LDY  MAINY
               BPL  MANEIT
               JMP  AUXIT
MANEIT         CLC             ;Indicate main pass
               JMP  (COPYSTRT)
SCROL4         LDY  WNDWDTH
               DEY
               JMP  (COPYSTRT) ;Jump into the entry point of the loop
SLFMOD         LDA  $FFFF,Y
               STA  $FFFF,Y
               LDA  $FFFF,Y
               STA  $FFFF,Y
               LDA  $FFFF,Y
               STA  $FFFF,Y
               LDA  $FFFF,Y
               STA  $FFFF,Y
               LDA  $FFFF,Y
               STA  $FFFF,Y
               LDA  $FFFF,Y
               STA  $FFFF,Y
               LDA  $FFFF,Y
               STA  $FFFF,Y
               LDA  $FFFF,Y
               STA  $FFFF,Y
               LDA  $FFFF,Y
               STA  $FFFF,Y
               LDA  $FFFF,Y
               STA  $FFFF,Y
               LDA  $FFFF,Y
               STA  $FFFF,Y
               LDA  $FFFF,Y
               STA  $FFFF,Y
               LDA  $FFFF,Y
               STA  $FFFF,Y
               LDA  $FFFF,Y
               STA  $FFFF,Y
               LDA  $FFFF,Y
               STA  $FFFF,Y
               LDA  $FFFF,Y
               STA  $FFFF,Y
               LDA  $FFFF,Y
               STA  $FFFF,Y
               LDA  $FFFF,Y
               STA  $FFFF,Y
               LDA  $FFFF,Y
               STA  $FFFF,Y
               LDA  $FFFF,Y
               STA  $FFFF,Y
               LDA  $FFFF,Y
               STA  $FFFF,Y
               LDA  $FFFF,Y
               STA  $FFFF,Y
               LDA  $FFFF,Y
               STA  $FFFF,Y
               DEY
MODBR1         BMI  PASSPROC
               JMP  (COPYSTRT)
PASSPROC       BIT  RD80VID
               BPL  BLANKLN
               BCS  BLK80LN
               BIT  PASSCTL    ;Do aux pass or not?
               BMI  BLANKLN    ;=> Not
AUXIT          LDY  AUXY
               LDA  BRCOPY
               STA  MODBR1
               SEC
               LDA  PAGE2ON
               JMP  (COPYSTRT)
BLK80LN        LDA  PAGE2OFF
               LDA  #$30       ;BMI opcode restored
               STA  MODBR1
               BNE  BLANKLN    ;Always taken



COPYSTRT       DA   0
OLDTOP         DFB  $FF
OLDBTM         DFB  $FF
OLDLFT         DFB  $FF
UPDOWN         DFB  $FF        ;Last scroll was down
OLDWDTH        DFB  $FF
OLD80LFT       DFB  $FF
MAINY          DS   1
AUXY           DS   1
BRCOPY         DS   1
BRBLNK         DS   1
PASSCTL        DS   1



BLANKLN        LDA  #$A0       ;Blackspace
               BIT  VFACTV     ;\
               BMI  GETY       ; >- If EVF is on, use inverse mask
               AND  INVFLG     ;/   (allows inverse clearing)

GETY           PHA             ;Save the space
               BIT  RD80VID
               BPL  WHY4
               LDY  MAINY
               BMI  AUXCLR
               CLC
               BCC  CLEARIT
WHY4           LDY  WNDWDTH
               DEY

CLEARIT        STA  $FFFF,Y    ;Clear the bottom line
               DEY
MODBR2         BPL  CLEARIT
               BIT  RD80VID
               BPL  EKSIT
               BCS  EKS80IT
               BIT  PASSCTL
               BMI  EKSIT      ;No aux pass
AUXCLR         LDY  AUXY
               SEC
               LDA  PAGE2ON
               LDA  BRBLNK
               STA  MODBR2
               PLA             ;Get the space
               BCS  CLEARIT    ;Always taken
EKS80IT        LDA  PAGE2OFF
               LDA  #$10       ;BPL opcode
               STA  MODBR2
               BNE  EKSIT2

EKSIT          PLA             ;Remove the space
EKSIT2         PLA             ;Recover text screen base address
               STA  BASH
               PLA
               STA  BASL
               PLA             ;\_
               TAX             ;/  Recover X register

               RTS
