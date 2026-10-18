# SPDX-License-Identifier: 0BSD
#
# Makefile - lint, elaboration, unit tests and simulation of the square block with free tools
# (Verilator, slang, Verible, SVUnit), as in the hexk-dv-toolbox image, and simulation on
# Questa or VCS for those who have them. 'make help' lists the targets.

SHELL         := /bin/bash
.SHELLFLAGS   := -eu -o pipefail -c
.DEFAULT_GOAL := help

PROJECT_ROOT := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
export PROJECT_ROOT
BUILD_DIR ?= $(PROJECT_ROOT)/build

include $(PROJECT_ROOT)/hexk.mk

VERILATOR      ?= verilator
SLANG          ?= slang
VERIBLE_FORMAT ?= verible-verilog-format
VERIBLE_LINT   ?= verible-verilog-lint
SVUNIT         ?= runSVUnit
QUESTA_VLIB    ?= vlib
QUESTA_VLOG    ?= vlog
QUESTA_VSIM    ?= vsim
VCS            ?= vcs

# make sim: the simulator, the UVM version (Verilator compiles UVM 2020 only), the test and its plusargs.
SIM      ?= verilator
UVM      ?= 2020
TEST     ?= square_smoke_test
SEED     ?= 1
PLUSARGS ?=

TOP      := square_tb
TB_F     := $(PROJECT_ROOT)/tb/square_tb.f
SV_FILES := $(shell cd $(PROJECT_ROOT) && find model rtl tb tests -name '*.sv' | sort)
UVM_HOME := $(UVM_ROOT)/$(UVM)

# What UVM needs on Verilator: no HDL access and no command-line DPI (hexk_tb_top_inc.svh reads
# +UVM_TESTNAME itself), and only the regular-expression part of the UVM DPI code.
VERILATOR_UVM := +define+UVM_HDL_NO_DPI +define+UVM_CMDLINE_NO_DPI \
                 $(HEXK_SV_LIB_HOME)/tests/unit/hexk_uvm_regex_dpi.cc -CFLAGS -I$(UVM_ROOT)/2020/src/dpi

# Questa on Windows (Git Bash, MinGW-w64 GCC): the UVM DPI code needs a POSIX regex.h, which
# hexk-sv-lib provides for its own tests.
ifeq ($(OS),Windows_NT)
QUESTA_CCFLAGS = -DQUESTA -I$(HEXK_SV_LIB_HOME)/tests/unit/mingw_compat
QUESTA_LDFLAGS = -ldflags -lstdc++
else
QUESTA_CCFLAGS = -DQUESTA
QUESTA_LDFLAGS =
endif

# Warnings in UVM and hexk-sv-lib belong to those projects.
SLANG_QUIET = --suppress-warnings '$(UVM_HOME)/src/...' --suppress-macro-warnings '$(UVM_HOME)/src/...' \
              --suppress-warnings '$(HEXK_SV_LIB_HOME)/...' --suppress-macro-warnings '$(HEXK_SV_LIB_HOME)/...'
QUIET_VLT   = $(BUILD_DIR)/third_party.vlt

.PHONY: help deps format format_check lint lint_verible lint_verilator elab test sim ci clean

help:
	@echo "make deps          fetch hexk-sv-lib v$(HEXK_SV_LIB_VERSION) and the UVM sources that are missing"
	@echo "make format        format every SystemVerilog file with Verible"
	@echo "make lint          format check, Verible lint, Verilator lint"
	@echo "make elab          slang elaboration against UVM 1.2 and UVM 2020"
	@echo "make test          SVUnit unit tests on Verilator"
	@echo "make sim           build and run TEST=$(TEST) on SIM=$(SIM) (verilator|questa|vcs), UVM=$(UVM) (1.2|2020)"
	@echo "make ci            lint, elab, test and sim on Verilator: what CI runs"
	@echo "make clean         remove $(BUILD_DIR) except the fetched dependencies"

deps: $(HEXK_DEPS)

