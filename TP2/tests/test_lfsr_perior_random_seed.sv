`define TEST2

`ifdef TEST2

localparam NB_LFSR_STEPS   = 65535;
localparam NB_RANDOM_SEEDS = 8;

reg [15:0] initial_state;
reg [15:0] random_seed;

initial
begin
    i_rst        = 1'b0;
    i_soft_reset = 1'b0;
    i_valid      = 1'b0;
    i_seed       = 16'h0001;

    reset();

    for (integer k = 0; k < NB_RANDOM_SEEDS; k = k + 1)
    begin
        random_seed = $urandom_range(1, 16'hFFFF);

        load_seed(random_seed);
        soft_reset();

        #1;
        initial_state = o_lfsr;

        // Debemos verificar la salida del LFSR con una señal o_valid, CAMBI
        if (initial_state != random_seed)
        begin
            $display("ERROR: La seed cargada no coincide con la seed observada en salida.");
            $display("Seed cargada: %h", random_seed);
            $display("Seed observada: %h", initial_state);
            $display("TEST FAILED");
            $finish(2);
        end

        i_valid = 1'b1;

        for (integer i = 0; i < NB_LFSR_STEPS; i = i + 1)
        begin
            @(posedge clk);
            #1;

            if ((i < (NB_LFSR_STEPS - 1)) && (o_lfsr == initial_state))
            begin
                $display("ERROR: El generador repitio el patron antes de completar el periodo.");
                $display("Seed inicial: %h", initial_state);
                $display("Paso: %0d", i + 1);
                $display("TEST FAILED");
                $finish(2);
            end
        end

        i_valid = 1'b0;
        #1;

        if (o_lfsr != initial_state)
        begin
            $display("ERROR: El generador no volvio a la seed inicial luego de completar el periodo.");
            $display("Seed inicial: %h", initial_state);
            $display("Salida actual: %h", o_lfsr);
            $display("TEST FAILED");
            $finish(2);
        end
    end

    $display("TEST PASSED");
    $finish();
end

`endif
`define TEST2

`ifdef TEST2

localparam NB_LFSR_STEPS    = 65535;
localparam NB_RANDOM_SEEDS  = 8;

reg [15:0] initial_state;
reg [15:0] random_seed;

initial
begin
    // Inicializamos variables
    i_rst        = 1'b0;
    i_soft_reset = 1'b0;
    i_valid      = 1'b0;
    i_seed       = 16'h0001;

    // Llamada a la task reset
    reset();

    // Iteramos por la cantidad de seed posibles con valores de seed random
    // Consultar si es necesario iterar 100 veces todo lo de abajo, porque ya con la cantidad de combinaciones
    // hay muchas iteraciones
    for (integer k = 0; k < NB_RANDOM_SEEDS; k = k + 1)
    begin
        random_seed = $urandom_range(1, 16'hFFFF);

        // Mediante las tasks hacemos una carga de la seed y un soft reset
        load_seed(random_seed);
        soft_reset();

        #1;
        // Guardamos el estado inicial de la salida del lfsr
        initial_state = o_lfsr;

        // Si el estado inicial es distinto de la random seed que se generó es porque falló.
        if (initial_state != random_seed)
        begin
            $display("ERROR: La seed cargada no coincide con la seed observada en salida.");
            $display("Seed cargada: %h", random_seed);
            $display("Seed observada: %h", initial_state);
            $display("TEST FAILED");
            $finish(2);
        end
        
        // Si la seed random se cargó bien, habilitamos la señal valid
        i_valid = 1'b1;

        // Iteramos por la cantidad de steps
        for (integer i = 0; i < NB_LFSR_STEPS; i = i + 1)
        begin
            @(posedge clk);
            #1ns;

            // Si durante la ejecución el ouput vuelve a ser igual al estado inicial antes de recorrer todas
            // las combinaciones posibles se produce un error
            if ((i < (NB_LFSR_STEPS - 1)) && (o_lfsr == initial_state))
            begin
                $display("ERROR: El generador repitio el patron antes de completar el periodo.");
                $display("Seed inicial: %h", initial_state);
                $display("Paso: %0d", i + 1);
                $display("TEST FAILED");
                $finish(2);
            end
        end

        // Desactivamos la señal habilitadora
        i_valid = 1'b0;
        #1;

        // Verificamos que al volver a iniciar la secuencia comience igual
        if (o_lfsr != initial_state)
        begin
            $display("ERROR: El generador no volvio a la seed inicial luego de completar el periodo.");
            $display("Seed inicial: %h", initial_state);
            $display("Salida actual: %h", o_lfsr);
            $display("TEST FAILED");
            $finish(2);
        end
    end

    $display("TEST PASSED");
    $finish();
end

`endif