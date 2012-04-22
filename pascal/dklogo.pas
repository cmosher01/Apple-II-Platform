program dk;

  uses
    turtlegraphics;
    
    
  type
    bitmaptype                          = packed array [0..44, 0..31]
                                            of boolean;
    
    
  var
    dk                                  : bitmaptype;
    r                                   : integer;
    nill                                : char;
    
    
  procedure makebitmap (var bitmap : bitmaptype; s : string);
  
    var
      j                         : integer;
      
    begin {procedure makebitmap}
      for j := 0 to length(s)-1 do
        bitmap[r, j] := not (s[j+1] = ' ');
      r := r-1
    end   {procedure makebitmap};
    
    
  procedure makedk1;
      
    begin {procedure makedk1}
      r := 44;
      makebitmap (dk, '              @                 ');
      makebitmap (dk, '             @@@                ');
      makebitmap (dk, '            @ @@@               ');
      makebitmap (dk, '            @ @@@               ');
      makebitmap (dk, '            @ @@@               ');
      makebitmap (dk, '@           @ @@@           @@@@');
      makebitmap (dk, '@@          @ @@@          @@@@@');
      makebitmap (dk, '@@@         @ @@@         @@@@ @');
      makebitmap (dk, '@@@@        @ @@@        @@@@  @');
      makebitmap (dk, '@@@@@       @ @@@       @@@@  @ ');
      makebitmap (dk, '@ @@@@      @ @@@      @@@@  @  ');
      makebitmap (dk, '@ @@@@@     @ @@@     @@@@  @   ');
      makebitmap (dk, '@ @ @@@@    @ @@@    @@@@  @    ');
      makebitmap (dk, '@ @  @@@@   @ @@@   @@@@  @     ');
      makebitmap (dk, '@ @@  @@@@  @ @@@  @@@@  @      ');
      makebitmap (dk, '@ @@@  @@@@ @ @@@ @@@@  @       ');
      makebitmap (dk, '@ @@ @  @@@@@ @@@@@@@  @        ');
      makebitmap (dk, '@ @@  @  @@@@ @@@@@@  @         ');
      makebitmap (dk, '@ @@   @  @@@ @@@@@  @          ');
      makebitmap (dk, '@ @@    @  @@@@@@@  @           ');
      makebitmap (dk, '@ @@     @  @@@@@  @            ');
      makebitmap (dk, '@ @@      @  @@@  @             ');
      makebitmap (dk, '@ @@       @  @  @              ')
    end   {procedure makedk1};
    
    
  procedure makedk2;
  
    begin {procedure makedk2}
      makebitmap (dk, '@ @@      @@@@@@@@@             ');
      makebitmap (dk, '@ @@     @@@@ @ @@@@            ');
      makebitmap (dk, '@ @@    @@@@  @  @@@@           ');
      makebitmap (dk, '@ @@   @@@@   @@  @@@@          ');
      makebitmap (dk, '@ @@  @@@@  @ @@@  @@@@         ');
      makebitmap (dk, '@ @@ @@@@  @@ @@@@  @@@@        ');
      makebitmap (dk, '@ @@@@@@  @ @ @@@ @  @@@@       ');
      makebitmap (dk, '@ @@@@@  @  @ @@@  @  @@@@      ');
      makebitmap (dk, '@ @@@@  @   @ @@@   @  @@@@     ');
      makebitmap (dk, '@ @@@  @    @ @@@    @  @@@@    ');
      makebitmap (dk, '@ @@  @     @ @@@     @  @@@@   ');
      makebitmap (dk, '@ @  @      @ @@@      @  @@@@  ');
      makebitmap (dk, '@   @       @ @@@       @  @@@@ ');
      makebitmap (dk, '@  @        @ @@@        @  @@@@');
      makebitmap (dk, '@ @         @ @@@         @  @@@');
      makebitmap (dk, '@@          @ @@@          @  @@');
      makebitmap (dk, '@           @ @@@           @@@@');
      makebitmap (dk, '            @ @@@               ');
      makebitmap (dk, '            @ @@@               ');
      makebitmap (dk, '            @ @@@               ');
      makebitmap (dk, '             @@@                ');
      makebitmap (dk, '              @                 ')
    end   {procedure makedk2};
    
      
  begin {program dead_kennedys}
    makedk1; makedk2;
    initturtle; drawblock (dk, 4, 0, 0, 32, 45, 131, 84, 14);
    read (nill)
  end   {program dead_kennedys}.
