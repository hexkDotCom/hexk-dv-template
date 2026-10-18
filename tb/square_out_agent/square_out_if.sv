// SPDX-License-Identifier: 0BSD
//
// square_out_if.sv
//
// The output of the square DUT: a result is valid in a clock cycle in which out_valid is 1;
// there is no back-pressure. The monitor of square_out_agent samples it through
// wait_for_result(), so the class itself has no pin-level code (guide IFC-8).

`ifndef SQUARE_OUT_IF_SV
`define SQUARE_OUT_IF_SV

interface square_out_if
   import square_model_pkg::*;
(
    input logic clk,
    input logic rst_n
);
   timeunit 1ns; timeprecision 1ps;

   // 1 in a cycle with a result.
   logic    out_valid;

   // The result; meaningful only while out_valid is 1.
   result_t out_data;

   clocking mon_cb @(posedge clk);
      input rst_n, out_valid, out_data;
   endclocking : mon_cb

   // Returns at the next rising edge of clk at which a result is valid outside reset, with that result.
   task automatic wait_for_result(output result_t result);
      do begin
         @(mon_cb);
      end while (!(mon_cb.rst_n && mon_cb.out_valid));
      result = mon_cb.out_data;
   endtask : wait_for_result

   // A result is never X or Z.
   out_data_known_a :
   assert property (@(posedge clk) disable iff (!rst_n) out_valid |-> !$isunknown(out_data))
   else $error("square_out_if: out_data is X or Z while out_valid is 1");

endinterface : square_out_if

`endif  // SQUARE_OUT_IF_SV
