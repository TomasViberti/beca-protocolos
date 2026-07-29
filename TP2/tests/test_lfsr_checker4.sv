`define TEST4

`ifdef TEST4

// Se pretende verificar que el modelo de estados funcione correctamente,
// de modo que este no cambie de estado si no se cumplieron estrictamente 
// los thresholds definidos

reg [15:0] invalid_value; // Valor que simula un threshold inválido

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

    // Test: 4 valids y 1 invalid nunca se debería lockear
    i_valid = 1'b1;
    checker_inject_invalid = 1'b0;

    // Se itera 100 veces
    for (integer i = 0; i < 100; i = i + 1)
    begin
        for (integer j = 0; j < 4; j = j + 1)
        begin
            @(posedge clk);
            #1;

            if (o_lock)
            begin
                $display("ERROR: Se lockeó la maquina de estados sin cumplir los thresholds");
                $display("TEST FAILED");
                $finish(2);
            end
        end
        // Inyección de un valor inválido en el 5to ciclo
        invalid_value = o_lfsr ^ 16'h0001; // Se corrompe un bit de la trama
        checker_inject_invalid = 1'b1;
        checker_inject_value = invalid_value;

        @(posedge clk);
        #1;

        // Se valida que el valor erróneo efectivamente rompa la cuenta de valid_count, impidiendo lockear
        if (o_lock)
        begin
            $display("ERROR: Se lockeó con 4 valores válidos consecutivos y 1 erroneo");
            $display("TEST FAILED");
            $finish(2);
        end

        checker_inject_invalid = 1'b0;
    end

    $display("TEST PASSED");
    $finish();
end

`endif
