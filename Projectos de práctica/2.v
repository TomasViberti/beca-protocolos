module contador_sincrono (
    input wire         clk,
    input wire       rst_n,
    inout wire      enable,
    output reg [7:0] count
);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        count <= 8'd0;
    end else if (enable) begin 
        count <= count + 8'd1;
    end
end
endmodule