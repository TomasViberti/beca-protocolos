`timescale 1ns / 1ps

module vio_illa (
    // Puertos de reloj y observación (Entradas al wrapper)
    input  wire        clock,
    input  wire [3:0]  o_led,
    input  wire [3:0]  o_led_b,
    input  wire [3:0]  o_led_g,
    
    // Puertos de control virtual (Salidas del wrapper)
    output wire        reset_vio,
    output wire        selMux,
    output wire [3:0]  sw_vio
);


    // Instancia del IP Core VIO (Virtual Input/Output)
    vio 
    u_vio 
    (
        .clk_0          (clock),
        .probe_out0_0  (reset_vio), 
        .probe_out1_0 (selMux),    
        .probe_out2_0   (sw_vio)     
    );

    // Instancia del IP Core ILA (Integrated Logic Analyzer)
    ila 
    u_ila 
    (
        .clk_0          (clock),
        .probe0_0       ( {o_led_g, o_led_b, o_led} ) 
    );

endmodule