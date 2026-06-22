`define TEST_4

`ifdef  TEST_4

localparam integer expected_limit;
localparam integer max_count_reached_flag;

initial
begin
    //-----> Forzamos los limites a un valor mas bajo para poder ver que se respeten
    force u_top_leds.u_counter.limit_0   = 32'h0000_0010;
    force u_top_leds.u_counter.limit_1   = 32'h0000_0020;
    force u_top_leds.u_counter.limit_2   = 32'h0000_0040;
    force u_top_leds.u_counter.limit_3   = 32'h0000_0080;

    for (integer i = 0; i < 100; i = i + 1)
    begin
        //-----> Inicialización de variables
        i_sw[0] = 'd0;
        i_sw[2:1] = $urandom_range(0,3); // Inicializamos el counter con un límite al azar
        i_sw[3] = $urandom_range(0,1);
        max_count_reached_flag = 0;

        //-----> Habilitamos reset
        reset();
        
        //-----> Asigno el limite random a mi variable local
        case (i_sw[2:1])
            2'b00 : expected_limit = u_top_leds.u_counter.limit_0;
            2'b01 : expected_limit = u_top_leds.u_counter.limit_1;
            2'b10 : expected_limit = u_top_leds.u_counter.limit_2;
            2'b11 : expected_limit = u_top_leds.u_counter.limit_3;
        endcase

        //-----> Sincronizamos con un posedge del clock
        @(posedge clock);

        //-----> Iniciamos el enable
        i_sw[0] = 'd1;
        
        for (integer i = 0; i < expected_limit; i = i + 1)
        begin
            //-----> Esperamos al flanco de subida
            @(posedge clock);

            //-----> Esperamos un momento random
            #(urandom_range(1,5)*1us);

            if(u_top_leds.u_counter.counter != i)
            begin
                $display("ERROR: El contador no coincide con el limite esperado");
                $finish(2);
            end
        end

        // Un ciclo extra en el cual debería volverse a cero después de alcanzar el límite
        @(posedge clock);
        if(u_top_leds.u_counter.counter != 0)
        begin
            $display("ERROR: El contador llego al limite pero no reinició a 0 en el sig ciclo.");
            $finish(2);
        end
    end

    $display("TEST PASSED: Todos los limites funcionan de manera correcta");
    $finish();
end
`endif
