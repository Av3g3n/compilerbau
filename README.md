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

Die guten Angriffe  werden mit ` FIN=example FOUT=myexe make` ausgeführt. Nun sollte ein handlebares Schwert `myexe` für euch zum Kampf bereitgestellt worden sein. Aktiviert es mit `./myexe` und führt unten gelistete Angriffe aus.
Haltet euch mit `FIN=example FOUT=myexe make clean` den Rücken für weitere neue Schwertgriffe frei.

## Wie benutzt man den Amboss zum Schmieden des Schwertes
Das `make` führt folgende Schritte zum Erstellen des Kompilierers durch.

1. `bison -d example.y` --> erstellt:
    - Headerfile: `example.tab.h`
    - Parser-Quelltext/Syntax Analysierer, wie yyparse: `example.tab.c`

2. `flex example.lex`  --> erstellt:
     - Lexikalischer Analysierer: `lex.yy.c`
       
3. `cc example.tab.c lex.yy.c -o myexe` --> erstellt:
      - Ausführbare Kompilierer: `myexe`

## Aktuell erlernte Angriffe
Das Schwert ist in der Lage verschiedene Mathematische Angriffe auf Integerzahlen durchzuführen, hierzu gehören die Grundoperationen wie:
- Addition(+)
- Subtraktion(-)
- Multiplikation(*)
- Division(/)

Die Wirksamkeit des Angriffes erscheint dann in der darauf folgenden Zeile.
## Fortschritt

- [x] Flex benutzt
- [x] Bison benutzt
- [ ] Full Integration of the Jugend
- [ ] Wat Produktives gemacht...

## FAQ

### Es kommt keine "myexe" raus und nirgendwo steht ein Fehler?

In dem Fall tritt der Fehler beim Kompilieren auf.  
Hierzu einfach mal in **build.sh** sich die Zeile mit **gcc** raussuchen und dort  
`gcc lex.yy.c -o myexe 2> /dev/null` mit `gcc lex.yy.c -o myexe` austauschen.
Wem das zu aufwändig ist, darf gerne einen Debugmodus schreiben. :D
