# env

`square_env`: the valid/ready initiator agent of hexk-sv-lib at the input of the DUT, the
passive `square_out_agent` at its output, a predictor that computes each expected result with
`square_model_pkg`, an in-order `hexk_scoreboard`, and coverage of the operands. Sequences are in
`sequences/`, one per file.

- Use: set `cfg` (a `square_env_cfg`) and, so that the scoreboard holds the phase until every
  expected result has arrived, `aggregator` before `build_phase`.
- Knobs (`square_env_cfg`): `in_cfg`, `out_cfg` and `sb_cfg` for the parts; `has_in_agent`,
  `has_out_agent` and `has_coverage` to leave parts out when the env is used inside a bigger
  one. The predictor and the scoreboard need both agents.
- Limits: coverage is collected on Questa and VCS only; Verilator 5.046 ignores covergroups.
