`define TEST5

`ifdef TEST5

integer i;
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

    // Test 5: once locked, two invalid values and one valid value must not unlock.
    i_valid = 1'b1;
    checker_inject_invalid = 1'b0;

    for (i = 0; i < 6; i = i + 1)
    begin
        @(posedge clk);
        #1;
    end

    if (!o_lock)
    begin
        $display("ERROR: o_lock did not lock after valid traffic.");
        $display("TEST FAILED");
        $finish(2);
    end

    for (i = 0; i < 6; i = i + 1)
    begin
        invalid_value = o_lfsr ^ 16'h0001;
        checker_inject_invalid = 1'b1;
        checker_inject_value = invalid_value;

        @(posedge clk);
        #1;

        if (!o_lock)
        begin
            $display("ERROR: o_lock unlocked after only one invalid value.");
            $display("TEST FAILED");
            $finish(2);
        end

        invalid_value = o_lfsr ^ 16'h0002;
        checker_inject_value = invalid_value;

        @(posedge clk);
        #1;

        if (!o_lock)
        begin
            $display("ERROR: o_lock unlocked after only two invalid values.");
            $display("TEST FAILED");
            $finish(2);
        end

        checker_inject_invalid = 1'b0;

        @(posedge clk);
        #1;

        if (!o_lock)
        begin
            $display("ERROR: o_lock unlocked after two invalid values followed by one valid value.");
            $display("TEST FAILED");
            $finish(2);
        end
    end

    $display("TEST PASSED");
    $finish();
end

`endif
