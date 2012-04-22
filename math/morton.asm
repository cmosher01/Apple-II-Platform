               ORG  $5000      ; Origin




                               ;________________ Global table _________________
                               ;
EMORTON        JMP  MORTON     ; Entry point for the (de)coder and compressor
                               ;
CODE           DS   1          ; Code Compress  /  Decompress Decode  indicator
LENGTH         DS   2          ; Length of input list(s)
ROWS           DS   $100       ; List of all row numbers (also used as new
                               ;   list by the decompressor)
COLS           DS   $100       ; List of all column numbers
MORTS          DS   $100       ; List of all Morton numbers
SIZES          DS   $100       ; List of sizes for the compressor
ROW            DS   1          ; Storage for row number
COL            DS   1          ; Storage for column number
MORT           DS   1          ; Storage for Morton number
SIZE           DS   1          ; Size of current square
GRPNUM         DS   1          ; Number for the group
GRPINC         DS   1          ; Increment for the group numbers
ANDMASK        DS   1          ; AND-mask for group numbers
ANDMASK2       DS   1          ; NOT ANDMASK
COUNT          DS   1          ; Counter of squares
MPOS           DS   1          ; Loop index for position in list of Morton #'s
                               ;
TITLE          ASC             "The Morton-Sequenced Region Storage System"
AUTHOR         ASC             "Christopher A. Mosher"
                               ;
                               ;_______________________________________________




                               ;_________________Main  program_________________
                               ;
MORTON         LDA  CODE       ; Check the indicator
               BEQ  M1         ; If clear, then decompress and decode,
                               ; else code and compress.
                               ;
               JSR  CODER      ; The Coder.
               JSR  COMPRS     ; The Compressor.
               RTS             ;
M1             JSR  DECOMPRS   ; The Decompressor.
               JSR  DECODER    ; The Decoder.
               RTS             ;
                               ;
                               ;
                               ; CODER (The Coder)
                               ;
                               ;  input:  ROWS   = list of row numbers
                               ;          COLS   = list of column numbers
                               ;          LENGTH = length of lists
                               ;
                               ; output:  MORTS  = list of Morton numbers
                               ;          LENGTH
                               ;
CODER          LDY  #$FF       ;
               LDA  LENGTH+1   ; If length is 256,
               BNE  CINTO      ; then branch into loop.
               LDY  LENGTH     ; Number of iterations for loop
CLOOP          DEY             ;
               CPY  #$FF       ;
               BEQ  CEXIT      ;
CINTO          LDA  ROWS,Y     ; -+
               STA  ROW        ;  !
               LDA  COLS,Y     ;  !_  Mortonize each
               STA  COL        ;  !   row/column pair
               JSR  MORTNIZE   ;  !
               LDA  MORT       ;  !
               STA  MORTS,Y    ; -+
               JMP  CLOOP      ;
CEXIT          RTS             ;
                               ;
                               ;
                               ; DECODER (The Decoder)
                               ;
                               ;  input:  MORTS  = list of Morton numbers
                               ;          LENGTH = length of list
                               ;
                               ; output:  ROWS   = list of row numbers
                               ;          COLS   = list of column numbers
                               ;          LENGTH
                               ;
DECODER        LDY  #$FF       ;
               LDA  LENGTH+1   ; If length is 256,
               BNE  DINTO      ; then branch into loop.
               LDY  LENGTH     ; Number of iterations for loop
DLOOP          DEY             ;
               CPY  #$FF       ;
               BEQ  DEXIT      ;
DINTO          LDA  MORTS,Y    ; -+
               STA  MORT       ;  !
               JSR  TABLRIZE   ;  !_  Tabularize each
               LDA  ROW        ;  !   Morton number
               STA  ROWS,Y     ;  !
               LDA  COL        ;  !
               STA  COLS,Y     ; -+
               JMP  DLOOP      ;
DEXIT          RTS             ;
                               ;
                               ;
                               ; MORTNIZE (Mortonize)
                               ;
                               ;  input:  ROW  = row number of square
                               ;                 (0-15)  ....abcd
                               ;          COL  = column number of square
                               ;                 (0-15)  ....efgh
                               ;
                               ; output:  MORT = Morton number of square
                               ;                 (0-255) aebfcgdh
                               ;
                               ;    ROW       COL      MORT    Carry
                               ; ....abcd  ....efgh  ........    .
