Write-Output DELETING...
Remove-Item -Path .\build\*

Write-Output BUILDING...
bison -d .\src\analyzer.y
Move-Item -Path .\analyzer.tab.c -Destination .\build
Move-Item -Path .\analyzer.tab.h -Destination .\build
flex .\src\analyzer.l
Move-Item -Path .\lex.yy.c -Destination .\build
g++ .\build\analyzer.tab.c .\build\lex.yy.c -o .\build\analyzer
