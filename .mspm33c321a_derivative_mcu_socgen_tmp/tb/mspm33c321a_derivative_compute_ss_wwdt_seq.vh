// Copyright (c) 2026 NC Factory
// License: Apache-2.0
// Scenario: scenario_wwdt_window
// Tests: WWDT0 @ 0x40017000
// WWDT registers: CR=0x000, SR=0x004, IM=0x008, RIS=0x00C, MIS=0x010,
//   ICR=0x014, PRESCALER=0x020, WINDOW=0x024, COUNTER=0x028, KEY=0x02C,
//   LOCK=0x030, FEATURE=0xFF8, ID=0xFFC

    $display("WWDT_SEQ: start");

    smoke_read32(32'h40017FFC, rd_data); // ID
    smoke_read32(32'h40017FF8, rd_data); // FEATURE

    // -----------------------------------------------------------------------
    // Normal service: configure window, service within window
    // -----------------------------------------------------------------------
    // PRESCALER: divide clock for ~10 ms timeout at 80 MHz
    smoke_write32(32'h40017020, 32'h000007CF); // PRESCALER = 1999
    smoke_read32(32'h40017020, rd_data);
    smoke_expect_eq(32'h40017020, rd_data, 32'h000007CF);
    // WINDOW: lower bound (25% of counter range)
    smoke_write32(32'h40017024, 32'h00004000); // WINDOW
    smoke_read32(32'h40017024, rd_data);
    smoke_expect_eq(32'h40017024, rd_data, 32'h00004000);
    // COUNTER: load reload value
    smoke_write32(32'h40017028, 32'h0000FFFF); // COUNTER
    smoke_read32(32'h40017028, rd_data);
    smoke_expect_eq(32'h40017028, rd_data, 32'h0000FFFF);
    // CR: enable WWDT
    smoke_write32(32'h40017000, 32'h00000001);
    smoke_read32(32'h40017000, rd_data);
    smoke_expect_eq(32'h40017000, rd_data, 32'h00000001);
    // SR: read status
    smoke_read32(32'h40017004, rd_data);
    // IM: early warning IRQ enable
    smoke_write32(32'h40017008, 32'h00000001);
    smoke_read32(32'h40017008, rd_data);
    smoke_expect_eq(32'h40017008, rd_data, 32'h00000001);
    // ICR: clear interrupt
    smoke_write32(32'h40017014, 32'hFFFFFFFF);
    // KEY: service watchdog (magic value)
    smoke_write32(32'h4001702C, 32'h0000ACCA); // service key
    smoke_read32(32'h4001702C, rd_data);
    $display("WWDT_SEQ: normal service done");

    // Window violation: write CR[WDOG_RST_EN] to enable reset
    smoke_write32(32'h40017000, 32'h00000003); // CR: wdt_en | rst_en
    smoke_read32(32'h40017000, rd_data);
    $display("WWDT_SEQ: window config done");

    if (smoke_errors == 0)
        $display("WWDT_SEQ: PASS");
    else
        $display("WWDT_SEQ: FAIL errors=%0d", smoke_errors);
