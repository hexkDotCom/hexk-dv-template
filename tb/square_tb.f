// SPDX-License-Identifier: 0BSD
//
// square_tb.f - the design and the testbench, after UVM and hexk-sv-lib (src/hexk_all.f).
// Needs $PROJECT_ROOT, the root of this repository (the Makefile sets it).

+incdir+${PROJECT_ROOT}/tb/square_out_agent
+incdir+${PROJECT_ROOT}/tb/env
+incdir+${PROJECT_ROOT}/tb/env/sequences
+incdir+${PROJECT_ROOT}/tb/tests

${PROJECT_ROOT}/model/square_model_pkg.sv
${PROJECT_ROOT}/rtl/square.sv
${PROJECT_ROOT}/tb/square_out_agent/square_out_if.sv
${PROJECT_ROOT}/tb/square_out_agent/square_out_pkg.sv
${PROJECT_ROOT}/tb/env/square_env_pkg.sv
${PROJECT_ROOT}/tb/tests/square_test_pkg.sv
${PROJECT_ROOT}/tb/square_tb.sv
