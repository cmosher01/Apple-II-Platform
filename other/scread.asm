                               ;  ____________________________________________
                               ; |                                            |
                               ; |                Screen  Read                |
                               ; |____________________________________________|
                               ;


               ORG  $98B0      ; Origin


                               ; ______________ Page 0 locations ______________
                               ;
BAS            EQU  $28        ; Text screen base address
CHRS           EQU  $FC        ; Storage for character
LEN            EQU  $FD        ; Storage for length of string
ROW            EQU  $FE        ; Storage for row
COL            EQU  $FF        ; Storage for column
                               ;
                               ;
                               ; ________________ Input buffer ________________
                               ;
STRING         EQU  $0200      ; Storage for string
                               ;
                               ;
                               ; _____________ I/O ROM  locations _____________
                               ;    _
ADSTORE        EQU  $C018      ; R7  |  eighty store switch:
ADSTOROF       EQU  $C000      ; W   |    off:  PAGE2 (page1/page2)
ADSTORON       EQU  $C001      ; W  _|    on :  PAGE2 (main /aux  )
                               ;    _
PAGE2          EQU  $C01C      ; R7  |  page two switch:
PAGE2OFF       EQU  $C054      ; RW  |    off: page1 (or main memory)
PAGE2ON        EQU  $C055      ; RW _|    on : page2 (or auxiliary memory)
                               ;
                               ;
                               ; ____________ Monitor  subroutines ____________
                               ;
BASCALC        EQU  $FBC1      ; Calculate text screen base address
                               ;
                               ;
                               ; ___________ ASCII  character codes ___________
                               ;
SP             EQU  $A0        ; space
                               ;
                               ; ______________________________________________




                               ; ________________ Global table ________________
                               ;                                 _
ENTRY          JMP  SCRNREAD   ; Entry point: SCRNREAD           _|- Jump table
                               ;                                 _
ALLOW          ASC             "'(),./0123456789:"                |  Table of
               ASC             "ABCDEFGHIJKLMNOPQRSTUVWXYZ"       |_ allowable
               ASC             "abcdefghijklmnopqrstuvwxyz"       |  characters
               DFB  $00        ;                                 _|
                               ;
                               ; ______________________________________________




                               ; ________________ Screen  Read ________________
                               ;
SCRNREAD       JSR  INSTR      ; If position is in the midst of a string,
               BCC  NOTIN      ;   then NOTIN else:
               JSR  BEGSTR     ; Set position to beginning of string.
               LDA  COL        ;
               PHA             ;
               JSR  MOVESTR    ; Move string from screen to memory.
               PLA             ;
               STA  COL        ;
               RTS             ; End.
NOTIN          LDA  #$00       ; Position is not in the midst of a string.
               STA  STRING     ; Zero string memory.
               STA  LEN        ; Zero length.
               RTS             ; End.
                               ;
                               ; ______________________________________________




                               ; ________________ Subroutines _________________
                               ; _
CALCADDR       LDA  ROW        ;  |  input:
               JSR  BASCALC    ;  |    ROW      row (0 origin)
               STA  ADSTORON   ;  |    COL      column (0 origin)
               STA  PAGE2OFF   ;  |
               LDA  COL        ;  |  output:
               LSR             ;  |    Y        offset for column
               BCS  L5         ;  |    BAS      base address
               STA  PAGE2ON    ;  |    PAGE2    set correctly
L5             TAY             ;  |
               RTS             ; _|  destroyed:
                               ;       (Y, BAS, PAGE2)
                               ;       A, P, ADSTORE
                               ;
                               ; _
RDSCRN         BIT  ADSTORE    ;  |  input:
               PHP             ;  |    ROW      row (0 origin)
               BIT  PAGE2      ;  |    COL      column (0 origin)
               PHP             ;  |
                               ;  |  output:
               JSR  CALCADDR   ;  |    A        character on screen
               LDA  (BAS),Y    ;  |
                               ;  |  destroyed:
               STA  PAGE2OFF   ;  |    (A)
               PLP             ;  |    P, Y, BAS
               BPL  L1         ;  |
               STA  PAGE2ON    ;  |
L1             STA  ADSTOROF   ;  |
               PLP             ;  |
               BPL  L2         ;  |
               STA  ADSTORON   ;  |
L2             RTS             ; _|
                               ;
                               ; _
