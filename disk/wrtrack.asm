                               ; Write Track



               ORG  $6000



INA            EQU  $1A



PTR            EQU  $00
IMAGE          EQU  $2000



SLOT           EQU  $60
DRVOFF         EQU  $C088
DRVON          EQU  $C089
DRVRD          EQU  $C08C
DRVWR          EQU  $C08D
DRVRDM         EQU  $C08E
DRVWRM         EQU  $C08F

               LDX  #0
LOOP4          LDA  #$7F
LOOP3          STA  IMAGE,X
               INX
               BNE  LOOP3
               INC  LOOP3+2
               LDA  LOOP3+2
               CMP  #$60
               BNE  LOOP4

               LDX  #SLOT
               LDA  DRVON,X
               LDA  DRVRDM,X
               LDA  DRVRD,X
               JSR  WRITE
               LDA  DRVOFF,X
               RTS




WRITE          LDA  #0
               STA  PTR
               LDA  #>IMAGE
               STA  PTR+1
               LDY  #<IMAGE
               LDX  #SLOT
               SEC
               LDA  DRVWR,X
               LDA  DRVRDM,X
               BMI  WPERR
               LDA  #$FF
               STA  DRVWRM,X
               CMP  DRVRD,X
               NOP
               JMP  LOOP1
ASYNC          EOR  #$80       ; 2
               NOP             ; 2
               NOP             ; 2
               JMP  WRIT       ; 3
LOOP1          PHA             ; 3
               PLA             ; 4
LOOP2          LDA  (PTR),Y    ; 5 (6 if page crossed)
               CMP  #$80       ; 2
               BCC  ASYNC      ; 2 (3 if branch, 4 if branch with page crossed)
               NOP             ; 2
WRIT           STA  DRVWR,X    ; 5
               CMP  DRVRD,X    ; 4
               INY             ; 2
               BNE  LOOP1      ; 2 (3 if branch, 4 if branch with page crossed)
               INC  PTR+1      ; 5
               BPL  LOOP2      ; 2 (3 if branch, 4 if branch with page crossed)
               LDA  DRVRDM,X
               LDA  DRVRD,X
WPERR          RTS
