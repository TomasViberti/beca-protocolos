`define TEST1

`ifdef TEST1

localparam NB_LFSR_STEPS = 65535;

reg [15:0] initial_state;

initial
begin
	// Inicializamos las variables
	i_rst        <= 1'b0;
	i_soft_reset <= 1'b0;
	i_valid      <= 1'b0;
	i_seed       <= 16'h0001;

	// Llamamos a la task reset
	reset();

	#1ns;

	// Guardamos el estado inicial de la salida del lfsr
	initial_state <= o_lfsr;
	i_valid <= 1'b1;

	// Iteramos por la cantidad de steps
	// Consultar si es necesario iterar 100 veces todo lo de abajo, porque ya con la cantidad de combinaciones
    // hay muchas iteraciones

	// Debemos verificar la salida del LFSR con una señal o_valid, CAMBIAR
	for (integer i = 0; i < NB_LFSR_STEPS; i = i + 1)
	begin
		@(posedge clk);
		#1ns;

		// Verificamos si antes de recorrer todas las combinaciones vuelve al estado incial
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
	i_valid <= 1'b0;
	#1ns;

	// Verificamos si al volver a iniciar vuelve al estado inicial
	if (o_lfsr != initial_state)
	begin
		$display("ERROR: El generador no volvio a la seed inicial luego de completar el periodo.");
		$display("Seed inicial: %h", initial_state);
		$display("Salida actual: %h", o_lfsr);
		$display("TEST FAILED");
		$finish(2);
	end

	$display("TEST PASSED");
	$finish();
end

`endif
