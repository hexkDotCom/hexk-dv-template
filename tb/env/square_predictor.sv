// SPDX-License-Identifier: 0BSD
//
// square_predictor.sv
//
// Turns every operand that the input agent saw into the result that the DUT must give,
// computed by square_model_pkg, and writes it to ap for the scoreboard.

`ifndef SQUARE_PREDICTOR_SV
`define SQUARE_PREDICTOR_SV

class square_predictor extends uvm_subscriber #(in_item_t);

   // One expected result per operand.
   uvm_analysis_port #(square_out_pkg::square_out_item) ap;

   `uvm_component_utils(square_predictor)

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      ap = new("ap", this);
   endfunction : build_phase

   function void write(in_item_t t);
      square_out_pkg::square_out_item expected = square_out_pkg::square_out_item::type_id::create("expected");
      expected.result = square_model_pkg::square(t.data);
      ap.write(expected);
   endfunction : write

endclass : square_predictor

`endif  // SQUARE_PREDICTOR_SV
