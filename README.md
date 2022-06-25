# orga-computadoras

Sobre los archivos de prueba:
Cada caso viene con sus respectivos archivos binarios, de extensión .dat, que contienen:
-La lista de estaciones, que servirá para determinar el número máximo de las mismas a considerar en el programa.
El programa lee la lista y determina el número máximo.
-La lista de tramos, es decir, la lista de uniones entre una estación y otra.
En algunos casos, la lista de tramos incluirá la relación tanto de los pares (i,j) como de los pares (j,i).
En otros casos, la lista de tramos incluirá únicamente la relación entre los pares (i,j).
El programa funciona bien para ambos casos.
-Una imágen .png del grafo a considerar. Esto permitirá ver más fácilmente qué salida se espera en cada caso.

Qué se espera de la salida de este programa:
-Los nodos aislados no contarán como líneas, ya que una línea de tren precisa de, por lo menos, dos estaciones conectadas entre sí.
-Se imprimirán las líneas en el siguiente formato:
"Linea A: a b c Linea B: e d"
Esto quiere decir que hay un subgrafo que conecta los nodos a b y c, y otro que conecta los nodos e y d, donde a, b, c, d y e son números de estaciones.
