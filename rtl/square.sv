// SPDX-License-Identifier: 0BSD
//
// square.sv
//
// The example DUT: takes an operand on a valid/ready channel and gives its square
// LATENCY clock cycles later, as a one-cycle pulse of out_valid with out_data. While it
// computes, in_ready is 0, so the sender sees back-pressure after every operand.
// Replace it with your design; the widths come from square_model_pkg.

`ifndef SQUARE_SV
`define SQUARE_SV

module square
   import square_model_pkg::*;
(
    input  logic     clk,
    input  logic     rst_n,
    input  logic     in_valid,
    output logic     in_ready,
    input  operand_t in_data,
    output logic     out_valid,
    output result_t  out_data
);

   localparam int unsigned COUNT_WIDTH = $clog2(LATENCY + 1);

   operand_t                   operand;
   logic     [COUNT_WIDTH-1:0] cycles_left;

   assign in_ready = (cycles_left == '0);

   always_ff @(posedge clk or negedge rst_n) begin
      if (!rst_n) begin
         operand     <= '0;
         cycles_left <= '0;
         out_valid   <= 1'b0;
         out_data    <= '0;
      end else begin
         out_valid <= 1'b0;
         if (in_valid && in_ready) begin
            operand     <= in_data;
            cycles_left <= COUNT_WIDTH'(LATENCY);
         end else if (cycles_left != '0) begin
            cycles_left <= cycles_left - 1'b1;
            if (cycles_left == COUNT_WIDTH'(1)) begin
               out_valid <= 1'b1;
               out_data  <= result_t'(operand) * result_t'(operand);
            end
         end
      end
   end

endmodule : square

`endif  // SQUARE_SV
