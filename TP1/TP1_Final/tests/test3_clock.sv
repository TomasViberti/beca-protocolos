`define TEST3

`ifdef TEST3

reg [N_LED - 1:0] prev_o_led;

initial 
begin
    //----> Aceleramos simulación (Igual que en test anteriores)
    force u_top_leds.u_counter.limit_0   = 32'h0000_0010; //En duda si es necesario para este test 
    force u_top_leds.u_counter.limit_1   = 32'h0000_0020; //En duda si es necesario para este test
    force u_top_leds.u_counter.limit_2   = 32'h0000_0040; //En duda si es necesario para este test
    force u_top_leds.u_counter.limit_3   = 32'h0000_0080; //En duda si es necesario para este test

    for (integer i = 0; i<10; i=i+1)
    begin
        //-----> Inicialización de variables
        i_sw[0]   = 'd0;
        i_sw[3:1] = $urandom_range(0,7);

        //-----> Reset
        reset();

        //-----> Habilitamos contador para que las luces vayan cambiando
        i_sw[0] = 'd1;

        //-----> Esperamos un momento corto y visualizable (ej: 1 a 5 microsegundos)
        #($urandom_range(1,5) * 1000);

        //-----> CAÍDA DEL RELOJ: Apagamos el generador de clock
        force clock = 'd1;

        // Guardamos el estado actual
        prev_o_led = o_led;

        // Esperamos un momento corto pero notorio sin reloj (ej: 10 a 20 us)
        #($urandom_range(10,20) * 1000);

        //-----> Verificación
        if (o_led != prev_o_led)
        begin
            $display("ERROR: El reloj se detuvo pero el LED modificó su estado estático.");
            $display("TEST FAILED");
            $finish(2);
        end

        //-----> Devolvemos el clock a su estado natural
        release clock;
    end

    $display("TEST PASSED");
    $finish();
end
`endif