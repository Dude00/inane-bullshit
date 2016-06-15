calc: calc.y calc.lex
	bison -d calc.y
	flex  -o calc.lex.c calc.lex
	g++ -std=gnu++11 -O3 -L C:\MinGW\msys\1.0\lib -o dudebot calc.lex.c calc.tab.c Dice.cc -lfl -lm -lWS2_32