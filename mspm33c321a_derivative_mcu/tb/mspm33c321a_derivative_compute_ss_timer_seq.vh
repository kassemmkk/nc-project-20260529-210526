// Copyright (c) 2026 NC Factory
// License: Apache-2.0
// Scenario: scenario_timer_basic
// Tests: TMR0-5 @ 0x4000C000-0x40011000
// TMR registers: CR=0x000, SR=0x004, IM=0x020, RIS=0x024, ICR=0x02C,
//   DMACR=0x040, CNT=0x100, PSC=0x104, ARR=0x108, RCR=0x10C,
//   CCR1=0x110, CCR2=0x114, CCR3=0x118, CCR4=0x11C, BDTR=0x120,
//   SMCR=0x124, CCMR1=0x128, CCMR2=0x12C, ID=0xFFC

    $display("TIMER_SEQ: start");

    // -----------------------------------------------------------------------
    // TMR0 @ 0x4000C000 — GP timer, overflow IRQ
    // -----------------------------------------------------------------------
    smoke_read32(32'h4000CFFC, rd_data); // ID
    smoke_write32(32'h4000C104, 32'h0000004F); // PSC = 79 => 1 MHz tick @80MHz
    smoke_read32(32'h4000C104, rd_data);
    smoke_expect_eq(32'h4000C104, rd_data, 32'h0000004F);
    smoke_write32(32'h4000C108, 32'h0000FFFF); // ARR = 65535
    smoke_read32(32'h4000C108, rd_data);
    smoke_expect_eq(32'h4000C108, rd_data, 32'h0000FFFF);
    smoke_write32(32'h4000C020, 32'h00000001); // IM: update interrupt
    smoke_write32(32'h4000C000, 32'h00000001); // CR: enable
    smoke_read32(32'h4000C004, rd_data); // SR
    smoke_write32(32'h4000C02C, 32'hFFFFFFFF); // ICR
    smoke_write32(32'h4000C000, 32'h00000000);
    $display("TIMER_SEQ: TMR0 done");

    // TMR1 @ 0x4000D000 — input capture
    smoke_read32(32'h4000DFFC, rd_data);
    smoke_write32(32'h4000D128, 32'h00000041); // CCMR1: CC1 input capture mode
    smoke_read32(32'h4000D128, rd_data);
    smoke_expect_eq(32'h4000D128, rd_data, 32'h00000041);
    smoke_write32(32'h4000D000, 32'h00000001);
    smoke_read32(32'h4000D004, rd_data);
    smoke_write32(32'h4000D000, 32'h00000000);
    $display("TIMER_SEQ: TMR1 done");

    // TMR2 @ 0x4000E000 — compare IRQ
    smoke_read32(32'h4000EFFC, rd_data);
    smoke_write32(32'h4000E110, 32'h00008000); // CCR1 = 0x8000 (compare threshold)
    smoke_read32(32'h4000E110, rd_data);
    smoke_expect_eq(32'h4000E110, rd_data, 32'h00008000);
    smoke_write32(32'h4000E000, 32'h00000001);
    smoke_read32(32'h4000E004, rd_data);
    smoke_write32(32'h4000E000, 32'h00000000);
    $display("TIMER_SEQ: TMR2 done");

    // TMR3 @ 0x4000F000 — prescaler test
    smoke_read32(32'h4000FFFC, rd_data);
    smoke_write32(32'h4000F104, 32'h000003E7); // PSC = 999
    smoke_read32(32'h4000F104, rd_data);
    smoke_expect_eq(32'h4000F104, rd_data, 32'h000003E7);
    smoke_write32(32'h4000F000, 32'h00000001);
    smoke_write32(32'h4000F000, 32'h00000000);
    $display("TIMER_SEQ: TMR3 done");

    // TMR4 @ 0x40010000 — center-aligned / up-down count (advanced GP)
    smoke_read32(32'h40010FFC, rd_data);
    smoke_write32(32'h40010000, 32'h00000060); // CR: center-aligned mode 3
    smoke_read32(32'h40010000, rd_data);
    smoke_expect_eq(32'h40010000, rd_data, 32'h00000060);
    smoke_write32(32'h40010108, 32'h00001000); // ARR
    smoke_write32(32'h40010000, 32'h00000061); // enable + center
    smoke_write32(32'h40010000, 32'h00000000);
    $display("TIMER_SEQ: TMR4 done");

    // TMR5 @ 0x40011000 — center-aligned advanced
    smoke_read32(32'h40011FFC, rd_data);
    smoke_write32(32'h40011000, 32'h00000060);
    smoke_read32(32'h40011000, rd_data);
    smoke_expect_eq(32'h40011000, rd_data, 32'h00000060);
    smoke_write32(32'h40011000, 32'h00000000);
    $display("TIMER_SEQ: TMR5 done");

    if (smoke_errors == 0)
        $display("TIMER_SEQ: PASS");
    else
        $display("TIMER_SEQ: FAIL errors=%0d", smoke_errors);
