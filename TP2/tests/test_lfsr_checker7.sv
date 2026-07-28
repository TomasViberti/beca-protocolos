`define TEST7

`ifdef TEST7

localparam integer NB_RANDOM_RESETS = 3;

integer i;
integer j;
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

    for (i = 0; i < NB_RANDOM_RESETS; i = i + 1)
    begin
        repeat($urandom_range(2, 12))
        begin
            @(posedge clk);
            #1;
        end

        i_seed = $urandom_range(1, 16'hFFFF);
        soft_reset();
        i_valid = 1'b1;
        checker_inject_invalid = 1'b0;

        seen_lock = 1'b0;
        for (j = 0; j < 10; j = j + 1)
        begin
            @(posedge clk);
            #1;

            if (o_lock)
                seen_lock = 1'b1;
        end

        if (!seen_lock)
        begin
            $display("ERROR: o_lock did not relock after a random reset.");
            $display("TEST FAILED");
            $finish(2);
        end
    end

    $display("TEST PASSED");
    $finish();
end

`endif
