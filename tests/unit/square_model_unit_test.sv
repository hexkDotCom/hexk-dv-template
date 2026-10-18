// SPDX-License-Identifier: 0BSD
//
// square_model_unit_test.sv
//
// SVUnit tests of square_model_pkg: the reference model is checked on its own, before the
// testbench relies on it. Results are compared as text, which reads well in a failure
// message and avoids width warnings of Verilator. Run with 'make test'.

`include "svunit_defines.svh"

module square_model_unit_test;
   import svunit_pkg::svunit_testcase;
   import square_model_pkg::square;
   import square_model_pkg::operand_t;

   string          name = "square_model_ut";
   svunit_testcase svunit_ut;

   function automatic void build();
      svunit_ut = new(name);
   endfunction : build

   task automatic setup();
      svunit_ut.setup();
   endtask : setup

   task automatic teardown();
      svunit_ut.teardown();
   endtask : teardown

   // Decimal text of the square of an operand, as the model computes it.
   function automatic string square_text(operand_t operand);
      return $sformatf("%0d", square(operand));
   endfunction : square_text

   `SVUNIT_TESTS_BEGIN

   `SVTEST(zero)
   `FAIL_UNLESS_STR_EQUAL(square_text(8'd0), "0")
   `SVTEST_END

   `SVTEST(one)
   `FAIL_UNLESS_STR_EQUAL(square_text(8'd1), "1")
   `SVTEST_END

   `SVTEST(small_operand)
   `FAIL_UNLESS_STR_EQUAL(square_text(8'd12), "144")
   `SVTEST_END

   // The largest operand: the result needs every bit of the output.
   `SVTEST(largest_operand)
   `FAIL_UNLESS_STR_EQUAL(square_text(8'd255), "65025")
   `SVTEST_END

   `SVUNIT_TESTS_END

endmodule : square_model_unit_test
