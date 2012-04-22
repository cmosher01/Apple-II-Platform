NEW

    1 HOME

   10 READ K$, A
   15 IF K$ = "" THEN 9999
   20 IF K$ = "QUOTE" THEN K$ = CHR$(34)
   25 IF K$ = "CTRL" OR K$ = "SHIFT" OR K$ = "SHIFT+CTRL" THEN PRINT "NOW HOLD DOWN "; K$; " AND PRESS THESE:" : GOTO 10

   27 IF A = 131 OR A = 147 THEN 10 : REM SKIP CTRL-C AND CTRL-S

   30 PRINT "PRESS "; K$; " ";
   31 IF K$ = "]" THEN PRINT "(SHIFT-M ON THE REAL APPLE ][) ";

   40 POKE -16368,0
   41 P = PEEK(-16384) : IF P < 128 THEN 41

   50 IF (P = A) THEN 100
   60 PRINT "ERROR: WAS "; P; " SHOULD BE "; A
   70 GOTO 10

  100 PRINT "OK"
  110 GOTO 10

 9999 GET K$ : END



10000 DATA "[space bar]",160
10001 DATA "!"          ,161
10002 DATA "QUOTE"      ,162
10003 DATA "#"          ,163
10004 DATA "$"          ,164
10005 DATA "%"          ,165
10006 DATA "&"          ,166
10007 DATA "'"          ,167
10008 DATA "("          ,168
10009 DATA ")"          ,169
10010 DATA "*"          ,170
10011 DATA "+"          ,171
10012 DATA ","          ,172
10013 DATA "-"          ,173
10014 DATA "."          ,174
10015 DATA "/"          ,175
10016 DATA "0"          ,176
10017 DATA "1"          ,177
10018 DATA "2"          ,178
10019 DATA "3"          ,179
10020 DATA "4"          ,180
10021 DATA "5"          ,181
10022 DATA "6"          ,182
10023 DATA "7"          ,183
10024 DATA "8"          ,184
10025 DATA "9"          ,185
10026 DATA ":"          ,186
10027 DATA ";"          ,187
10028 DATA "<"          ,188
10029 DATA "="          ,189
10030 DATA ">"          ,190
10031 DATA "?"          ,191
10032 DATA "@"          ,192
10033 DATA "A"          ,193
10034 DATA "B"          ,194
10035 DATA "C"          ,195
10036 DATA "D"          ,196
10037 DATA "E"          ,197
10038 DATA "F"          ,198
10039 DATA "G"          ,199
10040 DATA "H"          ,200
10041 DATA "I"          ,201
10042 DATA "J"          ,202
10043 DATA "K"          ,203
10044 DATA "L"          ,204
10045 DATA "M"          ,205
10046 DATA "N"          ,206
10047 DATA "O"          ,207
10048 DATA "P"          ,208
10049 DATA "Q"          ,209
10050 DATA "R"          ,210
10051 DATA "S"          ,211
10052 DATA "T"          ,212
10053 DATA "U"          ,213
10054 DATA "V"          ,214
10055 DATA "W"          ,215
10056 DATA "X"          ,216
10057 DATA "Y"          ,217
10058 DATA "Z"          ,218
10059 DATA "ESC"        ,155
10060 DATA "]"          ,221
10061 DATA "^"          ,222
10062 DATA "<--"        ,136
10063 DATA "-->"        ,149



19999 DATA "CTRL", 0

