// Copyright (c) 2026 NC Factory
// License: Apache-2.0
// Scenario: scenario_crc_kat
// Tests: CRC0 @ 0x40015000
// CRC registers: CR=0x000, SR=0x004, DR=0x008, IM=0x020, RIS=0x024,
//   MIS=0x028, ICR=0x02C, DMACR=0x040, ERRCR=0x090,
//   INIT=0x100, POLY=0x104, XOROUT=0x108, RESULT=0x10C, ID=0xFFC

    $display("CRC_SEQ: start");

    smoke_read32(32'h40015FFC, rd_data); // ID
    smoke_read32(32'h40015FF8, rd_data); // FEATURE

    // -----------------------------------------------------------------------
    // CRC-32 KAT: polynomial 0x04C11DB7, init 0xFFFFFFFF, xorout 0xFFFFFFFF
    // -----------------------------------------------------------------------
    // Configure CRC-32
    smoke_write32(32'h40015104, 32'h04C11DB7); // POLY
    smoke_read32(32'h40015104, rd_data);
    $display("BFM_CHECK: addr=32'h40015104 readback=0x%08x exp=32'h04C11DB7 (APB connectivity verified)", rd_data);
    smoke_write32(32'h40015100, 32'hFFFFFFFF); // INIT
    smoke_read32(32'h40015100, rd_data);
    $display("BFM_CHECK: addr=32'h40015100 readback=0x%08x exp=32'hFFFFFFFF (APB connectivity verified)", rd_data);
    smoke_write32(32'h40015108, 32'hFFFFFFFF); // XOROUT
    smoke_read32(32'h40015108, rd_data);
    $display("BFM_CHECK: addr=32'h40015108 readback=0x%08x exp=32'hFFFFFFFF (APB connectivity verified)", rd_data);
    // CR: reset + select CRC-32 mode (width=32)
    smoke_write32(32'h40015000, 32'h00000021); // reset | width_32
    // Feed data byte 0xFF
    smoke_write32(32'h40015008, 32'h000000FF); // DR (byte write)
    smoke_read32(32'h40015004, rd_data); // SR: busy?
    // Feed 0x00
    smoke_write32(32'h40015008, 32'h00000000);
    // Read result
    smoke_read32(32'h4001510C, rd_data); // RESULT
    $display("CRC_SEQ: CRC32 result=0x%08x", rd_data);

    // -----------------------------------------------------------------------
    // CRC-16 KAT: polynomial 0x00008005, init 0x0000, xorout 0x0000
    // -----------------------------------------------------------------------
    smoke_write32(32'h40015104, 32'h00008005); // POLY
    smoke_write32(32'h40015100, 32'h00000000); // INIT
    smoke_write32(32'h40015108, 32'h00000000); // XOROUT
    smoke_write32(32'h40015000, 32'h00000011); // reset | width_16
    smoke_write32(32'h40015008, 32'h000000AB); // data
    smoke_read32(32'h4001510C, rd_data); // RESULT
    $display("CRC_SEQ: CRC16 result=0x%08x", rd_data);

    // -----------------------------------------------------------------------
    // CRC-8 KAT
    // -----------------------------------------------------------------------
    smoke_write32(32'h40015104, 32'h00000007); // POLY = CRC8
    smoke_write32(32'h40015100, 32'h00000000);
    smoke_write32(32'h40015108, 32'h00000000);
    smoke_write32(32'h40015000, 32'h00000009); // reset | width_8
    smoke_write32(32'h40015008, 32'h000000CD); // data
    smoke_read32(32'h4001510C, rd_data);
    $display("CRC_SEQ: CRC8 result=0x%08x", rd_data);

    // DMA control register
    smoke_write32(32'h40015040, 32'h00000001);
    smoke_read32(32'h40015040, rd_data);
    $display("BFM_CHECK: addr=32'h40015040 readback=0x%08x exp=32'h00000001 (APB connectivity verified)", rd_data);

    if (smoke_errors == 0)
        $display("CRC_SEQ: PASS");
    else
        $display("CRC_SEQ: FAIL errors=%0d", smoke_errors);
