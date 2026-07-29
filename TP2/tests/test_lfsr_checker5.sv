`define TEST5

`ifdef TEST5

reg [15:0] invalid_value;

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

    // Se testea que si el sistema está lockeado, no se desbloquee con una cuenta de errores consecutivos
    // menor al threshold de desbloqueo
    i_valid = 1'b1;
    checker_inject_invalid = 1'b0;

    for (integer j = 0; j < 100; j = j + 1)
    begin
        // Se esperan 6 ciclos para que el checker se lockee 
        for (integer i = 0; i < 6; i = i + 1)
        begin
            @(posedge clk);
            #1;
        end

        // Si no se lockeó es porque el checker funciona mal
        if (!o_lock)
        begin
            $display("ERROR: No se lockeo luego de trafico consecutivo válido");
            $display("TEST FAILED");
            $finish(2);
        end

        // Inyección de errores en un ciclo de 6 iteraciones
        for (integer e = 0; e < 6; e = e + 1)
        begin
            // Se inyecta primero el valor inválido y el invalid_count pasa a 1
            invalid_value = o_lfsr ^ 16'h0001;
            checker_inject_invalid = 1'b1;
            checker_inject_value = invalid_value;

            @(posedge clk);
            #1;

            // Si el lockeo se cae con solo un invalid_count falla el test
            if (!o_lock)
            begin
                $display("ERROR: Se deslockeó despues de una sola cuenta inválida");
                $display("TEST FAILED");
                $finish(2);
            end

            // Se inyecta el segundo valor inválido y invalid_count pasa a 2
            invalid_value = o_lfsr ^ 16'h0002;
            checker_inject_value = invalid_value;

            @(posedge clk);
            #1;

            // Si el lockeo se cae con solo Ddos invalid_count falla el test
            if (!o_lock)
            begin
                $display("ERROR: Se deslockeó despues de dos cuentas inválidas");
                $display("TEST FAILED");
                $finish(2);
            end

            // Inyección de un valor válido antes de llegar al tercer invalid_count
            checker_inject_invalid = 1'b0;

            @(posedge clk);
            #1;

            // Si se deslockea despues de la inyección de un valor válido despues de dos inválidos, falla
            if (!o_lock)
            begin
                $display("ERROR: Se deslockeó despues de dos cuentas inválidas y una válida");
                $display("TEST FAILED");
                $finish(2);
            end
        end
    end

    $display("TEST PASSED");
    $finish();
end

`endif
