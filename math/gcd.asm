* Greatest Common Divisor, Binary Algorithm
*
* Copyright December 1987 by Christopher A. Mosher



*       This program embodies Josef Stein's binary greatest
* common divisor algorithm (1961).1
*       Given integers u and v such that 0 <= u,v < 65536, this
* algorithm finds their greatest common divisor, and leaves
* its value in u.
*       The main difference between this program and Stein's
* algorithm is that his algorithm uses interger division and
* negation, but this program uses two's compliment division and
* negation, so that a seperate byte to keep track of t's sign
* has to be introduced, and this byte will not be affected by
* the shift operation performed on the absolute part of t.
* ____________________
*
*       1Donald Ervin Knuth, The Art of Computer Programming,
* 2nd ed., vol. 2: Seminumerical Algorithms (Reading,
* Massuchusettes: Addison-Wesley Publishing Company, 1981),
* p. 321.



                               ; Definition of Variables
k              }    $F8        ; k
tneg           }    $F9        ; sign of t (high bit)
tlo            }    $FA        ; absolute value of t (low byte)
thi            }    $FB        ; absolute value of t (high byte)
vlo            }    $FC        ; v (low byte)
vhi            }    $FD        ; v (high byte)
ulo            }    $FE        ; u (low byte)
uhi            }    $FF        ; u (high byte)
negmask        }    $80        ; mask for tneg



               org  $300       ; starting address of machine code



                               ; B1. [Find power of 2.]
b1             lda  #$00       ; set k <- 0
               sta  k          ;
b1lp           lda  ulo        ; if u is odd, then go to b2u
               lsr             ;
               bcs  b2u        ;
               lda  vlo        ; if v is odd, then go to b2v
               lsr             ;
               bcs  b2v        ;
               lsr  uhi        ; set u <- u/2
               ror  ulo        ;
               lsr  vhi        ; set v <- v/2
               ror  vlo        ;
               inc  k          ; set k <- k+1
               bne  b1lp       ; repeat



                               ; B2. [Initialize.]
b2u            lda  vlo        ; (if u is odd, then) set t <- v
               sta  tlo        ;
               lda  vhi        ;
               sta  thi        ;
               lda  #negmask   ; set t negative
               sta  tneg       ;
               jmp  b4         ; go to b4
b2v            lda  ulo        ; (if u is even, then) set t <- u
               sta  tlo        ;
               lda  uhi        ;
               sta  thi        ;
               lda  #$00       ; set t positive
               sta  tneg       ;



                               ; B3. [Halve t.]
b3             lsr  thi        ; set t <- t/2
               ror  tlo        ;


                               ; B4. [Is t even?]
b4             lda  tlo        ; if t is even, then go to b3
               lsr             ;
               bcc  b3         ;



                               ; B5. [Reset max(u, v).]
b5             lda  tneg       ; if t < 0, then go to b5mi
               bmi  b5mi       ;
               lda  tlo        ; (if t >= 0, then) set u <- t
               sta  ulo        ;
               lda  thi        ;
               sta  uhi        ;
               jmp  b6         ; go to B6
b5mi           lda  tlo        ; (if t < 0, then) set v <- t (positive)
               sta  vlo        ;
               lda  thi        ;
               sta  vhi        ;



                               ; B6. [Subtract.]
b6             sec             ; set t <- u-v
               lda  ulo        ;
               sbc  vlo        ;
               sta  tlo        ;
               lda  uhi        ;
               sbc  vhi        ;
               sta  thi        ;
               lda  #$00       ;
               bcs  okt        ; if t is positive, then go to okt
               lda  tlo        ; negate t
               eor  #$FF       ; (negate each bit and add one)
               adc  #$01       ;
               sta  tlo        ;
               lda  thi        ;
               eor  #$FF       ;
               adc  #$00       ;
               sta  thi        ;
               lda  #negmask   ; set t negative
okt            sta  tneg       ;
               lda  tlo        ; if t <> 0, then go to b3
               bne  b3         ;
               lda  thi        ;
               bne  b3         ;
               lda  k          ; if k = 0, then terminate
               beq  exit       ;
b6l            asl  ulo        ; set u <- 2u
               rol  uhi        ;
               dec  k          ; set k <- k-1
               bne  b6l        ; if k <> 0, then repeat
exit           rts             ; terminate
