module lfsr_fibonacci#(
    parameter [15:0] FIXED_SEED = 16'b1
)
(
    input  wire       clk,
    input  wire       i_soft_reset,  // Reset sincrónico
    input  wire       i_rst,         // Reset asincrónico
    input  wire       i_valid,       // Habilitador para calcular
    input  wire [15:0] i_seed,       // Seed ingresada por puerto
    output wire [15:0] o_lfsr        // Salida del lfsr
);   

// Registro para el estado actual del LFSR
reg [15:0] lfsr_reg;

always @(posedge clk or posedge i_rst) 
begin

  // Si se activa por el reset asincronico se asigna la semilla fija
  if(i_rst)
  begin

    lfsr_reg <= FIXED_SEED;

  end 
  // Si se activa por el reset sincronico se asigna la semilla dinámica
  else if(i_soft_reset) begin

    lfsr_reg <= i_seed;

  end 
  // Operación del LFSR con i_valid como habilitador
  else if(i_valid) begin

    // Mediante la secuencia generada con la herramienta asignamos el polinomio
    lfsr_reg[0] <= lfsr_reg[1] ^ lfsr_reg[2] ^ lfsr_reg[4] ^ lfsr_reg[15];
    lfsr_reg[15:1] <= lfsr_reg[14:0];

  end

end

// Asignamos el registro LFSR a la salida
assign o_lfsr = lfsr_reg;

endmodule