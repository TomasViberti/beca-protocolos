//----> TOP LEDS
module top_leds
#(
  parameter N_SWITCH = 4                  ,
  parameter N_LED    = 4
)
(
//----> Output
  output  wire [N_LED    - 1 : 0] o_led   ,
  output  wire [N_LED    - 1 : 0] o_led_b ,
  output  wire [N_LED    - 1 : 0] o_led_g ,
//----> Inputs
  input   wire [N_SWITCH - 1 : 0] i_sw    ,
  input   wire                    i_reset ,
  input   wire                    clock
);

localparam   NB_SHIFT_REG = 4;

wire                          shift         ;
wire [NB_SHIFT_REG - 1 : 0]   led_enable    ;

//-----> Cables y multiplexores
wire        selMux;
wire        reset_vio;
wire [3:0]  sw_vio;

wire        reset_muxed;
wire [3:0]  sw_muxed;

// Multiplexores de control: Deciden si manda el VIO o la placa física
assign reset_muxed = selMux ? reset_vio : i_reset;
assign sw_muxed    = selMux ? sw_vio    : i_sw;

counter
u_counter
(  //----> Output
  .o_shift                (shift        ),
  //----> Inputs (Cambiamos i_sw e i_reset por las señales multiplexadas)
  .i_enable               (sw_muxed[0]  ),
  .i_sel_count_limit      (sw_muxed[2:1]),
  .i_reset                (reset_muxed  ),
  .clock                  (clock        )
);          

shift_reg 
u_shift_reg
(
  //----> Outputs
  .o_led_enable           (led_enable   ),
  //----> Inputs (Cambiamos i_sw e i_reset por las señales multiplexadas)
  .i_shift                (shift        ),
  .i_enable               (sw_muxed[0]  ),
  .i_reset                (reset_muxed  ), 
  .clock                  (clock        )
);

assign o_led    = led_enable;
// Cambiamos i_sw[3] por sw_muxed[3] para que el VIO pueda cambiar el color
assign o_led_b  = ( sw_muxed[3]) ? led_enable : 4'b0000   ; 
assign o_led_g  = (!sw_muxed[3]) ? led_enable : 4'b0000   ; 


`ifndef SYNTHESIS

    assign selMux    = 1'b0;
    assign reset_vio = 1'b0;
    assign sw_vio    = 4'b0000;
`else
    vio_illa 
    u_debug 
    (
        .clock      (clock),
        .o_led      (o_led),
        .o_led_b    (o_led_b),
        .o_led_g    (o_led_g),
        .reset_vio  (reset_vio),
        .selMux     (selMux),
        .sw_vio     (sw_vio)
    );
    
`endif

endmodule