LEGALCHR       HEX  DA         ;  |  input:                (PHX)
               STA  CHRS       ;  |    A        character to test
               LDX  #$00       ;  |
L3             LDA  ALLOW,X    ;  |
               BEQ  ILLEGAL    ;  |  output:
               CMP  #SP        ;  |    C        set: character is legal
               BEQ  L4         ;  |             clear: character is illegal
               CMP  CHRS       ;  |
               BEQ  LEGAL      ;  |  destroyed:
L4             INX             ;  |    P
               BNE  L3         ;  |
ILLEGAL        CLC             ;  |
               BCC  EXLEGAL    ;  |
LEGAL          SEC             ;  |
EXLEGAL        LDA  CHRS       ;  |
               HEX  FA         ;  |                       (PLX)
               RTS             ; _|
                               ;
                               ; _
RDEND          JSR  RDSCRN     ;  |  input:
               JSR  LEGALCHR   ;  |    ROW      row (0 origin)
               BCS  NOEND      ;  |    COL      column (0 origin)
               CMP  #SP        ;  |
               BNE  END        ;  |  output:
               INC  COL        ;  |    C        set: position in past end
               JSR  RDSCRN     ;  |             clear: position is not past end
               DEC  COL        ;  |    A        character at position
               JSR  LEGALCHR   ;  |
               BCC  END        ;  |  destroyed:
               LDA  #SP        ;  |    (A)
NOEND          CLC             ;  |    P, Y, BAS
               BCC  EXEND      ;  |
END            SEC             ;  |
EXEND          RTS             ; _|
                               ;
                               ; _
INSTR          LDA  COL        ;  |  input:
               PHA             ;  |    ROW      row (0 origin)
               JSR  RDSCRN     ;  |    COL      column (0 origin)
               JSR  LEGALCHR   ;  |
               BCS  IN         ;  |  output:
               CMP  #SP        ;  |    C        set: in midst of string
               BNE  NOIN       ;  |             clear: not in midst of string
               LDA  COL        ;  |
               CMP  #$00       ;  |  destroyed:
               BEQ  NOIN       ;  |    A, P, Y, BAS
               CMP  #$4F       ;  |
               BEQ  NOIN       ;  |
               DEC  COL        ;  |
               JSR  RDSCRN     ;  |
               JSR  LEGALCHR   ;  |
               BCC  NOIN       ;  |
               INC  COL        ;  |
               INC  COL        ;  |
               JSR  RDSCRN     ;  |
               JSR  LEGALCHR   ;  |
               BCS  IN         ;  |
NOIN           CLC             ;  |
               BCC  EXIN       ;  |
IN             SEC             ;  |
EXIN           PLA             ;  |
               STA  COL        ;  |
               RTS             ; _|
                               ;
                               ; _
BEGSTR         DEC  COL        ;  |  input:
               BMI  EXBEG      ;  |    ROW      row (0 origin)
               JSR  RDSCRN     ;  |    COL      column (0 origin)
               JSR  LEGALCHR   ;  |
               BCS  BEGSTR     ;  |  output:
               CMP  #SP        ;  |    COL      column (0 origin) of beginning
               BNE  EXBEG      ;  |             of string in midst
               DEC  COL        ;  |
               JSR  RDSCRN     ;  |  destroyed:
               JSR  LEGALCHR   ;  |    (COL)
               BCS  BEGSTR     ;  |    A, P, Y, BAS
               INC  COL        ;  |
EXBEG          INC  COL        ;  |
               RTS             ; _|
                               ;
                               ; _
MOVESTR        LDX  #$00       ;  |  input:
L8             JSR  RDEND      ;  |    ROW      row of beginning (0 origin)
               BCS  EXMOVE     ;  |    COL      column of beginning (0 origin)
               STA  STRING,X   ;  |
               INX             ;  |  output:
               LDA  COL        ;  |    STRING   string on screen
               CMP  #$4F       ;  |    LEN      length of string
               BEQ  EXMOVE     ;  |
               INC  COL        ;  |  destroyed:
               JMP  L8         ;  |    (STRING, LEN)
EXMOVE         LDA  #$00       ;  |    A, P, X, Y, BAS, COL
               STA  STRING,X   ;  |
               STX  LEN        ;  |
               RTS             ; _|
