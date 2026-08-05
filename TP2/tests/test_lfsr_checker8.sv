`define TEST8

`ifdef TEST8

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

    // Se espera a que el checker quede lockeado con tráfico válido continuo.
    i_valid = 1'b1;
    checker_inject_invalid = 1'b0;

    for (integer i = 0; i < 6; i = i + 1)
    begin
        @(posedge clk);
        #1;
    end

    if (!o_lock)
    begin
        $display("ERROR: No se lockeó antes de probar la corrupción en lock");
        $display("TEST FAILED");
        $finish(2);
    end

    // Mientras está lockeado, se inyecta un dato corrupto.
    invalid_value = o_lfsr ^ 16'h0001;
    checker_inject_invalid = 1'b1;
    checker_inject_value = invalid_value;

    @(posedge clk);
    #1;

    if (!o_lock)
    begin
        $display("ERROR: El checker perdió lock ante un solo dato corrupto");
        $display("TEST FAILED");
        $finish(2);
    end

    // Se vuelve a tráfico válido y se verifica que el checker permanezca lockeado.
    checker_inject_invalid = 1'b0;

    for (integer j = 0; j < 4; j = j + 1)
    begin
        @(posedge clk);
        #1;

        if (!o_lock)
        begin
            $display("ERROR: El checker se deslockeó después de un dato corrupto en lock");
            $display("TEST FAILED");
            $finish(2);
        end
    end

    $display("TEST PASSED");
    $finish();
end

`endif