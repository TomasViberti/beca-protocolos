`define TEST_4
`ifdef  TEST_4

integer expected_limit;

initial begin
    // -----> Forzamos los limites a un valor mas bajo para poder ver que se respeten
    force u_top_leds.u_counter.limit_0   = 32'h0000_0010;
    force u_top_leds.u_counter.limit_1   = 32'h0000_0020;
    force u_top_leds.u_counter.limit_2   = 32'h0000_0040;
    force u_top_leds.u_counter.limit_3   = 32'h0000_0080;

    //-----> Ciclo de iteraciones del test
    for (int j = 0; j < 100; j = j + 1) 
    begin
        
        // -----> Inicialización de variables 
        @(posedge clock);
        i_sw[0]   = 1'b0; 
        i_sw[2:1] = $urandom_range(0,3);
        i_sw[3]   = $urandom_range(0,1);

        // -----> Habilitamos reset
        reset(); 
        
        // -----> Asigno el limite random
        case (i_sw[2:1])
            2'b00 : expected_limit = u_top_leds.u_counter.limit_0;
            2'b01 : expected_limit = u_top_leds.u_counter.limit_1;
            2'b10 : expected_limit = u_top_leds.u_counter.limit_2;
            2'b11 : expected_limit = u_top_leds.u_counter.limit_3;
        endcase

        // -----> Iniciamos el enable
        @(posedge clock);
        i_sw[0] = 1'b1;
        
        // Bucle de validación ciclo a ciclo
        for (int i = 0; i <= expected_limit; i = i + 1)
        begin
            
            // -----> Esperamos un momento
            #1; 
            
            // -----> Evaluamos el estado actual
            if(u_top_leds.u_counter.counter != i) 
            begin
                $display("ERROR: Contador = %0d, Esperado = %0d a los %0t ns", u_top_leds.u_counter.counter, i, $time);
                $finish(2);
            end
            
            @(posedge clock);
        end

        #1;
        if(u_top_leds.u_counter.counter != 0) begin
            $display("ERROR: El contador pasó el limite");
            $finish(2);
        end
    end

    $display("TEST PASSED: Todos los limites funcionan de manera correcta");
    $finish();
end
`endif