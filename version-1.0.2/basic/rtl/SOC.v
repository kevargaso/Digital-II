module SOC (
    input 	     clk,    // system clock 
    input 	     resetn, // reset button
    output wire  LEDS,   // system LEDs
    input 	     RXD,    // UART receive
    output 	     TXD     // UART transmit
);
   wire [31:0] mem_addr;
   reg  [31:0] mem_rdata;
   wire mem_rstrb;
   wire [31:0] mem_wdata;
   wire [3:0]  mem_wmask;

   FemtoRV32 CPU(
      .clk(clk),
      .reset(resetn),		 
      .mem_addr(mem_addr),
      .mem_rdata(mem_rdata),
      .mem_rstrb(mem_rstrb),
      .mem_wdata(mem_wdata),
      .mem_wmask(mem_wmask),
      .mem_rbusy(1'b0),
      .mem_wbusy(1'b0)
   );
   wire [31:0] RAM_rdata;
   wire  wr = |mem_wmask;
   wire  rd = mem_rstrb; 

   bram RAM(
      .clk(clk),
      .mem_addr(mem_addr),
      .mem_rdata(RAM_rdata),
      .mem_rstrb(cs[0] & rd),
      .mem_wdata(mem_wdata),
      .mem_wmask({4{cs[0]}}&mem_wmask)
   );
   wire [31:0] uart_dout;
   wire [31:0] gpio_dout;
   wire [31:0] mult_dout;
   wire [31:0] div_dout;
   wire [31:0] bin2bcd_dout;
   wire [31:0] dpram_dout;


  peripheral_uart #(
     .clk_freq(26000000),    // 27000000 for gowin 33333333 for efinix
     .baud(115200)            // 57600 for gowin
   ) per_uart(
     .clk(clk), 
     .rst(!resetn), 
     .d_in(mem_wdata), 
     .cs(cs[5]), 
     .addr(mem_addr[4:0]), 
     .rd(rd), 
     .wr(wr), 
     .d_out(uart_dout), 
     .uart_tx(TXD), 
     .uart_rx(RXD), 
     .ledout(LEDS)
   ); 

	peripheral_mult mult1 (
		.clk(clk), 
		.reset(!resetn), 
		.d_in(mem_wdata[15:0]), 
		.cs(cs[3]), 
		.addr(mem_addr[4:0]), 
		.rd(rd), 
		.wr(wr), 
		.d_out(mult_dout) 
	);

   peripheral_div div1 (
      .clk(clk),
      .reset(!resetn),
		.d_in(mem_wdata[15:0]), 
		.cs(cs[2]), 
		.addr(mem_addr[4:0]), 
		.rd(rd), 
		.wr(wr), 
		.d_out(div_dout)       
   );

   // Instanciación del periférico bin2bcd
   peripheral_bin2bcd #(
      .INPUT_WIDTH(16),     // Ancho de entrada binaria (16 bits)
      .DECIMAL_DIGITS(5)    // 5 dígitos decimales para la salida BCD
   ) bin2bcd1 (
      .clk(clk),
      .reset(!resetn),
      .cs(cs[1]),           // Chip select para bin2bcd
      .wr(wr), 
      .rd(rd),
      .addr(mem_addr[4:0]), // Direcciones internas del periférico
      .d_in(mem_wdata),
      .d_out(bin2bcd_dout)
   );

/*
   peripheral_dpram dpram_p0( 
      .clk(clk),
      .reset(!resetn),
      .d_in(mem_wdata[15:0]),
      .cs(cs[6]),
      .addr(mem_addr[15:0]),
      .rd(rd),
      .wr(wr),
      .d_out(dpram_dout)
  );
*/
  // ============== Chip_Select (Addres decoder) ======================== 
  // se hace con los 8 bits mas significativos de mem_addr
  // Se asigna el rango de la memoria de programa 0x00000000 - 0x003FFFFF
  // ====================================================================
  reg [6:0]cs;  // CHIP-SELECT
  always @*
  begin
      case (mem_addr[31:16])	// direcciones - chip_select
        16'h0040: cs= 7'b0100000; 	//uart
        16'h0041: cs= 7'b0010000;	//gpio
        16'h0042: cs= 7'b0001000;	//mult
        16'h0043: cs= 7'b0000100;	//div
        16'h0044: cs= 7'b0000010;	//bin_to_bcd
        16'h0045: cs= 7'b1000000;   //dpRAM
        default:  cs= 7'b0000001;    //RAM            
      endcase
  end
  // ============== MUX ========================  // se encarga de lecturas del RV32
  always @*
  begin
      case (cs)
        7'b1000000: mem_rdata = dpram_dout;
        7'b0100000: mem_rdata = uart_dout;
        7'b0010000: mem_rdata = gpio_dout;
        7'b0001000: mem_rdata = mult_dout;
        7'b0000100: mem_rdata = div_dout;
        7'b0000010: mem_rdata = bin2bcd_dout;
        7'b0000001: mem_rdata = RAM_rdata;
        default: mem_rdata = 32'h66666666;
      endcase
  end
 // ============== MUX ========================  // 

`ifdef BENCH
   always @(posedge clk) begin
      if(cs[5] & wr ) begin
	 $write("%c", mem_wdata[7:0] );
	 $fflush(32'h8000_0001);
      end
   end
`endif


endmodule
