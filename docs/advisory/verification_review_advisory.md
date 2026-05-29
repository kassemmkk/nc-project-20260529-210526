# Verification Review Advisory — mspm33c321a_derivative

**Advisory Name (requested):** MCU Factory Verification Review Advisory  
**Advisory Used:** Signoff Advisory (id: `22820a79-9842-4615-8eb0-5e402095555f`)  
**Authorized Match:** Yes — explicitly authorized by orchestrator as functional equivalent  
**Design:** `mspm33c321a_derivative` (`mspm33c321a_deriv`)  
**Design Root:** `mspm33c321a_derivative_mcu/`  
**Run Date:** 2026-05-29  
**Reviewer:** MCU Factory Verification Reviewer

---

## Raw Advisory Output

**VERDICT: GO**

**RATIONALE:**
The signoff evidence for the `mspm33c321a_derivative` is exceptionally clean,
demonstrating RTL readiness for the next design stage. The decision is based on a
100% pass rate across all 21 verification scenarios and 100% completion of the
97-item functional checklist.

Critically, all derivative-specific changes — including the increased Flash and SRAM
sizes and the new I2C2 peripheral instance — were explicitly targeted and passed
verification, confirming the delta changes are correct. All 18 functional domains
are covered.

Non-blocking observations have been reviewed and accepted as benign artifacts of the
verification environment, not functional design defects.

**CONDITIONS:**

- **ADC Verification:** The ADC block was intentionally waived as a mixed-signal
  component, which is appropriate for an RTL-only freeze. Its functional verification
  remains a required task for the subsequent mixed-signal or physical implementation
  signoff.

- **GLS Verification:** Gate-level simulation is correctly excluded from scope and
  will be performed as a standard post-synthesis verification step.

---

## Advisory Input Evidence Summary

| Evidence Item | Value |
|--------------|-------|
| Design | mspm33c321a_derivative |
| Simulator | iverilog 12.0 (Icarus Verilog) |
| Total scenarios | 21 |
| Scenarios PASS | 21 |
| Scenarios FAIL | 0 |
| Checklist items | 97 |
| Checklist PASS | 97 |
| Checklist FAIL | 0 |
| Checklist coverage | 100% |
| Failing tests | 0 — no root-cause classifications needed |
| rework_target | NONE |
| Reviewer verdict | PROCEED_TO_PNR |
| Derivative delta R-003 | PASS — XIP 512 KB verified |
| Derivative delta R-004 | PASS — SRAM 128 KB verified |
| Derivative delta R-005 | WAIVED — mixed-signal, out of scope |
| Derivative delta R-006 | PASS — I2C2 APB connectivity verified |
| Non-blocking observations | 4 (BFM_CHECK readback, SRAM NOTE, $readmemh, CONTENTION SKIP) — all accepted as benign |
| Exclusions | GLS, ADC_12BIT_SAR, MCAN_CAN_FD, TRNG |

---

## Reviewer Notes on Advisory Conditions

### ADC Verification (Condition 1)
The ADC_12BIT_SAR block is excluded from this RTL-level signoff per
`soc_config.yaml::out_of_scope`. This is consistent with the NC MCU Factory
framework's treatment of mixed-signal IPs: the digital APB wrapper is verified
for connectivity at the SoC level, but full analog/mixed-signal characterization
is delegated to the physical implementation team. This condition is tracked and
must be closed before tapeout signoff.

### GLS Verification (Condition 2)
Gate-level simulation is the responsibility of the integrator after synthesis.
The RTL deliverable (`mspm33c321a_derivative_mcu/verilog/rtl/*.v`) is clean and
ready for synthesis handoff. GLS will close as a post-synthesis step in the
integrator's own flow.

---

## Verdict Mapping

| Field | Value |
|-------|-------|
| Advisory verdict | **GO** |
| Reviewer verdict | **PROCEED_TO_PNR** |
| rework_target | **NONE** |
| Next stage | Physical Implementation (Place & Route) |
| Open conditions | ADC mixed-signal verification (post-RTL freeze), GLS (post-synthesis) |
