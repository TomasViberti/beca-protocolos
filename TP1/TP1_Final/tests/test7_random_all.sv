`define TEST_7

`ifdef TEST_7

reg [N_LED - 1 : 0] snapshot_led;
reg [N_LED - 1 : 0] snapshot_led_b;
reg [N_LED - 1 : 0] snapshot_led_g;

initial
begin
    for (integer i = 0; i < 100; i = i + 1)
    begin
        //-----> Inicializacion aleatoria de entradas
        @(posedge clock);
        i_sw[0]   = $urandom_range(0,1);
        i_sw[2:1] = $urandom_range(0,3);
        i_sw[3]   = $urandom_range(0,1);

        //-----> A veces aplicamos reset para mezclar todos los componentes del banco
        if ($urandom_range(0,1))
        begin
            i_reset = 1'b0;
            #1;

            if (o_led != 4'b1000)
            begin
                $display("ERROR: Con reset activo el patron de leds no quedo inicializado.");
                $display("TEST FAILED");
                $finish(2);
            end

            if (i_sw[3])
            begin
                if (o_led_b != o_led || o_led_g != 'd0)
                begin
                    $display("ERROR: Con reset activo el color azul no coincide con i_sw[3].");
                    $display("TEST FAILED");
                    $finish(2);
                end
            end
            else
            begin
                if (o_led_g != o_led || o_led_b != 'd0)
                begin
                    $display("ERROR: Con reset activo el color verde no coincide con i_sw[3].");
                    $display("TEST FAILED");
                    $finish(2);
                end
            end

            repeat ($urandom_range(1,4)) @(posedge clock);
            i_reset = 1'b1;
            #1;
        end

        //-----> Chequeamos invariantes
        #1;

        if ((o_led & (o_led - 1'b1)) != 'd0)
        begin
            $display("ERROR: El patron de leds se rompió.");
            $display("TEST FAILED");
            $finish(2);
        end

        if (i_sw[3])
        begin
            if (o_led_b != o_led || o_led_g != 'd0)
            begin
                $display("ERROR: El color azul no coincide con i_sw[3].");
                $display("TEST FAILED");
                $finish(2);
            end
        end
        else
        begin
            if (o_led_g != o_led || o_led_b != 'd0)
            begin
                $display("ERROR: El color verde no coincide con i_sw[3].");
                $display("TEST FAILED");
                $finish(2);
            end
        end

        snapshot_led   = o_led;
        snapshot_led_b = o_led_b;
        snapshot_led_g = o_led_g;

        //-----> Aleatoriamente detenemos el clock para verificar que el sistema quede estable
        if ($urandom_range(0,1))
        begin
            force clock = 1'b0;
            #($urandom_range(1,10) * 1000);

            if (o_led != snapshot_led || o_led_b != snapshot_led_b || o_led_g != snapshot_led_g)
            begin
                $display("ERROR: Con el clock detenido las salidas cambiaron.");
                $display("TEST FAILED");
                $finish(2);
            end

            release clock;
        end
    end

    $display("TEST PASSED");
    $finish();
end

`endif