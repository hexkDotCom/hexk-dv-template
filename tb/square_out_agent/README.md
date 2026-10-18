# square_out_agent

Passive agent of the output of the square DUT: `square_out_if` (out_valid, out_data, a
clocking block for sampling and an assertion that a valid result is never X or Z), and a
monitor that writes one `square_out_item` to `ap` per result.

- Use: create `square_out_agent`, set `cfg` (a `square_out_agent_cfg` with `vif`) before
  `build_phase`, connect `ap`.
- Knobs: none; the agent is always passive, since the DUT drives the output.
- Limits: the interface has no back-pressure; a DUT whose output has a ready signal needs an
  active responder, such as the valid/ready agent of hexk-sv-lib (on Verilator 5.046 only if no
  other instance of that interface is in the testbench).
