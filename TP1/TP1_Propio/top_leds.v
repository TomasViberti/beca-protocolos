module top_leds
#(
    parameter B_LED = 4
)
(
// Outputs
output wire o_led   [B_LED - 1:0]         ,
output wire o_led_b [B_LED - 1:0]         ,
output wire o_led_g [B_LED - 1:0]         ,

// Inputs
  input   wire [N_SWITCH - 1 : 0] i_sw    ,
  input   wire                    i_reset ,
  input   wire                    clock
);

// Declaración cables internos

wire    shift                             ;
wire    led_enable                        ;

// Cables para las salidas del VIO
wire [3:0]  sw_vio;      // Los switches virtuales que vienen de la PC
wire        reset_vio;   // El reset virtual
wire        sel_mux;      // El selector que decide si usamos lo físico o lo virtual

// Cables para las salidas de los Multiplexores
wire [3:0]  sw_muxed;    // El switch final que usará el sistema
wire        reset_muxed; // El reset final que usará el sistema

// Multiplexado
assign reset_muxed = sel_mux ? reset_vio : i_reset;
assign sw_muxed = sel_mux ? sw_vio : i_sw;

//instancias
counter u_counter (
  .o_shift           (shift         ), 
  // Conexión de entradas a los cables multiplexados:
  .i_enable          (sw_muxed[0]   ), // Antes era i_sw[0]
  .i_sel_count_limit (sw_muxed[2:1] ), // Antes era i_sw[2:1]
  .i_reset           (reset_muxed   ), // Antes era i_reset
  .clock             (clock         )  // El reloj no se multiplexa
);          

// === TU TURNO ===
// ¿Cómo quedaría la instancia del shift_reg?
shift_reg u_shift_reg (
  .o_led_enable      (led_enable),
  .i_shift           (shift     ),
  .i_reset           (          ), // <-- ¿Qué cable conectamos aquí ahora?
  .clock             (clock     )
);

// ==========================================
// 4. LÓGICA DE SALIDA A LOS LEDS
// ==========================================
assign o_led   = led_enable;
// Para los colores, ahora también dependemos del switch multiplexado (bit 3)
assign o_led_b = ( sw_muxed[3]) ? 4'b1111 : 4'b0000; 
assign o_led_g = (!sw_muxed[3]) ? 4'b0000 : 4'b1111; 

// Aquí abajo irán las instancias del VIO y del ILA que haremos luego...

endmodule