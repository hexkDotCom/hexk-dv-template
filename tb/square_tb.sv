// SPDX-License-Identifier: 0BSD
//
// square_tb.sv
//
// Testbench top of the square block: clock and reset, the interfaces, the DUT, and the
// include of hexk-sv-lib that installs its report server and calls run_test() with
// +UVM_TESTNAME (guide IFC-9, TST-4). The inputs of the DUT come from the channel signals
// of the valid/ready interface; what the DUT drives on that channel goes to its ext_ inputs.

`include "hexk_macros.svh"

module square_tb;
   timeunit 1ns; timeprecision 1ps;

   import uvm_pkg::*;
   // Without a reference from the top, a simulator may leave the test package out of the
   // elaboration, and +UVM_TESTNAME finds no test (Questa: INVTST).
   import square_test_pkg::*;

   localparam time CLK_PERIOD = 10ns;
   localparam time RESET_TIME = 22ns;

   bit clk;
   bit rst_n;

   always #(CLK_PERIOD / 2) clk = !clk;

   initial begin
      #RESET_TIME;
      rst_n = 1'b1;
   end

   hexk_valid_ready_if #(
       .DATA_WIDTH(square_model_pkg::IN_WIDTH)
   ) in_if (
       .clk  (clk),
       .rst_n(rst_n)
   );

   square_out_if out_if (
       .clk  (clk),
       .rst_n(rst_n)
   );

   square dut (
       .clk      (clk),
       .rst_n    (rst_n),
       .in_valid (in_if.valid),
       .in_ready (in_if.ext_ready),
       .in_data  (in_if.data),
       .out_valid(out_if.out_valid),
       .out_data (out_if.out_data)
   );

   // Called by the include before run_test().
   function automatic void publish_interfaces();
      `hexk_vif_set(hexk_valid_ready_if#(square_model_pkg::IN_WIDTH), "uvm_test_top", "in_vif", in_if)
      `hexk_vif_set(square_out_if, "uvm_test_top", "out_vif", out_if)
   endfunction : publish_interfaces

   `define HEXK_TB_PRE_RUN_TEST publish_interfaces
   `include "base/hexk_tb_top_inc.svh"

endmodule : square_tb
