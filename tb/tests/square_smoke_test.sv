// SPDX-License-Identifier: 0BSD
//
// square_smoke_test.sv
//
// Sends +num_items random operands (200 by default) through the DUT; every result must
// match the model. Run it with +UVM_TESTNAME=square_smoke_test.

`ifndef SQUARE_SMOKE_TEST_SV
`define SQUARE_SMOKE_TEST_SV

class square_smoke_test extends square_base_test;

   `uvm_component_utils(square_smoke_test)

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   // The number of operands is the knob num_items, so it is kept out of the randomization.
   virtual function uvm_sequence_base create_stimulus();
      square_env_pkg::square_traffic_seq seq = square_env_pkg::square_traffic_seq::type_id::create("seq");
      seq.num_items.rand_mode(0);
      seq.num_items = 32'(knobs.get_int("num_items"));
      return seq;
   endfunction : create_stimulus

endclass : square_smoke_test

`endif  // SQUARE_SMOKE_TEST_SV
