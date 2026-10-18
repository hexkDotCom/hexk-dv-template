// SPDX-License-Identifier: 0BSD
//
// square_env_pkg.sv
//
// Package of square_env and its sequences. Compile after UVM, hexk-sv-lib
// (src/hexk_all.f), square_model_pkg and square_out_pkg.

`ifndef SQUARE_ENV_PKG_SV
`define SQUARE_ENV_PKG_SV

`include "hexk_macros.svh"

package square_env_pkg;
   timeunit 1ns; timeprecision 1ps;

   `include "uvm_macros.svh"
   import uvm_pkg::*;

   // The input agent and its parts, for the width of the operands (guide REU-6).
   typedef hexk_valid_ready_pkg::hexk_valid_ready_agent#(square_model_pkg::IN_WIDTH) in_agent_t;
   typedef hexk_valid_ready_pkg::hexk_valid_ready_agent_cfg#(square_model_pkg::IN_WIDTH) in_agent_cfg_t;
   typedef hexk_valid_ready_pkg::hexk_valid_ready_item#(square_model_pkg::IN_WIDTH) in_item_t;

   // The scoreboard of the results.
   typedef hexk_uvm_pkg::hexk_scoreboard#(square_out_pkg::square_out_item) scoreboard_t;

   `include "square_env_cfg.sv"
   `include "square_traffic_seq.sv"
   `include "square_predictor.sv"
   `include "square_coverage.sv"
   `include "square_env.sv"

endpackage : square_env_pkg

`endif  // SQUARE_ENV_PKG_SV
