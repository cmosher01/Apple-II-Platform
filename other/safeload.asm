                               ;
                               ; Safeguard Loader
                               ;
                               ; Load a machine language program
                               ; between the BASIC interpreter system
                               ; and its buffers.
                               ;
                               ; Christopher A. Mosher
                               ; June, 1988 (update)
                               ; May, 1987
                               ;



code           equ  $9700      ; start of (relocated) code
length         equ  $03        ; length of code (pages)
image          equ  $2100      ; start of code image
                               ;   code must have been previously
                               ;   assembled at the destination address
                               ;   and then loaded at the image address

                               ; BI global page locations
bi_warm        equ  $BE00      ; warmstart
prerr          equ  $BE0C      ; print error message
getbufr        equ  $BEF5      ; get buffer



                               ; Safeguard Loader

               org  $2000
               lda  #length
               jsr  getbufr
               bcs  nobufs
               cmp  #>code
               beq  relocate
nobufs         lda  #$0C       ; "no buffers available" message
               jsr  prerr      ; print error message
               jmp  bi_warm    ; exit to basic
relocate       ldy  #length
               ldx  #0
rlda           lda  image,x
rsta           sta  code,x
               inx
               bne  rlda
               inc  rlda+2
               inc  rsta+2
               dey
               bne  rlda
               rts
