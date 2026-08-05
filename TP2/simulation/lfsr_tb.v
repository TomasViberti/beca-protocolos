`timescale 1ns / 1ns

module tb_lfsr_fibonacci;

    // Declaración de señales
    reg clk;
    reg i_rst;           // Reset asincrónico
    reg i_soft_reset;    // Reset sincrónico
    reg i_valid;         // Habilitador aleatorio
    reg [15:0] i_seed;
    wire [15:0] o_lfsr;
    wire [15:0] checker_i_lfsr;
    wire        o_lock;

    reg         checker_inject_invalid;
    reg [15:0]  checker_inject_value;
    reg         o_lock_prev;

    localparam integer CHECKER_LOCK_THRESHOLD   = 5;
    localparam integer CHECKER_UNLOCK_THRESHOLD = 3;

    reg [15:0] exp_model_state;
    reg [3:0]  exp_valid_count;
    reg [3:0]  exp_invalid_count;
    reg        exp_lock;

    // Instancia del módulo
    lfsr_fibonacci 
    u_lfsr_fibonacci (
        .clk(clk),
        .i_rst(i_rst),
        .i_soft_reset(i_soft_reset),
        .i_valid(i_valid),
        .i_seed(i_seed),
        .o_lfsr(o_lfsr)
    );

    // Instancia del checker
    lfsr_checker
    u_lfsr_checker (
        .clk(clk),
        .i_rst(i_rst),
        .i_soft_reset(i_soft_reset),
        .i_valid(i_valid),
        .i_seed(i_seed),
        .i_lfsr(checker_i_lfsr),
        .o_lock(o_lock)
    );

    assign checker_i_lfsr = checker_inject_invalid ? checker_inject_value : o_lfsr;

    // Clock 10MHz (T = 100ns)
    initial clk = 0;
    always #50 clk = ~clk;

    // Monitoreo del estado de lock del checker
    task monitor_o_lock;
        begin
            o_lock_prev = 1'b0;

            forever begin
                @(posedge clk);
                #1;

                if (o_lock !== o_lock_prev) begin
                    $display("INFO: o_lock cambio a %b en %0t", o_lock, $time);
                    o_lock_prev = o_lock;
                end
            end
        end
    endtask

    // Task para reset asincrónico (tiempo entre 1us y 250us)
    task reset;
        time reset_time;
        begin
            i_valid = 1'b0;
            i_soft_reset = 1'b0;
            checker_inject_invalid = 1'b0;
            checker_inject_value = 16'h0000;
            i_rst = 1;
            reset_time = $urandom_range(1000, 250000);
            #reset_time;
            i_rst = 0;
            @(posedge clk);
            #1;
        end
    endtask

    // Task para reset sincrónico
    task soft_reset;
        begin
            i_valid = 1'b0;
            checker_inject_invalid = 1'b0;
            @(posedge clk);
            i_soft_reset = 1;
            #($urandom_range(1000, 250000));
            i_soft_reset = 0;
            @(posedge clk);
            #1;
        end
    endtask

    // Task para cargar semilla
    task load_seed(input [15:0] seed_val);
        begin
            @(posedge clk);
            i_seed = seed_val;
            #1;
        end
    endtask

    initial begin
        o_lock_prev = 1'b0;
        fork
            monitor_o_lock();
        join_none
    end

    // Inclusión de tests
    
    //`include "../tests/test_lfsr_period.sv"
    `include "../tests/test_lfsr_perior_random_seed.sv"
    //`include "../tests/test_lfsr_checker3.sv"
    //`include "../tests/test_lfsr_checker4.sv"
    //`include "../tests/test_lfsr_checker5.sv"
    //`include "../tests/test_lfsr_checker6.sv"
    //`include "../tests/test_lfsr_checker7.sv"
    //`include "../tests/test_lfsr_checker8.sv"

endmodule