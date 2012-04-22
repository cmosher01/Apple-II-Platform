 1  GOSUB 60000: GOSUB 10000: GOSUB 11000: GOTO 23000
 2  GOSUB 10000: REM To restart, type goto 2 from immediate mode.
 1000  ON MD% + 1 GOSUB 11000,12000
 1010  POKE  - 16368,0: WAIT  - 16384,128: GET A$: IF A$ = "" THEN 1010
 1020  POKE  - 16368,0:A% =  ASC (A$):A% = A% - 32 * (A% > 96 AND A% < 123)
 1999  IF MD% THEN 4000
 2000  IF 48 < A% AND A% < K%(E%) + 49 THEN E% = C%(E%,A% - 48):G% = G% - 1: GOTO 1000
 2010  IF A% = 65 AND S1%(E%) > 0 THEN E% = S1%(E%): GOTO 1000
 2020  IF A% = 66 AND S2%(E%) > 0 THEN E% = S2%(E%): GOTO 1000
 2030  IF A% = 67 AND S3%(E%) > 0 THEN E% = S3%(E%): GOTO 1000
 2040  IF A% = 69 THEN MD% = 1: GOTO 1000
 2050  IF A% = 70 AND F%(E%) > 0 THEN E% = F%(E%):G% = G% + 1: GOTO 1000
 2060  IF A% = 77 AND M%(E%) > 0 THEN E% = M%(E%):G% = G% + 1: GOTO 1000
 3000  IF A% = 71 THEN 20000
 3005  IF A% = 92 THEN 50000
 3010  IF A% = 68 THEN 21000
 3020  IF A% = 73 THEN 22000
 3030  IF A% = 76 THEN 23000
 3040  IF A% = 83 THEN 24000
 3050  IF A% = 81 THEN 25000
 3055  IF A% = 32 THEN 26000
 3060  IF (A% = 11 OR A% = 21) AND E% < MX% THEN E% = E% + 1:G% = 0: GOTO 1000
 3070  IF (A% = 8 OR A% = 10) AND E% > 0 THEN E% = E% - 1:G% = 0: GOTO 1000
 3999  GOTO 1010
 4000  IF 48 < A% AND A% < 65 THEN 30000
 4010  IF A% = 65 THEN 31000
 4020  IF A% = 66 THEN 32000
 4030  IF A% = 67 THEN 33000
 4040  IF A% = 70 THEN 34000
 4050  IF A% = 77 THEN 35000
 4060  IF A% = 78 THEN 36000
 4070  IF A% = 84 THEN 37000
 4080  IF A% = 90 THEN 38000
 4090  IF A% = 27 THEN MD% = 0: GOTO 1000
 4999  GOTO 3000
 10000  TEXT : HOME : INVERSE : PRINT  TAB( 41 -  LEN (TL$) / 2)TL$ TAB( 81): NORMAL : PRINT : POKE 34,2: RETURN 
 11000  HOME : VTAB 4: HTAB 41 -  LEN (N$(E%)) / 2: PRINT N$(E%): VTAB 7
 11005  IF K%(E%) > 0 THEN  FOR I = 1 TO K%(E%): PRINT "[" CHR$ (48 + I)"] " LEFT$ (N$(C%(E%,I)),34): NEXT : VTAB 7
 11010  IF F%(E%) > 0 THEN  HTAB 40: PRINT "[F] " LEFT$ (N$(F%(E%)),36)
 11020  IF M%(E%) > 0 THEN  HTAB 40: PRINT "[M] " LEFT$ (N$(M%(E%)),36)
 11030  VTAB 11: IF S1%(E%) > 0 THEN  HTAB 40: PRINT "[A] " LEFT$ (N$(S1%(E%)),36)
 11040  IF S2%(E%) > 0 THEN  HTAB 40: PRINT "[B] " LEFT$ (N$(S2%(E%)),36)
 11050  IF S3%(E%) > 0 THEN  HTAB 40: PRINT "[C] " LEFT$ (N$(S3%(E%)),36)
 11065  RETURN 
 12000  HOME : VTAB 4: HTAB 41 -  LEN (N$(E%)) / 2: PRINT N$(E%): VTAB 7
 12005  FOR I = 1 TO K%(E%) + (K%(E%) < 16): PRINT "[" CHR$ (I + 48)"] {"C%(E%,I)"}" TAB( 11) LEFT$ (N$(C%(E%,I)),28): NEXT : VTAB 7
 12010  HTAB 40: PRINT "[F] {"F%(E%)"}" TAB( 50) LEFT$ (N$(F%(E%)),30)
 12020  HTAB 40: PRINT "[M] {"M%(E%)"}" TAB( 50) LEFT$ (N$(M%(E%)),30)
 12030  VTAB 11: HTAB 40: PRINT "[A] {"S1%(E%)"}" TAB( 50) LEFT$ (N$(S1%(E%)),30)
 12040  HTAB 40: PRINT "[B] {"S2%(E%)"}" TAB( 50) LEFT$ (N$(S2%(E%)),30)
 12050  HTAB 40: PRINT "[C] {"S3%(E%)"}" TAB( 50) LEFT$ (N$(S3%(E%)),30): RETURN 
 20000  & ,O,39,41,14,9: INPUT "Go to entry: ";AA$:A$ =  STR$ ( INT ( ABS ( VAL (AA$)))):A% =  VAL (A$):E% = E% * ( NOT (A% OR AA$ = "0") OR A% > MX%) + A% * (A% <  = MX%):G% = 0: & ,C: GOTO 1000
 21000  & ,O,39,41,14,9: PRINT "Delete this entry? (Y,N) <Y>": POKE  - 16368,0: WAIT  - 16384,128: GET A$: IF A$ = "" THEN A$ = "Y"
 21010  POKE  - 16368,0:A% =  ASC (A$): IF A% = 78 OR A% = 110 THEN  & ,C: GOTO 1010
 21020  IF E% = 0 OR E% > EZ% THEN  HOME : PRINT "Cannot delete this entry.": VTAB 21: PRINT "Press any key to continue.";: POKE  - 16368,0: WAIT  - 16384,128: POKE  - 16368,0: & ,C: GOTO 1010
 21030  HOME : PRINT "Deleting entry number "E%".": PRINT : PRINT "(wait";:A% = 2 * EZ% - E% + 1:G% = 0
 21040  FOR I = E% TO EZ%:N$(I) = N$(I + 1):F%(I) = F%(I + 1):M%(I) = M%(I + 1)
 21050 S%(I) = S%(I + 1):S1%(I) = S1%(I + 1):S2%(I) = S2%(I + 1):S3%(I) = S3%(I + 1)
 21060 K%(I) = K%(I + 1): FOR J = 1 TO K%(I):C%(I,J) = C%(I + 1,J): NEXT 
 21070  HTAB 7: PRINT A%")  ";:A% = A% - 1: NEXT 
 21080  FOR I = 1 TO EZ%: IF F%(I) > E% THEN F%(I) = F%(I) - 1: GOTO 21100
 21090  IF F%(I) = E% THEN F%(I) = 0
 21100  IF M%(I) > E% THEN M%(I) = M%(I) - 1: GOTO 21120
 21110  IF M%(I) = E% THEN M%(I) = 0
 21120  IF S%(I) > E% THEN S%(I) = S%(I) - 1:S1%(I) = S%(I): GOTO 21210
 21130  IF S%(I) = E% THEN S%(I) = 0:S1%(I) = 0: GOTO 21210
 21140  IF S1%(I) > E% THEN S1%(I) = S1%(I) - 1: GOTO 21160
 21150  IF S1%(I) = E% THEN S1%(I) = 0
 21160  IF S2%(I) > E% THEN S2%(I) = S2%(I) - 1: GOTO 21180
 21170  IF S2%(I) = E% THEN S2%(I) = 0
 21180  IF S3%(I) > E% THEN S3%(I) = S3%(I) - 1: GOTO 21210
 21190  IF S3%(I) = E% THEN S3%(I) = 0
 21210  IF K%(I) = 0 THEN 21250
 21220  FOR J = 1 TO K%(I): IF C%(I,J) > E% THEN C%(I,J) = C%(I,J) - 1: GOTO 21240
 21230  IF C%(I,J) = E% THEN C%(I,J) = 0: IF J = K%(I) THEN K%(I) = K%(I) - 1
 21240  NEXT 
 21250 C%(I,K%(I) + 1) = 0: HTAB 7: PRINT A%")  ";:A% = A% - 1: NEXT :EZ% = EZ% - 1: & ,C: GOTO 1000
 22000  & ,O,39,41,14,9: PRINT "Insert before this entry? (Y,N) <Y>": POKE  - 16368,0: WAIT  - 16384,128: GET A$: IF A$ = "" THEN A$ = "Y"
 22010  POKE  - 16368,0:A% =  ASC (A$): IF A% = 78 OR A% = 110 THEN  & ,C: GOTO 1010
 22015  IF E% > EZ% + 1 OR EZ% = MX% THEN  HOME : PRINT "Cannot insert.": VTAB 21: PRINT "Press any key to continue.";: POKE  - 16368,0: WAIT  - 16384,128: POKE  - 16368,0: & ,C: GOTO 1010
 22020  IF E% = 0 THEN E% = 1
 22030 EZ% = EZ% + 1:G% = 0: HOME : PRINT "Inserting entry number "E%".": PRINT : PRINT "(wait";: FOR I = EZ% TO E% + 1 STEP  - 1
 22040 F%(I) = F%(I - 1): IF F%(I) > E% - 1 THEN F%(I) = F%(I) + 1
 22050 M%(I) = M%(I - 1): IF M%(I) > E% - 1 THEN M%(I) = M%(I) + 1
 22060 S%(I) = S%(I - 1): IF S%(I) > E% - 1 THEN S%(I) = S%(I) + 1
 22070 S1%(I) = S1%(I - 1): IF S1%(I) > E% - 1 THEN S1%(I) = S1%(I) + 1
 22080 S2%(I) = S2%(I - 1): IF S2%(I) > E% - 1 THEN S2%(I) = S2%(I) + 1
 22090 S3%(I) = S3%(I - 1): IF S3%(I) > E% - 1 THEN S3%(I) = S3%(I) + 1
 22100 N$(I) = N$(I - 1)
 22110 K%(I) = K%(I - 1): IF K%(I) = 0 THEN 22150
 22120  FOR J = 1 TO K%(I)
 22130 C%(I,J) = C%(I - 1,J): IF C%(I,J) > E% - 1 THEN C%(I,J) = C%(I,J) + 1
 22140  NEXT 
 22150  IF K%(I + 1) > K%(I) THEN  FOR J = K%(I) + 1 TO K%(I + 1):C%(I,J) = 0: NEXT 
 22160  HTAB 7: PRINT I")  ";
 22170  NEXT 
 22180  FOR I = E% - 1 TO 1 STEP  - 1
 22190  IF F%(I) > E% - 1 THEN F%(I) = F%(I) + 1
 22200  IF M%(I) > E% - 1 THEN M%(I) = M%(I) + 1
 22210  IF S%(I) > E% - 1 THEN S%(I) = S%(I) + 1
 22220  IF S1%(I) > E% - 1 THEN S1%(I) = S1%(I) + 1
 22230  IF S2%(I) > E% - 1 THEN S2%(I) = S2%(I) + 1
 22240  IF S3%(I) > E% - 1 THEN S3%(I) = S3%(I) + 1
 22250  FOR J = 1 TO K%(I)
 22260  IF C%(I,J) > E% - 1 THEN C%(I,J) = C%(I,J) + 1
 22270  NEXT : HTAB 7: PRINT I")  ";
 22280  NEXT 
 22290 F%(E%) = 0:M%(E%) = 0:S1%(E%) = 0:S2%(E%) = 0:S3%(E%) = 0:K%(E%) = 0:N$(E%) = "/blank insert/":S%(E%) = 0: FOR I = 1 TO 16:C%(E%,I) = 0: NEXT 
 22300  & ,C: GOTO 1000
 23000  & ,O,39,41,14,9: INPUT "Load file: ";A$:A$ =  LEFT$ (A$,28): IF A$ = "" THEN  & ,C: GOTO 1010
 23005 AA$ = "N": IF 0 < EZ% THEN  HOME : PRINT "Append? (Y,N) <N>": POKE  - 16368,0: WAIT  - 16384,128: GET AA$: IF AA$ = "" THEN AA$ = "N"
 23006  POKE  - 16368,0:A% =  ASC (AA$):A% = (A% = 89) OR (A% = 121): HOME : PRINT "Loading file " LEFT$ (A$,22)"."
 23007  IF A% THEN  PRINT "Appending at entry "EZ% + 1"."
 23010 F$ = "P." + A$: VTAB 20: PRINT "(wait)";: ONERR  GOTO 23500
 23020  VTAB 5: PRINT : PRINT C4$"VERIFY"F$C4$"OPEN"F$C4$"READ"F$
 23030  INPUT TL$,S%: FOR I = A% * EZ% + 1 TO S% + A% * EZ%: INPUT N$(I),F%(I),M%(I),S%(I):S1%(I) = 0:S2%(I) = 0:S3%(I) = 0: IF S%(I) >  - 1 THEN S1%(I) = S%(I): GOTO 23070
 23060  INPUT S1%(I): INPUT S2%(I): IF S%(I) =  - 3 THEN  INPUT S3%(I)
 23070  INPUT K%(I):C%(I,K%(I) + 1) = 0: IF K%(I) > 0 THEN  FOR J = 1 TO K%(I): INPUT C%(I,J): NEXT 
 23080  NEXT : PRINT C4$"CLOSE"F$: ONERR  GOTO 63000
 23085  IF  NOT A% THEN 23490
 23086  VTAB 20: HTAB 6: PRINT " ";:AA% = S%
 23090  FOR I = EZ% + 1 TO S% + EZ%:F%(I) = F%(I) + (F%(I) > 0) * EZ%:M%(I) = M%(I) + (M%(I) > 0) * EZ%
 23100 S%(I) = S%(I) + (S%(I) > 0) * EZ%:S1%(I) = S1%(I) + (S1%(I) > 0) * EZ%:S2%(I) = S2%(I) + (S2%(I) > 0) * EZ%:S3%(I) = S3%(I) + (S3%(I) > 0) * EZ%
 23110  FOR J = 1 TO K%(I):C%(I,J) = C%(I,J) + EZ%: NEXT : IF K%(I) < 16 THEN C%(I,K%(I) + 1) = 0
 23120  HTAB 7: PRINT AA%")  ";:AA% = AA% - 1: NEXT 
 23490 F$ =  MID$ (F$,3):E% = 1:G% = 0:EZ% = A% * EZ% + S%: & ,C: GOSUB 10000: GOTO 1000
 23500  HOME : PRINT C4$"CLOSE"F$:F$ =  MID$ (F$,3):ER% =  PEEK (222): POKE 216,0: ONERR  GOTO 63000
 23510  IF ER% = 5 THEN  HOME : PRINT "Warning: End of data error.": GOTO 23950
 23520  IF ER% = 6 THEN  HOME : PRINT "File " LEFT$ (F$,20)" not found.": GOTO 23590
 23530  IF ER% = 8 THEN  HOME : PRINT "I/O Error.": GOTO 23590
 23540  IF ER% = 12 THEN  HOME : PRINT "No buffers available.": GOTO 23590
 23550  IF ER% = 13 OR ER% = 163 OR ER% = 107 OR ER% = 254 THEN  HOME : PRINT "Incorrect type of file.": GOTO 23590
 23560  IF ER% = 77 THEN  HOME : PRINT "Out of memory.": GOTO 23590
 23570  IF ER% = 255 THEN  & ,C: TEXT : HOME : END 
 23580  HOME : PRINT "Error number "ER%"."
 23590  VTAB 21: PRINT "Press any key to continue.";: POKE  - 16368,0: WAIT  - 16384,128: POKE  - 16368,0: & ,C: GOTO 23000
 24000  & ,O,39,41,14,9: PRINT "Save file: "; LEFT$ (F$,25);: HTAB 12: INPUT "";A$: IF A$ = "" THEN  & ,C: GOTO 1010
 24010 F$ = "P." + A$: HOME : PRINT "Saving file " LEFT$ (A$,23)".": PRINT : PRINT "(wait)": ONERR  GOTO 24500
 24020  VTAB 5: PRINT : PRINT C4$"OPEN"F$C4$"CLOSE"F$C4$"UNLOCK"F$C4$"DELETE"F$C4$"OPEN"F$C4$"WRITE"F$
 24030  PRINT TL$: PRINT EZ%: FOR I = 1 TO EZ%
 24040  PRINT N$(I): PRINT F%(I): PRINT M%(I): PRINT S%(I): IF S%(I) >  - 1 THEN 24060
 24050  PRINT S1%(I): PRINT S2%(I): IF S%(I) =  - 3 THEN  PRINT S3%(I)
 24060  PRINT K%(I): IF K%(I) > 0 THEN  FOR J = 1 TO K%(I): PRINT C%(I,J): NEXT 
 24070  NEXT : PRINT C4$"CLOSE"F$: ONERR  GOTO 63000
 24080 F$ =  MID$ (F$,3): & ,C: GOTO 1000
 24500  PRINT C4$"CLOSE"F$:F$ =  MID$ (F$,3):ER% =  PEEK (222): POKE 216,0: ONERR  GOTO 63000
 24510  IF ER% = 4 THEN  HOME : PRINT "Disk is write protected.": GOTO 24570
 24520  IF ER% = 8 THEN  HOME : PRINT "I/O error.": GOTO 24570
 24530  IF ER% = 9 THEN  HOME : PRINT "Disk is full.": GOTO 24570
 24540  IF ER% = 13 THEN  HOME : PRINT "Incorrect type of file.": GOTO 24570
 24550  IF ER% = 255 THEN F$ = "P." + F$: PRINT C4$"OPEN"F$C4$"CLOSE"F$C4$"UNLOCK"F$C4$"DELETE"F$: & ,C: TEXT : HOME : END 
 24560  HOME : PRINT "Error number "ER%"."
 24570  VTAB 21: PRINT "Press any key to continue.";: POKE  - 16368,0: WAIT  - 16384,128: POKE  - 16368,0: & ,C: GOTO 24000
 25000 AA% = E%: POKE 34,3: HOME : VTAB 3 * (AA% > 9) + (13 - AA%) * (AA% < 10)
 25010  FOR I = (AA% - 10) * (AA% > 9) TO AA% + 10 * (AA% < MX% - 9) + (MX% - AA%) * (AA% > MX% - 10): PRINT : HTAB 4: PRINT  LEFT$ (N$(I),76);: NEXT : VTAB 14: HTAB 2: PRINT ">";: POKE 33,78: POKE 32,2
 25040  POKE  - 16368,0: WAIT  - 16384,128: GET A$: IF A$ = "" THEN 25040
 25050 A% =  ASC (A$): POKE  - 16368,0
 25060  IF (A% = 8 OR A% = 11) AND (AA% > 0) THEN AA% = AA% - 1: PRINT  CHR$ (22);: IF AA% > 9 THEN  VTAB 4: HTAB 2: PRINT N$(AA% - 10);
 25070  IF (A% = 21 OR A% = 10) AND (AA% < MX%) THEN AA% = AA% + 1: CALL  - 912: IF AA% < MX% - 9 THEN  VTAB 24: HTAB 2: PRINT N$(AA% + 10);
 25080  IF A% = 13 THEN E% = AA%: GOTO 25110
 25090  IF A% = 27 THEN 25110
 25100  GOTO 25040
 25110  POKE 32,0: POKE 33,80: POKE 34,2:G% = 0: GOTO 1000
 26000  & ,O,39,41,14,9: PRINT "person number      : "E%: PRINT "generation counter : "G%: PRINT "size               : ";: IF E% > EZ% THEN  INVERSE 
 26010  PRINT EZ%: NORMAL : PRINT : PRINT "Press any key to continue.";: POKE  - 16368,0: WAIT  - 16384,128: POKE  - 16368,0: & ,C: GOTO 1010
 30000  & ,O,39,41,14,9: PRINT "Child number "A% - 48;: INPUT ": ";A$:C%(E%,A% - 48) = C%(E%,A% - 48) * ( NOT ( VAL (A$) OR A$ = "0") OR ( VAL (A$) > MX%)) +  VAL (A$) * ( VAL (A$) <  = MX%): IF A% - 48 > K%(E%) THEN K%(E%) = A% - 48
 30010  IF A% - 48 = K%(E%) AND C%(E%,A% - 48) = 0 THEN K%(E%) = A% - 49
 30015  IF K%(E%) < 16 THEN C%(E%,K%(E%) + 1) = 0
 30020  & ,C: GOTO 1000
 31000  & ,O,39,41,14,9: INPUT "First spouse: ";A$:S1%(E%) = S1%(E%) * ( NOT ( VAL (A$) OR A$ = "0") OR ( VAL (A$) > MX%)) +  VAL (A$) * ( VAL (A$) <  = MX%): IF S%(E%) >  - 1 THEN S%(E%) = S1%(E%)
 31010  & ,C: GOTO 1000
 32000  & ,O,39,41,14,9: INPUT "Second spouse: ";A$:S2%(E%) = S2%(E%) * ( NOT ( VAL (A$) OR A$ = "0") OR ( VAL (A$) > MX%)) +  VAL (A$) * ( VAL (A$) <  = MX%): IF S%(E%) >  - 2 THEN S%(E%) =  - 2
 32010  IF S2%(E%) = 0 THEN S%(E%) = S1%(E%)
 32020  & ,C: GOTO 1000
 33000  & ,O,39,41,14,9: INPUT "Third spouse: ";A$:S3%(E%) = S3%(E%) * ( NOT ( VAL (A$) OR A$ = "0") OR ( VAL (A$) > MX%)) +  VAL (A$) * ( VAL (A$) <  = MX%): IF S%(E%) >  - 3 THEN S%(E%) =  - 3
 33010  IF S3%(E%) = 0 THEN S%(E%) =  - 2
 33020  & ,C: GOTO 1000
 34000  & ,O,39,41,14,9: INPUT "Father: ";A$:F%(E%) = F%(E%) * ( NOT ( VAL (A$) OR A$ = "0") OR ( VAL (A$) > MX%)) +  VAL (A$) * ( VAL (A$) <  = MX%): & ,C: GOTO 1000
 35000  & ,O,39,41,14,9: INPUT "Mother: ";A$:M%(E%) = M%(E%) * ( NOT ( VAL (A$) OR A$ = "0") OR ( VAL (A$) > MX%)) +  VAL (A$) * ( VAL (A$) <  = MX%): & ,C: GOTO 1000
 36000  & ,O,39,41,14,9: PRINT "Name: "N$(E%): VTAB 17: HTAB 7: INPUT "";A$:N$(E%) =  LEFT$ (A$,78): & ,C: GOTO 1000
 37000  & ,O,39,41,14,9: PRINT "Title: "TL$: VTAB 17: HTAB 8: INPUT "";A$:TL$ =  LEFT$ (A$,76): & ,C: GOSUB 10000: GOTO 1000
 38000  & ,O,39,41,14,9: INPUT "Size: ";AA$:A$ =  STR$ ( INT ( ABS ( VAL (AA$)))):A% =  VAL (A$):EZ% = EZ% * ( NOT (A% OR AA$ = "0") OR A% > MX%) + A% * (A% <  = MX%)
 38010  & ,C: GOTO 1000
 50000  & ,O,20,44,1,22: PRINT : PRINT C4$"Catalog": PRINT : PRINT "Press any key to continue.";: POKE  - 16368,0: WAIT  - 16384,128: POKE  - 16368,0: & ,C: GOTO 1010
 60000  ONERR  GOTO 63000
 60005  HOME : PRINT : PRINT "PR#3"
 60010  PRINT : PRINT "BRUN PORTAL": PRINT : PRINT "BRUN EXTRA.VARIABLES"
 60080  TEXT : NORMAL : HOME : INVERSE : PRINT  TAB( 33)"P e d i g r e e" TAB( 81): NORMAL 
 60090  VTAB 4: HTAB 37: PRINT "(wait)"
 60100 MX% = 750
 60110  DIM N$(MX% + 1),F%(MX% + 1),M%(MX% + 1),S%(MX% + 1),S1%(MX% + 1),S2%(MX% + 1),S3%(MX% + 1),K%(MX% + 1),C%(MX% + 1,16)
 60120 E% = 0:G% = 0:EZ% = 0:MD% = 0:A$ = "":AA$ = "":A% = 0:AA% = 0:I = 0:J = 0
 60130 TL$ = "P e d i g r e e":C4$ =  CHR$ (13) +  CHR$ (4):F$ = "":MS% = 0:N% = 0:S% = 0:ER% = 0:EL% = 0
 60140  FOR I = 0 TO MX% + 1:N$(I) = "/blank/": NEXT 
 60999  RETURN 
 63000 ER% =  PEEK (222):EL% =  PEEK (218) +  PEEK (219) * 256: POKE 216,0
 63010  IF ER% = 255 THEN  TEXT : HOME : END 
 63999  HOME : PRINT "Error number "ER%" at line "EL%".": TEXT : VTAB 22: END 
