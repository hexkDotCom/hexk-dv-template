// SPDX-License-Identifier: 0BSD
//
// square_out_agent.sv
//
// Passive agent of the output of the square DUT: a monitor and its analysis port.

`ifndef SQUARE_OUT_AGENT_SV
`define SQUARE_OUT_AGENT_SV

class square_out_agent extends uvm_agent;

   // One item per result; the port of the monitor.
   uvm_analysis_port #(square_out_item) ap;

   // Configuration; set by the parent before build_phase.
   square_out_agent_cfg                 cfg;

   // The monitor.
   square_out_monitor                   mon;

   `uvm_component_utils(square_out_agent)

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   function uvm_active_passive_enum get_is_active();
      return UVM_PASSIVE;
   endfunction : get_is_active

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (cfg == null) begin
         `uvm_fatal("SQUARE_OUT_CFG", "the agent has no cfg")
      end
      mon     = square_out_monitor::type_id::create("mon", this);
      mon.cfg = cfg;
   endfunction : build_phase

   function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      ap = mon.ap;
   endfunction : connect_phase

endclass : square_out_agent

`endif  // SQUARE_OUT_AGENT_SV