MORTNIZE       LSR  COL        ; ....abcd  0....efg  ........    h
               ROR  MORT       ; ....abcd  0....efg  h.......    .
               LSR  ROW        ; 0....abc  0....efg  h.......    d
               ROR  MORT       ; 0....abc  0....efg  dh......    .
               LSR  COL        ; 0....abc  00....ef  dh......    g
               ROR  MORT       ; 0....abc  00....ef  gdh.....    .
               LSR  ROW        ; 00....ab  00....ef  gdh.....    c
               ROR  MORT       ; 00....ab  00....ef  cgdh....    .
               LSR  COL        ; 00....ab  000....e  cgdh....    f
               ROR  MORT       ; 00....ab  000....e  fcgdh...    .
               LSR  ROW        ; 000....a  000....e  fcgdh...    b
               ROR  MORT       ; 000....a  000....e  bfcgdh..    .
               LSR  COL        ; 000....a  0000....  bfcgdh..    e
               ROR  MORT       ; 000....a  0000....  ebfcgdh.    .
               LSR  ROW        ; 0000....  0000....  ebfcgdh.    a
               ROR  MORT       ; 0000....  0000....  aebfcgdh    .
               RTS             ;
                               ;
                               ;
                               ; TABLRIZE (Tabularize)
                               ;
                               ;  input:  MORT = Morton number of square
                               ;                 (0-255) abcdefgh
                               ;
                               ; output:  ROW  = row number of square
                               ;                 (0-15)  ....aceg
                               ;          COL  = column number of square
                               ;                 (0-15)  ....bdfh
                               ;
                               ;    ROW       COL      MORT    Carry
                               ; ........  ........  abcdefgh    .
TABLRIZE       LDA  #$00       ;
               STA  ROW        ; 00000000  ........  abcdefgh    .
               STA  COL        ; 00000000  00000000  abcdefgh    .
               ASL  MORT       ; 00000000  00000000  bcdefgh0    a
               ROL  ROW        ; 0000000a  00000000  bcdefgh0    0
               ASL  MORT       ; 0000000a  00000000  cdefgh00    b
               ROL  COL        ; 0000000a  0000000b  cdefgh00    0
               ASL  MORT       ; 0000000a  0000000b  defgh000    c
               ROL  ROW        ; 000000ac  0000000b  defgh000    0
               ASL  MORT       ; 000000ac  0000000b  efgh0000    d
               ROL  COL        ; 000000ac  000000bd  efgh0000    0
               ASL  MORT       ; 000000ac  000000bd  fgh00000    e
               ROL  ROW        ; 00000ace  000000bd  fgh00000    0
               ASL  MORT       ; 00000ace  000000bd  gh000000    f
               ROL  COL        ; 00000ace  00000bdf  gh000000    0
               ASL  MORT       ; 00000ace  00000bdf  h0000000    g
               ROL  ROW        ; 0000aceg  00000bdf  h0000000    0
               ASL  MORT       ; 0000aceg  00000bdf  00000000    h
               ROL  COL        ; 0000aceg  0000bdfh  00000000    0
               RTS             ;
                               ;
                               ;
                               ; COMPRS (The Compressor)
                               ;
                               ;  input:  MORTS  = list of Morton numbers
                               ;          LENGTH = length of list
                               ;
                               ; output:  MORTS  = compressed list of
                               ;                   Morton numbers
                               ;          SIZES  = list of sizes
                               ;
COMPRS         LDX  #$00       ; -+
               LDA  #$00       ;  !
CPLOOP1        STA  SIZES,X    ;  !
               INX             ;  !
               CPX  LENGTH     ;  !_  Initialize the
               BNE  CPLOOP1    ;  !   list of sizes
               LDA  LENGTH+1   ;  !
               BNE  SKPCPL2    ;  !
               LDA  #$FF       ;  !
CPLOOP2        STA  SIZES,X    ;  !
               INX             ;  !
               BNE  CPLOOP2    ; -+
SKPCPL2        LDA  #$03       ;
               STA  SIZE       ; Start with size 3 (8x8)
CPLOOP3        JSR  CALCGINC   ; Calculate GRPINC
               JSR  CALCAMSK   ; Calculate the AND-masks
               LDA  #$00       ;
               STA  GRPNUM     ; Start with group number at $00
CPLOOP4        LDA  #$00       ;
               STA  COUNT      ; Initialize the counter of squares in group
               LDX  #$00       ; Start with Morton number in position 0
CPLOOP5        LDA  SIZES,X    ; If the size of the Morton number
               CMP  #$FF       ; equals $FF,
               BEQ  NXTCPL5    ; then go to the next number
               LDA  MORTS,X    ; The Morton number
               EOR  GRPNUM     ; Exclusive-or with the group number in order to
               AND  ANDMASK    ; see if this number belongs to this group
               BNE  NXTCPL5    ; If it does not belong, then do not count it,
               INC  COUNT      ; else, count it.
