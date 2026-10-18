// SPDX-License-Identifier: 0BSD
//
// square_out_item.sv
//
// One result at the output of the square DUT, as the monitor saw it or as the predictor
// expects it. Compared by its result only.

`ifndef SQUARE_OUT_ITEM_SV
`define SQUARE_OUT_ITEM_SV

class square_out_item extends uvm_sequence_item;

   // The result.
   square_model_pkg::result_t result;

   `uvm_object_utils(square_out_item)

   function new(string name = "square_out_item");
      super.new(name);
   endfunction : new

   // The result on one line.
   function string convert2string();
      return $sformatf("result=0x%0h", result);
   endfunction : convert2string

   function void do_copy(uvm_object rhs);
      square_out_item other;
      super.do_copy(rhs);
      if (!$cast(other, rhs)) begin
         `uvm_fatal("SQUARE_OUT_COPY", "do_copy() from an object that is not a square_out_item")
      end
      result = other.result;
   endfunction : do_copy

   function bit do_compare(uvm_object rhs, uvm_comparer comparer);
      square_out_item other;
      bit             same;
      if (!$cast(other, rhs)) begin
         return 0;
      end
      same = super.do_compare(rhs, comparer);
      same &= comparer.compare_field_int("result", 64'(result), 64'(other.result), $bits(result));
      return same;
   endfunction : do_compare

   function void do_print(uvm_printer printer);
      super.do_print(printer);
      printer.print_field_int("result", 64'(result), $bits(result), UVM_HEX);
   endfunction : do_print

endclass : square_out_item

`endif  // SQUARE_OUT_ITEM_SV
