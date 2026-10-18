// SPDX-License-Identifier: 0BSD
//
// square_traffic_seq.sv
//
// Sends num_items operands to the square DUT through the input agent: first zero and the
// largest operand, where a multiplier goes wrong and which a uniform draw rarely gives, then
// random ones. Start it on the sequencer of the input agent.

`ifndef SQUARE_TRAFFIC_SEQ_SV
`define SQUARE_TRAFFIC_SEQ_SV

class square_traffic_seq extends uvm_sequence #(in_item_t);

   // The largest number of operands that one sequence sends.
   localparam int unsigned MAX_ITEMS = 10_000;

   // Number of operands.
   rand int unsigned num_items;

   constraint num_items_cstr {num_items inside {[1 : MAX_ITEMS]};}

   `uvm_object_utils(square_traffic_seq)

   function new(string name = "square_traffic_seq");
      super.new(name);
   endfunction : new

   // The operands that come first, in this order.
   localparam square_model_pkg::operand_t CORNERS[2] = '{'0, '1};

   task body();
      for (int unsigned i = 0; i < num_items; i++) begin
         in_item_t item = in_item_t::type_id::create("item");
         start_item(item);
         `hexk_randomize_or_fatal(item, "SQUARE_SEQ_RAND")
         if (i < $size(CORNERS)) begin
            item.data = CORNERS[i];
         end
         finish_item(item);
      end
   endtask : body

endclass : square_traffic_seq

`endif  // SQUARE_TRAFFIC_SEQ_SV
