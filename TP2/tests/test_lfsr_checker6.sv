`define TEST6

`ifdef TEST6

integer i;
integer j;

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

    // Test 6: 5 valid cycles and 3 invalid cycles must transition between lock and unlock.
    for (i = 0; i < 3; i = i + 1)
    begin
        i_valid = 1'b1;
        checker_inject_invalid = 1'b0;

        for (j = 0; j < 5; j = j + 1)
        begin
            @(posedge clk);
            #1;
        end

        if (!o_lock)
        begin
            $display("ERROR: o_lock did not lock after five valid cycles.");
            $display("TEST FAILED");
            $finish(2);
        end

        for (j = 0; j < 3; j = j + 1)
        begin
            checker_inject_invalid = 1'b1;
            checker_inject_value = o_lfsr ^ 16'h00FF;

            @(posedge clk);
            #1;
        end

        checker_inject_invalid = 1'b0;

        if (o_lock)
        begin
            $display("ERROR: o_lock did not unlock after three invalid cycles.");
            $display("TEST FAILED");
            $finish(2);
        end
    end

    $display("TEST PASSED");
    $finish();
end

`endif
