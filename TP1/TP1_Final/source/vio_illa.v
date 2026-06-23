module vio_illa (
    input  wire        clock,
    // Entradas desde el Top para espiar con el ILA
    input  wire [3:0]  o_led,
    input  wire [3:0]  o_led_b,
    input  wire [3:0]  o_led_g,
    
    // Salidas virtuales desde el VIO hacia el multiplexor del Top
    output wire        reset_vio,
    output wire        selMux,
    output wire [3:0]  sw_vio
);

    vio u_vio (
        .clk          (clock),
        .probe_out0   (reset_vio), // Genera el reset virtual
        .probe_out1   (selMux),    // Genera el selector del multiplexor
        .probe_out2   (sw_vio)     // Genera los switches virtuales
    );

    ila u_ila (
        .clk          (clock),
        // Concatenamos las 3 salidas de 4 bits en un bus de 12 bits
        .probe0       ({o_led_g, o_led_b, o_led}) 
    );

endmodule