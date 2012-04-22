SET CC65_HOME=C:\apple2\windows_programs\assemblers\cc65
SET CC65DIR=%CC65_HOME%\bin

rem "%CC65DIR%\ca65" -v -l -t apple2 -o hrf040.o65 hrf040.s65
rem "%CC65DIR%\ld65" -v -C hrf040.ld65config -m hrf040.map hrf040.o65

"%CC65DIR%\ca65" -v -l -t apple2 -o hrf070.o65 hrf070.s65
"%CC65DIR%\ld65" -v -C hrf070.ld65config -m hrf070.map hrf070.o65
