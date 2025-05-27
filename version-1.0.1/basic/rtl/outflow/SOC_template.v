
// Efinity Top-level template
// Version: 2023.2.307
// Date: 2024-09-23 12:37

// Copyright (C) 2013 - 2023 Efinix Inc. All rights reserved.

// This file may be used as a starting point for Efinity synthesis top-level target.
// The port list here matches what is expected by Efinity constraint files generated
// by the Efinity Interface Designer.

// To use this:
//     #1)  Save this file with a different name to a different directory, where source files are kept.
//              Example: you may wish to save as /Work/Proyects/ecb_T8_T113/femtoRV/basic/rtl/SOC.v
//     #2)  Add the newly saved file into Efinity project as design file
//     #3)  Edit the top level entity in Efinity project to:  SOC
//     #4)  Insert design content.


module SOC
(
  input RXD,
  input clk,
  input resetn,
  output LEDS,
  output TXD
);


endmodule

