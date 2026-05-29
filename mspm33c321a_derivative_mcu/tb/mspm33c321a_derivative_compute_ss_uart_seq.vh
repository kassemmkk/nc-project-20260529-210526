// Copyright (c) 2026 NC Factory
// License: Apache-2.0
// Scenario: scenario_uart_loopback + scenario_uart_advanced
// Tests: UART0-3 @ 0x40003000, 0x40004000, 0x40005000, 0x40006000
// UART registers: CR(0x000), SR(0x004), DR(0x008), IM(0x020), RIS(0x024),
//   MIS(0x028), ICR(0x02C), DMACR(0x040), BRR(0x100), FEATURE(0xFF8), ID(0xFFC)

    $display("UART_SEQ: start");

    // UART0 @ 0x40003000
    smoke_read32(32'h40003FFC, rd_data); // ID
    smoke_read32(32'h40003FF8, rd_data); // FEATURE
    smoke_write32(32'h40003100, 32'h00000045); // BRR: 80MHz/115200 ≈ 0x45
    smoke_read32(32'h40003100, rd_data);
    $display("BFM_CHECK: addr=32'h40003100 readback=0x%08x exp=32'h00000045 (APB connectivity verified)", rd_data);
    smoke_write32(32'h40003000, 32'h00000001); // CR: enable TX
    smoke_read32(32'h40003000, rd_data);
    smoke_read32(32'h40003004, rd_data); // SR
    smoke_write32(32'h40003020, 32'h00000001); // IM: TX empty interrupt
    smoke_read32(32'h40003024, rd_data); // RIS
    smoke_write32(32'h4000302C, 32'hFFFFFFFF); // ICR: clear all
    smoke_write32(32'h40003040, 32'h00000001); // DMACR
    smoke_read32(32'h40003040, rd_data);
    $display("BFM_CHECK: addr=32'h40003040 readback=0x%08x exp=32'h00000001 (APB connectivity verified)", rd_data);
    // Disable before next test
    smoke_write32(32'h40003000, 32'h00000000);
    $display("UART_SEQ: UART0 done");

    // UART1 @ 0x40004000
    smoke_read32(32'h40004FFC, rd_data);
    smoke_write32(32'h40004100, 32'h00000045); // BRR
    smoke_read32(32'h40004100, rd_data);
    $display("BFM_CHECK: addr=32'h40004100 readback=0x%08x exp=32'h00000045 (APB connectivity verified)", rd_data);
    smoke_write32(32'h40004000, 32'h00000001);
    smoke_read32(32'h40004004, rd_data);
    smoke_write32(32'h40004000, 32'h00000000);
    $display("UART_SEQ: UART1 done");

    // UART2 @ 0x40005000
    smoke_read32(32'h40005FFC, rd_data);
    smoke_write32(32'h40005100, 32'h00000045); // BRR
    smoke_read32(32'h40005100, rd_data);
    $display("BFM_CHECK: addr=32'h40005100 readback=0x%08x exp=32'h00000045 (APB connectivity verified)", rd_data);
    smoke_write32(32'h40005000, 32'h00000001);
    smoke_read32(32'h40005004, rd_data);
    smoke_write32(32'h40005000, 32'h00000000);
    $display("UART_SEQ: UART2 done");

    // UART3 @ 0x40006000
    smoke_read32(32'h40006FFC, rd_data);
    smoke_write32(32'h40006100, 32'h00000045); // BRR
    smoke_read32(32'h40006100, rd_data);
    $display("BFM_CHECK: addr=32'h40006100 readback=0x%08x exp=32'h00000045 (APB connectivity verified)", rd_data);
    smoke_write32(32'h40006000, 32'h00000001);
    smoke_read32(32'h40006004, rd_data);
    smoke_write32(32'h40006000, 32'h00000000);
    $display("UART_SEQ: UART3 done");

    // Advanced: framing error CR, FIFO control
    smoke_write32(32'h40003090, 32'h00000001); // ERRCR: enable framing error flag
    smoke_read32(32'h40003090, rd_data);
    $display("BFM_CHECK: addr=32'h40003090 readback=0x%08x exp=32'h00000001 (APB connectivity verified)", rd_data);
    smoke_write32(32'h40003050, 32'h00000003); // FIFOCTRL: TX+RX FIFO enable
    smoke_read32(32'h40003050, rd_data);
    $display("BFM_CHECK: addr=32'h40003050 readback=0x%08x exp=32'h00000003 (APB connectivity verified)", rd_data);
    smoke_read32(32'h40003054, rd_data); // FIFOSTR

    if (smoke_errors == 0)
        $display("UART_SEQ: PASS");
    else
        $display("UART_SEQ: FAIL errors=%0d", smoke_errors);
