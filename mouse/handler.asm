               ORG  $4000      ; Origin




                               ; ______________ Page 0 locations ______________
                               ;
CV             EQU  $25        ; Vertical cursor position
BASL           EQU  $28        ; Text screen base address (low)
BASH           EQU  $29        ; Text screen base address (high)
INVFLG         EQU  $32        ; Inverse flag
OLDBASL        EQU  $08        ; Storage for old text screen position (low)
OLDBASH        EQU  $09        ; Storage for old text screen position (high)
ROW            EQU  $FE        ; Storage for row
COL            EQU  $FF        ; Storage for column
                               ;
                               ;
                               ; _______________ Page 3 vectors _______________
                               ;
IRQLOCL        EQU  $03FE      ; User IRQ interrupt vector (low)
IRQLOCH        EQU  $03FF      ; User IRQ interrupt vector (high)
                               ;
                               ;
                               ; ___________ Screen hole  locations ___________
                               ;
MINL           EQU  $0478      ; Clamping minimum to set (low)
MAXL           EQU  $04F8      ; Clamping maximum to set (low)
MINH           EQU  $0578      ; Clamping minimum to set (high)
MAXH           EQU  $05F8      ; Clamping maximum to set (high)
MOUXL          EQU  $047C      ; X coordinate (low)
MOUYL          EQU  $04FC      ; Y coordinate (low)
MOUXH          EQU  $057C      ; X coordinate (high)
MOUYH          EQU  $05FC      ; Y coordinate (high)
MOUARM         EQU  $067C      ; Interrupt arming byte
MOUSTAT        EQU  $077C      ; Mouse status byte:
                               ; value    meaning
                               ; 1....... button down
                               ; .1...... button down still
                               ; ..1..... movement since last read
                               ; ....1... VBL interrupt has occurred
                               ; .....1.. button interrupt has occurred
                               ; ......1. movement interrupt has occurred
MOUMODE        EQU  $07FC      ; Mouse mode byte:
                               ; value    meaning
                               ; ....1... VBL interrupts enabled
                               ; .....1.. button interrupts enabled
                               ; ......1. movement interrupts enabled
                               ; .......1 mouse on
MINXL          EQU  $047D      ; X clamping minimum (low)
MINYL          EQU  $04FD      ; Y clamping minimum (low)
MINXH          EQU  $057D      ; X clamping minimum (high)
MINYH          EQU  $05FD      ; Y clamping minimum (high)
MAXXL          EQU  $067D      ; X clamping maximum (low)
MAXYL          EQU  $06FD      ; Y clamping maximum (low)
MAXXH          EQU  $077D      ; X clamping maximum (high)
MAXYH          EQU  $07FD      ; Y clamping maximum (high)
CH             EQU  $057B      ; Horizontal cursor position
                               ;
                               ;
                               ; _____________ I/O ROM  locations _____________
                               ;
PAGE2          EQU  $C01C      ; R7 -+  page two switch
PAGE2OFF       EQU  $C054      ; RW  !    off: page1 (or main memory)
PAGE2ON        EQU  $C055      ; RW -+    on : page2 (or auxiliary memory)
                               ;
                               ;
                               ; ____________ Monitor  subroutines ____________
                               ;
MTABLE         EQU  $C412      ; Start of mouse ROM table
SETM           EQU  $00        ; Set up mouse mode
SERVEM         EQU  $01        ; Set up carry flag and MOUSTAT
READM          EQU  $02        ; Read positon registers (IIe only)
CLEARM         EQU  $03        ; Set X and Y coordinates to 0
POSM           EQU  $04        ; Set mouse to X and Y coodinates
CLAMPM         EQU  $05        ; Set clamping boundaries:
                               ; A value  meaning
                               ;     0    X coordinate
                               ;     1    Y coordinate
HOMEM          EQU  $06        ; Set mouse to upper left corner of window
INITM          EQU  $07        ; Set default values
BASCALC        EQU  $FBC1      ; Calculate text screen base address
NEWVTAB        EQU  $FC86      ; Move cursor to vertical position
COUT           EQU  $FDED      ; Standard character out routine
                               ;
                               ;
                               ; ______________________________________________




                               ; ________________ Global table ________________
                               ;
EMOUON         JMP  MOUON      ; Entry for MOUON         -+_ Jump
EMOOUOFF       JMP  MOUOFF     ; Entry for MOUOFF        -+  table
                               ;
CURSOR         DFB  $42        ; Mouse text B            -+
ROWSTRT        DS   $100       ; Row stack                !
COLSTRT        DS   $100       ; Column stack             !- Data table
STAKLEN        DS   1          ; Length of stacks         !
FULLSTK        DS   1          ; Full stack indicator    -+
                               ;
TITLE          ASC             "Mouse Handler"           -+_ Title
AUTHOR         ASC             "Christopher A. Mosher"   -+  page
                               ;
                               ;
                               ; ______________________________________________




                               ; Turn on the mouse
