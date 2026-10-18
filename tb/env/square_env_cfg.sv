// SPDX-License-Identifier: 0BSD
//
// square_env_cfg.sv
//
// Configuration of square_env: the cfgs of its agents and of its scoreboard, and which
// parts the env builds. The test creates it (through create_cfg() of the base test), which
// randomizes it once; the env passes the parts down by assignment (guide CFG-1 to CFG-3).

`ifndef SQUARE_ENV_CFG_SV
`define SQUARE_ENV_CFG_SV

class square_env_cfg extends uvm_object;

   // Cfg of the agent at the input, an initiator of the valid/ready channel.
   rand in_agent_cfg_t                  in_cfg;

   // Cfg of the passive agent at the output.
   square_out_pkg::square_out_agent_cfg out_cfg;

   // Cfg of the scoreboard that compares the results with the predicted ones.
   hexk_uvm_pkg::hexk_scoreboard_cfg    sb_cfg;

   // 1: the env builds the agent at the input; 0 when a parent env sends the operands.
   bit                                  has_in_agent  = 1;

   // 1: the env builds the agent at the output.
   bit                                  has_out_agent = 1;

   // 1: the env builds the coverage of the operands.
   bit                                  has_coverage  = 1;

   `uvm_object_utils(square_env_cfg)

   function new(string name = "square_env_cfg");
      super.new(name);
      in_cfg  = in_agent_cfg_t::type_id::create("in_cfg");
      out_cfg = square_out_pkg::square_out_agent_cfg::type_id::create("out_cfg");
      sb_cfg  = hexk_uvm_pkg::hexk_scoreboard_cfg::type_id::create("sb_cfg");
   endfunction : new

endclass : square_env_cfg

`endif  // SQUARE_ENV_CFG_SV
