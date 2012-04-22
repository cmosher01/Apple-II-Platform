
                             {  C a l e n d a r  }
                                       
                                       
                    { author      : Christopher A. Mosher }
                    { date        : April 2, 1984         }
                    { source file : utility:calendar.text }
                                       
                                       
program calendar;
  
  
  uses turtlegraphics;
  
  
  type
    month                       = (january  , february, march   , april   ,
                                   may      , june    , july    , august  ,
                                   september, october , november, december,
                                   illegal                                 );
    year                        = record
                                    n   : integer;
                                    era : string[2]
                                    end {record};
    string2                     = string[2];
    string9                     = string[9];
  
  
  var
    mo                          : month;
    yr                          : year;
    nill                        : char;
    monthstr                    : array [january..december] of string9;
    days_in, days_in_jl,
    adday  , adday_jl  ,
    addayl , addayl_jl          : array [january..december] of integer;


  procedure init_var1;
    
    begin {procedure init_var1}
      monthstr[  january] := 'January';
      monthstr[ february] := 'February';
      monthstr[    march] := 'March';
      monthstr[    april] := 'April';
      monthstr[      may] := 'May';
      monthstr[     june] := 'June';
      monthstr[     july] := 'July';
      monthstr[   august] := 'August';
      monthstr[september] := 'September';
      monthstr[  october] := 'October';
      monthstr[ november] := 'November';
      monthstr[ december] := 'December'
    end   {procedure init_var1};
  
  
  procedure init_var2;
    
    begin {procedure init_var2}
      days_in[  january] := 31;         days_in_jl[  january] := 31;
      days_in[ february] := 28;         days_in_jl[ february] := 29;
      days_in[    march] := 31;         days_in_jl[    march] := 31;
      days_in[    april] := 30;         days_in_jl[    april] := 30;
      days_in[      may] := 31;         days_in_jl[      may] := 31;
      days_in[     june] := 30;         days_in_jl[     june] := 30;
      days_in[     july] := 31;         days_in_jl[     july] := 31;
      days_in[   august] := 31;         days_in_jl[   august] := 30;
      days_in[september] := 30;         days_in_jl[september] := 31;
      days_in[  october] := 31;         days_in_jl[  october] := 30;
      days_in[ november] := 30;         days_in_jl[ november] := 31;
      days_in[ december] := 31;         days_in_jl[ december] := 30
    end   {procedure init_var2};
  
  
  procedure init_var3;
    
    begin {procedure init_var3}
      adday[  january] := 0;            addayl[  january] := 0;
      adday[ february] := 3;            addayl[ february] := 3;
      adday[    march] := 3;            addayl[    march] := 4;
      adday[    april] := 6;            addayl[    april] := 0;
      adday[      may] := 1;            addayl[      may] := 2;
      adday[     june] := 4;            addayl[     june] := 5;
      adday[     july] := 6;            addayl[     july] := 0;
      adday[   august] := 2;            addayl[   august] := 3;
      adday[september] := 5;            addayl[september] := 6;
      adday[  october] := 0;            addayl[  october] := 1;
      adday[ november] := 3;            addayl[ november] := 4;
      adday[ december] := 5;            addayl[ december] := 6
    end   {procedure init_var3};
  
  
  procedure init_var4;
    
    begin {procedure init_var4}
      adday_jl[  january] := 0;         addayl_jl[  january] := 0;
      adday_jl[ february] := 3;         addayl_jl[ february] := 3;
      adday_jl[    march] := 4;         addayl_jl[    march] := 5;
      adday_jl[    april] := 0;         addayl_jl[    april] := 1;
      adday_jl[      may] := 2;         addayl_jl[      may] := 3;
      adday_jl[     june] := 5;         addayl_jl[     june] := 6;
      adday_jl[     july] := 0;         addayl_jl[     july] := 1;
      adday_jl[   august] := 3;         addayl_jl[   august] := 4;
      adday_jl[september] := 5;         addayl_jl[september] := 6;
      adday_jl[  october] := 1;         addayl_jl[  october] := 2;
      adday_jl[ november] := 3;         addayl_jl[ november] := 4;
      adday_jl[ december] := 6;         addayl_jl[ december] := 0
    end   {procedure init_var4};
  
  
  procedure init_screen;
  
    var
      i_i       : integer;
      
    begin {procedure init_screen}
      initturtle;
      for i_i := 0 to 6 do
        begin
          pencolor (none); moveto (35, 20*i_i);
          pencolor (white); moveto (245, 20*i_i)
        end   {for i_i := 0 to 6 do};
      for i_i := 0 to 7 do
        begin
          pencolor (none); moveto (30*i_i+35, 0);
          pencolor (white); moveto (30*i_i+35, 120)
        end   {for i_i := 0 to 7 do};
      pencolor (white)
    end   {procedure init_screen};
    
    
  procedure cap(var era_c : string2);
  
    var
      i_c     : integer;
  
    begin {procedure cap}
      for i_c := 1 to 2 do
        if era_c[i_c] in ['a'..'z']
          then
            era_c[i_c] := chr(ord(era_c[i_c])-32)
    end   {procedure cap};
    
    
  procedure caplow(var mo_c : string9);
  
    var
      i_c       : integer;
      
    begin {procedure caplow}
      if mo_c[1] in ['a'..'z']
        then
          mo_c[1] := chr(ord(mo_c[1])-32);
      for i_c := 2 to length(mo_c) do
        if mo_c[i_c] in ['A'..'Z']
          then
            mo_c[i_c] := chr(ord(mo_c[i_c])+32)
    end   {procedure caplow};
    
    
  function legal(mo_l : month; yr_l : year) : boolean;
  
    begin {function legal}
      legal := false;
      with yr_l do
        if (mo_l in [january..december]) and (n > 0) and
           ((n < 10000) and (era = 'AD') or (n < 46) and (era = 'BC'))
          then
            legal := true
    end   {function legal};
    
    
  procedure read_moyr;
  
    var
      i_r       : month;
      moipt     : string9;
      fd        : boolean;
      
    begin {procedure read_moyr}
      repeat {until legal}
        page (output); gotoxy (0, 10);
        write ('Enter month: '); readln (moipt);
        if eof
          then
            exit (read_moyr);
        write ('Enter year: '); readln (yr.n);
        if eof
          then
            exit (read_moyr);
        write ('AD or BC? '); readln (yr.era);
        caplow(moipt); cap(yr.era);
        fd := false;
        for i_r := january to december do
          if moipt = monthstr[i_r]
            then
              begin
                mo := i_r;
                fd := true
              end   {then};
        if not fd
          then
            mo := illegal
        until legal(mo, yr)
    end   {procedure read_moyr};
    
    
  function leap(yr_l : year) : boolean;
  
    begin {function leap}
      leap := false;
      with yr_l do
        if era = 'BC'
          then
            begin
              if (9 <= n) and (n <= 45) and (n mod 3 = 0)
                then
                  leap := true
            end   {then}
          else
            begin
              if (8 <= n) and (n <= 1751) and (n mod 4 = 0)
                then
                  leap := true;
              if (1752 <= n) and (n <= 9999) and
                 (((n mod 4 = 0) and (n mod 100 <> 0))
                  or (n mod 400 = 0))
                then
                  leap := true
            end   {else}
    end   {function leap};
    
    
  function first_day(yr_f : year; mo_f : month) : integer;
  
    var
      d_f       : integer;
      
    begin {function first_day}
      with yr_f do
        if era = 'BC'
          then
            begin
              if (1 <= n) and (n <= 8)
                then
                  d_f := 8-n;
              if (9 <= n) and (n <= 45)
                then
                  d_f := (3-n-n div 3) mod 7
            end   {then}
          else
            begin
              if (1 <= n) and (n <= 7)
                then
                  d_f := n;
              if (8 <= n) and (n <= 1751)
                then
                  d_f := (n mod 7 - n div 4 - 1) mod 7;
              if n = 1752
                then
                  begin
                    if mo_f < september
                      then
                        d_f := 4;
                    if mo_f > september 
                      then
                        d_f := 7
                  end   {then};
              if (1753 <= n) and (n <= 9999)
                then
                  begin
                    d_f := (n mod 7 + n div 4 - n div 100 +
                            n div 400 + 1) mod 7;
                    if ((n mod 4 = 0) and (n mod 100 <> 0)) or (n mod 400 = 0)
                      then
                        d_f := d_f-1
                  end   {then}
            end   {else};
      if d_f = 0
        then
          d_f := 7;
      first_day := d_f
    end   {function first_day};
    
    
  procedure sept1752;
  
    var
      d         : integer;
      dl        : integer[2];
      dn        : string[2];
      
    begin {procedure sept1752}
      dl := 0;
      for d := 1 to 2 do
        begin
          dl := dl+1;
          moveto (80+d*30, 107);
          str (dl, dn); wstring (dn)
        end   {for d := 1 to 2 do};
      dl := 13;
      for d := 14 to 30 do
        begin
          dl := dl+1;
          moveto ((d-10) mod 7*30+44, (5-(d-10) div 7)*20+7);
          str (dl, dn); wstring (dn)
        end   {for d := 14 to 30 do};
      read (nill)
    end   {procedure sept1752};
    
    
  procedure draw_calendar (day_d : integer; mon_d : month; yr_d : year);
  
    var
      title     : string[18];
      yearstr   : string[4];
      d         : integer;
      dl        : integer[2];
      dn        : string[2];
      days_in_d : integer;
      adday_d,
      l_d       : integer;
      
    begin {procedure draw_calendar}
      init_screen;
      str (yr_d.n, yearstr);
      if yr_d.era = 'BC'
        then
          title := concat(monthstr[mon_d], ', ', yearstr, ' BC')
        else
          title := concat(monthstr[mon_d], ', AD ', yearstr);
      moveto (140-7*length(title) div 2, 170); wstring (title);
      moveto ( 47, 135); wchar ('S');   moveto ( 77, 135); wchar ('M');
      moveto (107, 135); wchar ('T');   moveto (137, 135); wchar ('W');
      moveto (167, 135); wchar ('T');   moveto (197, 135); wchar ('F');
      moveto (227, 135); wchar ('S');
      if (yr_d.n = 1752) and (mon_d = september)
        then
          begin
            sept1752;
            exit (draw_calendar)
          end   {then};
      if (yr_d.era = 'BC') or ((1 <= yr_d.n) and (yr_d.n <= 7))
        then
          begin
            days_in_d := days_in_jl[mon_d];
            if leap(yr_d)
              then
                begin
                  adday_d := addayl_jl[mon_d];
                  l_d := 0;
                  if mon_d = february
                    then
                      l_d := 1
                end   {then}
              else
                begin
                  adday_d := adday_jl[mon_d];
                  l_d := 0
                end   {else}
          end   {then}
        else
          begin
            days_in_d := days_in[mon_d];
            if leap(yr_d)
              then
                begin
                  adday_d := addayl[mon_d];
                  l_d := 0;
                  if mon_d = february
                    then
                      l_d := 1;
                end   {then}
              else
                begin
                  adday_d := adday[mon_d];
                  l_d := 0
                end   {else}
          end   {else};
      dl := 0;
      for d := 1 to days_in_d+l_d do
        begin
          dl := dl+1;
          moveto (((d+day_d+adday_d-2) mod 7)*30+44,
                  (5-(d+(day_d+adday_d) mod 7-2) div 7)*20+7);
          str (dl, dn); wstring (dn)
        end   {for d := 1 to days_in_d+l_d do};
      read (nill)
    end   {procedure draw_calendar};
    
    
  begin {program calendar}
    init_var1; init_var2; init_var3; init_var4;
    read_moyr;
    while not eof do
      begin
        draw_calendar (first_day(yr, mo), mo, yr);
        textmode;
        read_moyr
      end   {while not eof do};
    page (output)
  end   {program calendar}.
