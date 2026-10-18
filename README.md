# hexk-dv-template

A starting point for a SystemVerilog/UVM verification project that runs on free tools: lint,
elaboration, unit tests and a UVM testbench, green in CI from the first push.

- **Tools:** the [hexk-dv-toolbox](https://github.com/hexkDotCom/hexk-dv-toolbox) image, with
  Verilator 5.046, slang, Verible, SVUnit and the UVM sources at versions that work together.
- **Library:** [hexk-sv-lib](https://github.com/hexkDotCom/hexk-sv-lib), fetched at a pinned
  release: base test, report server, scoreboard, valid/ready agent, checks.
- **Style:** the code follows the
  [HEXK SystemVerilog/UVM style guide](https://github.com/hexkDotCom/sv-uvm-style-guide); rule
  IDs such as `CFG-2` in the comments point into it.

Press **Use this template** on GitHub, or copy the files. The example DUT squares a number;
replace it with yours and keep the structure.

## Run

With Docker (or Podman), from the root of your copy:

```bash
docker run --rm -it -u $(id -u):$(id -g) -v "$PWD":/work -w /work ghcr.io/hexkdotcom/hexk-dv-toolbox:2026.10.0 make ci
```

In VS Code, **Reopen in Container** uses `.devcontainer/devcontainer.json`, the same image;
GitHub Codespaces does too. Without a container, install the tools listed in the toolbox README
and run `make` directly.

| Target | What it does |
|---|---|
| `make deps` | fetches hexk-sv-lib and, outside the image, the UVM sources into `build/` |
| `make format` | formats every SystemVerilog file with Verible |
| `make lint` | format check, Verible lint with the style guide rules, Verilator `-Wall` lint |
| `make elab` | slang elaboration of the testbench against UVM 1.2 and UVM 2020, warnings as errors |
| `make test` | SVUnit unit tests on Verilator |
| `make sim` | builds and runs `TEST=square_smoke_test` on Verilator with UVM 2020 |
| `make ci` | `lint elab test sim`: what the CI workflow runs |

`make sim SIM=questa UVM=1.2` and `make sim SIM=vcs UVM=2020` build and run the same test on
Questa or VCS, if you have them; `SEED=` and `PLUSARGS=` pass a seed and plusargs, such as
`PLUSARGS=+num_items=1000`. A run passes when the banner of the test says `SIMULATION PASSED`
and the simulator reported no error of its own.

## Layout

| Path | Content |
|---|---|
| `rtl/` | the DUT |
| `model/` | the reference model, plain SystemVerilog without UVM, and the widths of the DUT |
| `tb/square_out_agent/` | a passive agent for the output of the DUT: interface, item, monitor |
| `tb/env/` | the env: input agent (from hexk-sv-lib), predictor, scoreboard, coverage, sequences |
| `tb/tests/` | the base test and the tests |
| `tb/square_tb.sv`, `tb/square_tb.f` | the testbench top and the file list |
| `tests/unit/` | SVUnit unit tests |
| `lint/` | Verible, Verilator and slang settings, and the waivers with their reasons |
| `hexk.mk` | the pinned versions of hexk-sv-lib and the UVM sources |
| `.github/workflows/ci.yml` | CI in the toolbox image |

## Adapting it

1. Put your design in `rtl/` and its widths and model in `model/`; rename `square` throughout.
2. Write an agent per interface of the DUT, or use those of hexk-sv-lib (valid/ready,
   clock/reset, pins).
3. Keep one test per file in `tb/tests/`; a test gives its stimulus in `create_stimulus()`.
4. To move to a newer hexk-sv-lib, change `HEXK_SV_LIB_VERSION` and `HEXK_SV_LIB_COMMIT` in
   `hexk.mk`; to a newer toolbox, the image tag in the workflow, the dev container and here.

## Known limits of Verilator 5.046

The testbench is written so that it simulates on Verilator. What that takes:

- UVM 2020 only (Verilator cannot compile UVM 1.2), with `UVM_HDL_NO_DPI` and
  `UVM_CMDLINE_NO_DPI`; the testbench top reads `+UVM_TESTNAME` itself.
- One instance per agent interface type: with several instances of the same interface,
  Verilator wakes the tasks of one on events of another. That is why the output of the DUT
  has an interface of its own instead of a second valid/ready interface.
- No functional coverage: Verilator ignores covergroups; Questa and VCS collect them.
- No soft-constraint override with `randomize() with`: the smoke test sets `num_items` with
  `rand_mode(0)` instead.

## License

0BSD: use it for anything, without attribution. hexk-sv-lib, which `make deps` fetches, is
Apache-2.0.
