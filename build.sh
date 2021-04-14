#!/bin/bash

function removeFiles {
	rm lex.yy.c
	rm myexe
}

function clearFiles {
	echo -e "Clear created files?"
        read -p '[Y/n]: ' CHOICE
        case "$CHOICE" in
                [yY][eE][sS]|[yY]|"") removeFiles ;;
                [nN][oO]|[nN]) ;;
                *)      echo -e "\nwrong input!"
                                clearData ;;
	esac
}

clearFiles

echo "create lex.yy.c"
flex $1

echo -e "compile lex.yy.c to file \"myexe\""
gcc lex.yy.c -o myexe 2> /dev/null
