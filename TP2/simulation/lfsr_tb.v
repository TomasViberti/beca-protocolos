`timescale 1ns / 1ns

module tb_lfsr_fibonacci;

    // Declaración de señales
    reg clk;
    reg i_rst;           // Reset asincrónico
    reg i_soft_reset;    // Reset sincrónico
    reg i_valid;         // Habilitador aleatorio
    reg [15:0] i_seed;
    wire [15:0] o_lfsr;

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

    // Clock 10MHz (T = 100ns)
    initial clk = 0;
    always #50 clk = ~clk;

    // Task para reset asincrónico (tiempo entre 1us y 250us)
    task reset;
        time reset_time;
        begin
            i_valid = 1'b0;
            i_soft_reset = 1'b0;
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

    // Inclusión de tests
    //`include "../tests/test_lfsr_period.sv"
    `include "../tests/test_lfsr_perior_random_seed.sv"

endmodule