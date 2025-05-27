`timescale 1ns / 1ps
`include "/home/kevargaso/Documents/Digital II/version 1.0.2/basic/rtl/cores/bin2bcd/bin2bcd.v"

module bin2bcd_tb;
    // Parámetros del test bench
    parameter INPUT_WIDTH = 16;
    parameter DECIMAL_DIGITS = 5;
    parameter CLK_PERIOD = 25000000; // 10ns = 100MHz
    
    // Señales de entrada
    reg i_Clock;
    reg [INPUT_WIDTH-1:0] i_Binary;
    reg i_Start;
    
    // Señales de salida
    wire [DECIMAL_DIGITS*4-1:0] o_BCD;
    wire o_DV;
    
    // Instancia del módulo bajo prueba
    bin2bcd #(
        .INPUT_WIDTH(INPUT_WIDTH),
        .DECIMAL_DIGITS(DECIMAL_DIGITS)
    )uut (
        .i_Clock(i_Clock),
        .i_Binary(i_Binary),
        .i_Start(i_Start),
        .o_BCD(o_BCD),
        .o_DV(o_DV)
    );
    
    // Generación de reloj
    always #(CLK_PERIOD/2) i_Clock = ~i_Clock;
    
    // Variables para el test bench
    integer i;
    reg [INPUT_WIDTH-1:0] test_values [0:9];
    
    // Inicialización
    initial begin
        // Inicializar valores de prueba
        test_values[0] = 16'd0;      // 0
        test_values[1] = 16'd123;    // 123
        test_values[2] = 16'd999;     // 999
        test_values[3] = 16'd4096;   // 4096
        test_values[4] = 16'd32767;   // 32767
        test_values[5] = 16'd65535;   // 65535
        test_values[6] = 16'd10000;   // 10000
        test_values[7] = 16'd5432;    // 5432
        test_values[8] = 16'd888;     // 888
        test_values[9] = 16'd42;      // 42
        
        // Inicializar señales
        i_Clock = 0;
        i_Binary = 0;
        i_Start = 0;
        
        // Iniciar simulación
        #100;
        
        // Probar varios valores
        for (i = 0; i < 10; i = i + 1) begin
            i_Binary = test_values[i];
            #(CLK_PERIOD*20);
            i_Start = 1;
            #(CLK_PERIOD);
            i_Start = 0;
            
            // Esperar hasta que la conversión esté completa
            wait(o_DV == 1);
            #(CLK_PERIOD*5);
            
            // Mostrar resultados en consola
            $display("Binary: %d -> BCD: %x", i_Binary, o_BCD);
            
            // Pequeña pausa entre pruebas
            #(CLK_PERIOD*10);
        end
        
        // Finalizar simulación
        #100;
        $display("Simulación completada");
        $finish;
    end
    
    // Generar archivo VCD para GTKWave
    initial begin
        $dumpfile("bin2bcd_tb.vcd");
        $dumpvars(0, bin2bcd_tb);
    end
endmodule