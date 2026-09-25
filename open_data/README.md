# Open measurement data — 4-Level Split-Resonant HV ultrasound pulser

Raw oscilloscope captures behind the measured waveforms in Fig. 5 of the
paper. Chip: 180 nm BCD, 2-channel, driven at 30 V / 40 kHz.

Each file is a Tektronix scope CSV export. **The first 17 rows are scope
metadata** (model, per-channel settings, sample interval, etc.); the
waveform samples begin after the `TIME,...` label row. In Python:

```python
import numpy as np
raw = np.genfromtxt("<file>.csv", delimiter=",", skip_header=17)
t = raw[:, 0]        # time, seconds
```

Time is in **seconds**; all channel/MATH values are in **volts**.

---

## 1. `staircase_IL_1p9nF_PZT.csv`
*(original capture: 2026-09-08 bench, `Tek3000_002_ALL.csv`, scope MSO44B)*

The 4-level V_TX staircase and inductor current, driving the **real
1.9 nF air-coupled bulk-PZT** load. Backs the top panel of Fig. 5
("4-level staircase + inductor current, 1.9 nF PZT · 50 Ω sense").

| Column | Signal | Units | Notes |
|--------|--------|-------|-------|
| 0 | TIME | s | |
| 1 | CH1 | V | aux (not plotted) |
| 2 | **CH3 = V_TX** | V | 30 V 4-level staircase output |
| 3 | (empty) | — | export separator |
| 4 | TIME | s | duplicate time base for the MATH block |
| 5 | **MATH1 = 50 Ω sense** | V | voltage across the 50 Ω series sense resistor |

Inductor current: **I_L [mA] = (MATH1 − baseline) / 50 Ω × 1000**, where
`baseline` is the small V_TX-correlated offset removed by a linear fit over
the flat (non-charging) intervals. Sense resistor = **50 Ω**.

## 2. `arb_patterns_duty_2nF.csv`
*(original capture: 2026-09-07 bench, `Tek2000_007_ALL.csv`)*

Arbitrary-waveform demo, frame A: pulse-width control at 40 kHz
(**50 % / 40 / 60 % duty**), on the **2 nF ceramic dummy** load. Backs the
lower-left panel of Fig. 5 ("Supports arbitrary TX patterns").

## 3. `arb_patterns_PRF_phaseskip_2nF.csv`
*(original capture: 2026-09-07 bench, `Tek2000_008_ALL.csv`)*

Arbitrary-waveform demo, frame B: timing agility — **40 kHz → 20 kHz PRF**
change and a **half-period phase skip**, on the **2 nF ceramic dummy**
load. Backs the lower-right panel of Fig. 5.

Column map for files 2 and 3 (scope channels CH1–CH4 + MATH2):

| Column | Signal | Units | Notes |
|--------|--------|-------|-------|
| 0 | TIME | s | |
| 1 | CH1 | V | aux |
| 2 | **CH2 = V_TX** | V | pulser output (the plotted trace) |
| 3 | CH3 | V | aux |
| 4 | CH4 | V | aux |
| 5 | (empty) | — | export separator |
| 6 | TIME | s | duplicate time base for the MATH block |
| 7 | MATH2 | V | 25 Ω-shunt sense (I_L), not used in this panel |

---

### Loads
- **1.9 nF air-coupled bulk PZT** — the real, pessimistic application load
  (file 1).
- **2 nF ceramic dummy capacitor** — a fixed, purely-capacitive load used
  for the arbitrary-pattern demos (files 2, 3), the same capacitive basis
  reported by prior art.