MOUON          LDA  #$00       ; Initialize variables
               STA  STAKLEN
               STA  FULLSTK
                               ;
               LDA  IRQLOCL    ; -+
               STA  IRQLS      ;  !_ Save user IRQ
               LDA  IRQLOCH    ;  !  interrupt vector
               STA  IRQHS      ; -+
                               ;
               LDA  #<IRQHNDL  ; -+
               STA  IRQLOCL    ;  !_ Install mouse IRQ
               LDA  #>IRQHNDL  ;  !  interrupt vector
               STA  IRQLOCH    ; _+
                               ;
               LDX  #INITM     ; -+_ Set default
               JSR  MOUSER     ; -+  values
                               ;
               LDA  #$58       ; -+
               STA  MAXL       ;  !
               LDA  #$00       ;  !
               STA  MAXH       ;  !_ Set clamping boundaries
               STA  MINH       ;  !  for X coordinate
               LDA  #$1C       ;  !
               STA  MINL       ;  !
               LDA  #$00       ;  !
               LDX  #CLAMPM    ;  !
               JSR  MOUSER     ; -+
                               ;
               LDA  #$A5       ; -+
               STA  MAXL       ;  !
               LDA  #$00       ;  !_ Set clamping boundaries
               STA  MAXH       ;  !  for Y coordinate
               STA  MINH       ;  !
               LDA  #$28       ;  !
               STA  MINL       ;  !
               LDA  #$01       ;  !
               LDX  #CLAMPM    ;  !
               JSR  MOUSER     ; -+
                               ;
               LDA  #$07       ; -+_ Set mouse
               LDX  #SETM      ;  !  mode (movement and button)
               JSR  MOUSER     ; -+
                               ;
               LDA  ROW        ; -+
               ASL             ;  !
               ASL             ;  !
               ASL             ;  !
               STA  MOUYL      ;  !
               LDA  #$00       ;  !
               STA  MOUYH      ;  !
               LDA  COL        ;  !_ Set mouse
               ASL             ;  !  X and Y coordinates
               ASL             ;  !
               STA  MOUXL      ;  !
               LDA  #$00       ;  !
               ROL             ;  !
               STA  MOUXH      ;  !
               LDX  #POSM      ;  !
               JSR  MOUSER     ; -+
                               ;
               BIT  PAGE2      ; -+_ Store
               PHP             ; -+  PAGE2
                               ;
               JSR  NEWCUR     ; Output new cursor and restore and save values
                               ;
               STA  PAGE2OFF   ; -+
               PLP             ;  !_ Restore
               BPL  EXINT      ;  !  PAGE2
               STA  PAGE2ON    ; -+
                               ;
EXINT          CLI             ; Enable interrupts
               RTS             ;




                               ; Turn off the mouse
                               ;
MOUOFF         LDA  #$00       ; -+_ Set mouse
               LDX  #SETM      ;  !  mode (off)
               JSR  MOUSER     ; -+
                               ;
               LDA  IRQLS      ; -+
               STA  IRQLOCL    ;  !_ Restore IRQ
               LDA  IRQHS      ;  !  interrupt vector
               STA  IRQLOCH    ; -+
                               ;
               BIT  PAGE2      ; -+_ Store
               PHP             ; -+  PAGE2
                               ;
               STA  PAGE2OFF   ; -+
               BIT  OLDP2S     ;  !
               BPL  L7         ;  !_ Remove
               STA  PAGE2ON    ;  !  cursor
L7             LDY  OLDY       ;  !
               LDA  OLDCHR     ;  !
               STA  (OLDBASL),Y; -+
                               ;
               STA  PAGE2OFF   ; -+
               PLP             ;  !_ Restore
               BPL  L9         ;  !  PAGE2
               STA  PAGE2ON    ;  !
L9             RTS             ; -+




                               ; Interrupt handler
                               ;
IRQHNDL        PHA             ;
               DFB  $DA        ; PHX
               DFB  $5A        ; PHY
               LDX  #SERVEM    ;
               JSR  MOUSER     ; Service mouse interrupt
               BCS  EXIRQ      ; If not mouse interrupt then exit
               LDA  MOUSTATS   ; Get mouse status
               LSR             ;
               LSR             ; Put movement bit in carry
               BCC  CHKBTN     ; If no movement then check button
                               ;
               BIT  PAGE2      ; -+_ Store
               PHP             ; -+  PAGE2
                               ;
               LDA  BASH       ; -+
               PHA             ;  !_ Store cursor
               LDA  BASL       ;  !  position
               PHA             ; -+
                               ;
               JSR  MVEHNDL    ; Handle movement
                               ;
               PLA             ; -+
               STA  BASL       ;  !_ Restore cursor
               PLA             ;  !  position
               STA  BASH       ; -+
                               ;
               STA  PAGE2OFF   ; -+
               PLP             ;  !_ Restore
               BPL  EXIRQ      ;  !  PAGE2
               STA  PAGE2ON    ; -+
                               ;
CHKBTN         LSR             ; Put button bit in carry.
               BCC  EXIRQ      ; If not button interrupt then exit
               SEI             ; Disable interrupts
               JSR  BTNHNDL    ; Handle button press
               CLI             ; Enable interrupts

