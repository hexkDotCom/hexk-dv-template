// SPDX-License-Identifier: 0BSD
//
// square_out_agent_cfg.sv
//
// Configuration of square_out_agent: the interface. The agent is always passive (the DUT
// drives the output), so there is no is_active.

`ifndef SQUARE_OUT_AGENT_CFG_SV
`define SQUARE_OUT_AGENT_CFG_SV

class square_out_agent_cfg extends uvm_object;

   // The interface of the agent; mandatory.
   virtual square_out_if vif;

   `uvm_object_utils(square_out_agent_cfg)

   function new(string name = "square_out_agent_cfg");
      super.new(name);
   endfunction : new

endclass : square_out_agent_cfg

`endif  // SQUARE_OUT_AGENT_CFG_SV
