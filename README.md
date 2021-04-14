# Compilerschmiede der Gruppe T4

Hier wird an den heißen Brennöfen der ultimative Compiler geschmiedet!  
Mit dabei sind:  
* Daniel (Schmied1)  
* Tobias (Schmied2)  
* Florian (Schmied3)  
* Jens (Schmied4)  
* Jakob (Schmied5)  

## Wie benutzt man dieses Schwert?

> Nur mit Muskeln kommt man halt nicht weiter nh

1. Ihr schreibt euch ein **FILENAME.lex**
2. Im Terminal gebt ihr `./build.sh FILENAME.lex` ein
3. Nun könnt ihr im Terminal `./myexe` ausführen und gebt händisch irgendnen Müll ein oder ihr nehmt den super vorkonfigurierten Scheißbatzen mittels `./myexe < dummy`

## Fortschritt

- [x] Flex benutzt
- [] Bison benutzt
- [] Wat produktives gemacht...

## FAQ

### Es kommt keine "myexe" raus und nirgendwo steht ein Fehler?

In dem Fall tritt der Fehler beim Kompilieren auf.  
Hierzu einfach mal in **build.sh** sich die Zeile mit **gcc** raussuchen und dort  
`gcc lex.yy.c -o myexe 2> /dev/null` mit `gcc lex.yy.c -o myexe` austauschen.
Wem das zu aufwändig ist, darf gerne einen Debugmodus schreiben. :D
