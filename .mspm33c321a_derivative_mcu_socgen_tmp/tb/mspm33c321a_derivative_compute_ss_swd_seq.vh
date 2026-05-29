    $display("QUICK_GPIO: start");
    smoke_read32(32'h40000FFC, rd_data);
    $display("GPIO0 ID = 0x%08x (exp 0x00100020)", rd_data);
    smoke_read32(32'h40003FFC, rd_data);
    $display("UART0 ID = 0x%08x", rd_data);
    smoke_read32(32'h40015FFC, rd_data);
    $display("CRC0 ID = 0x%08x", rd_data);
    smoke_read32(32'h40016FFC, rd_data);
    $display("AES0 ID = 0x%08x", rd_data);
    smoke_read32(32'h4001EFFC, rd_data);
    $display("SYSTICK0 ID = 0x%08x", rd_data);
    // SRAM test
    smoke_write32(32'h20001000, 32'hDEADBEEF);
    smoke_read32(32'h20001000, rd_data);
    $display("SRAM[0x1000] = 0x%08x (exp 0xDEADBEEF)", rd_data);
    // GPIO MODER test - explicit 
    smoke_write32(32'h40000100, 32'h00000003);
    smoke_read32(32'h40000100, rd_data);
    $display("GPIO0 MODER after 0x3 write = 0x%08x", rd_data);
    // Verify SYSTICK write
    smoke_write32(32'h4001E008, 32'h00001234);
    smoke_read32(32'h4001E008, rd_data);
    $display("SYSTICK RELOAD after 0x1234 write = 0x%08x (exp 0x1234)", rd_data);
    if (smoke_errors == 0) $display("QUICK_GPIO: PASS");
    else $display("QUICK_GPIO: FAIL errors=%0d", smoke_errors);