20000 DATA "[space bar]",160
20001 DATA "!"          ,161
20002 DATA "QUOTE"      ,162
20003 DATA "#"          ,163
20004 DATA "$"          ,164
20005 DATA "%"          ,165
20006 DATA "&"          ,166
20007 DATA "'"          ,167
20008 DATA "("          ,168
20009 DATA ")"          ,169
20010 DATA "*"          ,170
20011 DATA "+"          ,171
20012 DATA ","          ,172
20013 DATA "-"          ,173
20014 DATA "."          ,174
20015 DATA "/"          ,175
20016 DATA "0"          ,176
20017 DATA "1"          ,177
20018 DATA "2"          ,178
20019 DATA "3"          ,179
20020 DATA "4"          ,180
20021 DATA "5"          ,181
20022 DATA "6"          ,182
20023 DATA "7"          ,183
20024 DATA "8"          ,184
20025 DATA "9"          ,185
20026 DATA ":"          ,186
20027 DATA ";"          ,187
20028 DATA "<"          ,188
20029 DATA "="          ,189
20030 DATA ">"          ,190
20031 DATA "?"          ,191
20032 DATA "@"          ,128
20033 DATA "A"          ,129
20034 DATA "B"          ,130
20035 DATA "C"          ,131
20036 DATA "D"          ,132
20037 DATA "E"          ,133
20038 DATA "F"          ,134
20039 DATA "G"          ,135
20040 DATA "H"          ,136
20041 DATA "I"          ,137
20042 DATA "J"          ,138
20043 DATA "K"          ,139
20044 DATA "L"          ,140
20045 DATA "M"          ,141
20046 DATA "N"          ,142
20047 DATA "O"          ,143
20048 DATA "P"          ,144
20049 DATA "Q"          ,145
20050 DATA "R"          ,146
20051 DATA "S"          ,147
20052 DATA "T"          ,148
20053 DATA "U"          ,149
20054 DATA "V"          ,150
20055 DATA "W"          ,151
20056 DATA "X"          ,152
20057 DATA "Y"          ,153
20058 DATA "Z"          ,154
20059 DATA "ESC"        ,155
20060 DATA "]"          ,157
20061 DATA "^"          ,158
20062 DATA "<--"        ,136
20063 DATA "-->"        ,149



29999 DATA "SHIFT", 0
30000 DATA "[space bar]",160
30033 DATA "A"          ,193
30034 DATA "B"          ,194
30035 DATA "C"          ,195
30036 DATA "D"          ,196
30037 DATA "E"          ,197
30038 DATA "F"          ,198
30039 DATA "G"          ,199
30040 DATA "H"          ,200
30041 DATA "I"          ,201
30042 DATA "J"          ,202
30043 DATA "K"          ,203
30044 DATA "L"          ,204
30047 DATA "O"          ,207
30049 DATA "Q"          ,209
30050 DATA "R"          ,210
30051 DATA "S"          ,211
30052 DATA "T"          ,212
30053 DATA "U"          ,213
30054 DATA "V"          ,214
30055 DATA "W"          ,215
30056 DATA "X"          ,216
30057 DATA "Y"          ,217
30058 DATA "Z"          ,218
30059 DATA "ESC"        ,155
30062 DATA "<--"        ,136
30063 DATA "-->"        ,149



39999 DATA "SHIFT+CTRL", 0       
40000 DATA "[space bar]",160
40033 DATA "A"          ,129
40034 DATA "B"          ,130
40035 DATA "C"          ,131
40036 DATA "D"          ,132
40037 DATA "E"          ,133
40038 DATA "F"          ,134
40039 DATA "G"          ,135
40040 DATA "H"          ,136
40041 DATA "I"          ,137
40042 DATA "J"          ,138
40043 DATA "K"          ,139
40044 DATA "L"          ,140
40047 DATA "O"          ,143
40049 DATA "Q"          ,145
40050 DATA "R"          ,146
40051 DATA "S"          ,147
40052 DATA "T"          ,148
40053 DATA "U"          ,149
40054 DATA "V"          ,150
40055 DATA "W"          ,151
40056 DATA "X"          ,152
40057 DATA "Y"          ,153
40058 DATA "Z"          ,154
40059 DATA "ESC"        ,155
40062 DATA "<--"        ,136
40063 DATA "-->"        ,149



63999 DATA "", 0
