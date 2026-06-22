### 1. Violaciones de Tiempo (Setup y Hold)

En un camino de datos entre dos Flip-Flops (FF), el reloj impone las reglas del juego:

* **Tiempo de Setup ($t_{su}$):** La ventana de tiempo *antes* del flanco de reloj donde el dato ya debe estar estable. Si tu lógica combinacional es muy lenta y el dato llega tarde, violas el setup.
* **Tiempo de Hold ($t_h$):** La ventana de tiempo *después* del flanco de reloj donde el dato no debe cambiar. Si tu lógica combinacional es demasiado rápida y el dato cambia prematuramente, violas el hold.
* **Resultado:** Cualquier violación de estos tiempos provoca una Violación de Tiempo (*Timing Violation*), lo que nos lleva directamente al siguiente concepto.

### 2. Definición de Metaestabilidad

Si la señal de datos cambia exactamente durante la ventana prohibida de *Setup* o *Hold*, el Flip-Flop captura la señal en plena transición.

**Definición:** La metaestabilidad es el estado anómalo en el que la salida del Flip-Flop no se decide ni por un '0' lógico ni por un '1' lógico. Queda atrapada en un voltaje intermedio o oscilando durante un tiempo impredecible. Eventualmente se resolverá a un estado válido (0 o 1) por el ruido térmico del silicio, en igual probabilidad para 0 o 1, pero el retraso que genera propagará valores basura o inconsistentes al resto del circuito sincrónico.

### 3. Gray Coding (Código Gray)

Es la solución para evitar metaestabilidad al cruzar **buses** enteros a otro dominio de reloj.

* **Concepto:** Es un sistema de numeración binaria donde **solo un bit cambia de estado a la vez** entre dos valores consecutivos (ej. `00` -> `01` -> `11` -> `10`).
* **El problema que resuelve:** Si cruzas un bus binario normal (ej. pasar de `011` a `100`, donde cambian 3 bits simultáneamente) a otro reloj, el *skew* (diferencia de retardo en los cables) hará que el reloj receptor pueda leer un valor transitorio erróneo (ej. `111`). Al usar Gray, como solo cambia un bit, el reloj receptor leerá el valor viejo o el nuevo, pero **nunca** un valor basura intermedio.

### 4. Sincronización del Reset (Asynchronous Assertion, Synchronous De-assertion)

* **El Problema:** Un reset asíncrono se activa inmediatamente, pero si lo *desactivas* (lo levantas) justo en el flanco de reloj, violas el *Recovery Time* (el equivalente al Setup para resets) y toda tu FPGA entra en metaestabilidad al arrancar.
* **La Solución:** Usamos un circuito llamado "Reset Synchronizer". Conectamos la entrada del primer FF de un sincronizador directamente a '1' lógico (VCC).
* **El Mecanismo:** Cuando aprietas el botón de reset, el sistema se reinicia asíncronamente al instante. Pero al soltar el botón, ese '1' fijo viaja a través de los dos FFs al ritmo del reloj. Si el primer FF cae en metaestabilidad, el segundo le da tiempo a resolverse. Como resultado, tu sistema sale del reset de forma limpia y 100% síncrona con tu reloj.

