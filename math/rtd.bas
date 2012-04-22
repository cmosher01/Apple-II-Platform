 100  GOTO 60000
 1000  HOME : VTAB 5: HTAB 8: PRINT "Main menu:": PRINT 
 1010  HTAB 13: PRINT "Search     (search for a record or folder)": PRINT 
 1020  HTAB 13: PRINT "View       (view the current record or folder)": PRINT 
 1030  HTAB 13: PRINT "Edit       (edit the current record or folder)": PRINT 
 1040  HTAB 13: PRINT "Delete     (delete the current record or folder)": PRINT 
 1050  HTAB 13: PRINT "Add new    (add new records or folders)": PRINT 
 1060  HTAB 13: PRINT "Quit       (quit using Record TrackDown)": PRINT 
 1100  GOSUB 11000: GOSUB 12000: IF L% = 0 THEN 1100
 1110  IF R% = 6 THEN 2000
 1120  IF R% = 8 THEN 3000
 1130  IF R% = 10 THEN 4000
 1140  IF R% = 12 THEN 5000
 1150  IF R% = 14 THEN 6000
 1160  IF R% = 16 THEN 62000
 1170  GOTO 1100
 1180  REM 
 1190  REM 
 2000  REM search
 2010 A$ = "": HOME : VTAB 5: HTAB 8: PRINT "Search for what?": PRINT 
 2020  GOSUB 19000: ON I% GOTO 2100,2500
 2100  REM search for record
 2110  HOME : VTAB 5: HTAB 8: PRINT "Search by:": PRINT 
 2120  HTAB 13: PRINT "subject": PRINT 
 2130  HTAB 13: PRINT "folder number": PRINT 
 2140  HTAB 13: PRINT "date": PRINT 
 2150  HTAB 13: PRINT "description": PRINT 
 2160  GOSUB 11000: GOSUB 12000: IF L% = 0 THEN 2160
 2170  IF ST$ = "subject" THEN I% = 1: GOTO 2220
 2180  IF ST$ = "folder number" THEN I% = 2: GOTO 2220
 2190  IF ST$ = "date" THEN I% = 4: GOTO 2220
 2200  IF ST$ = "description" THEN I% = 3: GOTO 2220
 2210  GOTO 2160
 2220  HOME : VTAB 5: HTAB 8: PRINT "Search for "ST$".": PRINT 
 2230  HTAB 13: PRINT "Enter "ST$": "A$;: HTAB 21 +  LEN (ST$): INPUT "";A$
 2240  IF A$ = "" THEN 2000
 2245  PRINT : PRINT D$"open"FR$: PRINT D$"read"FR$:RC% = 0:RF% = 0
 2250  HOME : VTAB 5: HTAB 8: PRINT "Searching for '" LEFT$ (A$,30)"'.": PRINT 
 2260  HTAB 13: PRINT "Wait."
 2280 RC% = RC% + 1: ONERR  GOTO 2300
 2290  FOR I = 1 TO 4: INPUT L$(I): NEXT : POKE 216,0: GOTO 2350
 2300  POKE 216,0:RC% = 0: HOME : GOSUB 16500: GOSUB 13000: GOTO 2430
 2350 B$ = L$(I%): IF I% = 4 THEN DT% =  VAL (B$): GOSUB 14000:B$ = DT$
 2360  GOSUB 15000: IF  NOT E% THEN 2280
 2370 RC$(1) = L$(1):RC$(2) = L$(2):RC$(3) = L$(3):RC%(1) =  VAL (L$(4))
 2380  HOME : GOSUB 20000: GOSUB 16000
 2390  GOSUB 11000: GOSUB 12000: IF L% = 0 THEN 2390
 2400  IF ST$ = "continue searching" THEN  HOME : GOTO 2250
 2410  IF ST$ = "go to main menu" THEN 2430
 2420  GOTO 2390
 2430  PRINT D$"close"FR$: GOTO 1000
 2500  REM search for folder
 2510  HOME : VTAB 5: HTAB 8: PRINT "Search by:": PRINT 
 2520  HTAB 13: PRINT "name": PRINT 
 2530  HTAB 13: PRINT "number": PRINT 
 2540  HTAB 13: PRINT "media": PRINT 
 2550  HTAB 13: PRINT "location": PRINT 
 2560  GOSUB 11000: GOSUB 12000: IF L% = 0 THEN 2560
 2570  IF ST$ = "name" THEN I% = 1: GOTO 2620
 2580  IF ST$ = "number" THEN I% = 2: GOTO 2620
 2590  IF ST$ = "media" THEN I% = 3: GOTO 2620
 2600  IF ST$ = "location" THEN I% = 4: GOTO 2620
 2610  GOTO 2560
 2620  HOME : VTAB 5: HTAB 8: PRINT "Search for "ST$".": PRINT 
 2630  HTAB 13: PRINT "Enter "ST$": "A$;: HTAB 21 +  LEN (ST$): INPUT "";A$
 2640  IF A$ = "" THEN 2000
 2645  PRINT : PRINT D$"open"FF$: PRINT D$"read"FF$:RF% = 0:RC% = 0
 2650  HOME : VTAB 5: HTAB 8: PRINT "Searching for '" LEFT$ (A$,30)"'.": PRINT 
 2660  HTAB 13: PRINT "Wait."
 2680 RF% = RF% + 1: ONERR  GOTO 2700
 2690  FOR I = 1 TO 4: INPUT L$(I): NEXT : POKE 216,0: GOTO 2750
 2700  POKE 216,0:RF% = 0: HOME : GOSUB 16500: GOSUB 13000: GOTO 2820
 2750 B$ = L$(I%): GOSUB 15000: IF  NOT E% THEN 2680
 2760  FOR I = 1 TO 4:RF$(I) = L$(I): NEXT 
 2770  HOME : GOSUB 25000: GOSUB 18000
 2780  GOSUB 11000: GOSUB 12000: IF L% = 0 THEN 2780
 2790  IF ST$ = "continue searching" THEN  HOME : GOTO 2650
 2800  IF ST$ = "go to main menu" THEN 2820
 2810  GOTO 2780
 2820  PRINT D$"close"FF$: GOTO 1000
 2980  REM 
 2990  REM 
 3000  REM view
 3010  HOME : VTAB 5: HTAB 8
 3015  IF RC% = 0 AND RF% = 0 THEN  PRINT "You must search for a record or a folder": HTAB 8: PRINT "before you view one.": GOSUB 13000: GOTO 1000
 3017  PRINT "View what?": PRINT 
 3020  GOSUB 19000: ON I% GOTO 3100,3500
 3100  REM view record
 3105  HOME : IF RC% = 0 THEN  VTAB 5: HTAB 8: PRINT "You must search for a record before": HTAB 8: PRINT "you view one.": GOSUB 13000: GOTO 1000
 3110  GOSUB 20000: GOSUB 13000: GOTO 1000
 3500  REM view folder
 3505  IF RF% > 0 THEN  HOME : GOSUB 25000: GOSUB 13000: GOTO 1000
 3510 A$ = RC$(2): HOME : VTAB 5: HTAB 8: PRINT "Searching for folder number "A$".": PRINT : HTAB 13: PRINT "Wait."
 3520  PRINT : PRINT D$"open"FF$: PRINT D$"read"FF$:RF% = 0: ONERR  GOTO 3550
 3530 RF% = RF% + 1: FOR I = 1 TO 4: INPUT L$(I): NEXT : IF A$ <  > L$(2) THEN 3530
 3540  POKE 216,0: GOTO 3600
 3550  POKE 216,0: HOME : VTAB 5: HTAB 8: PRINT "Cannot find folder number "A$".": GOSUB 13000: GOTO 3630
 3600  FOR I = 1 TO 4:RF$(I) = L$(I): NEXT 
 3620  HOME : GOSUB 25000: GOSUB 13000
 3630  PRINT D$"close"FF$: GOTO 1000
 3980  REM 
 3990  REM 
 4000  REM edit
 4010  HOME : VTAB 5: HTAB 8
 4015  IF RC% = 0 AND RF% = 0 THEN  PRINT "You must search for a record or a folder": HTAB 8: PRINT "before you edit one.": GOSUB 13000: GOTO 1000
 4017  PRINT "Edit what?": PRINT 
 4020  GOSUB 19000: ON I% GOTO 4100,4500
 4100  REM edit record
 4105  HOME : IF RC% = 0 THEN  VTAB 5: HTAB 8: PRINT "You must search for a record before": HTAB 8: PRINT "you edit one.": GOSUB 13000: GOTO 1000
 4110  GOSUB 20000: GOSUB 30000
 4120  HOME : GOSUB 20000: GOSUB 17000
 4130  GOSUB 11000: GOSUB 12000: IF L% = 0 THEN 4130
 4140  IF ST$ = "save the changes" THEN 4170
 4150  IF ST$ = "don't save the changes" THEN RC% = 0: GOTO 1000
 4160  GOTO 4130
 4170  HOME : VTAB 5: HTAB 8: PRINT "Saving changes.": PRINT : HTAB 13: PRINT "Wait."
 4180  PRINT : PRINT D$"open"FR$: PRINT D$"open"FT$
 4190  IF RC% = 1 THEN  PRINT D$"write"FT$: GOTO 4210
 4200  FOR I = 1 TO (RC% - 1) * 4: PRINT D$"read"FR$: INPUT X$: PRINT D$"write"FT$: PRINT X$: NEXT 
 4210  PRINT RC$(1): PRINT RC$(2): PRINT RC$(3): PRINT RC%(1)
 4220  PRINT D$"read"FR$: FOR I = 1 TO 4: INPUT X$: NEXT 
 4230  ONERR  GOTO 4250
 4240  PRINT D$"read"FR$: INPUT X$: PRINT D$"write"FT$: PRINT X$: GOTO 4240
 4250  POKE 216,0: PRINT D$"close"FR$: PRINT D$"close"FT$: PRINT D$"delete"FR$: PRINT D$"rename"FT$","FR$
 4260  GOTO 1000
 4500  REM edit folder
 4510  HOME 
 4520  IF RF% = 0 THEN  VTAB 5: HTAB 8: PRINT "You must search for a folder before": HTAB 8: PRINT "you edit one.": GOSUB 13000: GOTO 1000
 4530  GOSUB 25000: GOSUB 35000
 4540  HOME : GOSUB 25000: GOSUB 17000
 4550  GOSUB 11000: GOSUB 12000: IF L% = 0 THEN 4550
 4555  IF ST$ = "save the changes" THEN 4570
 4560  IF ST$ = "don't save the changes" THEN RF% = 0: GOTO 1000
 4565  GOTO 4550
 4570  HOME : VTAB 5: HTAB 8: PRINT "Saving changes.": PRINT : HTAB 13: PRINT "Wait."
 4580  PRINT : PRINT D$"open"FF$: PRINT D$"open"FT$
 4590  IF RF% = 1 THEN  PRINT D$"write"FT$: GOTO 4610
 4600  FOR I = 1 TO (RF% - 1) * 4: PRINT D$"read"FF$: INPUT X$: PRINT D$"write"FT$: PRINT X$: NEXT 
 4610  FOR I = 1 TO 4: PRINT RF$(I): NEXT 
 4620  PRINT D$"read"FF$: FOR I = 1 TO 4: INPUT X$: NEXT 
 4630  ONERR  GOTO 4650
 4640  PRINT D$"read"FF$: INPUT X$: PRINT D$"write"FT$: PRINT X$: GOTO 4640
 4650  POKE 216,0: PRINT D$"close"FF$: PRINT D$"close"FT$: PRINT D$"delete"FF$: PRINT D$"rename"FT$","FF$
 4660  GOTO 1000
 4980  REM 
 4990  REM 
 5000  REM delete
 5010  HOME : VTAB 5: HTAB 8
 5015  IF RC% = 0 AND RF% = 0 THEN  PRINT "You must search for a record or a folder": HTAB 8: PRINT "before you delete one.": GOSUB 13000: GOTO 1000
 5017  PRINT "Delete what?": PRINT 
 5020  GOSUB 19000: ON I% GOTO 5100,5500
 5100  REM delete record
 5105  HOME : IF RC% = 0 THEN  VTAB 5: HTAB 8: PRINT "You must search for a record before": HTAB 8: PRINT "you delete one.": GOSUB 13000: GOTO 1000
 5110  GOSUB 20000: GOSUB 18500
 5120  GOSUB 11000: GOSUB 12000: IF L% = 0 THEN 5120
 5130  IF ST$ = "yes" THEN 5200
 5140  IF ST$ = "no" THEN 1000
 5150  GOTO 5120
 5200  HOME : VTAB 5: HTAB 8: PRINT "Deleting the record.": PRINT : HTAB 13: PRINT "Wait."
 5210  PRINT : PRINT D$"open"FR$: PRINT D$"open"FT$
 5220  IF RC% = 1 THEN 5250
 5240  FOR I = 1 TO (RC% - 1) * 4: PRINT D$"read"FR$: INPUT X$: PRINT D$"write"FT$: PRINT X$: NEXT 
 5250  PRINT D$"read"FR$: INPUT X$,X$,X$,X$
 5260  ONERR  GOTO 5280
 5270  PRINT D$"read"FR$: INPUT X$: PRINT D$"write"FT$: PRINT X$: GOTO 5270
 5280  POKE 216,0: PRINT D$"close"FR$: PRINT D$"close"FT$: PRINT D$"delete"FR$: PRINT D$"rename"FT$","FR$:RC% = 0: GOTO 1000
 5500  REM delete folder
 5510  HOME : VTAB 5: HTAB 8
 5520  IF RF% = 0 THEN  PRINT "You must search for a folder before": HTAB 8: PRINT "you delete one.": GOSUB 13000: GOTO 1000
 5530  PRINT "Checking to see if folder is empty.": PRINT : HTAB 13: PRINT "Wait."
 5540  PRINT : PRINT D$"open"FR$: PRINT D$"read"FR$:I% = 0: ONERR  GOTO 5560
 5550  INPUT X$,A$,X$,X$: IF A$ = RF$(2) THEN I% = 1: GOTO 5560
 5555  GOTO 5550
 5560  POKE 216,0: PRINT D$"close"FR$: IF  NOT I% THEN 5600
 5565  IF  NOT I% THEN 5600
 5570  VTAB 7: HTAB 13: CALL  - 958: PRINT "The current folder is not empty.": PRINT : HTAB 13: PRINT "Are you sure you want to delete it?": PRINT : HTAB 18: PRINT "yes": PRINT : HTAB 18: PRINT "no"
 5580  GOSUB 11000: GOSUB 12000: IF L% = 0 THEN 5580
 5590  IF ST$ = "yes" THEN 5600
 5593  IF ST$ = "no" THEN 1000
 5595  GOTO 5580
 5600  HOME : VTAB 5: HTAB 8: PRINT "Deleting the folder.": PRINT : HTAB 13: PRINT "Wait."
 5610  PRINT : PRINT D$"open"FF$: PRINT D$"open"FT$
 5620  IF RF% = 1 THEN 5650
 5640  FOR I = 1 TO (RF% - 1) * 4: PRINT D$"read"FF$: INPUT X$: PRINT D$"write"FT$: PRINT X$: NEXT 
 5650  PRINT D$"read"FF$: INPUT X$,X$,X$,X$
 5660  ONERR  GOTO 5680
 5670  PRINT D$"read"FF$: INPUT X$: PRINT D$"write"FT$: PRINT X$: GOTO 5670
 5680  POKE 216,0: PRINT D$"close"FF$: PRINT D$"close"FT$: PRINT D$"delete"FF$: PRINT D$"rename"FT$","FF$:RF% = 0: GOTO 1000
 5980  REM 
 5990  REM 
 6000  REM add new
 6010  HOME : VTAB 5: HTAB 8: PRINT "Add a new what?": PRINT 
 6020  GOSUB 19000: ON I% GOTO 6100,6500
 6100  REM add new records
 6110 RC$(1) = "":RC$(2) = "":RC$(3) = "":RC%(1) = 0:RC% = 0
 6120  HOME : GOSUB 20000: GOSUB 30000: IF I% THEN  GOSUB 40000: GOTO 6110
 6130  GOTO 1000
 6500  REM add new folders
 6510 RF$(1) = "":RF$(2) = "":RF$(3) = "":RF$(4) = "":RF% = 0
 6520  HOME : GOSUB 25000: GOSUB 35000: IF I% THEN  GOSUB 45000: GOTO 6510
 6530  GOTO 1000
 8980  REM 
 8990  REM 
 8999  REM print out record file
 9000  PRINT D$"open"FR$: PRINT D$"read"FR$
 9010  ONERR  GOTO 9030
 9020  FOR I = 1 TO 4: INPUT X$: PRINT X$: NEXT : PRINT "----------------------------------------": GOTO 9010
 9030  POKE 216,0: PRINT D$"close"FR$: END 
 9499  REM print out folder file
 9500  PRINT D$"open"FF$: PRINT D$"read"FF$
 9510  ONERR  GOTO 9530
 9520  FOR I = 1 TO 4: INPUT X$: PRINT X$: NEXT : PRINT "----------------------------------------": GOTO 9520
 9530  POKE 216,0: PRINT D$"close"FF$: END 
 9999  REM print title
 10000  TEXT : NORMAL : HOME : PRINT : VTAB 1: INVERSE : PRINT  TAB( 25)"R e c o r d   T r a c k D o w n" TAB( 81): NORMAL : PRINT : POKE 34,2: RETURN 
 10999  REM wait for mouse selection
 11000  POKE RA%,R%: POKE CA%,C%: CALL MN%: WAIT BT%,T7%,T7%: WAIT BT%,T7%: CALL MF%:R% =  PEEK (RA%):C% =  PEEK (CA%): RETURN 
 11999  REM read string from screen
 12000  POKE RA%,R%: POKE CA%,C%: CALL SR%:L% =  PEEK (LA%):RB% =  PEEK (RA%):CB% =  PEEK (CA%):ST$ = "": IF L% > 0 THEN  FOR I = 0 TO L% - 1:ST$ = ST$ +  CHR$ ( PEEK (SA% + I) - T7%): NEXT 
 12010  RETURN 
 12999  REM wait for mouse button press
 13000  VTAB 24: HTAB 23: PRINT "Press the mouse button to continue.";: WAIT BT%,T7%,T7%: WAIT BT%,T7%: RETURN 
 14000  REM date number to date string converter
 14001  REM   input:
 14002  REM     dt%  :  date:
 14003  REM                xxxx............ month number     (1 -  12)
 14004  REM                ....xxxxx....... day              (1 -  31)
 14005  REM                .........xxxxxxx year since 1960  (0 - 127)
 14006  REM 
 14007  REM   output:
 14008  REM     dt$  :  date:
 14009  REM                "<month>/<day>/<year>"
 14010  REM 
 14015  IF DT% = 0 THEN DT$ = "": RETURN 
 14020 I = DT% / 128:YR% = 1960 + (I -  INT (I)) * 128
 14030 I = I / 32:DY% = (I -  INT (I)) * 32
 14040 MT% = I + 16 * (I < 1)
 14050 DT$ =  STR$ (MT%) + "/" +  STR$ (DY%) + "/" +  STR$ (YR%)
 14060  RETURN 
 14500  REM date string to date number converter
 14501  REM   input:
 14502  REM     dt$  :  (as above)
 14503  REM 
 14504  REM   output:
 14505  REM     dt%  :  (as above)
 14506  REM 
 14520 DT% =  VAL ( MID$ (DT$, LEN (DT$) - 3)) - 1960
 14530 DY% =  VAL ( MID$ (DT$, LEN (DT$) - 6,1)) * 10 +  VAL ( MID$ (DT$, LEN (DT$) - 5,1))
 14540 I$ =  MID$ (DT$,2,1):MT% =  VAL ( LEFT$ (DT$,1)): IF I$ <  > "/" THEN MT% =  VAL (I$) + MT% * 10
 14550 DT% = DT% + DY% * T7%:DT% = DT% + MT% * 4096 - 65536 * (MT% > 7)
 14560  RETURN 
 15000  REM see if A$ is a substring of B$; return E%
 15010 E% = 0:A% =  LEN (A$):B% =  LEN (B$): IF (A% > B%) OR  NOT A% OR  NOT B% THEN  RETURN 
 15020 A1% = 511:B1% = 767: POKE 254,A%: POKE 255,B%
 15100  FOR I = 1 TO A%: POKE A1% + I, ASC ( MID$ (A$,I,T0%)): NEXT 
 15105  FOR I = 1 TO B%: POKE B1% + I, ASC ( MID$ (B$,I,T0%)): NEXT 
 15110  CALL CP%:E% =  PEEK (253): RETURN 
 15999  REM print record found menu
 16000  VTAB 15: PRINT : PRINT "________________________________________________________________________________"
 16010  VTAB 18: HTAB 8: PRINT "Found the above record.  Now what?": PRINT 
 16020  HTAB 13: PRINT "continue searching": PRINT 
 16030  HTAB 13: PRINT "go to main menu"
 16040  RETURN 
 16499  REM print record not found
 16500  VTAB 15: PRINT : PRINT "________________________________________________________________________________"
 16510  VTAB 18: HTAB 8: PRINT "Search for '" LEFT$ (A$,30)"' failed.": RETURN 
 16999  REM print done edit menu
 17000  VTAB 15: PRINT : PRINT "________________________________________________________________________________"
 17010  VTAB 18: HTAB 8: PRINT "Now what?": PRINT 
 17020  HTAB 13: PRINT "save the changes": PRINT 
 17030  HTAB 13: PRINT "don't save the changes"
 17040  RETURN 
 17999  REM print folder found menu
 18000  VTAB 15: PRINT : PRINT "________________________________________________________________________________"
 18010  VTAB 18: HTAB 8: PRINT "Found the above folder.  Now what?": PRINT 
 18020  HTAB 13: PRINT "continue searching": PRINT 
 18030  HTAB 13: PRINT "go to main menu"
 18040  RETURN 
 18499  REM print delete confirmation menu
 18500  VTAB 15: PRINT : PRINT "________________________________________________________________________________"
 18510  VTAB 18: HTAB 8: PRINT "Are you sure you want to delete the above record?": PRINT 
 18520  HTAB 13: PRINT "yes": PRINT : HTAB 13: PRINT "no": RETURN 
 18999  REM record/folder choice menu
 19000  HTAB 13: PRINT "record": PRINT : HTAB 13: PRINT "folder"
 19010  GOSUB 11000: GOSUB 12000: IF L% = 0 THEN 19010
 19020  IF ST$ = "record" THEN I% = 1: RETURN 
 19030  IF ST$ = "folder" THEN I% = 2: RETURN 
 19040  GOTO 19010
 20000  REM display a record
 20010  VTAB 5: HTAB 17: PRINT "Subject: "RC$(1): PRINT 
 20020  HTAB 11: PRINT "Folder number: "RC$(2): PRINT 
 20030  HTAB 20: PRINT "Date: ";
 20040 DT% = RC%(1): GOSUB 14000: PRINT DT$: PRINT 
 20050  HTAB 13: PRINT "Description: "RC$(3)
 20070  RETURN 
 25000  REM display a folder
 25010  VTAB 5: HTAB 20: PRINT "Name: "RF$(1): PRINT 
 25020  HTAB 18: PRINT "Number: "RF$(2): PRINT 
 25040  HTAB 19: PRINT "Media: "RF$(3): PRINT 
 25050  HTAB 16: PRINT "Location: "RF$(4)
 25060  RETURN 
 30000  REM edit a displayed record
 30005 I% = 1
 30010  VTAB 5: HTAB 26: INPUT "";A$: IF A$ = "" THEN A$ = RC$(1): VTAB 5: HTAB 26: PRINT A$: IF A$ = "" THEN I% = 0: RETURN 
 30015 RC$(1) = A$
 30020  VTAB 7: HTAB 26: INPUT "";A$: IF A$ = "" THEN A$ = RC$(2): VTAB 7: HTAB 26: PRINT A$: IF A$ = "" THEN 30020
 30025 RC$(2) = A$
 30030  VTAB 9: HTAB 26: INPUT "";A$: IF A$ = "" THEN DT% = RC%(1): GOSUB 14000:A$ = DT$: VTAB 9: HTAB 26: PRINT A$: IF A$ = "" THEN 30030
 30035 DT$ = A$: GOSUB 14500:RC%(1) = DT%
 30050  VTAB 11: HTAB 26: INPUT "";A$: IF A$ = "" THEN A$ = RC$(3): VTAB 11: HTAB 26: PRINT A$: IF A$ = "" THEN 30050
 30060 RC$(3) = A$: RETURN 
 35000  REM edit a displayed folder
 35005 I% = 1
 35010  VTAB 5: HTAB 26: INPUT "";A$: IF A$ = "" THEN A$ = RF$(1): VTAB 5: HTAB 26: PRINT A$: IF A$ = "" THEN I% = 0: RETURN 
 35015 RF$(1) = A$
 35020  VTAB 7: HTAB 26: INPUT "";A$: IF A$ = "" THEN A$ = RF$(2): VTAB 7: HTAB 26: PRINT A$: IF A$ = "" THEN 35020
 35025 RF$(2) = A$
 35030  VTAB 9: HTAB 26: INPUT "";A$: IF A$ = "" THEN A$ = RF$(3): VTAB 9: HTAB 26: PRINT A$: IF A$ = "" THEN 35030
 35035 RF$(3) = A$
 35040  VTAB 11: HTAB 26: INPUT "";A$: IF A$ = "" THEN A$ = RF$(4): VTAB 11: HTAB 26: PRINT A$: IF A$ = "" THEN 35040
 35050 RF$(4) = A$: RETURN 
 40000  REM append a record
 40100  PRINT D$"open"FR$: PRINT D$"append"FR$
 40110  FOR I = 1 TO 3: PRINT RC$(I): NEXT : PRINT RC%(1)
 40120  PRINT D$"close"FR$
 40130  RETURN 
 45000  REM append a folder
 45005  PRINT D$"open"FF$: PRINT D$"append"FF$
 45010  FOR I = 1 TO 4: PRINT RF$(I): NEXT 
 45020  PRINT D$"close"FF$
 45030  RETURN 
 60000  REM init
 60001 L% = 0:R% = 0:C% = 0:RB% = 0:CB% = 0
 60002 SE% = 16384:CP% =  - 27136:MN% =  - 26880:MF% = MN% + 3:SR% = MN% + 432
 60003 LA% = 253:RA% = 254:CA% = 255:SA% = 512
 60004 BT% =  - 16285:T7% = 128:T0% = 1
 60005 D$ = "":FR$ = "records":FF$ = "folders":FT$ = "temporary"
 60010  NORMAL : TEXT : HOME : VTAB 8: HTAB 25: PRINT "R e c o r d   T r a c k D o w n": GOSUB 13000
 60020  GOSUB 10000: VTAB 5: HTAB 8: PRINT "Loading information from disk.": PRINT : HTAB 13: PRINT "Wait."
 60030  PRINT D$"bloadrm.subs": CALL  - 16648: CALL SE%
 61000  PRINT D$"open"FR$: PRINT D$"open/ram/"FR$
 61010  ONERR  GOTO 61030
 61020  PRINT D$"read"FR$: INPUT X$: PRINT D$"write/ram/"FR$: PRINT X$: GOTO 61020
 61030  POKE 216,0: PRINT D$"close"FR$: PRINT D$"close/ram/"FR$
 61100  PRINT D$"open"FF$: PRINT D$"open/ram/"FF$
 61110  ONERR  GOTO 61130
 61120  PRINT D$"read"FF$: INPUT X$: PRINT D$"write/ram/"FF$: PRINT X$: GOTO 61120
 61130  POKE 216,0: PRINT D$"close"FF$: PRINT D$"close/ram/"FF$
 61140  PRINT D$"prefix/ram": GOTO 1000
 61999  REM quit
 62000  HOME : VTAB 5: HTAB 8: PRINT "Saving information to disk.": PRINT : HTAB 13: PRINT "Wait.": PRINT D$"prefix/"
 62005  PRINT D$"open/ram/"FR$: PRINT D$"open"FR$: PRINT D$"close"FR$: PRINT D$"unlock"FR$: PRINT D$"delete"FR$: PRINT D$"open"FR$
 62010  ONERR  GOTO 62030
 62020  PRINT D$"read/ram/"FR$: INPUT X$: PRINT D$"write"FR$: PRINT X$: GOTO 62020
 62030  POKE 216,0: PRINT D$"close/ram/"FR$: PRINT D$"close"FR$: PRINT D$"lock"FR$
 62100  PRINT D$"open/ram/"FF$: PRINT D$"open"FF$: PRINT D$"close"FF$: PRINT D$"unlock"FF$: PRINT D$"delete"FF$: PRINT D$"open"FF$
 62110  ONERR  GOTO 62130
 62120  PRINT D$"read/ram/"FF$: INPUT X$: PRINT D$"write"FF$: PRINT X$: GOTO 62120
 62130  POKE 216,0: PRINT D$"close/ram/"FF$: PRINT D$"close"FF$: PRINT D$"lock"FF$
 62140  TEXT : HOME : END 
