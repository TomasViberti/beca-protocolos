`define TEST6

`ifdef TEST6

initial
begin
    i_rst = 1'b0;
    i_soft_reset = 1'b0;
    i_valid = 1'b0;
    checker_inject_invalid = 1'b0;
    checker_inject_value = 16'h0000;
    i_seed = 16'h0001;

    reset();
    load_seed(16'h0001);
    soft_reset();

    // Se verifica que el sistema cambie de estados al ocurrir 5 cuentas válidas y 3 cuentas inválidas
    for (integer i = 0; i < 100; i = i + 1)
    begin
        i_valid = 1'b1;
        checker_inject_invalid = 1'b0; // Se inicia con tráfico válido

        // Luego de una desincronización, el primer ciclo válido se usa para resincronizar el modelo.
        // Por eso se esperan seis ciclos para volver a lockear.
        for (integer j = 0; j < 6; j = j + 1)
        begin
            @(posedge clk);
            #1;
        end

        // Luego de 6 ciclos válidos el sistema debe lockearse
        if (!o_lock)
        begin
            $display("ERROR: No se lockeó con seis valid counts");
            $display("TEST FAILED");
            $finish(2);
        end

        // Se inyecta 3 invalid_count seguidos
        for (integer e = 0; e < 3; e = e + 1)
        begin
            checker_inject_invalid = 1'b1;
            checker_inject_value = o_lfsr ^ 16'h00FF; // Corrupción en bits de la trama

            @(posedge clk);
            #1;
        end

        // Se restaura el tráfico 
        checker_inject_invalid = 1'b0;

        // Si no se deslockeó depsues de los tres invalid_count falla el test
        if (o_lock)
        begin
            $display("ERROR: No se deslockeó despues de tres invalid_count");
            $display("TEST FAILED");
            $finish(2);
        end
    end

    $display("TEST PASSED");
    $finish();
end

`endif
