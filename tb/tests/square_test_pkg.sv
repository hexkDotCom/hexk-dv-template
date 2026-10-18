// SPDX-License-Identifier: 0BSD
//
// square_test_pkg.sv
//
// Package of the tests of the square block. Add a test as a file here and an include below.

`ifndef SQUARE_TEST_PKG_SV
`define SQUARE_TEST_PKG_SV

`include "hexk_macros.svh"

package square_test_pkg;
   timeunit 1ns; timeprecision 1ps;

   `include "uvm_macros.svh"
   import uvm_pkg::*;

   `include "square_base_test.sv"
   `include "square_smoke_test.sv"

endpackage : square_test_pkg

`endif  // SQUARE_TEST_PKG_SV
