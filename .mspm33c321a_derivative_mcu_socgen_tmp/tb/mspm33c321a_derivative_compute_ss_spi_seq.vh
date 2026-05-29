// Copyright (c) 2026 NC Factory
// License: Apache-2.0
// Scenario: scenario_spi_transfer
// Tests: SPI0 @ 0x40007000, SPI1 @ 0x40008000
// SPI registers (from nc_spi): CR=0x000, SR=0x004, DR=0x008, IM=0x020,
//   RIS=0x024, ICR=0x02C, DMACR=0x040, CLKDIV=0x100, CTRL=0x104,
//   FEATURE=0xFF8, ID=0xFFC

    $display("SPI_SEQ: start");

    // SPI0 @ 0x40007000
    smoke_read32(32'h40007FFC, rd_data); // ID
    smoke_read32(32'h40007FF8, rd_data); // FEATURE
    // Configure: CLKDIV for ~1 MHz from 80 MHz => div=80
    smoke_write32(32'h40007100, 32'h00000050); // CLKDIV = 80
    smoke_read32(32'h40007100, rd_data);
    smoke_expect_eq(32'h40007100, rd_data, 32'h00000050);
    // CTRL: SPI mode 0, 8-bit, master
    smoke_write32(32'h40007104, 32'h00000007);
    smoke_read32(32'h40007104, rd_data);
    smoke_expect_eq(32'h40007104, rd_data, 32'h00000007);
    // CR: enable SPI
    smoke_write32(32'h40007000, 32'h00000001);
    smoke_read32(32'h40007004, rd_data); // SR
    smoke_write32(32'h40007020, 32'h00000001); // IM
    smoke_write32(32'h4000702C, 32'hFFFFFFFF); // ICR
    smoke_write32(32'h40007040, 32'h00000003); // DMACR
    smoke_read32(32'h40007040, rd_data);
    smoke_expect_eq(32'h40007040, rd_data, 32'h00000003);
    // Mode 3 check: CTRL bits [1:0] = 11
    smoke_write32(32'h40007104, 32'h00000003);
    smoke_read32(32'h40007104, rd_data);
    smoke_expect_eq(32'h40007104, rd_data, 32'h00000003);
    // 16-bit frame: CTRL[4:3] = 01 => frame_size=16
    smoke_write32(32'h40007104, 32'h0000000B);
    smoke_read32(32'h40007104, rd_data);
    smoke_expect_eq(32'h40007104, rd_data, 32'h0000000B);
    smoke_write32(32'h40007000, 32'h00000000); // disable
    $display("SPI_SEQ: SPI0 done");

    // SPI1 @ 0x40008000
    smoke_read32(32'h40008FFC, rd_data); // ID
    smoke_write32(32'h40008100, 32'h00000050); // CLKDIV
    smoke_read32(32'h40008100, rd_data);
    smoke_expect_eq(32'h40008100, rd_data, 32'h00000050);
    smoke_write32(32'h40008000, 32'h00000001);
    smoke_read32(32'h40008004, rd_data);
    smoke_write32(32'h40008000, 32'h00000000);
    $display("SPI_SEQ: SPI1 done");

    if (smoke_errors == 0)
        $display("SPI_SEQ: PASS");
    else
        $display("SPI_SEQ: FAIL errors=%0d", smoke_errors);
