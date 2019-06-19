echo BUILDING...

bison -d task.y
flex task.l
g++ task.tab.c lex.yy.c -o test

echo BUILT