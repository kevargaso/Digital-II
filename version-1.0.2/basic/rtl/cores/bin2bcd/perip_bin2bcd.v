module peripheral_bin2bcd(clk, reset, d_in, cs, addr, rd, wr, d_out);
  
  // Parámetros para bin2bcd
  parameter INPUT_WIDTH = 16;     // Ancho de entrada binaria (16 bits)
  parameter DECIMAL_DIGITS = 5;   // 5 dígitos decimales para la salida BCD
  
  // Interfaz de bus (igual que peripheral_div)
  input clk;
  input reset;
  input [15:0] d_in;
  input cs;
  input [4:0] addr;      // 4 LSB from j1_io_addr
  input rd;
  input wr;
  output reg [31:0] d_out;

  //------------------------------------ regs and wires-------------------------------
  reg [4:0] s;          // selector mux_4 and write registers
  reg [15:0] binary_input;  // Valor binario a convertir
  reg init;             // Señal para iniciar la conversión
  wire [DECIMAL_DIGITS*4-1:0] bcd_output; // Resultado BCD del módulo
  wire done;            // Señal de conversión completada
  //------------------------------------ regs and wires-------------------------------

  always @(*) begin//------address_decoder------------------------------
    if (cs) begin
      case (addr)
        5'h04: s = 5'b00001; // binary_input 
        5'h08: s = 5'b00100; // init
        5'h0C: s = 5'b01000; // bcd_output (resultado)
        5'h10: s = 5'b10000; // done
        default: s = 5'b00000;
      endcase
    end
    else 
      s = 5'b00000;
  end//------------------address_decoder--------------------------------

  always @(posedge clk) begin//-------------------- escritura de registros 
    if(reset) begin
      init = 0;
      binary_input = 0;
    end
    else begin
      if (cs && wr) begin
         binary_input = s[0] ? d_in : binary_input;  // Write Binary Input Register
         init = s[2] ? d_in[0] : init;               // Write Init bit
      end
    end
  end//------------------------------------------- escritura de registros

  always @(posedge clk) begin//-----------------------mux_4 :  multiplexa salidas del periferico
    if(reset)
      d_out = 0;
    else if (cs && rd) begin
      case (s[4:0])
        5'b01000: d_out = {12'b0, bcd_output};     // BCD output (20 bits en LSB)
        5'b10000: d_out = {31'b0, done};           // Done flag
        default: d_out = 32'h00000000;
      endcase
    end
  end//-----------------------------------------------mux_4

  // Instanciación del módulo bin2bcd
  bin2bcd #(
    .INPUT_WIDTH(INPUT_WIDTH),
    .DECIMAL_DIGITS(DECIMAL_DIGITS)
  ) bin2bcd_inst (
    .i_Clock(clk),
    .i_Binary(binary_input),
    .i_Start(init),
    .o_BCD(bcd_output),
    .o_DV(done)
  );

endmodule
