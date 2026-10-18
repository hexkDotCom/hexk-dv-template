// SPDX-License-Identifier: 0BSD
//
// square_out_pkg.sv
//
// Package of square_out_agent, the passive agent of the output of the square DUT.
// Compile square_out_if.sv and this file after square_model_pkg and UVM.

`ifndef SQUARE_OUT_PKG_SV
`define SQUARE_OUT_PKG_SV

package square_out_pkg;
   timeunit 1ns; timeprecision 1ps;

   `include "uvm_macros.svh"
   import uvm_pkg::*;

   `include "square_out_item.sv"
   `include "square_out_agent_cfg.sv"
   `include "square_out_monitor.sv"
   `include "square_out_agent.sv"

endpackage : square_out_pkg

`endif  // SQUARE_OUT_PKG_SV
