module lfsr_checker #(
    parameter [15:0] FIXED_SEED        = 16'hFFFF,
    parameter integer LOCK_THRESHOLD   = 5,
    parameter integer UNLOCK_THRESHOLD = 3
)
(
    input  wire        clk,
    input  wire        i_rst,         // Reset asincrónico 
    input  wire        i_soft_reset,  // Reset sincrónico 
    input  wire        i_valid,       // Habilitador de cálculo (Clock Enable)
    input  wire [15:0] i_seed,        // Semilla externa dinámica
    input  wire [15:0] i_lfsr,        // Combinación obtenida del LFSR
    output wire        o_lock         // Estado de sincronización del enlace
);

    // Estado que el checker espera que tenga el LFSR
    reg [15:0] model_state;
    
    // Contadores 
    reg [3:0]  valid_count;
    reg [3:0]  invalid_count;
    
    // Registro que representa el estado de lockeado, es decir
    // cuando el checker y el LFSR están sincronizados
    reg        lock_reg;

    // Cable para el feedback del LFSR
    wire       feedback;
    assign feedback = model_state[1] ^ model_state[2] ^ model_state[4] ^ model_state[15];

    // Estados candidatos para el próximo ciclo.
    wire [15:0] internal_next_state;
    wire [15:0] absorbed_next_state;
    assign internal_next_state  = {model_state[14:0], feedback};
    assign absorbed_next_state  = {i_lfsr[14:0], (i_lfsr[1] ^ i_lfsr[2] ^ i_lfsr[4] ^ i_lfsr[15])};

    always @(posedge clk or posedge i_rst) 
    begin

        if (i_rst)
        begin
            model_state   <= FIXED_SEED;
            valid_count   <= 4'd0;
            invalid_count <= 4'd0;
            lock_reg      <= 1'b0; // Inicia en estado deslockeado
        end

        else if (i_soft_reset) begin
            model_state   <= i_seed;
            valid_count   <= 4'd0;
            invalid_count <= 4'd0;
            lock_reg      <= 1'b0;
        end

        else if (i_valid) begin
            // Evaluación ciclo a ciclo contra el flujo entrante
            if (i_lfsr == model_state) 
            begin
                // Coincidencia: Dato válido
                // Se asigna el feedback (próximo estado esperado) al model state
                model_state   <= internal_next_state;
                invalid_count <= 4'd0; // Se resetea la cuenta de errores consecutivos
                
                // Si lock_reg = 0, es decir, no está lockeado
                if (!lock_reg) 

                // Se realiza la lógica para lockear o sumar uno a la cuenta de aciertos
                // consecutivos, según corresponda
                begin
                    // Si la cuenta es igual al threshold de lockeo, se lockea
                    if (valid_count == LOCK_THRESHOLD - 1'b1) 
                    begin
                        lock_reg    <= 1'b1; // Bloquea tras N aciertos, o sea, lock_reg = 1
                        valid_count <= 4'd0; // Se resetea la cuenta de aciertos consecutivos
                    end 
                    // Si la cuenta no es igual al threshold de lockeo, se suma uno a valid_count
                    else begin
                        valid_count <= valid_count + 1'b1;
                    end
                end
            end 
            
            // Si no coinciden la informacion entrante del LFSR con el model state del checker
            else begin
                // Si está lockeado, el modelo sigue avanzando con su propio feedback
                // para mantener el efecto Flywheel. Si no lo está, absorbe el dato
                // entrante para intentar resincronizarse.
                if (lock_reg)
                    model_state <= internal_next_state;
                else
                    model_state <= absorbed_next_state;

                valid_count   <= 4'd0; // Resetea aciertos consecutivos
                
                // Si el checker estaba en estado de lock
                if (lock_reg) 
                begin
                    // En caso de que la cuenta de no-aciertos consecutivos sea igual a UNLOCK_THRESHOLD
                    if (invalid_count == UNLOCK_THRESHOLD - 1'b1) 
                    begin
                        lock_reg      <= 1'b0; // Desbloquea tras M errores, es decir, se pone lock_reg = 0
                        invalid_count <= 4'd0; // Reseteo cuenta de no-aciertos
                    end 
                    // Si la cuenta de no-aciertos es menor al UNLOCK_THRESHOLD
                    else begin
                        invalid_count <= invalid_count + 1'b1; // Sumo uno a la cuenta
                    end
                end
                else begin
                    invalid_count <= 4'd0;
                end
            end
        end
    end

    // El valor de lock_reg lo asigno a o_lock a modo de bandera
    assign o_lock = lock_reg;

endmodule