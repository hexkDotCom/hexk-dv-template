// SPDX-License-Identifier: 0BSD
//
// square_env.sv
//
// Environment of the square DUT: an initiator agent of hexk-sv-lib at the input, a passive
// agent at the output, a predictor and an in-order hexk_scoreboard between them, and
// coverage of the operands. The parent sets cfg, and aggregator if the scoreboard should
// keep the phase alive until every expected result has arrived (guide OBJ-2), before
// build_phase. Works as the top env and inside a bigger one (guide REU-1).

`ifndef SQUARE_ENV_SV
`define SQUARE_ENV_SV

class square_env extends uvm_env;

   // Configuration; set by the parent before build_phase.
   square_env_cfg                          cfg;

   // The objection aggregator of the test; null: the scoreboard holds no objection.
   hexk_uvm_pkg::hexk_objection_aggregator aggregator;

   // Agent at the input; null when cfg.has_in_agent is 0.
   in_agent_t                              in_agent;

   // Agent at the output; null when cfg.has_out_agent is 0.
   square_out_pkg::square_out_agent        out_agent;

   // Predicts the results; null unless both agents are there.
   square_predictor                        predictor;

   // Compares the results with the predicted ones; null unless both agents are there.
   scoreboard_t                            sb;

   // Coverage of the operands; null when cfg.has_coverage is 0 or there is no input agent.
   square_coverage                         coverage;

   `uvm_component_utils(square_env)

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (cfg == null) begin
         `uvm_fatal("SQUARE_ENV_CFG", "the env has no cfg")
      end
      build_agents();
      build_checkers();
   endfunction : build_phase

   function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      if (sb != null) begin
         in_agent.ap.connect(predictor.analysis_export);
         predictor.ap.connect(sb.expected_export);
         out_agent.ap.connect(sb.actual_export);
      end
      if (coverage != null) begin
         in_agent.ap.connect(coverage.analysis_export);
      end
   endfunction : connect_phase

   local function void build_agents();
      if (cfg.has_in_agent) begin
         in_agent     = in_agent_t::type_id::create("in_agent", this);
         in_agent.cfg = cfg.in_cfg;
      end
      if (cfg.has_out_agent) begin
         out_agent     = square_out_pkg::square_out_agent::type_id::create("out_agent", this);
         out_agent.cfg = cfg.out_cfg;
      end
   endfunction : build_agents

   local function void build_checkers();
      if (cfg.has_in_agent && cfg.has_out_agent) begin
         predictor     = square_predictor::type_id::create("predictor", this);
         sb            = scoreboard_t::type_id::create("sb", this);
         sb.cfg        = cfg.sb_cfg;
         sb.aggregator = aggregator;
      end
      if (cfg.has_in_agent && cfg.has_coverage) begin
         coverage = square_coverage::type_id::create("coverage", this);
      end
   endfunction : build_checkers

endclass : square_env

`endif  // SQUARE_ENV_SV
