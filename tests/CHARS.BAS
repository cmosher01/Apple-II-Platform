NEW



   2 HOME : VTAB 10

   5 A% = 1024
   6 C% = 0
  10 FOR I = 0 TO 7
  20   GOSUB 1000
  30   A% = A% + 128
  40   C% = C% + 32
  50 NEXT I
  60 END



1000 REM
1001   CC% = C% : AA% = A%
1005   FOR J = 0 TO 31
1010     POKE AA%,CC%
1020     AA% = AA%+1
1030     CC% = CC%+1
1040   NEXT J
1050 RETURN



RUN
