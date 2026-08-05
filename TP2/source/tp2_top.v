module tp2_top
#(
    parameter [15:0] FIXED_SEED = 16'hFFFF,
    parameter integer LOCK_THRESHOLD = 5,
    parameter integer UNLOCK_THRESHOLD = 3
)
(
    input  wire        clk,
    input  wire        i_rst,
    input  wire        i_soft_reset,
    input  wire        i_valid,
    input  wire [15:0] i_seed,
    output wire        o_lock,
    output wire [15:0] o_lfsr
);

    lfsr_fibonacci #(
        .FIXED_SEED(FIXED_SEED)
    ) u_lfsr_fibonacci (
        .clk(clk),
        .i_soft_reset(i_soft_reset),
        .i_rst(i_rst),
        .i_valid(i_valid),
        .i_seed(i_seed),
        .o_lfsr(o_lfsr)
    );

    lfsr_checker #(
        .FIXED_SEED(FIXED_SEED),
        .LOCK_THRESHOLD(LOCK_THRESHOLD),
        .UNLOCK_THRESHOLD(UNLOCK_THRESHOLD)
    ) u_lfsr_checker (
        .clk(clk),
        .i_rst(i_rst),
        .i_soft_reset(i_soft_reset),
        .i_valid(i_valid),
        .i_seed(i_seed),
        .i_lfsr(o_lfsr),
        .o_lock(o_lock)
    );

endmodule