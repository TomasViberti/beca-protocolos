TP1: Principios de la verificación

Componentes: 
i_switch[0]
i_switch[2:1]
i_switch[3]
clock
reset

Test Plan:

1- Test enable: En un momento random desactivar el enable y ver que los leds no cambien de color
2- Clock: cae el clock y el diseño quede estático
3- Limites de cuenta: reset -> i_switch[2:1] = 0,1,2,3 y verificar el periodo en que cambian los leds.
4- Limites de cuenta random
5- Test de cambio de color de leds
6- Test reset
7- Test de randomizar todos los componentes


Tip: Para verificación no hay una regla para utilizar tipeo bloqueante o no bloqueante. Esas reglas se siguen en diseño.


Al tener dos flip flops conectados entre si con lógica combinacional entre estos dos, surge la posibilidad de una Violacion de Tiempo. Si el tiempo que tarda la señal en atravesar mi circuito es mayor al periodo del clock, se puede perder información entre los flip flops o incluso que salga duplicada por valores que coinciden.

Por otro lado, cada clock tiene su tiempo de setup y su tiempo de hold. El tiempo de setup es el tiempo antes de que cambie de flanco el clock (en nuestro caso siempre en el posedge) en el que la señal que llega al flip flop ya tiene que estar establecida. En cambio el tiempo de hold es el tiempo que la señal tiene que permanecer estable luego de que cambio el flanco. Si la señal no llega establecida antes del tiempo de setup o si la señal cambia antes de que pase el tiempo de hold, se produce el fenómeno conocido como violacion de tiempo.

Definir metaestabilidad

Graycoding 

El reset es asíncrono, y al levantarlo, se busca que sea síncrono. Esto se logra poniendo siempre un 1 en la entrada de mi sincronizador (dos flip flops en cascada). De esta forma la metaestabilidad se da adentro del sincronizador pero a la salida del mismo ya no.