$(QUIET_VLT): $(HEXK_DEPS)
	@printf '%s\n' '`verilator_config' 'lint_off -file "$(UVM_ROOT)/*"' 'lint_off -file "$(HEXK_SV_LIB_HOME)/*"' \
	   'lint_off -rule INITIALDLY -file "*/uvm_globals.svh"' > $@

format:
	@cd $(PROJECT_ROOT) && $(VERIBLE_FORMAT) --flagfile=lint/.verible-format --inplace $(SV_FILES)

format_check:
	@echo "== format check (verible-verilog-format --verify)"
	@cd $(PROJECT_ROOT) && $(VERIBLE_FORMAT) --flagfile=lint/.verible-format --inplace --verify $(SV_FILES)

lint: format_check lint_verible lint_verilator

lint_verible:
	@echo "== lint (verible-verilog-lint)"
	@cd $(PROJECT_ROOT) && $(VERIBLE_LINT) --rules_config=lint/.rules.verible_lint $(SV_FILES)

lint_verilator: $(QUIET_VLT)
	@echo "== lint (verilator --lint-only -Wall): design"
	@cd $(PROJECT_ROOT) && $(VERILATOR) --lint-only -Wall lint/verilator.vlt model/square_model_pkg.sv rtl/square.sv \
	   --top-module square
	@echo "== lint (verilator --lint-only -Wall): testbench with UVM 2020"
	@# UNUSEDSIGNAL is off for the testbench: Verilator reports class members as unused that are only read through a
	@# handle of another class.
	@$(VERILATOR) --lint-only -Wall -Wno-UNUSEDSIGNAL --timing --timescale 1ns/1ps $(PROJECT_ROOT)/lint/verilator.vlt $(QUIET_VLT) \
	   +incdir+$(UVM_ROOT)/2020/src +define+UVM_HDL_NO_DPI +define+UVM_CMDLINE_NO_DPI $(UVM_ROOT)/2020/src/uvm_pkg.sv \
	   -f $(HEXK_SV_LIB_HOME)/src/hexk_all.f -f $(TB_F) --top-module $(TOP)

elab: $(HEXK_DEPS)
	@for version in 1.2 2020; do \
	   echo "== elab (slang, UVM $$version)"; \
	   $(MAKE) --no-print-directory elab_one UVM=$$version; \
	done

.PHONY: elab_one
elab_one:
	@$(SLANG) -f $(PROJECT_ROOT)/lint/slang.f $(SLANG_QUIET) --top $(TOP) \
	   +incdir+$(UVM_HOME)/src $(UVM_HOME)/src/uvm_pkg.sv -f $(HEXK_SV_LIB_HOME)/src/hexk_all.f -f $(TB_F)

test:
	@echo "== test (SVUnit on Verilator)"
	@mkdir -p $(BUILD_DIR)/svunit
	@cd $(PROJECT_ROOT)/tests/unit && $(SVUNIT) -s verilator -o $(BUILD_DIR)/svunit \
	   -f $(PROJECT_ROOT)/tests/unit/unit.f -c_arg "-j 0" > $(BUILD_DIR)/svunit/test.log 2>&1 || true
	@grep -E '^%Error|^%Warning|FAILED|tests passing|suites passing' $(BUILD_DIR)/svunit/test.log || true
	@grep -q '\[testrunner\]: PASSED' $(BUILD_DIR)/svunit/test.log || \
	   { echo "test: FAILED (log: $(BUILD_DIR)/svunit/test.log)"; exit 1; }

SIM_DIR := $(BUILD_DIR)/sim_$(SIM)_uvm$(UVM)
SIM_LOG := $(SIM_DIR)/$(TEST)_$(SEED).log

# A run passes when the simulator exits with 0, the banner of hexk_base_test says SIMULATION PASSED,
# and the simulator itself reported no error.
define check_run
	@grep -q 'SIMULATION PASSED' $(SIM_LOG) && ! grep -qE '$(1)' $(SIM_LOG) || \
	   { grep -E 'UVM_(ERROR|FATAL) |$(1)|TEST (PASSED|FAILED)' $(SIM_LOG) | head -20; \
	     echo "sim: $(TEST) FAILED (log: $(SIM_LOG))"; exit 1; }
	@grep -E 'TEST PASSED' $(SIM_LOG)
	@echo "sim: $(TEST) passed on $(SIM) with UVM $(UVM) (log: $(SIM_LOG))"
