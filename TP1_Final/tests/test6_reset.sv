`define TEST_6

`ifdef TEST_6

reg [N_LED - 1 : 0] prev_o_led;
reg [N_LED - 1 : 0] prev_o_led_b;
reg [N_LED - 1 : 0] prev_o_led_g;

initial
begin
    for (integer i = 0; i < 100; i = i + 1)
    begin
        //-----> Inicializacion de variables
        @(posedge clock);
        i_sw[0]   = 1'b1;
        i_sw[2:1] = $urandom_range(0,3);
        i_sw[3]   = $urandom_range(0,1);

        //-----> Dejamos que el diseno avance antes de resetearlo
        repeat ($urandom_range(1,10)) @(posedge clock);

        prev_o_led   = o_led;
        prev_o_led_b = o_led_b;
        prev_o_led_g = o_led_g;

        //-----> Aplicamos reset asincronico y verificamos solo salidas
        i_sw[0] = 1'b0;
        i_reset = 1'b0;
        #1;

        if (o_led != 4'b1000)
        begin
            $display("ERROR: Tras reset el patron de leds no volvio al estado inicial.");
            $display("TEST FAILED");
            $finish(2);
        end

        if (i_sw[3])
        begin
            if (o_led_b != o_led || o_led_g != 'd0)
            begin
                $display("ERROR: Tras reset el color azul no coincide con i_sw[3].");
                $display("TEST FAILED");
                $finish(2);
            end
        end
        else
        begin
            if (o_led_g != o_led || o_led_b != 'd0)
            begin
                $display("ERROR: Tras reset el color verde no coincide con i_sw[3].");
                $display("TEST FAILED");
                $finish(2);
            end
        end

        //-----> Mientras el reset siga activo, las salidas deben permanecer estables
        repeat ($urandom_range(1,5)) @(posedge clock);
        #1;

        if (o_led != 4'b1000)
        begin
            $display("ERROR: Con reset activo el patron de leds cambio.");
            $display("TEST FAILED");
            $finish(2);
        end

        if (i_sw[3])
        begin
            if (o_led_b != o_led || o_led_g != 'd0)
            begin
                $display("ERROR: Con reset activo el color azul no se mantuvo.");
                $display("TEST FAILED");
                $finish(2);
            end
        end
        else
        begin
            if (o_led_g != o_led || o_led_b != 'd0)
            begin
                $display("ERROR: Con reset activo el color verde no se mantuvo.");
                $display("TEST FAILED");
                $finish(2);
            end
        end

        //-----> Liberamos el reset y confirmamos que la salida sigue en el estado inicial
        @(posedge clock);
        i_reset = 1'b1;
        #1;

        if (o_led != 4'b1000)
        begin
            $display("ERROR: Al liberar reset el patron de leds no quedo en el estado esperado.");
            $display("TEST FAILED");
            $finish(2);
        end

        if (i_sw[3])
        begin
            if (o_led_b != o_led || o_led_g != 'd0)
            begin
                $display("ERROR: Al liberar reset el color azul no coincide con i_sw[3].");
                $display("TEST FAILED");
                $finish(2);
            end
        end
        else
        begin
            if (o_led_g != o_led || o_led_b != 'd0)
            begin
                $display("ERROR: Al liberar reset el color verde no coincide con i_sw[3].");
                $display("TEST FAILED");
                $finish(2);
            end
        end
    end

    $display("TEST PASSED");
    $finish();
end

`endif