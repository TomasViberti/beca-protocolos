`define TEST7

`ifdef TEST7

localparam NB_LFSR_STEPS = 65535;

reg seen_lock;

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

    // Test 7: random resets must re-lock after traffic resumes.
    i_valid = 1'b1;
    checker_inject_invalid = 1'b0;

    for (integer i = 0; i < 100; i = i + 1)
    begin  
        // Se espera un numero aleatorio de ciclos con tráfico normal
        repeat($urandom_range(1, NB_LFSR_STEPS))
        begin
            @(posedge clk);
            #1;
        end

        // Se inyecta un reset sincrónico con una semilla aleatoria
        i_seed = $urandom_range(1, 16'hFFFF);
        soft_reset();
        i_valid = 1'b1;
        checker_inject_invalid = 1'b0;

        // El sistema debe lockearse nuevamente despues de un numero aleatorio de ciclos mayor o igual a 5
        seen_lock = 1'b0;
        for (integer j = 0; j < $urandom_range(5, 500); j = j + 1)
        begin
            @(posedge clk);
            #1;

            // Si el sistema se volvió a lockear lo registro en la bandera del test
            if (o_lock)
                seen_lock = 1'b1;
        end

        // Si tras un numero aleatorio entre 5 y 500 ciclos el checker no se volvió a lockear, el test falla
        if (!seen_lock)
        begin
            $display("ERROR: No se lockeó despues de un reset random");
            $display("TEST FAILED");
            $finish(2);
        end
    end

    $display("TEST PASSED");
    $finish();
end

`endif
