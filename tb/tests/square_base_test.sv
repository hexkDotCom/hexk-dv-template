// SPDX-License-Identifier: 0BSD
//
// square_base_test.sv
//
// Base test of the square block, on hexk_base_test of hexk-sv-lib, which brings the report
// server, the knobs, the watchdog, the objection aggregator and the TEST PASSED / TEST FAILED
// verdict. This class creates the cfg of the env, fetches the interfaces, builds the env and
// says where the stimulus of a test starts; a test only gives its stimulus in
// create_stimulus() (guide TST-1, TST-2). Every test checks in check_phase that each operand
// it sent was compared (guide TST-6).

`ifndef SQUARE_BASE_TEST_SV
`define SQUARE_BASE_TEST_SV

class square_base_test extends hexk_uvm_pkg::hexk_base_test;

   // The env of the block.
   square_env_pkg::square_env     env;

   // The cfg of the env, as the base test randomized it.
   square_env_pkg::square_env_cfg cfg;

   `uvm_component_utils(square_base_test)

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   virtual function void define_knobs();
      knobs.add_int("num_items", 200, "operands that a test sends to the DUT", 1,
                    longint'(square_env_pkg::square_traffic_seq::MAX_ITEMS));
   endfunction : define_knobs

   virtual function uvm_object create_cfg();
      return square_env_pkg::square_env_cfg::type_id::create("cfg");
   endfunction : create_cfg

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!$cast(cfg, block_cfg)) begin
         `uvm_fatal("SQUARE_TEST_CFG", "create_cfg() did not return a square_env_cfg")
      end
      `hexk_vif_get_or_fatal(hexk_valid_ready_if#(square_model_pkg::IN_WIDTH), "in_vif", cfg.in_cfg.vif)
      `hexk_vif_get_or_fatal(square_out_if, "out_vif", cfg.out_cfg.vif)
      // A result that never comes is an error after 1 us, instead of a run phase that never ends.
      cfg.sb_cfg.max_wait_ps     = `hexk_ps(1us);
      watchdog.global_timeout_ps = `hexk_ps(10ms);
      env                        = square_env_pkg::square_env::type_id::create("env", this);
      env.cfg                    = cfg;
      env.aggregator             = objections;
   endfunction : build_phase

   virtual function uvm_sequencer_base stimulus_sequencer();
      return env.in_agent.sqr;
   endfunction : stimulus_sequencer

   // Every operand that the stimulus sent was compared with its result.
   function void check_phase(uvm_phase phase);
      hexk_uvm_pkg::hexk_sb_stats stats = env.sb.get_stats();
      super.check_phase(phase);
      `hexk_check_eq(stats.matched, expected_matches(), "SQUARE_MATCHED")
   endfunction : check_phase

   // The number of results that the scoreboard must have matched at the end of the test.
   virtual function int unsigned expected_matches();
      return 32'(knobs.get_int("num_items"));
   endfunction : expected_matches

endclass : square_base_test

`endif  // SQUARE_BASE_TEST_SV
