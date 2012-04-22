
                                                 
                                  {  C r y p t o g r a p h e r  }
                                                 
                                                 
                                                 
                                                 
                                                 
                                                 
                                                 
                                                 
                                                 
                                                 
                                { author : Christopher A. Mosher }
                                { date   : April 23, 1984        }
                                { file   : utility:crypt.code    }
{$P}

program cryptographer;


  const
    sp = ' ';
    
    
  type
    stringmax                   = string[255];
    component                   = array [1..95] of integer;
    alphabet                    = record
                                    plain  : component;
                                    cipher : component
                                  end {record};
    filename                    = string[23];
    key                         = stringmax;
    process                     = (encrypt, decrypt);
    response                    = string[1];
    message                     = string[9];
    
    
  var
    systerm                     : file of char;
    fi, fo                      : filename;
    resp                        : response;
    key1, key2                  : key;
    alph                        : alphabet;
    proc                        : process;
    msg                         : message;
    i                           : integer;
{$P}
  
  function posis(int : integer; st : stringmax) : integer;
  
    var
      i_p, p_p          : integer;
      
    begin {function posis}
      p_p := 0; i_p := 1;
      while (i_p <= length(st)) and (p_p = 0) do
        begin
          if int = ord(st[i_p]) mod 128
            then
              p_p := i_p;
          i_p := i_p+1
        end   {while do};
      posis := p_p
    end   {function posis};
{$P}

  function posii(int : integer; ia : component) : integer;
  
    var
      i_p, p_p          : integer;
      
    begin {function posii}
      p_p := 0; i_p := 1;
      while (i_p <= 95) and (p_p = 0) do
        begin
          if int = ia[i_p]
            then
              p_p := i_p;
          i_p := i_p+1
        end    {while do};
      posii := p_p
    end   {function posii};
{$P}

  procedure fixkey (var key_f : key);
  
    var
      ii_f, j_f          : integer;
      
    begin {procedure fixkey}
      for ii_f := 1 to length(key_f)-1 do
        for j_f := ii_f+1 to length(key_f) do
          if key_f[ii_f] = key_f[j_f]
            then
              key_f[j_f] := sp;
      ii_f := pos(sp, key_f);
      while ii_f <> 0 do
        begin
          delete (key_f, ii_f, 1);
          ii_f := pos(sp, key_f)
        end   {while ii_f <> 0 do}
      end   {procedure fixkey};
{$P}

  procedure initalphabet (var alph_i : alphabet; key1_i, key2_i : key);
    
    var
      i_i, j_i,      
      c_i, ofs_i        : integer;
      used              : boolean;
      newcipher         : component;
      
    begin {procedure initalphabet}
      with alph_i do
        begin
          for i_i := 1 to length(key1_i) do
            plain[i_i] := ord(key1_i[i_i]) mod 128;
          for i_i := 1 to length(key2_i) do
            cipher[i_i] := ord(key2_i[i_i]) mod 128;
          i_i := length(key1_i)+1;
          for c_i := 32 to 126 do
            if posis(c_i, key1_i) = 0
              then
                begin
                  plain[i_i] := c_i;
                  i_i := i_i+1
                end   {then};
          i_i := length(key2_i)+1;
          for c_i := 32 to 126 do
            if posis(c_i, key2_i) = 0
              then
                begin
                  cipher[i_i] := c_i;
                  i_i := i_i+1
                end   {then};
          ofs_i := posii(65, plain);
          for i_i := 1 to 96-ofs_i do
            newcipher[i_i+ofs_i-1] := cipher[i_i];
          if ofs_i <> 1
            then
              for i_i := 97-ofs_i to 95 do
                newcipher[i_i+ofs_i-96] := cipher[i_i];
          cipher := newcipher
        end   {with alph_i do}
    end   {procedure initalphabet};
{$P}
    
  procedure cryptfile (fi_c, fo_c : filename; alph_c : alphabet;
                       proc_c :process);
  
    var
      inf_c, outf_c     : file of char;
      l                 : record
                            p : integer;
                            c : integer
                          end {record};
      ch, ln            : integer;
      
    begin {procedure cryptfile}
      ch := 0; ln := 0;
      reset (inf_c, fi_c);
      rewrite (outf_c, fo_c);
      page (output); gotoxy (0, 10);
      writeln ('Cryptographer [1.1]');
      writeln; writeln (fi_c); write ('<   0>');
      while not eof(inf_c) do
        begin
          while not (eoln(inf_c) or eof(inf_c)) do
            begin
              case proc_c of
                encrypt : begin
                            l.p := ord(inf_c^) mod 128;
                            l.c := alph_c.cipher[posii(l.p, alph_c.plain)];
                            outf_c^ := chr(l.c)
                          end   {encrypt};
                decrypt : begin
                            l.c := ord(inf_c^) mod 128;
                            l.p := alph_c.plain[posii(l.c, alph_c.cipher)];
                            outf_c^ := chr(l.p)
                          end   {decrypt}
              end   {case proc_c of};
              ch := ch+1;
              put (outf_c); get (inf_c)
            end   {while not (eoln or eof) do};
          writeln (outf_c);
          ln := ln+1;
          write ('.');
          if ln mod 30 = 0
            then
              begin
                writeln; write ('<', ln:4, '>')
              end   {then};
          get (inf_c)
        end   {while not eof do};
      close (outf_c, lock);
      writeln; writeln;
      writeln (ch, ' characters in ', ln, ' lines.');
      writeln
    end   {procedure cryptfile};
{$P}

  begin {program cryptographer}
    rewrite (systerm, 'systerm:');
    page (output); gotoxy (0, 10);
    write ('Enter  input filename: '); readln (fi);
    write ('Enter output filename: '); readln (fo);
    repeat {until pos(resp, 'EeDd') > 0}
      write ('Encrypt or decrypt? (e, d): '); readln (resp);
      writeln;
    until pos(resp, 'EeDd') > 0;
    write ('Enter specific key: ');
    readln (systerm, key1); readln (systerm, key2);
    fixkey (key1); fixkey (key2);
    if (resp = 'E') or (resp = 'e')
      then
        proc := encrypt
      else
        proc := decrypt;
    with alph do
      for i := 1 to 95 do
        begin
          plain[i] := 0;
          cipher[i] := 0
        end   {for i := 1 to 95 do};
    initalphabet (alph, key1, key2);
    cryptfile (fi, fo, alph, proc);
    case proc of
      encrypt : msg := 'encrypted';
      decrypt : msg := 'decrypted'
    end   {case proc of};
    writeln (fi, sp, msg, ' to ', fo, '.')
  end   {program cryptographer}.
