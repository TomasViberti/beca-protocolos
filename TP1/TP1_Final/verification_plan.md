TP1: Principios de la verificación

Componentes: 
i_switch[0]
i_switch[2:1]
i_switch[3]
clock
reset

Test Plan:

1- Test enable: En un momento random desactivar el enable y ver que los leds no cambien de color.

2- Clock: cae el clock y el diseño quede estático.

3- Limites de cuenta: reset -> i_switch[2:1] = 0,1,2,3 y verificar el periodo en que cambian los leds.

4- Limites de cuenta random.

5- Test de cambio de color de leds.
   
6- Test reset.

7- Test de randomizar todos los componentes.


Tip: Para verificación no hay una regla para utilizar tipeo bloqueante o no bloqueante. Esas reglas se siguen en diseño.

Si estoy testeando en caja negra, debo poder verificar con las salidas de mi sistema. De este modo no es recomendable usar las variables internas para verificar comportamiento, por ejemplo el counter interno.

