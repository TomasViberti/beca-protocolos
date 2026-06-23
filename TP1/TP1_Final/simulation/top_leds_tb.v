`default_nettype none
`timescale 1ns/1ns

module top_leds_tb();

localparam N_SWITCH = 4 ;
localparam N_LED    = 4 ;

wire [N_LED - 1 : 0] o_led  ;
wire [N_LED - 1 : 0] o_led_b;
wire [N_LED - 1 : 0] o_led_g;

reg  [N_SWITCH - 1 : 0] i_sw;
reg                     i_reset;
reg                     clock;

top_leds
u_top_leds
(
//----> Output
  .o_led      (o_led),
  .o_led_b    (o_led_b),
  .o_led_g    (o_led_g),
//----> Inputs
  .i_sw       (i_sw   ),
  .i_reset    (i_reset),
  .clock      (clock  )
);


//----> Generamos clock
initial
begin
  clock   <= 'd0;
end
always #5 clock = ~clock;


//----> Task para el reset
task reset ();
time reset_time;
begin
  //----> Reset en 0
  i_reset <= 'd0;

  //----> Randomizo duracion del reset
  reset_time = $urandom_range(1,100);
  #reset_time;

  //----> Levanto reset de manera sincronica
  @(posedge clock);

  //----> Levanto reset
  i_reset <= 'd1; 
end
endtask

//----> Inclusión de tests
//`include "../tests/test1_enable.sv"
//`include "../tests/test2_color_leds.sv"
//`include "../tests/test3_clock.sv"
//`include "../tests/test4_random_count_limit.sv"
`include "../tests/test5_count_limit.sv"

vio_illa 
u_vio_illa
(
    .clock     (clock),
    
    // Le pasamos las señales que queremos espiar
    .o_led     (o_led),
    .o_led_b   (o_led_b),
    .o_led_g   (o_led_g),
    
    // Recibimos las señales de control virtuales para nuestros multiplexores
    .reset_vio (reset_vio),
    .selMux    (selMux),
    .sw_vio    (sw_vio)
);

endmodule

