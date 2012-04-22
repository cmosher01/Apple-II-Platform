
{       John H. Conway's Game of Life


        author : Christopher A. Mosher
        date   : May 2, 1984
        file   : user1:life
        
        
                John H. Conway invented a game which he claims  models  the
                
        genetic  laws for birth, survival, and death.  Sometimes called the
        
        "game of life," it is played on a two dimensional grid.  Initially,
        
        each square on the grid is either occupied by  an  organism  or  is
        
        vacant.   The  following  laws  for future generations of organisms
        
        are inherent:
        
                1. Birth    : An organism will be born in each 
                              vacant square which has  exactly
                              three neighbors.
                              
                2. Survival : An organism with  two  or  three
                              neighbors  will  survive  to the
                              next generation.
                              
                3. Death    : An  organism  with  four or more
                              neighbors will die of overcrowd-
                              ing.  An organism with less than
                              two   neighbors   will   die  of
                              loneliness.
                              
        This  program  allows  for  the entry of the grid size (up to 10 by
        
        10), and of the  organisms  of  the  initial  grid,  generation  0.
        
        The  program will then continue by printing subsequent generations,
        
        pausing after each for a keypress, until ^Z is typed.
        
        
}


program life;
  
  
  {     declaration of intrinsic units used
  }
  
  
  uses
    turtlegraphics;
  
  
  {     declaration of constants
  }
  
  
  const
    vacant                              = ' ';
    occupied                            = 'x';
    
    
  {     declaration of types
  }
  
  
  type
    coordinate                          = 1..10;
    organism                            = char;
    orgnsmtbl                           = array [0..11, 0..11] of organism;
    
    
  {     declaration of variables
  }
  
  
  var
    r, c, x, y                          : coordinate;
    i, j                                : integer;
    longgen                             : integer[3];
    grid, newgrid                       : orgnsmtbl;
    nill                                : char;
    
    
  {     procedure initgrid
  }
  
  
  procedure initgrid (n_g, m_g : coordinate);
  
    var
      i_g                       : integer;
      
    begin {procedure initgrid}
      initturtle;
      for i_g := 0 to n_g do
        begin
          pencolor (none); moveto (0, 19*i_g);
          pencolor (white); moveto (27*m_g, 19*i_g)
        end   {for i_g := 0 to n_g do};
      for i_g := 0 to m_g do
        begin
          pencolor (none); moveto (27*i_g, 0);
          pencolor (white); moveto (27*i_g, 19*n_g)
        end   {for i_g := 0 to m_g do};
      pencolor (none)
    end   {procedure initgrid};
    
    
  {     procedure populate
  }
  
  
  procedure populate (var grid_p : orgnsmtbl);
  
    var
      i_p, j_p                  : coordinate;
      gen_p                     : string[4];
      
    begin {procedure populate}
      for i_p := 1 to r do
        for j_p := 1 to c do
          begin
            moveto (27*(j_p-1)+11, 19*(r-i_p)+7);
            wchar (grid_p[i_p, j_p])
          end   {for i_p := 1 to r do for j_p := 1 to c do};
      moveto (83, 0);
      str (longgen, gen_p);
      wstring (concat(' generation ', gen_p, ' '))
    end   {procedure populate};
    
    
  {     function neighbors
  }
  
  
  function neighbors(grid_n : orgnsmtbl; p_n, q_n : coordinate) : integer;
  
    var
      n_n                       : 0..8;
      
    begin {function neighbors}
      n_n := 0;
      if grid_n[p_n-1, q_n-1] = occupied then n_n := n_n+1;
      if grid_n[p_n-1, q_n  ] = occupied then n_n := n_n+1;
      if grid_n[p_n-1, q_n+1] = occupied then n_n := n_n+1;
      if grid_n[p_n  , q_n-1] = occupied then n_n := n_n+1;
      if grid_n[p_n  , q_n+1] = occupied then n_n := n_n+1;
      if grid_n[p_n+1, q_n-1] = occupied then n_n := n_n+1;
      if grid_n[p_n+1, q_n  ] = occupied then n_n := n_n+1;
      if grid_n[p_n+1, q_n+1] = occupied then n_n := n_n+1;
      neighbors := n_n
    end   {function neighbors};
    
    
  {     main program
  }
  
  
  begin {program lab15m}
    
    {initialize variables}
    for i := 0 to 11 do
      for j := 0 to 11 do
        grid[i, j] := vacant;
    newgrid := grid;
    
    {enter initial grid}
    page (output); gotoxy (0, 10);
    write ('Enter dimensions of grid (rows <sp> columns): '); readln (r, c);
    if eof
      then
        halt;
    writeln; writeln ('Enter coordinates of original organisms: (0 0 to stop)');
    write ('row <sp> col: '); readln (x, y);
    repeat {until (x = 0) and (y = 0)}
      if (x <= r) and (y <= c) and (x > 0) and (y > 0)
        then
          grid[x, y] := occupied
        else
          writeln ('Illegal entry; re-enter: ');
      write ('row <sp> col: '); readln (x, y)
    until (x = 0) and (y = 0);
    
    {output grid for generation 0}
    page (output);
    initgrid (r, c);
    longgen := 0;
    populate (grid);
    read (nill);
    
    {output grid for subsequent generations}
    repeat {until eof}
      longgen := longgen+1;
      for i := 1 to r do
        for j := 1 to c do
          case grid[i, j] of
            vacant   : case neighbors(grid, i, j) of
                         0,1,2,4,5,6,7,8 : newgrid[i, j] := vacant;
                         3               : newgrid[i, j] := occupied
                       end   {case neighbors of};
            occupied : case neighbors(grid, i, j) of
                         0,1,4,5,6,7,8   : newgrid[i, j] := vacant;
                         2,3             : newgrid[i, j] := occupied
                       end   {case neighbors of}
          end   {case grid of};
      grid := newgrid;
      populate (grid);
      read (nill)
    until eof
  
  end   {program lab15m}.
