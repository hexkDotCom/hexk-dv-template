# AGENTS.md

Instructions for AI coding assistants working in this repository.

- The code follows the HEXK SystemVerilog/UVM style guide:
  https://github.com/hexkDotCom/sv-uvm-style-guide (`sv_uvm_style_guide.md`). Cite the rule ID
  when you deviate, and add a waiver with its reason in `lint/` rather than switching a check off.
- The testbench uses hexk-sv-lib (fetched into `build/hexk-sv-lib` by `make deps`); read
  `build/hexk-sv-lib/llms.txt` and `docs/api/<module>.md` there before using a module.
- Everything must pass `make ci` in the hexk-dv-toolbox image: format, Verible and Verilator lint,
  slang elaboration against UVM 1.2 and 2020, unit tests, and the smoke test on Verilator.
- Verilator 5.046 limits that shape the code are listed in `README.md`; keep to them.
- Do not claim a test passed unless you ran it and saw `SIMULATION PASSED`.
