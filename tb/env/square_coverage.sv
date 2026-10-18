// SPDX-License-Identifier: 0BSD
//
// square_coverage.sv
//
// Functional coverage of the operands that reached the DUT: zero, the largest operand, and
// small and large ones in between. The covergroup is created unless the knob coverage is
// 0 (+coverage=0). Verilator does not build covergroups; Questa and VCS do.

`ifndef SQUARE_COVERAGE_SV
`define SQUARE_COVERAGE_SV

class square_coverage extends uvm_subscriber #(in_item_t);

   localparam square_model_pkg::operand_t MAX_OPERAND = '1;

   covergroup operand_cg with function sample (square_model_pkg::operand_t operand);
      option.per_instance = 1;
      operand_cp: coverpoint operand {
         bins zero = {0};
         bins small_values = {[1 : MAX_OPERAND / 2]};
         bins large_values = {[MAX_OPERAND / 2 + 1 : MAX_OPERAND - 1]};
         bins max_value = {MAX_OPERAND};
      }
   endgroup : operand_cg

   `uvm_component_utils(square_coverage)

   function new(string name, uvm_component parent);
      super.new(name, parent);
      `hexk_cg_new(operand_cg)
   endfunction : new

   function void write(in_item_t t);
      if (operand_cg != null) begin
         operand_cg.sample(t.data);
      end
   endfunction : write

endclass : square_coverage

`endif  // SQUARE_COVERAGE_SV
