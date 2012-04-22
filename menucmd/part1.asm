                               ;
                               ; Menu Command
                               ;   part 1: the front end installer
                               ;   incorporating
                               ;   Safeguard Loader
                               ;
                               ;
                               ; Christopher A. Mosher
                               ; February 1988
                               ;



               ORG  $2000



NXTCMD         EQU  $2122      ; image address of NXTCMD in part 2
CODE           EQU  $8700      ; start of (relocated) code
LENGTH         EQU  $13        ; length of code (pages)
IMAGE          EQU  $2100      ; start of code image
                               ;   code must have been previously
                               ;   assembled at the destination address
                               ;   and then loaded at the image address



                               ; BASIC interpreter system global page
BIENTRY        EQU  $BE00      ; warmstart
EXTCMD         EQU  $BE06      ; external command handler (JMP $FFFF)
PRINTERR       EQU  $BE0C      ; error message printer
ERNOBUF        EQU  $0C        ; no buffers available
GETBUFR        EQU  $BEF5      ; allocate A pages below $9A00; C = success?
FREBUFR        EQU  $BEF8      ; free all allocated space



                               ; Menu Command part 1

               JSR  FREBUFR
               LDA  #LENGTH
               JSR  GETBUFR
               BCC  SFSK1
               LDA  #ERNOBUF
               JSR  PRINTERR
               JMP  BIENTRY
SFSK1          CMP  #>CODE
               BEQ  SFSK2
               LDA  #ERNOBUF
               JSR  PRINTERR
               JMP  BIENTRY
SFSK2          LDA  EXTCMD+1
               STA  NXTCMD+1
               LDA  EXTCMD+2
               STA  NXTCMD+2
               LDA  #<CODE
               STA  EXTCMD+1
               LDA  #>CODE
               STA  EXTCMD+2
               JSR  RELOCATE
               JMP  BIENTRY



RELOCATE                       ; Relocate machine language code
                               ;
                               ; input : IMAGE : address of code image
                               ;         CODE  : address of code destination
                               ;         LENGTH: length of code (pages)

               LDY  #LENGTH
               BEQ  RSK1
               LDA  #<IMAGE
               STA  RLDA+1
               LDA  #>IMAGE
               STA  RLDA+2
               LDA  #<CODE
               STA  RSTA+1
               LDA  #>CODE
               STA  RSTA+2
               LDX  #0
RLDA           LDA  $FFFF,X
RSTA           STA  $FFFF,X
               INX
               BNE  RLDA
               INC  RLDA+2
               INC  RSTA+2
               DEY
               BNE  RLDA
RSK1           RTS
