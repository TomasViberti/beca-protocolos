`define TEST3

`ifdef TEST3

localparam integer NB_LFSR_STEPS = 65535;

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

    // Test destinado a verificar que ante un periodo de tiempo se lockee el sistema como es esperado.
    seen_lock = 1'b0;
    i_valid = 1'b1;
    checker_inject_invalid = 1'b0;

    // Se itera el test 10 veces pues la cantidad de steps del LFSR ya es extensa
    for (integer j = 0; j < 10; j = j + 1)
    begin
        for (integer i = 0; i < NB_LFSR_STEPS; i = i + 1)
        begin
            @(posedge clk);
            #1;

            // Si la bandera de lock está activa registro en la bandera seen_lock dicho evento
            if (o_lock)
            seen_lock = 1'b1;

            // Si en algún momento difieren las banderas, falla el test porque sigue habiendo tráfico sincronizado
            // y no deberían cambiar las banderas.
            if (seen_lock && !o_lock)
            begin
                $display("ERROR: o_lock Se desbloqueó mientras había tráfico sincronizado");
                $display("TEST FAILED");
                $finish(2);
            end
        end

        // Si nunca se puso en uno la variable seen_lock es porque el checker no funciona y falla el test
        if (!seen_lock)
        begin
            $display("ERROR: o_lock nunca se lockeó durante tráfico sincronizado");
            $display("TEST FAILED");
            $finish(2);
        end

        $display("TEST PASSED");
        $finish();
    end
    
end

`endif
