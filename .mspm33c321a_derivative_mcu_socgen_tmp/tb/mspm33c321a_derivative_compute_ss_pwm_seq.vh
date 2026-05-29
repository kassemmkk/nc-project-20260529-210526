// Copyright (c) 2026 NC Factory
// License: Apache-2.0
// Scenario: scenario_pwm_output
// Tests: PWM0 @ 0x40012000, PWM1 @ 0x40013000
// PWM registers: CR=0x000, SR=0x004, IM=0x020, RIS=0x024, ICR=0x02C,
//   DMACR=0x040, CR1=0x100, CR2=0x104, SMCR=0x108, DIER=0x10C,
//   CNT=0x110, PSC=0x114, ARR=0x118, RCR=0x11C,
//   CCR1=0x120, CCR2=0x124, CCR3=0x128, CCR4=0x12C, BDTR=0x130, ID=0xFFC

    $display("PWM_SEQ: start");

    // -----------------------------------------------------------------------
    // PWM0 @ 0x40012000
    // -----------------------------------------------------------------------
    smoke_read32(32'h40012FFC, rd_data); // ID
    smoke_write32(32'h40012114, 32'h0000004F); // PSC = 79 => 1 MHz
    smoke_read32(32'h40012114, rd_data);
    smoke_expect_eq(32'h40012114, rd_data, 32'h0000004F);
    smoke_write32(32'h40012118, 32'h000003E7); // ARR = 999 => 1kHz PWM
    smoke_read32(32'h40012118, rd_data);
    smoke_expect_eq(32'h40012118, rd_data, 32'h000003E7);
    smoke_write32(32'h40012120, 32'h000001F4); // CCR1 = 500 => 50% duty
    smoke_read32(32'h40012120, rd_data);
    smoke_expect_eq(32'h40012120, rd_data, 32'h000001F4);
    smoke_write32(32'h40012100, 32'h00000001); // CR1: enable counter
    smoke_read32(32'h40012004, rd_data); // SR
    // Fault input response: BDTR - MOE bit
    smoke_write32(32'h40012130, 32'h00008000); // BDTR: MOE=1 (main output enable)
    smoke_read32(32'h40012130, rd_data);
    smoke_expect_eq(32'h40012130, rd_data, 32'h00008000);
    smoke_write32(32'h40012100, 32'h00000000);
    $display("PWM_SEQ: PWM0 done");

    // -----------------------------------------------------------------------
    // PWM1 @ 0x40013000 — complementary outputs + dead-time
    // -----------------------------------------------------------------------
    smoke_read32(32'h40013FFC, rd_data); // ID
    smoke_write32(32'h40013114, 32'h0000004F); // PSC
    smoke_read32(32'h40013114, rd_data);
    smoke_expect_eq(32'h40013114, rd_data, 32'h0000004F);
    smoke_write32(32'h40013118, 32'h000003E7); // ARR
    smoke_write32(32'h40013120, 32'h000001F4); // CCR1 = 50% duty
    smoke_write32(32'h40013124, 32'h000001F4); // CCR2
    // Dead-time: BDTR[7:0] = dead-time value
    smoke_write32(32'h40013130, 32'h00008014); // BDTR: MOE=1, DTG=0x14 (dead-time)
    smoke_read32(32'h40013130, rd_data);
    smoke_expect_eq(32'h40013130, rd_data, 32'h00008014);
    smoke_write32(32'h40013100, 32'h00000001);
    smoke_read32(32'h40013004, rd_data); // SR
    smoke_write32(32'h40013100, 32'h00000000);
    $display("PWM_SEQ: PWM1 done");

    if (smoke_errors == 0)
        $display("PWM_SEQ: PASS");
    else
        $display("PWM_SEQ: FAIL errors=%0d", smoke_errors);