NXTCPL5        INX             ; The Morton number in the next position
               BNE  CPLOOP5    ;
               LDA  COUNT      ;
               CMP  GRPINC     ; See if the number of Morton squares in this
                               ;   group is enough to completely fill the
                               ;   group (this number coincidentally equals
                               ;   the increment for the group numbers)
               BNE  NXTCPL4    ; If not, then check the next group
                               ; else compress the numbers
                               ;   for this group and size.
                               ; *** COMPRESS ***
               LDX  #$00       ;
CPLOOP51       LDA  SIZES,X    ;
               BNE  NXTCPL51   ;
               LDA  MORTS,X    ;
               EOR  GRPNUM     ;
               AND  ANDMASK    ;
               BNE  NXTCPL51   ;
               LDA  MORTS,X    ;
               AND  ANDMASK2   ;
               CMP  ANDMASK2   ; See if this is the Morton number to keep
               BNE  L1         ; If not, then remove it,
               LDA  SIZE       ; else, make SIZE its size.
               BNE  L2         ;
L1             LDA  #$FF       ; Remove the number from the list
L2             STA  SIZES,X    ;
NXTCPL51       INX             ;
               BNE  CPLOOP51   ;
NXTCPL4        LDA  GRPNUM     ;
               CLC             ;
               ADC  GRPINC     ; Increment the group number
               STA  GRPNUM     ;
               BNE  CPLOOP4    ;
               DEC  SIZE       ; The next smallest size
               BEQ  DONE       ;
               JMP  CPLOOP3    ;
DONE           RTS             ;
                               ;
                               ;
                               ; DECOMPRS (The Decompressor)
                               ;
                               ;  input:  MORTS  = compressed list of
                               ;                   Morton numbers
                               ;          SIZES  = list of sizes
                               ;
                               ; output:  MORTS  = list of Morton numbers
                               ;          LENGTH = length of list
                               ;
DECOMPRS       LDA  #$00       ;
               STA  LENGTH+1   ; Initialize high order byte of length.
               STA  MPOS       ; Start with Morton number in position 0
               LDY  #$00       ; Start with top of new list at 0
DLOOP1         LDX  MPOS       ; Position in list
               LDA  MORTS,X    ;
               STA  MORT       ; The Morton number
               LDA  SIZES,X    ;
               STA  SIZE       ; The size
               BEQ  COPY       ; If size is 0 then just copy the number.
               CMP  #$FF       ; If size is $FF,
               BEQ  DONE2      ; then done, else, size is 1, 2, or 3.
               JSR  CALCGINC   ; Calculate GRPINC
               JSR  CALCAMSK   ; Calculate AND-masks
               LDX  GRPINC     ; Number of squares for this size
               LDA  MORT       ; The Morton number
               AND  ANDMASK    ; The discriminant for this group
DLOOP2         STA  ROWS,Y     ; Put into the new list
               INY             ; The next position in the new list
               BNE  SKPDL2     ; If the new list is of length $100
               LDY  #$01       ;
               STY  LENGTH+1   ;
               LDY  #$00       ;
SKPDL2         DFB  $1A        ; INA for the next new number
               DEX             ; Decrement the loop counter
               BNE  DLOOP2     ;
               BEQ  NXTDL1     ; Go to the Morton number in the next position
COPY           LDA  MORT       ; The Morton number
               STA  ROWS,Y     ; Insert into the new list
               INY             ; The next position in the new list
               BNE  NXTDL1     ; If the new list is of length $100
               LDY  #$01       ;
               STY  LENGTH+1   ;
               LDY  #$00       ;
NXTDL1         INC  MPOS       ; The Morton number in the next position
               BNE  DLOOP1     ;
DONE2          STY  LENGTH     ; The length of the new list
               LDX  #$00       ; -+
DLOOP3         LDA  ROWS,X     ;  !_  Transfer the new list (ROWS)
               STA  MORTS,X    ;  !   to the Morton number list (MORTS)
               INX             ;  !
               BNE  DLOOP3     ; -+
               RTS             ;
CALCGINC       LDX  SIZE       ; -+
               LDA  #$01       ;  !
CGIL1          ASL             ;  !
               ASL             ;  !_  Calculate increment for
               DEX             ;  !   group numbers
               BNE  CGIL1      ;  !
               STA  GRPINC     ;  !
               RTS             ; -+
CALCAMSK       LDX  SIZE       ; -+
               LDA  #$FF       ;  !
CAML1          ASL             ;  !
               ASL             ;  !_  Calculate the AND-masks
               DEX             ;  !   for this size
               BNE  CAML1      ;  !
               STA  ANDMASK    ;  !
               EOR  #$FF       ;  !
               STA  ANDMASK2   ;  !
               RTS             ; -+
