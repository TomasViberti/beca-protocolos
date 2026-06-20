`default_nettype none
`timescale 1ps/1ps // Paso/resolución

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
(
//----> Output
  .o_led      (o_led),
  .o_led_b    (o_led_b),
  .o_led_g    (o_led_g),
//----> Inputs
  i_sw        (i_sw   ),
  i_reset     (i_reset),
  clock       (clock  )
);

initial
begin
  clock   <= 'd0;

  forever
  begin
    clock <= ~clock;
    #5us;
  end  
end

// always #5us clock <= ~clock;
task reset ();
time reset_time;
begin
  i_reset <= 'd0;

  reset_time = $urandom_range(1,100) * 1ns;
  #reset_time;

  @(posedge clock);

  i_reset <= 'd1;
end
endtask

initial
begin
  i_reset <= 'd0;
  i_sw    <= 'd0;

  #100us;

  i_reset <= 'd1;

  #100us;

  i_sw[0] <= 1'b1;
  i_sw[2:1] <= 2'b10;

  i_sw[3] <= 1'b1

  #100us;

  i_sw[0] <= 1'b1;
  i_sw[2:1] <= 2'b10;

  i_sw[3] <= 1'b1

  #100us;

  finish();
end


endmodule