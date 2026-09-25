# ISSCC2027_USG10p

Open-source design and measurement data for this ISSCC 2027 submission — a
4-Level Split-Resonant high-voltage ultrasound pulser for low-Q charging-path
operation.

## Contents
- **`open_design/`** — digital controller RTL (Verilog): the on-chip FSM that
  sequences the pulser's rail / PASS / HOLD / IDLE switches and the passive
  diode-recovery phases, with scan-configurable timing.
- **`open_data.zip`** — measured oscilloscope waveforms (CSV) behind the paper's
  measurement figure: the 4-level output staircase and inductor current, and the
  arbitrary-pattern demos. See the `README.md` inside the archive for per-file
  column maps and units.
