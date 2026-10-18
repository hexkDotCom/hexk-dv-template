# tests

`square_base_test` builds the env on `hexk_base_test` of hexk-sv-lib: report server, knobs,
watchdog, objection aggregator and the TEST PASSED / TEST FAILED verdict. A test extends it and
returns its stimulus from `create_stimulus()`; the base test starts it on the input agent under
one objection and checks at the end that every operand was compared.

| Test | What it does |
|---|---|
| `square_smoke_test` | `+num_items` operands (200 by default): zero, the largest one, then random ones |

Select a test with `make sim TEST=<name>`; `+hexk_knobs_help` in `PLUSARGS` lists the knobs.
