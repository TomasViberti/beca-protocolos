module lfsr_checker#(
    parameter [15:0] FIXED_SEED = 16'b1
)
(
    input  wire         clk,
    input  wire         i_soft_reset,
    input  wire         i_rst,
    input  wire         i_valid,
    input  wire [15:0]  i_seed,
    input  wire [15:0]  i_lfsr,
    output reg          o_lock
);

// Thresholds
localparam integer LOCK_THRESHOLD   = 5;
localparam integer UNLOCK_THRESHOLD = 3;

reg [15:0] model_state;
reg [2:0]  valid_count;
reg [1:0]  invalid_count;

// Task para determinar el proximo estado del lfsr
task [15:0] next_lfsr;
    input [15:0] state;
    begin
        next_lfsr[0]   = state[1] ^ state[2] ^ state[4] ^ state[15];
        next_lfsr[15:1] = state[14:0];
    end
endtask

always @(posedge clk or posedge i_rst)
begin
    if (i_rst)
    begin
        model_state   <=  FIXED_SEED;
        valid_count   <=        3'd0;
        invalid_count <=        2'd0;
        o_lock        <=        1'b0;
    end
    else if (i_soft_reset)
    begin
        model_state   <= i_seed;
        valid_count   <=   3'd0;
        invalid_count <=   2'd0;
        o_lock        <=   1'b0;
    end
    else if (i_valid)
    begin
        if (i_lfsr == next_lfsr(model_state))
        begin
            model_state  <= i_lfsr;
            invalid_count <= 2'd0;

            if (valid_count == LOCK_THRESHOLD - 1)
            begin
                o_lock      <= 1'b1;
                valid_count <= valid_count;
            end
            else
            begin
                valid_count <= valid_count + 1'b1;
            end
        end
        else
        begin
            valid_count <= 3'd0;

            if (invalid_count == UNLOCK_THRESHOLD - 1)
            begin
                o_lock        <= 1'b0;
                invalid_count <= invalid_count;
            end
            else
            begin
                invalid_count <= invalid_count + 1'b1;
            end
        end
    end
end

endmodule