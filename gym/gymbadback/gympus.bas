 5  HIMEM: 32767: ONERR  GOTO 19000
 10  HOME : INVERSE : FOR I = 1 TO 24: PRINT "  ";: HTAB 39: PRINT "  ";: NEXT : VTAB 1: PRINT  SPC( 40);: VTAB 23: PRINT  SPC( 40);: NORMAL : VTAB 20: HTAB 9: PRINT "PRESS ANY KEY TO CONTINUE";
 11 A$ = "GYMNASTICS COMPETITION":B$ = "SCORE TABULATOR"
 12  VTAB 4: HTAB 10: PRINT A$;: VTAB 6: HTAB 14: PRINT B$;: VTAB 9: HTAB 20: PRINT "BY";: VTAB 12: HTAB 14: PRINT "RICK" SPC( 5)"CHRIS";: VTAB 13: HTAB 19: PRINT "AND";: VTAB 14: HTAB 13: PRINT "LEWIS" SPC( 5)"MOSHER": VTAB 16: HTAB 17: PRINT "M.P.H.S.": GOSUB 10100
 15  FOR X = 1 TO 24: CALL 14392: NEXT 
 16  HOME : INVERSE : FOR I = 1 TO 24: PRINT "  ";: HTAB 39: PRINT "  ";: NEXT : VTAB 1: PRINT  SPC( 40);: VTAB 23: PRINT  SPC( 40);: NORMAL : VTAB 20: HTAB 9: PRINT "PRESS ANY KEY TO CONTINUE";
 17 A$ = "UNDER  THE":B$ = "DIRECTION OF":C$ = "JERRY RABINOWITZ":D$ = "MOUNT PLEASANT":E$ = "HIGH SCHOOL":F$ = "1984":G$ = "[ALL RIGHTS RESERVED]"
 18  VTAB 4: HTAB 16: PRINT A$: VTAB 6: HTAB 15: PRINT B$: VTAB 9: HTAB 13: PRINT C$: VTAB 12: HTAB 14: PRINT D$: VTAB 13: HTAB 16: PRINT E$: VTAB 15: HTAB 19: PRINT F$
 19  VTAB 17: HTAB 11: PRINT G$: GOSUB 10100
 20  FOR X = 1 TO 24: CALL 14392: NEXT 
 40  POKE 768,104: POKE 769,168: POKE 770,104: POKE 771,166: POKE 772,223: POKE 773,154: POKE 774,72: POKE 775,152: POKE 776,72: POKE 777,96
 50  CLEAR :X = 100: DIM N$(X),CN(X),T$(X),FX(X),V(X),H(X),PB(X),R(X),HB(X),C$(6),SL$(7),E$(6)
 55  DIM S(X),I(X),P(X),E2$(7),E3$(7),RK(X)
 60  FOR X = 1 TO 6: READ C$(X),E$(X): NEXT : DATA  "IV (6-9)","FX","IV (10+)"," H","III (10-12)"," R","III (13+)"," V","II","PB","I","HB" 
 65  FOR X = 1 TO 7: READ E2$(X): NEXT : DATA "All Around","Floor Exercise","Pommel Horse","Horizontal Bar","Parallel Bars","Still Rings","Vault"
 66  FOR X = 1 TO 7: READ E3$(X): NEXT : DATA "ALL AROUND","FLOOR EXERCISE","POMMEL HORSE","HORIZONTAL BAR","PARALLEL BARS","STILL RINGS","VAULT"
 70 BS$ =  CHR$ (8):CR$ =  CHR$ (13):D$ = CR$ +  CHR$ (4)
 90  GOSUB 21000
 99  REM MAIN MENU
 100 NS = 2:SL$(1) = "RETRIEVE EXISTING DATA":SL$(2) = "ENTER NEW DATA": GOSUB 10000: IF S = 2 THEN 2000
 999  REM RETRIEVE DATA
 1000  HOME : VTAB 8: PRINT "ENTER FILENAME: ";:LT = 20: GOSUB 10200: HOME : IF W$ = "" THEN 100
 1101  HOME : PRINT D$"UNLOCK"W$D$"LOCK"W$: GOTO 1110
 1102  VTAB 8: PRINT W$" NOT FOUND.": PRINT : PRINT : PRINT "PRESS ANY KEY TO CONTINUE.": GOSUB 10100: GOTO 1000
 1110  HOME : VTAB 8: HTAB 21 -  INT ( LEN (W$) / 2): PRINT W$: VTAB 10: HTAB 10: PRINT "LOADING DATA FROM DISK."D$"OPEN"W$D$"READ"W$
 1120  INPUT N: FOR X = 1 TO N: INPUT N$(X),CN(X),T$(X),FX(X),H(X),R(X),V(X),PB(X),HB(X): NEXT : PRINT D$"CLOSE"W$
 1999  REM MENU
 2000 NS = 6:SL$(1) = "ENTER NAMES":SL$(2) = "ENTER SCORES":SL$(3) = "PRINT SCORES":SL$(4) = "MODIFY DATA":SL$(5) = "CATALOG FILES":SL$(6) = "EXIT PROGRAM":TL$ = "GYMNASTICS": GOSUB 10000: ON S GOSUB 3000,4000,5000,7000,8000,6000: GOTO 2000
 2999  REM ENTER NAMES
 3000  IF  LEN (N$(1)) THEN  RETURN 
 3005 SA = 1: HOME : VTAB 2: HTAB 16: PRINT "ENTER NAMES": POKE 34,2:X = 1
 3010  HOME : VTAB 6: PRINT "COMPETITOR "X: VTAB 9: PRINT "(<RETURN> TO QUIT)": VTAB 8: PRINT "ENTER NAME (LAST FIRST): ";:LT = 20: GOSUB 10200: GOSUB 3030:N$(X) = W$: CALL  - 868
 3011  PRINT : PRINT "ENTER NUMBER: ";: CALL  - 868:LT = 3: GOSUB 10200:CN(X) =  VAL (W$): IF CN(X) < 100 OR CN(X) > 699 THEN 3011
 3012  PRINT : PRINT "ENTER TEAM: ";:LT = 8: GOSUB 10200:T$(X) = W$
 3013  IF  LEN (T$(X)) < 8 THEN  FOR LL = 1 TO 8 -  LEN (T$(X)):T$(X) = T$(X) + " ": NEXT 
 3020  HOME : VTAB 8: PRINT "NAME:" TAB( 10)N$(X): PRINT "NUMBER:" TAB( 10)CN(X): PRINT "TEAM:" TAB( 10)T$(X): PRINT "CLASS:" TAB( 10)C$( INT (CN(X) / 100))
 3021  VTAB 20: PRINT "IS THIS CORRECT? (Y,N)": GOSUB 10100:X = X + ((A <  > 78) AND (A <  > 110)): GOTO 3010
 3030  IF W$ = "" THEN N = X - 1: HOME : VTAB 10: PRINT "HAVE ALL NAMES BEEN ENTERED? (Y,N)": GOSUB 10100: POP : TEXT : IF A$ = "N" THEN 3010
 3040  RETURN 
 3999  REM ENTER SCORES
 4000 SA = 1: HOME : VTAB 2: HTAB 15: PRINT "ENTER SCORES": POKE 34,2
 4010  HOME : VTAB 9: PRINT "(<RETURN> TO QUIT)": VTAB 8: PRINT "ENTER COMPETITOR NUMBER: ";:LT = 3: GOSUB 10200: GOSUB 4200:CN =  VAL (W$):X = 0: FOR X1 = 1 TO N: IF CN(X1) = CN THEN X = X1
 4015  NEXT : IF X = 0 THEN  VTAB 8: PRINT : PRINT "COMPETITOR NUMBER "W$" NOT FOUND.": PRINT : PRINT : PRINT "PRESS ANY KEY TO CONTINUE.": GOSUB 10100: GOTO 4010
 4020  HOME : VTAB 8: HTAB 10: INVERSE : PRINT "FX";: NORMAL : PRINT " ";:PU = FX(X): GOSUB 12000: HTAB 26: PRINT "V ";:PU = V(X): GOSUB 12000: PRINT : PRINT : HTAB 11: PRINT "H ";:PU = H(X): GOSUB 12000: HTAB 25: PRINT "PB ";:PU = PB(X): GOSUB 12000: PRINT 
 4021  PRINT : HTAB 11: PRINT "R ";:PU = R(X): GOSUB 12000: HTAB 25: PRINT "HB ";:PU = HB(X): GOSUB 12000: PRINT : GOSUB 4300
 4022  VTAB 6: HTAB 5: PRINT "#";CN(X);"     ";N$(X)
 4023  VTAB 15: HTAB 17: PRINT "AA ";:PU = FX(X) + V(X) + H(X) + PB(X) + R(X) + HB(X): GOSUB 12000
 4025  VTAB 18: HTAB 16: PRINT "<-- - PREVIOUS": HTAB 16: PRINT "--> - NEXT": VTAB 21: HTAB 13: PRINT "ENTER SCORE WHEN": HTAB 13: PRINT "APPROPRIATE EVENT": HTAB 13: PRINT "IS HIGHLIGHTED": VTAB 8: HTAB 12:E = 1
 4030  GOSUB 10100: IF A <  > 8 AND A <  > 21 AND (A < 48 OR A > 57) THEN 4030
 4035  IF A > 47 AND A < 58 THEN LT = 4:F = A: PRINT " " VAL ( CHR$ (F));: GOTO 4100
 4040  IF A = 8 OR A = 21 THEN E = E + 2 * (A = 21) - 1
 4045  IF E < 1 OR E > 6 THEN E = 6 * (E > 6) + (E < 1): GOTO 4030
 4050  PRINT BS$BS$E$(E + 2 * (A = 8) - 1);: VTAB 2 * E + 6 - 6 * (E > 3): HTAB 10 * (E < 4) + 25 * (E > 3): INVERSE : PRINT E$(E);: NORMAL : GOTO 4030
 4100  GOSUB 10200:S =  VAL ( CHR$ (F) + W$): IF S < 0 OR S > 10 THEN  HTAB 13 * (E < 4) + 28 * (E > 3): PRINT "     "BS$BS$BS$BS$BS$ CHR$ (7);:F = 48:LT = 5: GOTO 4100
 4110  ON E GOSUB 4111,4112,4113,4114,4115,4116: GOTO 4010
 4111 FX(X) = S: RETURN 
 4112 H(X) = S: RETURN 
 4113 R(X) = S: RETURN 
 4114 V(X) = S: RETURN 
 4115 PB(X) = S: RETURN 
 4116 HB(X) = S: RETURN 
 4200  IF W$ = "" THEN  TEXT : POP 
 4210  RETURN 
 4300  IF FX(X) = 0 THEN  VTAB 8: HTAB 13: PRINT "-    ";
 4301  IF H(X) = 0 THEN  VTAB 10: HTAB 13: PRINT "-    ";
 4302  IF R(X) = 0 THEN  VTAB 12: HTAB 13: PRINT "-    ";
 4303  IF V(X) = 0 THEN  VTAB 8: HTAB 28: PRINT "-    ";
 4304  IF PB(X) = 0 THEN  VTAB 10: HTAB 28: PRINT "-    ";
 4305  IF HB(X) = 0 THEN  VTAB 12: HTAB 28: PRINT "-    ";
 4306  RETURN 
 4999  REM PRINT SCORES
 5000 NS = 2:SL$(1) = "CLASS/EVENT":SL$(2) = "ALL SCORES":TL$ = "PRINT SCORES": GOSUB 10000:P = S:SL$(1) = "SCREEN":SL$(2) = "PRINTER":TL$ = "": GOSUB 10000: PRINT D$"PR#"S - 1:SC = (S = 1): GOSUB 20000: ON P GOSUB 5100,5440: TEXT : PRINT D$"PR#0": RETURN 
 5100  PRINT D$"PR#0":NS = 6:SL$(1) = "CLASS IV 6-9":SL$(2) = "CLASS IV 10+":SL$(3) = "CLASS III 10-12":SL$(4) = "CLASS III 13+":SL$(5) = "CLASS II":SL$(6) = "CLASS I": GOSUB 10000:C = S
 5110 NS = 7:SL$(1) = "ALL AROUND":SL$(2) = "FLOOR EXERCISE":SL$(3) = "POMMEL HORSE":SL$(4) = "HORIZONTAL BAR":SL$(5) = "PARALLEL BARS":SL$(6) = "STILL RINGS":SL$(7) = "VAULT": GOSUB 10000:E = S
 5120 Y = 1: FOR X = 1 TO N: IF  INT (CN(X) / 100) = C THEN P(Y) = X:Y = Y + 1
 5130  NEXT :Y = Y - 1:AS = 0: ON E GOTO 5140,5150,5160,5170,5180,5190,5200
 5140  FOR X = 1 TO Y:S(X) = FX(P(X)) + H(P(X)) + HB(P(X)) + PB(P(X)) + R(P(X)) + V(P(X)): NEXT :N2 = Y: GOSUB 10300: GOTO 5210
 5150  FOR X = 1 TO Y:S(X) = FX(P(X)): NEXT :N2 = Y: GOSUB 10300: GOTO 5210
 5160  FOR X = 1 TO Y:S(X) = H(P(X)): NEXT :N2 = Y: GOSUB 10300: GOTO 5210
 5170  FOR X = 1 TO Y:S(X) = HB(P(X)): NEXT :N2 = Y: GOSUB 10300: GOTO 5210
 5180  FOR X = 1 TO Y:S(X) = PB(P(X)): NEXT :N2 = Y: GOSUB 10300: GOTO 5210
 5190  FOR X = 1 TO Y:S(X) = R(P(X)): NEXT :N2 = Y: GOSUB 10300: GOTO 5210
 5200  FOR X = 1 TO Y:S(X) = V(P(X)): NEXT :N2 = Y: GOSUB 10300
 5210  PRINT D$"PR#" NOT SC: IF  NOT SC THEN QQ$ = "Class " + C$(C) + "     " + E2$(E): PRINT  TAB( 41 -  INT ( LEN (QQ$) / 2))QQ$: PRINT : PRINT : PRINT  TAB( 16)"#" TAB( 27)"NAME" TAB( 40)"  TEAM        SCORE    RANK": PRINT 
 5220  IF SC THEN QQ$ = "CLASS " + C$(C) + "     " + E3$(E): HOME : VTAB 2: PRINT  TAB( 21 -  INT ( LEN (QQ$) / 2))QQ$: VTAB 4: PRINT  TAB( 2)"#" TAB( 12)"NAME" TAB( 28)"TEAM" TAB( 35)"SCORE": PRINT 
 5230  FOR X = 1 TO Y: IF SC AND (X / 16 =  INT (X / 16)) THEN  PRINT : PRINT "PRESS ANY KEY TO CONTINUE.": GOSUB 10100: HOME : VTAB 4
 5240  IF SC AND ((E = 1 AND FX(P(I(X))) AND H(P(I(X))) AND HB(P(I(X))) AND PB(P(I(X))) AND R(P(I(X))) AND V(P(I(X)))) OR E <  > 1) THEN  PRINT CN(P(I(X))) TAB( 5)N$(P(I(X))) TAB( 26)T$(P(I(X))) TAB( 35);: ON E GOTO 5370,5380,5390,5400,5410,5420,5430
 5245  IF SC AND E = 1 THEN 5340
 5250  IF  NOT SC AND ((E = 1 AND FX(P(I(X))) AND H(P(I(X))) AND HB(P(I(X))) AND PB(P(I(X))) AND R(P(I(X))) AND V(P(I(X)))) OR E <  > 1) THEN  PRINT  TAB( 15)CN(P(I(X))) TAB( 20)N$(P(I(X))) TAB( 40)T$(P(I(X))) SPC( 6);: ON E GOTO 5260,5280,5290,5300,5310,5320,5330
 5255  IF E = 1 THEN 5340
 5260 PU = FX(P(I(X))) + H(P(I(X))) + HB(P(I(X))) + PB(P(I(X))) + R(P(I(X))) + V(P(I(X))): GOSUB 12000: PRINT  SPC( 5)RK(X)
 5270  GOTO 5340
 5280 PU = FX(P(I(X))): GOSUB 12000: PRINT  SPC( 5)RK(X): GOTO 5340
 5290 PU = H(P(I(X))): GOSUB 12000: PRINT  SPC( 5)RK(X): GOTO 5340
 5300 PU = HB(P(I(X))): GOSUB 12000: PRINT  SPC( 5)RK(X): GOTO 5340
 5310 PU = PB(P(I(X))): GOSUB 12000: PRINT  SPC( 5)RK(X): GOTO 5340
 5320 PU = R(P(I(X))): GOSUB 12000: PRINT  SPC( 5)RK(X): GOTO 5340
 5330 PU = V(P(I(X))): GOSUB 12000: PRINT  SPC( 5)RK(X)
 5340  NEXT : IF SC AND ((X - 1) / 16 <  >  INT ((X - 1) / 16)) THEN  PRINT : PRINT "PRESS ANY KEY TO CONTINUE.": GOSUB 10100: RETURN 
 5350  IF  NOT SC THEN  PRINT  CHR$ (12)
 5360  RETURN 
 5370 PU = FX(P(I(X))) + H(P(I(X))) + HB(P(I(X))) + PB(P(I(X))) + R(P(I(X))) + V(P(I(X))): GOSUB 12000: PRINT : GOTO 5340
 5380 PU = FX(P(I(X))): GOSUB 12000: PRINT : GOTO 5340
 5390 PU = H(P(I(X))): GOSUB 12000: PRINT : GOTO 5340
 5400 PU = HB(P(I(X))): GOSUB 12000: PRINT : GOTO 5340
 5410 PU = PB(P(I(X))): GOSUB 12000: PRINT : GOTO 5340
 5420 PU = R(P(I(X))): GOSUB 12000: PRINT : GOTO 5340
 5430 PU = V(P(I(X))): GOSUB 12000: PRINT : GOTO 5340
 5440  FOR X = 1 TO N:S(X) = CN(X): NEXT :AS = 1:N2 = N: GOSUB 10300
 5450  IF SC THEN  HOME : VTAB 2: PRINT  TAB( 2)"#" TAB( 12)"NAME": PRINT  TAB( 7)"FX" TAB( 13)"H" TAB( 19)"R" TAB( 25)"V" TAB( 31)"PB" TAB( 37)"HB": PRINT  TAB( 7)"AA": PRINT : POKE 34,5
 5460  IF  NOT SC THEN QQ$ = "Competitor List": PRINT  TAB( 41 -  INT ( LEN (QQ$) / 2))QQ$: PRINT : PRINT : PRINT  TAB( 2)"#" TAB( 12)"NAME" TAB( 29)"TEAM" TAB( 39)"FX" SPC( 4)"H" SPC( 5)"R" SPC( 5)"V" SPC( 5)"PB" SPC( 4)"HB" SPC( 4)"AA": PRINT 
 5480  FOR X = 1 TO N: IF SC AND (X / 4 =  INT (X / 4)) THEN  PRINT : PRINT "PRESS ANY KEY TO CONTINUE": GOSUB 10100: HOME : VTAB 6
 5490  IF SC THEN  PRINT CN(I(X)) TAB( 5)N$(I(X)): PRINT  TAB( 5);:PU = FX(I(X)): GOSUB 12000: PRINT  TAB( 11);:PU = H(I(X)): GOSUB 12000: PRINT  TAB( 17);:PU = R(I(X)): GOSUB 12000
 5500  IF SC THEN  PRINT  TAB( 23);:PU = V(I(X)): GOSUB 12000: PRINT  TAB( 29);:PU = PB(I(X)): GOSUB 12000: PRINT  TAB( 35);:PU = HB(I(X)): GOSUB 12000: PRINT : PRINT  TAB( 5);:PU = FX(I(X)) + H(I(X)) + R(I(X)) + V(I(X)) + PB(I(X)) + HB(I(X)): GOSUB 12000: PRINT : PRINT 
 5510  IF  NOT SC THEN  PRINT CN(I(X)) TAB( 5)N$(I(X)) TAB( 27)T$(I(X)) TAB( 37);:PU = FX(I(X)): GOSUB 12000: PRINT " ";:PU = H(I(X)): GOSUB 12000: PRINT " ";:PU = R(I(X)): GOSUB 12000: PRINT " ";:PU = V(I(X)): GOSUB 12000: PRINT " ";:PU = PB(I(X)): GOSUB 12000: PRINT " ";:PU = HB(I(X)): GOSUB 12000
 5520  IF  NOT SC THEN  PRINT " ";:PU = FX(I(X)) + H(I(X)) + R(I(X)) + V(I(X)) + PB(I(X)) + HB(I(X)): GOSUB 12000: PRINT : PRINT 
 5530  NEXT : IF SC AND ((X - 1) / 4 <  >  INT ((X - 1) / 4)) THEN  PRINT : PRINT "PRESS ANY KEY TO CONTINUE.";: GOSUB 10100
 5540  IF  NOT SC THEN  PRINT  CHR$ (12)
 5550  RETURN 
 5560  REM  END
 6000  HOME : VTAB 10: PRINT "DO YOU REALLY WISH TO END? (Y,N)": GOSUB 10100: IF A$ <  > "Y" THEN  RETURN 
 6005  HOME : IF  NOT (SA) THEN 6100
 6010  VTAB 8: PRINT "ENTER FILENAME: ";:LT = 20: GOSUB 10200: IF W$ = "" THEN  VTAB 10: HTAB 1: PRINT "A FILENAME MUST BE SPECIFIED": GOTO 6010
 6011  PRINT D$"UNLOCK"W$: VTAB 10: PRINT W$" ALREADY EXISTS; ENTER NEW FILENAME": GOTO 6010
 6020  HOME : VTAB 8: HTAB 21 -  INT ( LEN (W$) / 2): PRINT W$: VTAB 10: HTAB 11: PRINT "SAVING DATA TO DISK."D$"OPEN"W$D$"WRITE"W$
 6030  PRINT N: FOR X = 1 TO N: PRINT N$(X)CR$CN(X)CR$T$(X)CR$FX(X)CR$H(X)CR$R(X)CR$V(X)CR$PB(X)CR$HB(X): NEXT : PRINT D$"CLOSE"W$
 6100  HOME : VTAB 8: HTAB 14: PRINT "END OF PROGRAM": POKE 49280,0
 6999  REM MODIFY DATA
 7000 NS = 3:SL$(1) = "ADD":SL$(2) = "CHANGE":SL$(3) = "DELETE":TL$ = "MODIFY DATA": GOSUB 10000: ON S GOSUB 7200,7001,7400: GOTO 2000
 7001 SA = 1: HOME : VTAB 2: HTAB 16: PRINT "CHANGE DATA": POKE 34,2
 7010  HOME : VTAB 9: PRINT "(<RETURN> TO QUIT)": VTAB 8: PRINT "ENTER COMPETITOR NUMBER: ";:LT = 3: GOSUB 10200: GOSUB 4200:CN =  VAL (W$):X = 0: FOR X1 = 1 TO N: IF CN(X1) = CN THEN X = X1
 7015  NEXT : IF X = 0 THEN  VTAB 8: PRINT : PRINT "COMPETITOR NUMBER "W$" NOT FOUND.": PRINT : PRINT : PRINT "PRESS ANY KEY TO CONTINUE.": GOSUB 10100: GOTO 7010
 7021  HOME 
 7022  VTAB 6: HTAB 5: PRINT "#   : ";CN(X)
 7023  VTAB 7: HTAB 5: PRINT "NAME: ";N$(X)
 7024  VTAB 8: HTAB 5: PRINT "TEAM: ";T$(X)
 7030  VTAB 10: PRINT "CORRECT NAME: ";:LT = 20: GOSUB 10200:N$(X) = W$: CALL  - 868: PRINT 
 7032  VTAB 11: PRINT "CORRECT #   : ";: CALL  - 868:LT = 3: GOSUB 10200:CN(X) =  VAL (W$): PRINT : IF CN(X) < 100 OR CN(X) > 699 THEN 7032
 7033  VTAB 12: PRINT "CORRECT TEAM: ";:LT = 8: GOSUB 10200:T$(X) = W$: PRINT : IF  LEN (T$(X)) < 8 THEN  FOR LL = 1 TO 8 -  LEN (T$(X)):T$(X) = T$(X) + " ": NEXT 
 7034  HOME : VTAB 8: PRINT "NAME:" TAB( 10)N$(X): PRINT "NUMBER:" TAB( 10)CN(X): PRINT "TEAM:" TAB( 10)T$(X): PRINT "CLASS:" TAB( 10)C$( INT (CN(X) / 100))
 7035  VTAB 20: PRINT "IS THIS CORRECT? (Y/N)": GOSUB 10100: IF A$ = "N" THEN 7021
 7040  TEXT : RETURN 
 7200 SA = 1: HOME : VTAB 2: HTAB 17: PRINT "ADD NAMES": POKE 34,2:X = N + 1
 7210  HOME : VTAB 6: PRINT "COMPETITOR "X: VTAB 9: PRINT "(<RETURN> TO QUIT)": VTAB 8: PRINT "ENTER NAME (LAST FIRST): ";:LT = 20: GOSUB 10200: GOSUB 7230:N$(X) = W$: CALL  - 868
 7211  PRINT : PRINT "ENTER NUMBER: ";: CALL  - 868:LT = 3: GOSUB 10200:CN(X) =  VAL (W$): IF CN(X) < 100 OR CN(X) > 699 THEN 7211
 7212  PRINT : PRINT "ENTER TEAM: ";:LT = 8: GOSUB 10200:T$(X) = W$
 7213  IF  LEN (T$(X)) < 8 THEN  FOR LL = 1 TO 8 -  LEN (T$(X)):T$(X) = T$(X) + " ": NEXT 
 7220  HOME : VTAB 8: PRINT "NAME:" TAB( 10)N$(X): PRINT "NUMBER:" TAB( 10)CN(X): PRINT "TEAM:" TAB( 10)T$(X): PRINT "CLASS:" TAB( 10)C$( INT (CN(X) / 100))
 7221  VTAB 20: PRINT "IS THIS CORRECT? (Y,N)": GOSUB 10100:X = X + ((A <  > 78) AND (A <  > 110)): GOTO 7210
 7230  IF W$ = "" THEN N = X - 1: HOME : VTAB 10: PRINT "HAVE ALL NAMES BEEN ENTERED? (Y,N)": GOSUB 10100: POP : TEXT : IF A$ = "N" THEN 7210
 7240  RETURN 
 7400 SA = 1: HOME : VTAB 2: HTAB 15: PRINT "DELETE DATA": POKE 34,2
 7410  HOME : VTAB 9: PRINT "(<RETURN> TO QUIT)": VTAB 8: PRINT "ENTER COMPETITOR NUMBER: ";:LT = 3: GOSUB 10200: GOSUB 4200:CN =  VAL (W$):X = 0: FOR X1 = 1 TO N: IF CN(X1) = CN THEN X = X1
 7415  NEXT : IF X = 0 THEN  VTAB 8: PRINT : PRINT "COMPETITOR NUMBER "W$" NOT FOUND.": PRINT : PRINT : PRINT "PRESS ANY KEY TO CONTINUE.": GOSUB 10100: GOTO 7410
 7421  HOME 
 7422  VTAB 6: HTAB 5: PRINT "#   : ";CN(X)
 7423  VTAB 7: HTAB 5: PRINT "NAME: ";N$(X)
 7424  VTAB 8: HTAB 5: PRINT "TEAM: ";T$(X)
 7430  VTAB 12: HTAB 5: PRINT "DO YOU WANT TO": VTAB 13: HTAB 5: PRINT "DELETE THIS COMPETITOR? (Y,N)": GOSUB 10100: IF A$ = "N" THEN 7490
 7440  FOR Q = X + 1 TO N:CN(Q - 1) = CN(Q):N$(Q - 1) = N$(Q):T$(Q - 1) = T$(Q):FX(Q - 1) = FX(Q):H(Q - 1) = H(Q):R(Q - 1) = R(Q):V(Q - 1) = V(Q):PB(Q - 1) = PB(Q):HB(Q - 1) = HB(Q): NEXT :N = N - 1
 7490  TEXT : RETURN 
 7999  REM CATALOG FILES
 8000  TEXT : HOME : VTAB 1: HTAB 15: PRINT "CATALOG FILES": POKE 34,2: VTAB 24: HTAB 8: PRINT "PRESS ANY KEY TO CONTINUE.": VTAB 3: POKE 35,23: PRINT D$"CATALOG": GOSUB 10100: TEXT : RETURN 
 9999  REM MENU
 10000  HOME : IF  LEN (TL$) THEN  VTAB 2: HTAB 21 -  INT ( LEN (TL$) / 2): PRINT TL$: VTAB 4: HTAB 19: PRINT "MENU"
 10001  VTAB  INT (12 - NS / 2) + 1: FOR X = 1 TO NS: HTAB 12: PRINT SL$(X): NEXT : VTAB 21: HTAB 16: PRINT "<-- - UP": HTAB 16: PRINT "--> - DOWN": HTAB 11: PRINT "<RETURN> - SELECT":VT = 0
 10002  IF VT <  INT (12 - NS / 2) + 1 THEN VT =  INT (12 - NS / 2) + 1
 10003  IF VT >  INT (12 + NS / 2) THEN VT =  INT (12 + NS / 2)
 10004  VTAB VT: HTAB 7: PRINT "--->";: GOSUB 10100
 10005  IF A = 8 THEN  HTAB 7: PRINT "    ";:VT = VT - 1: GOTO 10002
 10006  IF A = 21 THEN  HTAB 7: PRINT "    ";:VT = VT + 1: GOTO 10003
 10007  IF A = 13 THEN S = VT +  INT ((NS + 1) / 2) - 12: RETURN 
 10008  GOTO 10004
 10099  REM KEY CLICK
 10100 A =  - 16336: POKE  - 16368,0
 10101  IF  PEEK ( - 16384) < 128 THEN 10101
 10102 A =  PEEK (A) -  PEEK (A) -  PEEK (A) -  PEEK (A): GET A$:A =  ASC (A$): RETURN 
 10199  REM STRING INPUT
 10200 W$ = "":V =  PEEK (37) + 1:H =  PEEK (36) + 1
 10201  PRINT  CHR$ (95);: GOSUB 10100
 10202  IF A = 24 THEN  VTAB V: HTAB H: PRINT  SPC(  LEN (W$) + 1);: VTAB V: HTAB H: GOTO 10200
 10203  IF A = 13 THEN  PRINT  CHR$ (8)" ";: RETURN 
 10204  IF A = 8 THEN  GOSUB 10208: GOTO 10201
 10205  IF ( LEN (W$) = LT) OR A = 44 OR A < 32 OR A > 126 THEN  PRINT  CHR$ (7) CHR$ (8);: GOTO 10201
 10206  PRINT  CHR$ (8)A$;:W$ = W$ + A$: GOTO 10201
 10208  IF  NOT  LEN (W$) THEN  PRINT  CHR$ (8);: RETURN 
 10209  PRINT  CHR$ (8) CHR$ (8)"  " CHR$ (8) CHR$ (8);: IF  LEN (W$) = 1 THEN W$ = "": RETURN 
 10210 W$ =  LEFT$ (W$, LEN (W$) - 1): RETURN 
 10299  REM SORT
 10300  FOR X = 1 TO N2:I(X) = X: NEXT :M = 1: IF N2 = 1 THEN  RETURN 
 10301 M = 3 * M + 1: IF M < N2 THEN 10301
 10302 M = (M - 1) / 3: IF M < 1 THEN  GOSUB 11000: RETURN 
 10303  FOR X = M + 1 TO N2:LL = X - M:TS = S(X):TI = I(X)
 10304  IF AS = (S(LL) > TS) THEN S(LL + M) = S(LL):I(LL + M) = I(LL):LL = LL - M: IF LL > 0 THEN 10304
 10305 S(LL + M) = TS:I(LL + M) = TI: NEXT : GOTO 10302
 11000 RC = 1: FOR X = 1 TO N2: IF (S(X - 1) - S(X)) > .01 AND FX(P(I(X))) AND H(P(I(X))) AND HB(P(I(X))) AND PB(P(I(X))) AND R(P(I(X))) AND V(P(I(X))) AND E = 1 THEN RC = RC + 1
 11005  IF (S(X) < S(X - 1)) AND E <  > 1 THEN RC = RC + 1
 11010 RK(X) = RC: NEXT : RETURN 
 11999  REM PRINT USING
 12000 PU% =  VAL ( STR$ (PU * 100))
 12005  IF PU% < 1000 THEN  PRINT " ";
 12010  PRINT  INT (PU% / 100)"." INT (PU% / 10) -  INT (PU% / 100) * 10;PU% -  INT (PU% / 10) * 10;: RETURN 
 18999  REM ERROR HANDLER
 19000  CALL 768:ER =  PEEK (222):EL =  PEEK (218) +  PEEK (219) * 256
 19020  IF EL = 1101 THEN 1102
 19030  IF EL = 6011 THEN 6020
 19040  IF ER = 255 THEN 19500
 19050  IF ER = 9 THEN  HOME : VTAB 8: PRINT "DISK FULL; INSERT A DIFFERENT DISK.": PRINT : PRINT : PRINT "PRESS ANY KEY WHEN READY.": GOSUB 10100: RESUME 
 19060  IF ER = 8 THEN  HOME : VTAB 8: PRINT "I/O ERROR; INSERT A DIFFERENT DISK.": PRINT : PRINT : PRINT "PRESS ANY KEY WHEN READY.": GOSUB 10100: RESUME 
 19070  IF ER = 4 THEN  HOME : VTAB 8: PRINT "DISK WRITE PROTECTED; INSERT A DIFFERENT DISK.": PRINT : PRINT : PRINT "PRESS ANY KEY WHEN READY.": GOSUB 10100: RESUME 
 19080  TEXT : HOME : PRINT D$"CLOSE": VTAB 8: PRINT "ERROR "ER" AT LINE "EL".": END 
 19500  HOME : PRINT D$"CLOSE": VTAB 8: PRINT "EXIT PROGRAM? (Y,N)": GOSUB 10100: IF A = 78 OR A = 110 THEN  RESUME 
 19510  HOME : VTAB 8: PRINT "SAVE DATA? (Y,N)": GOSUB 10100: IF A = 78 OR A = 110 THEN 6100
 19520  GOTO 6000
 19999  REM PAGE TITLE
 20000  HOME :ZA$ = "SABI COMPETITION":ZB$ = "OLYMPIAD GYMNASTICS CLUB":ZC$ = "Wilmington, Delaware":ZE$ = "Dave Hirst Gymnastics Center"
 20010  PRINT  TAB( 41 -  INT ( LEN (ZA$) / 2))ZA$
 20020  PRINT  TAB( 41 -  INT ( LEN (ZB$) / 2))ZB$
 20025  PRINT  TAB( 41 -  INT ( LEN (ZE$) / 2))ZE$
 20030  PRINT  TAB( 41 -  INT ( LEN (ZC$) / 2))ZC$
 20040  IF  LEN (ZD$) THEN  PRINT  TAB( 41 -  INT ( LEN (ZD$) / 2))ZD$
 20050  PRINT : PRINT 
 20060  HOME : RETURN 
 21000  HOME : VTAB 2: HTAB 7: PRINT "ENTER PAGE TITLE INFORMATION": POKE 34,2: VTAB 8: PRINT "ENTER DATE: ";:LT = 30: GOSUB 10200:ZD$ = W$
 21020  TEXT : RETURN 
 63999  END 
 65535  REM  By Chris Mosher and Rick Lewis
