// SPDX-License-Identifier: 0BSD
//
// square_model_pkg.sv
//
// Reference model of the square DUT, in plain SystemVerilog without UVM, so that it is
// unit-tested with SVUnit on its own and used by the predictor of the testbench. The widths
// of the DUT are defined here once; the RTL, the interfaces and the testbench take them from
// this package.

`ifndef SQUARE_MODEL_PKG_SV
`define SQUARE_MODEL_PKG_SV

package square_model_pkg;

   // Width of an operand at the input of the DUT.
   localparam int unsigned IN_WIDTH  = 8;

   // Width of a result at the output of the DUT: the square of the widest operand fits.
   localparam int unsigned OUT_WIDTH = 2 * IN_WIDTH;

   // Clock cycles from the transfer of an operand to its result; the DUT takes no operand meanwhile.
   localparam int unsigned LATENCY   = 2;

   // An operand.
   typedef logic [IN_WIDTH-1:0] operand_t;

   // A result.
   typedef logic [OUT_WIDTH-1:0] result_t;

   // The result that the DUT gives for an operand.
   function automatic result_t square(operand_t operand);
      return result_t'(operand) * result_t'(operand);
   endfunction : square

endpackage : square_model_pkg

`endif  // SQUARE_MODEL_PKG_SV
