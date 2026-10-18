// SPDX-License-Identifier: 0BSD
//
// square_out_monitor.sv
//
// Writes one square_out_item to ap for every result at the output of the DUT.

`ifndef SQUARE_OUT_MONITOR_SV
`define SQUARE_OUT_MONITOR_SV

class square_out_monitor extends uvm_monitor;

   // One item per result.
   uvm_analysis_port #(square_out_item) ap;

   // Configuration, set by the agent before build_phase.
   square_out_agent_cfg                 cfg;

   `uvm_component_utils(square_out_monitor)

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (cfg == null || cfg.vif == null) begin
         `uvm_fatal("SQUARE_OUT_CFG", "the monitor has no cfg or no interface")
      end
      ap = new("ap", this);
   endfunction : build_phase

   task run_phase(uvm_phase phase);
      forever begin
         square_out_item item = square_out_item::type_id::create("item");
         cfg.vif.wait_for_result(item.result);
         `uvm_info("SQUARE_OUT_ITEM", item.convert2string(), UVM_HIGH)
         ap.write(item);
      end
   endtask : run_phase

endclass : square_out_monitor

`endif  // SQUARE_OUT_MONITOR_SV
