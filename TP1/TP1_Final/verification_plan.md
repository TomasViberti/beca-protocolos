TP1: Principios de la verificación

Componentes: 
i_switch[0]
i_switch[2:1]
i_switch[3]
clock
reset

Test Plan:

1- Test enable: En un momento random desactivar el enable y ver que los leds no cambien de color.
   - **Propuesta:** (Ya implementada en TEST1). Correr un bucle de N iteraciones simulando un reinicio general. Luego, habilitar el sistema (`i_sw[0]=1`), esperar un periodo de tiempo aleatorio para que avance y apagar el conteo (`i_sw[0]=0`). Capturar en una variable temporal la salida actual de `o_led` y verificar en un lazo continuo durante tiempos asimétricos (ej. de 50 a 500 ciclos) usando sentencias aserciones lógicas que la salida permanezca congelada e idéntica, reportando error inmediato si existe alteración temporal.

2- Clock: cae el clock y el diseño quede estático.
   - **Propuesta:** Intervenir las lógicas de generación de reloj del TB principal. Después de funcionar con normalidad por un espacio `t`, detener arbitrariamente el flanco alternativo (dejarlo en 0 fijo). Esperar una cantidad de retrasos `#` larga (ej: 100μs ~ 1ms). Validar mediante una condicional unificada que frente a la ausencia de estímulo posicional (posedge) ningún componente modifique los `o_led`, `o_led_g`, `o_led_b` ni conteos parciales internos.

3- Limites de cuenta: reset -> i_switch[2:1] = 0,1,2,3 y verificar el periodo en que cambian los leds.
   - **Propuesta:** Forzar internamente (force) límites de cuenta cortos (`limit_0` a `limit_3`) como táctica aceleradora. Correr un lazo `for` secuencial por los 4 parámetros posibles del vector `i_sw[2:1]`. Con el flag manual del reloj en alto, emplear un contador independiente en la simulación que registre metódicamente la cantidad de saltos de clock ocurridos antes que el bit `o_led` se desplace al siguiente pin posicional. Realizar `$display`/comprobante que demuestre el ensamble exacto frente la aserción: (Delay medido == Límite configurado esperado). 

4- Limites de cuenta random.
   - **Propuesta:** Mientras la fase natural está evolucionando fluidamente, inyectar `$urandom_range(0,3)` dentro de `i_sw[2:1]` iteradas veces de modo concurrente. Al momento de aplicar una aserción, crear un *Predictor local* que observe cuándo ocurrió el salto aleatorio del MUX, evalúe en cascada a qué valor saltó la variable y chequee si el pulso emisor resultante para `shift_register` acató inmediatamente los lineamientos combinacionales nuevos del contador frente a su antiguo margen comparativo del límite.

5- Test de cambio de color de leds.
   - **Propuesta:** Crear un bloque de tareas paralelo (fork/join) y asignar repetidamente un `$urandom_range(0,1)`  al bit de control visual (`i_sw[3]`); mientras el test sigue contando a su propio ritmo. Construir un 'checker' de alta fidelidad iterando eternamente sobre las jerarquías de salidas de tal suerte que si la orden evaluada en `i_sw[3]` es igual a alta `(1)`, se confirme obligatoriamente aserción estricta de variables: (`o_led_g` == 0) Y a su vez equivalencia: (`o_led_b` == `o_led`); comprobando el caso inverso rigurosamente sin demoras posicionales.

6- Test reset.
   - **Propuesta:** Crear cortes aleatorizados de inyección para el Reset (ej. instanciando la tarea local `reset()` dentro de puntos ciegos de la simulación). Usando directivas tipo `always @(negedge i_reset)`, capturar la reacción instantánea sin depender del flanco de reloj, verificando combinacionalmente que en todo el árbol dependiente devenga a sus valores por defecto esperados por especificación (por ejemplo garantizando inequívocamente la recarga del registro de shift para mostrar su primer encendido con el parámetro base, tipo `4'b1000`).

7- Test de randomizar todos los componentes.
   - **Propuesta:** Corresponde a la prueba más densa y exhaustiva que une todas las estrategias. Generar un vector de 10,000 sentencias lógicas donde concurrentemente todo cambia a la vez: transiciones caóticas en instantes de reset, rebotes del enable `i_sw[0]`, permutaciones de límite y cambios de tonalidad LED. Para corroborar correctitud de las fases no medibles se emplean Arquitecturas de Módulos de Referencia *(Golden Reference Data Model)* dentro del testbench comportándose analíticamente, de forma pareada a cada evento que sucede en top, contrastándose ciclo a ciclo cada salida resultante y deteniendo agresivamente la simulación al menor sesgo predictivo.


Tip: Para verificación no hay una regla para utilizar tipeo bloqueante o no bloqueante. Esas reglas se siguen en diseño.


