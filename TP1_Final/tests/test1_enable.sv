`define TEST1

`ifdef TEST1

localparam NB_COUNTER = 32;

reg [N_LED      - 1 : 0] prev_o_led    ;

reg [NB_COUNTER - 1 : 0] clock_counter ;

initial
begin
    force u_top_leds.u_counter.limit_0   = 32'h0000_0010;
    force u_top_leds.u_counter.limit_1   = 32'h0000_0020;
    force u_top_leds.u_counter.limit_2   = 32'h0000_0040;
    force u_top_leds.u_counter.limit_3   = 32'h0000_0080;

    //----> Corremos el test por 100 iteraciones
    for(integer i=0; i<100; i=i+1)
    begin

        //----> Inicializamos las variables
        i_sw[0]       = 'd0;
        i_sw[3:1]     = $urandom_range(0,7);
        prev_o_led    = 'd0;
        clock_counter = 'd0;

        //----> Reset
        reset();
        
        i_sw[0] = 'd1;
        
        //----> Esperamos un momento random
        #($urandom_range(1,5) * 1us);
        
        //----> Deshabilitamos el contador y guardamos el valor del led en ese instante.
        i_sw[0]     = 'd0   ;
        // Esperamos un instante microscópico asegurando que el hardware evalúe la salida antes de copiarla
        #1;
        prev_o_led  = o_led ;
        //----> Esperamos un momento random.
        clock_counter = $urandom_range(50,500);
        //----> Checkeamos funcionamiento.
        for(integer j=0; j<clock_counter; j=j+1)
        begin
          @(posedge clock);
          if(prev_o_led != o_led)
          begin
            $display("ERROR: El valor del led cambio.");
            $display("TEST FAILED");
            $finish(2);
          end 
        end
    end
$display("TEST PASSED");
$finish();
end
    
`endif