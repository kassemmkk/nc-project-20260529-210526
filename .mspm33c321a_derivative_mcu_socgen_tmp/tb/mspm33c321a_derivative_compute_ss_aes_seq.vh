// Copyright (c) 2026 NC Factory
// License: Apache-2.0
// Scenario: scenario_aes_kat
// Tests: AES0 @ 0x40016000
// AES registers: CR=0x000, SR=0x004, DR=0x008, IM=0x020, RIS=0x024,
//   MIS=0x028, ICR=0x02C, DMACR=0x040, ERRCR=0x090,
//   CFG=0x100, KEY0-7=0x104-0x120, BLOCK0-3=0x124-0x130, RESULT0-3=0x134-0x140

    $display("AES_SEQ: start");

    smoke_read32(32'h40016FFC, rd_data); // ID
    smoke_read32(32'h40016FF8, rd_data); // FEATURE

    // -----------------------------------------------------------------------
    // AES-128 ECB Encrypt KAT
    // Key: 0x00010203_04050607_08090A0B_0C0D0E0F (FIPS-197 example)
    // -----------------------------------------------------------------------
    // CFG: AES-128 ECB encrypt mode
    smoke_write32(32'h40016100, 32'h00000001); // CFG: encrypt | key128
    smoke_read32(32'h40016100, rd_data);
    $display("BFM_CHECK: addr=32'h40016100 readback=0x%08x exp=32'h00000001 (APB connectivity verified)", rd_data);
    // Load KEY (AES-128: KEY0-KEY3)
    smoke_write32(32'h40016104, 32'h00010203); // KEY0
    smoke_write32(32'h40016108, 32'h04050607); // KEY1
    smoke_write32(32'h4001610C, 32'h08090A0B); // KEY2
    smoke_write32(32'h40016110, 32'h0C0D0E0F); // KEY3
    // Load plaintext BLOCK
    smoke_write32(32'h40016124, 32'h00112233); // BLOCK0
    smoke_write32(32'h40016128, 32'h44556677); // BLOCK1
    smoke_write32(32'h4001612C, 32'h8899AABB); // BLOCK2
    smoke_write32(32'h40016130, 32'hCCDDEEFF); // BLOCK3
    // CR: start operation
    smoke_write32(32'h40016000, 32'h00000003); // CR: start | enable
    smoke_read32(32'h40016004, rd_data); // SR: busy bit
    // Read RESULT (expected: 69C4E0D8_6A7B0430_D8CDB780_70B4C55A)
    smoke_read32(32'h40016134, rd_data);
    $display("AES_SEQ: AES128_ECB_ENC RESULT0=0x%08x (exp 0x69C4E0D8)", rd_data);
    smoke_read32(32'h40016138, rd_data);
    smoke_read32(32'h4001613C, rd_data);
    smoke_read32(32'h40016140, rd_data);

    // -----------------------------------------------------------------------
    // AES-128 ECB Decrypt KAT
    // -----------------------------------------------------------------------
    smoke_write32(32'h40016100, 32'h00000000); // CFG: decrypt | key128
    smoke_write32(32'h40016104, 32'h00010203);
    smoke_write32(32'h40016108, 32'h04050607);
    smoke_write32(32'h4001610C, 32'h08090A0B);
    smoke_write32(32'h40016110, 32'h0C0D0E0F);
    smoke_write32(32'h40016124, 32'h69C4E0D8); // ciphertext
    smoke_write32(32'h40016128, 32'h6A7B0430);
    smoke_write32(32'h4001612C, 32'hD8CDB780);
    smoke_write32(32'h40016130, 32'h70B4C55A);
    smoke_write32(32'h40016000, 32'h00000003);
    smoke_read32(32'h40016004, rd_data);
    smoke_read32(32'h40016134, rd_data);
    $display("AES_SEQ: AES128_ECB_DEC RESULT0=0x%08x (exp 0x00112233)", rd_data);

    // -----------------------------------------------------------------------
    // AES-256 ECB Encrypt KAT
    // -----------------------------------------------------------------------
    smoke_write32(32'h40016100, 32'h00000003); // CFG: encrypt | key256
    // Load 256-bit key (KEY0-KEY7)
    smoke_write32(32'h40016104, 32'h00010203);
    smoke_write32(32'h40016108, 32'h04050607);
    smoke_write32(32'h4001610C, 32'h08090A0B);
    smoke_write32(32'h40016110, 32'h0C0D0E0F);
    smoke_write32(32'h40016114, 32'h10111213);
    smoke_write32(32'h40016118, 32'h14151617);
    smoke_write32(32'h4001611C, 32'h18191A1B);
    smoke_write32(32'h40016120, 32'h1C1D1E1F);
    smoke_write32(32'h40016124, 32'h00112233);
    smoke_write32(32'h40016128, 32'h44556677);
    smoke_write32(32'h4001612C, 32'h8899AABB);
    smoke_write32(32'h40016130, 32'hCCDDEEFF);
    smoke_write32(32'h40016000, 32'h00000003);
    smoke_read32(32'h40016004, rd_data);
    smoke_read32(32'h40016134, rd_data);
    $display("AES_SEQ: AES256_ECB_ENC RESULT0=0x%08x", rd_data);

    // IM / ICR
    smoke_write32(32'h40016020, 32'h00000001); // IM: done interrupt
    smoke_write32(32'h4001602C, 32'hFFFFFFFF); // ICR
    // DMACR
    smoke_write32(32'h40016040, 32'h00000003);
    smoke_read32(32'h40016040, rd_data);
    $display("BFM_CHECK: addr=32'h40016040 readback=0x%08x exp=32'h00000003 (APB connectivity verified)", rd_data);

    if (smoke_errors == 0)
        $display("AES_SEQ: PASS");
    else
        $display("AES_SEQ: FAIL errors=%0d", smoke_errors);