endef

sim: $(HEXK_DEPS) $(QUIET_VLT)
	@echo "== sim $(TEST) ($(SIM), UVM $(UVM), seed $(SEED))"
	@mkdir -p $(SIM_DIR)
ifeq ($(SIM),verilator)
	@test "$(UVM)" = 2020 || { echo "sim: Verilator cannot compile UVM $(UVM); use UVM=2020"; exit 1; }
	@$(VERILATOR) --binary -j 0 --timing --timescale 1ns/1ps -Wno-fatal -Mdir $(SIM_DIR)/obj_dir -o $(TOP) \
	   $(PROJECT_ROOT)/lint/verilator.vlt $(QUIET_VLT) +incdir+$(UVM_HOME)/src $(UVM_HOME)/src/uvm_pkg.sv \
	   $(VERILATOR_UVM) -f $(HEXK_SV_LIB_HOME)/src/hexk_all.f -f $(TB_F) --top-module $(TOP) \
	   > $(SIM_DIR)/build.log 2>&1 || { tail -30 $(SIM_DIR)/build.log; exit 1; }
	@$(SIM_DIR)/obj_dir/$(TOP) +UVM_TESTNAME=$(TEST) +verilator+seed+$(SEED) $(PLUSARGS) > $(SIM_LOG) 2>&1 || \
	   { tail -30 $(SIM_LOG); echo "sim: the simulator exited with an error (log: $(SIM_LOG))"; exit 1; }
	$(call check_run,^%Error)
else ifeq ($(SIM),questa)
	@cd $(SIM_DIR) && $(QUESTA_VLIB) work > /dev/null && \
	   $(QUESTA_VLOG) -sv -quiet -timescale 1ns/1ps -l compile.log +incdir+$(UVM_HOME)/src $(UVM_HOME)/src/uvm_pkg.sv \
	      $(UVM_HOME)/src/dpi/uvm_dpi.cc -ccflags "$(QUESTA_CCFLAGS)" -f $(HEXK_SV_LIB_HOME)/src/hexk_all.f -f $(TB_F) \
	      > /dev/null || { grep -E '^\*\* (Error|Fatal)' compile.log; exit 1; }
	@cd $(SIM_DIR) && $(QUESTA_VSIM) -c $(QUESTA_LDFLAGS) -sv_seed $(SEED) $(TOP) +UVM_TESTNAME=$(TEST) $(PLUSARGS) \
	   -do "run -all; quit -f" > $(SIM_LOG) 2>&1 || { tail -30 $(SIM_LOG); exit 1; }
	$(call check_run,^# \*\* (Error|Fatal))
else ifeq ($(SIM),vcs)
	@cd $(SIM_DIR) && $(VCS) -full64 -sverilog -timescale=1ns/1ps -q -l compile.log \
	   +incdir+$(UVM_HOME)/src $(UVM_HOME)/src/uvm_pkg.sv $(UVM_HOME)/src/dpi/uvm_dpi.cc -CFLAGS -DVCS \
	   -f $(HEXK_SV_LIB_HOME)/src/hexk_all.f -f $(TB_F) -top $(TOP) > /dev/null || { grep -E '^Error' compile.log; exit 1; }
	@cd $(SIM_DIR) && ./simv +ntb_random_seed=$(SEED) +UVM_TESTNAME=$(TEST) $(PLUSARGS) > $(SIM_LOG) 2>&1 || \
	   { tail -30 $(SIM_LOG); exit 1; }
	$(call check_run,^(Error|Fatal))
else
	@echo "sim: SIM=$(SIM) is not one of verilator, questa, vcs"; exit 1
endif

ci: lint elab test sim

clean:
	@rm -rf $(BUILD_DIR)/svunit $(BUILD_DIR)/sim_* $(QUIET_VLT)