EXIRQ          HEX  7A         ; PLY
               HEX  FA         ; PLX
               PLA             ;
               RTI             ;
                               ;
                               ; Movement handler
                               ;
MVEHNDL        STA  PAGE2OFF   ; -+
               BIT  OLDP2S     ;  !
               BPL  L1         ;  !_ Remove
               STA  PAGE2ON    ;  !  old cursor
L1             LDY  OLDY       ;  !
               LDA  OLDCHR     ;  !
               STA  (OLDBASL),Y; -+
                               ;
               JSR  CALCROW    ; Calculate row
               JSR  CALCCOL    ; Calculate column
                               ;
NEWCUR         LDA  ROW        ;
               JSR  BASCALC    ; Calculate base address
                               ; -+
               STA  PAGE2OFF   ;  !
               LDA  COL        ;  !_ Choose
               LSR             ;  !  main/aux mem
               BCS  L3         ;  !
               STA  PAGE2ON    ; -+
                               ;
L3             TAY             ; -+
               STY  OLDY       ;  !
               LDA  (BASL),Y   ;  !
               STA  OLDCHR     ;  !
               LDA  CURSOR     ;  !
               STA  (BASL),Y   ;  !_ Output cursor and
               LDA  PAGE2      ;  !  save old values
               STA  OLDP2S     ;  !
               LDA  BASL       ;  !
               STA  OLDBASL    ;  !
               LDA  BASH       ;  !
               STA  OLDBASH    ; -+
                               ;
               RTS             ;
                               ;
                               ; Button handler
                               ;
BTNHNDL        JSR  CALCROW    ; Calculate row
               JSR  CALCCOL    ; Calculate column
               JSR  CHKRC      ; See if this row/column pair exists
               BCS  EXBTN      ; If it does, then exit, else
               JSR  PUSHRC     ; put them on the stacks
               JSR  PRINV      ; and print the inverse space
EXBTN          RTS             ; exit




                               ; Execute a mouse subroutine
                               ;
MOUSER         PHA             ;
               LDA  MTABLE,X   ; Get mouse subroutine address (low)
               STA  MOUSRADR   ; Set up mouse subroutine address
               PLA             ;
               PHP             ;
               SEI             ; Disable interrupts
               STX  XSAVE      ;
               STY  YSAVE      ;
               JSR  DOMOUSE    ; Execute mouse subroutine
               LDY  YSAVE      ;
               LDX  XSAVE      ;
               PHA             ;
               LDA  MOUXL
               STA  MOUXLS
               LDA  MOUXH
               STA  MOUXHS
               LDA  MOUYL
               STA  MOUYLS
               LDA  MOUYH
               STA  MOUYHS
               LDA  MOUSTAT
               STA  MOUSTATS
               PLA
               PLP
               RTS
DOMOUSE        LDY  #$40
               LDX  #$C4
               JMP  (MOUSRADR)

XSAVE          DS   1
YSAVE          DS   1
MOUXLS         DS   1
MOUXHS         DS   1
MOUYLS         DS   1
MOUYHS         DS   1
MOUSTATS       DS   1
OLDCHR         DS   1
OLDP2S         DS   1
OLDY           DS   1
IRQLS          DS   1
IRQHS          DS   1
MOUSRADR       DS   1          ; Mouse subroutine address (low)
               DFB  $C4        ; Mouse subroutine address (high)
                               ;
CALCROW        LDA  MOUYLS     ; -+
               LSR             ;  !_ Calculate
               LSR             ;  !  ROW
               LSR             ;  !
               STA  ROW        ;  !
               RTS             ; -+
                               ;
CALCCOL        LSR  MOUXHS     ; -+
               ROR  MOUXLS     ;  !
               LSR  MOUXHS     ;  !_ Calculate
               ROR  MOUXLS     ;  !  COL
               LDA  MOUXLS     ;  !
               STA  COL        ;  !
               RTS             ; -+

PUSHRC         LDY  STAKLEN    ; Push ROW and COL on the appropriate stacks
               LDA  ROW
               STA  ROWSTRT,Y
               LDA  COL
               STA  COLSTRT,Y
               INC  STAKLEN
               BNE  EXPUSH
               LDA  #$FF
               STA  FULLSTK
EXPUSH         RTS

CHKRC          LDA  FULLSTK    ; See if ROW and COL already exist
               BMI  FOUND      ; on the stacks
               LDY  #$00
               BEQ  ENTRC
RC1            LDA  ROWSTRT,Y
               CMP  ROW
               BNE  NOCHKCOL
               LDA  COLSTRT,Y
               CMP  COL
               BEQ  FOUND
NOCHKCOL       INY
ENTRC          CPY  STAKLEN
               BNE  RC1
               CLC
               RTS
FOUND          SEC
               RTS

PRINV          LDA  #$3F       ; Print an inverse space
               STA  INVFLG
               LDA  ROW
               STA  CV
               JSR  NEWVTAB
               LDA  COL
               STA  CH
               LDA  #$20
               STA  OLDCHR
               JSR  COUT
               LDA  #$FF
               STA  INVFLG
               RTS
