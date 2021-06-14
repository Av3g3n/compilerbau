# Compilerschmiede T4

Hier wurde an den heißen Brennöfen der ultimative Compiler geschmiedet!  
Mit dabei waren:
* Bossschmied Jakob 
>" Ob mirs gelang, bei Tag und Nacht, mein eignes Glück zu schmieden? Oft hab’ ich andre froh gemacht, mein Lohn war Schweiß und Frieden."
* Daniel (Schmied1)  
* Tobias (Schmied2)  
* Florian (Schmied3)  
* Jens (Schmied4)  


## Wie benutzt man dieses Schwert?

> Nur mit Muskeln kommt man halt nicht weiter nh

Das Schwert kann mit folgenden Kommandos auf der Kommandozeile gezogen werden:
- ` ./t4compiler`

Folgende zusätzliche Optionen können die Präzision der Klinge verbessern:
- `-h` : Zeigt alle verfügbaren Optionen
- `-v` : Verbose , bzw Debug-Mode(scharfe präzise Klinge) 


## Wie benutzt man den Amboss zum Schmieden des Schwertes
Bevor das make ausgeführt werden kann muss man export FMODE=interpreter/parsetree ausführen.

Das `make` führt folgende Schritte zum Erstellen des Kompilierers durch.

1. `bison -d t4_parser_gen.y` --> erstellt:
    - Headerfile: `t4_parser_gen.tab.h`
    - Parser-Quelltext/Syntax Analysierer, wie yyparse: `example.tab.c`

2. `flex t4_analyzer.lex`  --> erstellt:
     - Lexikalischer Analysierer: `lex.yy.c`
       
3. `	gcc t4_parser_gen.tab.c lex.yy.c t4_F.c -o t4compiler -lm
      - Führbares Schwert(Kompilierer): `t4compiler` 

## Die verschiedenen Schwertangriffe
- Das Schwert ist in der Lage die Grundrechenoperationen auszuführen(Addition, Subtraktion, Multiplikation und Division).
- Variablen werden wie folgt deklariert: ` z = 12;`
- Eine Variable kann mit `hau_raus VAR;` ausgegeben werden
- IF-ELSE-Konditionen werden wie folgt benutzt: 	
```
wenn(z==3){
	CODE;
}
sonst {
	MORECODE;
}
```

- Schleifen können auf die Folgende Art benutzt werden:

```
schleife(z>0){
	hau_raus z;
	z = z - 1;
}

```

Die Wirksamkeit eines Angriffes erscheint dann in der darauf folgenden Zeile.
## Fortschritt
Lexikalische Analyse
-----------------------------------------
Identifier Integer-Literale				```check```
- Zuweisungszeichen			
	-- Symbole für Grundrechenarten
	-- Klammern					```check```
- Kontrollstrukturen
	-- Keyowrds( 'wenn'|'wenn sonst'|'schleife'|'global')	```check```

Syntaktische Analyse
-----------------------------------------
- Erkennen korrekter Deklarationen			```check```
- korrekte Folge von Wertzuweisungen		
    -- Vollständig geklammerte Expression	
    -- Unvollständig geklammerte Expression		```check```
- Erkennen korrekter geschachtelter
  Kontrollstrukturen					```check```

Semantische Analyse
-----------------------------------------
- Erkennen mehrfacher Deklarationen
  des gleichen Identifiers				```check```

Code-Generierung
-----------------------------------------
- Speicherung in geeigneter Datenstruktur		
	- Erweiterung Syntaxbaum			```check```

Simulation Syntaxbaum
-----------------------------------------
- Ausdruck des Syntaxbaums				```check```

## FAQ


