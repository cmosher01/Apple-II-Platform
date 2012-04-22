program thisway;
uses applestuff;

var
k, j, i, d : integer;

begin
d := 30;
for k := 1 to 2 do begin
for i := 1 to 4 do begin note(20,d*2);note(20,d);note(20,d);note(22,d*2);
                   note(22,d);note(22,d);note(27,d*2);note(27,d);
                   note(27,d);note(27,d);note(27,d);note(27,d);note(27,d) end;
for i := 1 to 2 do begin note(25,d*2);note(25,d);note(25,d);note(25,d);
note(25,d);note(25,d);note(25,d) end;
note(27,d*2);note(27,d);note(27,d);note(27,d);note(27,d);note(27,d);
note(27,d);note(27,d*2);note(27,d);note(27,d);note(20,d*2);note(18,d*2);
for i := 1 to 2 do begin note(25,d*2);note(25,d);note(25,d);note(25,d);
note(25,d);note(25,d);note(25,d) end;
for i := 1 to 2 do begin note(22,d*2);note(22,d);note(22,d);note(22,d);
note(22,d);note(22,d);note(22,d) end;
for i := 1 to 2 do begin 
for j := 1 to 2 do begin note(20,d*2);note(20,d);note(20,d);note(20,d);
                         note(20,d);note(20,d);note(20,d) end;
for j := 1 to 4 do begin note(17,d);note(18,d);note(18,d);note(18,d) end
end;
note(20,d*2);note(20,d);note(20,d);note(20,d);note(20,d);note(20,d);
note(20,d);note(22,d*2);note(22,d);note(22,d);note(22,d);note(22,d);
note(22,d);note(22,d)
end
end
