`define TEST3

`ifdef TEST3

localparam integer NB_LFSR_STEPS = 65535;

integer i;
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

    // Test 3: valid traffic for one full period must lock and stay locked.
    seen_lock = 1'b0;
    i_valid = 1'b1;
    checker_inject_invalid = 1'b0;

    for (i = 0; i < NB_LFSR_STEPS; i = i + 1)
    begin
        @(posedge clk);
        #1;

        if (o_lock)
            seen_lock = 1'b1;

        if (seen_lock && !o_lock)
        begin
            $display("ERROR: o_lock unlocked while valid traffic was maintained.");
            $display("Step: %0d", i + 1);
            $display("TEST FAILED");
            $finish(2);
        end
    end

    if (!seen_lock)
    begin
        $display("ERROR: o_lock never locked during valid traffic.");
        $display("TEST FAILED");
        $finish(2);
    end

    $display("TEST PASSED");
    $finish();
end

`endif
