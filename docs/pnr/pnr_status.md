# PnR Status — mspm33c321a_derivative_mcu (Run v2)

**Last Updated:** 2026-05-31
**Run Tag:** pnr_run_v2
**Status:** SYNTHESIS IN PROGRESS

## Pre-run Fixes Applied (Session Restart Recovery)

| Fix | Description |
|-----|-------------|
| IP paths updated | All 48 `/workspace/.../ip/` paths → `/nc/ip/<NAME>/<VERSION>/` |
| CF_SRAM LEF/lib/GDS updated | → `/nc/ip/CF_SRAM_1024x32/v2.2.0-nc/` |
| RUN_CTS=false | Correct librelane 3.x gating variable (replaces invalid SKIP_STEPS) |
| RUN_POST_CTS_RESIZER_TIMING=false | No post-CTS resizer since CTS is skipped |
| amuxbus ports removed | 100 inout amuxbus_a/b declarations removed from wrapper.v (prevents GPL-0326) |
| mcu_chip.v added | Now included in VERILOG_FILES (82 total) |
| FP_TEMPLATE_COPY_POWER_PINS=false | Prevents DRT-0302 VDDIO bterm error |
| DRT_OPT_ITERS=40 | Reduced from default 64 for faster convergence |

## Synthesis Scope
- Synthesised: wrapper glue, compute_ss, hazard3 CPU (22 files), OpenDAP SWD debug (7 files), NC_* IPs (48 files)
- Black-boxed: CF_SRAM_1024x32 (32 instances, hard macro)
- Excluded: padframe/IO cells (chip-top level), sky130 stdcell lib (tech mapping target)

## Current Progress
- Step 03: Yosys.Synthesis — IN PROGRESS (PID 20756)
- Expected synthesis duration: ~20-30 minutes
- Expected total PnR duration: ~12-20 hours

## Run Directory
`mspm33c321a_derivative_mcu/openlane/mspm33c321a_derivative_mcu_wrapper/runs/pnr_run_v2/`
