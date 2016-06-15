IF EXIST calc.lex (
	del calc.lextemp /f /q
	copy /Y calc.lex calc.lextemp
) ELSE (
	copy /Y calc.lextemp calc.lex
	del calc.tab.h /f /q
	del calc.tab.c /f /q
	del calc.lex.c /f /q
)
make