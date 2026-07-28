`define TEST4

`ifdef TEST4

integer i;
integer j;
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

    // Test 4: 4 valid values and 1 invalid value must never lock.
    i_valid = 1'b1;
    checker_inject_invalid = 1'b0;

    for (i = 0; i < 8; i = i + 1)
    begin
        for (j = 0; j < 4; j = j + 1)
        begin
            @(posedge clk);
            #1;

            if (o_lock)
            begin
                $display("ERROR: o_lock locked with only four valid values.");
                $display("TEST FAILED");
                $finish(2);
            end
        end

        invalid_value = o_lfsr ^ 16'h0001;
        checker_inject_invalid = 1'b1;
        checker_inject_value = invalid_value;

        @(posedge clk);
        #1;

        if (o_lock)
        begin
            $display("ERROR: o_lock locked after a pattern of four valid values and one invalid value.");
            $display("TEST FAILED");
            $finish(2);
        end

        checker_inject_invalid = 1'b0;
    end

    $display("TEST PASSED");
    $finish();
end

`endif
