                               ;
                               ; The Command interpreter system.
                               ;
                               ; Part One.
                               ;
                               ; Christopher A. Mosher
                               ;
                               ; must set CODE and LENGTH properly
                               ;

CODE           EQU  $A000      ; start of (relocated) code
LENGTH         EQU  $05        ; length of code (pages)

DESTADDR       EQU  $FE        ; address of destination (lo hi)
SOURADDR       EQU  $FC        ; address of source (lo hi)

IMAGE          EQU  $2100      ; start of code image
                               ;   code must have been previously
                               ;   assembled at the destination address
                               ;   and then loaded at the image address



               ORG  $2000

                               ; Command interpreter system.
               LDA  #<CODE     ; move LENGTH pages from IMAGE to CODE
               STA  DESTADDR
               LDA  #>CODE
               STA  DESTADDR+1
               LDX  #LENGTH



                               ; Relocate and execute machine language code
                               ;
                               ; input : DESTADDR: address of destination
                               ;                X: length of code (pages)
                               ;                   $00 <= X <= $80
               LDA  DESTADDR
               BNE  RSK1
               LDA  DESTADDR+1
               DFB  $3A        ; DEA
               DFB  $2C        ; BIT absorbs LDA DESTADDR+1
RSK1           LDA  DESTADDR+1
               PHA
               LDA  DESTADDR
               DFB  $3A        ; DEA
               PHA
               LDA  #<IMAGE
               STA  SOURADDR
               LDA  #>IMAGE
               STA  SOURADDR+1
RLP1           DEX
               BMI  EXR
               LDY  #0
RLP2           LDA  (SOURADDR),Y
               STA  (DESTADDR),Y
               INY
               BNE  RLP2
               INC  SOURADDR+1
               INC  DESTADDR+1
               BNE  RLP1
EXR            RTS             ; begin executing at DESTADDR
