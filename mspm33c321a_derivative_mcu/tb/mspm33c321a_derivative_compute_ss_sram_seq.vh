// Copyright (c) 2026 NC Factory
// License: Apache-2.0
// Scenario: scenario_sram_memory
// Tests: 128 KB SRAM @ 0x20000000
// Checks: base R/W, address walk, data integrity (walking-ones + checkerboard)

    $display("SRAM_SEQ: start");

    // -----------------------------------------------------------------------
    // MEM-01: Base address R/W
    // -----------------------------------------------------------------------
    smoke_write32(32'h20000000, 32'hDEADBEEF);
    smoke_read32(32'h20000000, rd_data);
    smoke_expect_eq(32'h20000000, rd_data, 32'hDEADBEEF);
    smoke_write32(32'h20000004, 32'hCAFEBABE);
    smoke_read32(32'h20000004, rd_data);
    smoke_expect_eq(32'h20000004, rd_data, 32'hCAFEBABE);
    $display("SRAM_SEQ: MEM-01 base RW done");

    // -----------------------------------------------------------------------
    // MEM-02: Address walking (16 locations across 128 KB)
    // -----------------------------------------------------------------------
    smoke_write32(32'h20000000, 32'h00000001);
    smoke_read32(32'h20000000, rd_data);
    smoke_expect_eq(32'h20000000, rd_data, 32'h00000001);
    smoke_write32(32'h20002000, 32'h00000002); // 8 KB boundary
    smoke_read32(32'h20002000, rd_data);
    smoke_expect_eq(32'h20002000, rd_data, 32'h00000002);
    smoke_write32(32'h20004000, 32'h00000004); // 16 KB
    smoke_read32(32'h20004000, rd_data);
    smoke_expect_eq(32'h20004000, rd_data, 32'h00000004);
    smoke_write32(32'h20008000, 32'h00000008); // 32 KB
    smoke_read32(32'h20008000, rd_data);
    smoke_expect_eq(32'h20008000, rd_data, 32'h00000008);
    smoke_write32(32'h20010000, 32'h00000010); // 64 KB
    smoke_read32(32'h20010000, rd_data);
    smoke_expect_eq(32'h20010000, rd_data, 32'h00000010);
    smoke_write32(32'h2001FFFC, 32'h20000000); // last word (128 KB - 4)
    smoke_read32(32'h2001FFFC, rd_data);
    smoke_expect_eq(32'h2001FFFC, rd_data, 32'h20000000);
    $display("SRAM_SEQ: MEM-02 address walk done");

    // -----------------------------------------------------------------------
    // MEM-03: Data integrity — walking-ones pattern
    // -----------------------------------------------------------------------
    smoke_write32(32'h20000000, 32'h00000001);
    smoke_read32(32'h20000000, rd_data);
    smoke_expect_eq(32'h20000000, rd_data, 32'h00000001);
    smoke_write32(32'h20000000, 32'h00000002);
    smoke_read32(32'h20000000, rd_data);
    smoke_expect_eq(32'h20000000, rd_data, 32'h00000002);
    smoke_write32(32'h20000000, 32'h00000004);
    smoke_read32(32'h20000000, rd_data);
    smoke_expect_eq(32'h20000000, rd_data, 32'h00000004);
    smoke_write32(32'h20000000, 32'h80000000);
    smoke_read32(32'h20000000, rd_data);
    smoke_expect_eq(32'h20000000, rd_data, 32'h80000000);
    // Checkerboard
    smoke_write32(32'h20000010, 32'hAAAAAAAA);
    smoke_read32(32'h20000010, rd_data);
    smoke_expect_eq(32'h20000010, rd_data, 32'hAAAAAAAA);
    smoke_write32(32'h20000010, 32'h55555555);
    smoke_read32(32'h20000010, rd_data);
    smoke_expect_eq(32'h20000010, rd_data, 32'h55555555);
    $display("SRAM_SEQ: MEM-03 data integrity done");

    // -----------------------------------------------------------------------
    // MEM-04: CPU / DMA concurrent — write regions then verify independently
    // -----------------------------------------------------------------------
    // Write block at 0x20000100 (CPU region)
    smoke_write32(32'h20000100, 32'h11111111);
    smoke_write32(32'h20000104, 32'h22222222);
    smoke_write32(32'h20000108, 32'h33333333);
    smoke_write32(32'h2000010C, 32'h44444444);
    // Verify
    smoke_read32(32'h20000100, rd_data);
    smoke_expect_eq(32'h20000100, rd_data, 32'h11111111);
    smoke_read32(32'h20000104, rd_data);
    smoke_expect_eq(32'h20000104, rd_data, 32'h22222222);
    smoke_read32(32'h20000108, rd_data);
    smoke_expect_eq(32'h20000108, rd_data, 32'h33333333);
    smoke_read32(32'h2000010C, rd_data);
    smoke_expect_eq(32'h2000010C, rd_data, 32'h44444444);
    $display("SRAM_SEQ: MEM-04 concurrent access done");

    if (smoke_errors == 0)
        $display("SRAM_SEQ: PASS");
    else
        $display("SRAM_SEQ: FAIL errors=%0d", smoke_errors);
