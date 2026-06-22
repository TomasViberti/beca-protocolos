`define TEST_2

`ifdef TEST_2

initial 
begin
    for (integer i = 0; i<100; i=i+1)
    begin
        //-----> Inicialización de variables
        i_sw[0] = 'd0;
        i_sw[2:1] = $urandom_range(0,3);

        //-----> Reset
        reset();

        //-----> Habilitamos contador
        i_sw[0] = 'd1;

        //-----> Esperamos un momento random para que se empiecen a mover los leds 
        #($urandom_range(1,5) * 1us);

        //-----> Ponemos i_sw[3] en un valor aleatorio entre 0 y 1
        i_sw[3] = $urandom_range(0,1);

        //-----> Verificación
        // Esperamos un instante minúsculo (#1) o un flanco de reloj
        // para dar tiempo a que la lógica combinacional asigne las salidas
        #1;
        if (i_sw[3])
        begin
            if (o_led_b != o_led || o_led_g != 'd0)
            begin
                $display("ERROR: Si el switch [3] está en 1, se deben prender los leds azules");
                $display("TEST FAILED");
                $finish(2);
            end
        end
        else
        begin
            if (o_led_g != o_led || o_led_b != 'd0)
            begin
                $display("ERROR: Si el switch [3] está en 0, se deben prender los leds verdes");
                $display("TEST FAILED");
                $finish(2);
            end
        end
    end
    $display("TEST PASSED");
    $finish();
end

`endif

            







        


        
