module mux_basico (
    input wire [3:0]    a,
    input wire [3:0]    b,
    input wire        sel,
    output reg [3:0]  out    
);

always @(*) begin
    if (sel) begin //El begin y el end son como los corchetes "{}" en otros lenguajes. Se pueden prescindir si solo hay una línea de código, pero es buena práctica usarlos
        out = a;
    end else begin
        out = b;
    end
endmodule


