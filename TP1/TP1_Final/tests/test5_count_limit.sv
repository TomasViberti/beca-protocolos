`define TEST_4_STRESS

`ifdef TEST_4_STRESS

integer expected_limit;

initial begin
    // -----> Forzamos los limites a un valor mas bajo para poder llegar a la cuenta
    force u_top_leds.u_counter.limit_0   = 32'h0000_0010;
    force u_top_leds.u_counter.limit_1   = 32'h0000_0020;
    force u_top_leds.u_counter.limit_2   = 32'h0000_0040;
    force u_top_leds.u_counter.limit_3   = 32'h0000_0080;

    for (int j = 0; j < 100; j= j +1) 
    begin
        
        //-----> Una iteración por cada limite.
        for (int i = 0; i < 4;i = i + 1) 
        begin
            
            // -----> Inicialización sincrónica para el límite actual
            @(posedge clock);
            i_sw[0]   = 1'b0;  
            i_sw[2:1] = i[1:0]; 
            i_sw[3]   = $urandom_range(0,1); // Randomizamos el color, no afecta la cuenta

            // -----> Habilitamos reset
            reset(); 
            
            // -----> Asignamos el límite
            case (i[1:0])
                2'b00 : expected_limit = u_top_leds.u_counter.limit_0;
                2'b01 : expected_limit = u_top_leds.u_counter.limit_1;
                2'b10 : expected_limit = u_top_leds.u_counter.limit_2;
                2'b11 : expected_limit = u_top_leds.u_counter.limit_3;
            endcase

            // -----> Iniciamos el enable en el siguiente posedge
            @(posedge clock);
            i_sw[0] = 1'b1;
            
            // -----> Verificación
            for (int e = 0; e < expected_limit;e = e + 1) 
            begin
                
                // Se espera un pequeño momento
                #1; 
                
                if(u_top_leds.u_counter.counter != e) 
                begin
                    $display("ERROR (Iter %0d, Límite %0d): Contador = %0d, Esperado = %0d a los %0t ns", 
                             j, i, u_top_leds.u_counter.counter, e, $time);
                    $finish(2);
                end
                
                // Esperamos al siguiente flanco 
                @(posedge clock); 
            end
            
            //-----> Esperamos un momento para que se ponga en 0 el counter
            #1;
            if(u_top_leds.u_counter.counter > expected_limit) 
            begin
                $display("ERROR (Iter %0d, Límite %0d): El contador llego al limite pero no reinicio a 0.", j, i);
                $finish(2);
            end
        end
    end

    $display("TEST PASSED");
    $finish();
end
`endif