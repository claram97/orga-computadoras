# orga-computadoras

## Enunciado:
### Líneas ferroviarias Light
* Se tiene una lista de estaciones de ferrocarril. A efectos de simplificar, los nombres de las estaciones han sido reemplazados por 1, 2, ..., n-1, n donde n <= 20 es el número total de estaciones. Se tiene, además, una lista de los tramos de vía que unen, directamente entre sí, estaciones contiguas. Los tramos de vía pueden utilizarse en ambos sentidos.
Escribir un programa en assembler Intel 80x86 que lea n y la lista de tramos. Luego, agrupar las estaciones en líneas, donde una línea se define como un conjunto de estaciones alcanzables entre sí, y listarlas.
Ejemplo:
**Input:
n = 9 y los tramos son (8,1), (3,6), (4,9), (1,7), (2,7), (1,4), (5,4) y (1,9)
**Output:
Línea 1: 1 2 4 5 7 8 9
Línea 2: 3 6


##Sobre los archivos de prueba:
Cada caso viene con sus respectivos archivos binarios, de extensión .dat, que contienen:
*La lista de estaciones, que servirá para determinar el número máximo de las mismas a considerar en el programa.
El programa lee la lista y determina el número máximo.
*La lista de tramos, es decir, la lista de uniones entre una estación y otra.
En algunos casos, la lista de tramos incluirá la relación tanto de los pares (i,j) como de los pares (j,i).
En otros casos, la lista de tramos incluirá únicamente la relación entre los pares (i,j).
El programa funciona bien para ambos casos.
*Una imágen .png del grafo a considerar. Esto permitirá ver más fácilmente qué salida se espera en cada caso.

##Qué se espera de la salida de este programa:
*Los nodos aislados no contarán como líneas, ya que una línea de tren precisa de, por lo menos, dos estaciones conectadas entre sí.
*Se imprimirán las líneas en el siguiente formato:
"Linea A: a b c Linea B: e d"
Esto quiere decir que hay un subgrafo que conecta los nodos a b y c, y otro que conecta los nodos e y d, donde a, b, c, d y e son números de estaciones.
