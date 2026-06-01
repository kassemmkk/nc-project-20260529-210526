# PnR Status — mspm33c321a_derivative_mcu_wrapper

## Run: pnr_run_v2 (resumed)

**Status**: RUNNING — GlobalPlacement completed, post-GPL repair in progress  
**PID**: 84508  
**Log**: /tmp/pnr_gpl.log  
**Run dir**: .../openlane/mspm33c321a_derivative_mcu_wrapper/runs/pnr_run_v2/

## Fixes Applied This Session

| Fix | Description | Status |
|-----|-------------|--------|
| GPL-0326 (first) | Removed `reset_n_pad_a_esd_0_h`, `reset_n_pad_a_noesd_h` from wrapper.v port list | ✅ Applied |
| GPL-0326 (ODB) | Removed same 2 ports from all 13 intermediate ODB files via OpenROAD | ✅ Applied |
| GPL-0326 (netlists) | Patched all 12 intermediate .nl.v/.pnl.v copies in run dir | ✅ Applied |

## Flow Progress

| Step | Description | Status |
|------|-------------|--------|
| 01-03 | Yosys synthesis | ✅ DONE |
| 04-09 | Checkers + STA pre-PnR | ✅ DONE |
| 10-44 | Floorplan → macro placement → PDN → ApplyDEFTemplate | ✅ DONE |
| 45-46 | GlobalPlacement (routability-driven, density=0.5279) | ✅ DONE (overflow ~144) |
| 47-48 | IO placement + power grid check | ✅ DONE |
| 49-50 | STA mid-PnR + RepairDesignPostGPL | 🔄 IN PROGRESS |
| 51+ | DetailedPlacement → GlobalRoute → DRT → Signoff | ⏳ PENDING |

## Global Placement Results

- Final overflow: ~144.7 (GRT-based, routability-driven)
- Overflowed tiles: ~0.74%
- Density: 0.5279
- Convergence: Achieved (routability revert-to-snapshot, then Nesterov settled)
