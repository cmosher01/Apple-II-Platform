******************************************************
* Hyper-fast self-mod 40 columns text screen scroll. *
*                         By                         *
*            Mark Foerster, June 13, 1988            *
******************************************************
               LST  OFF



WNDLFT         EQU  $20
WNDWDTH        EQU  $21
WNDTOP         EQU  $22
WNDBTM         EQU  $23
BASL           EQU  $28
BASH           EQU  $29
INVFLG         EQU  $32
VFACTV         EQU  $67B
VTABZ          EQU  $FC24



               ORG  $D000

               TXA             ;\_
               PHA             ;/  Save X register
               LDA  BASL       ;Save text screen base address
               PHA
               LDA  BASH
               PHA

               LDA  WNDBTM     ;Advance load of window bottom
               LDY  WNDTOP     ;\_
               CPY  OLDTOP     ;/ Change in top?
               BNE  INISHLZ    ;=> Yes, reinitialize
               LDY  WNDLFT     ;\_
               CPY  OLDLFT     ;/ Change in left margin?
               BNE  INISHLZ    ;=> Yes, reinitialize
               CMP  OLDBTM     ;Change in bottom?
               BNE  INISHLZ    ;=> Yes, reinitialize
               JMP  SCROLL     ;WINDOW PARAMETERS UNCHANGED!



INISHLZ        CLC
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

               LDY  WNDTOP     ;\
               STY  OLDTOP     ; |
               LDY  WNDBTM     ; |_ Save window
               STY  OLDBTM     ; |  parameters
               LDY  WNDLFT     ; |
               STY  OLDLFT     ;/

               TAX             ;Offset for starting self-mod initialization
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
               JSR  VTABZ
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
               CPY  #7
               BCC  REGDOWN
               CMP  #$80
               BCC  REGDOWN
                               ;Crossing thirds move down
               ADC  #$A7       ; ADD #$A8
               LDY  #4
               BCS  ADVANCE    ;Always taken
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

SETBLNK        STA  CLEARIT+2
               STY  CLEARIT+3



SCROLL         LDY  WNDWDTH
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
               BMI  BLANKLN
               JMP  (COPYSTRT)



COPYSTRT       DA   0
OLDTOP         DFB  $FF
OLDBTM         DFB  $FF
OLDLFT         DFB  $FF



BLANKLN        LDY  WNDWDTH    ;Advance load of window width

               LDA  #$A0       ;Blackspace
               BIT  VFACTV     ;\
               BMI  CLEARIT    ; >- If EVF is on, use inverse mask
               AND  INVFLG     ;/   (allows inverse clearing)

CLEARIT        DEY             ;\
               STA  $FFFF,Y    ; >- Clear the bottom line
               BNE  CLEARIT    ;/

               PLA             ;Recover text screen base address
               STA  BASH
               PLA
               STA  BASL
               PLA             ;\_
               TAX             ;/  Recover X register

               RTS
