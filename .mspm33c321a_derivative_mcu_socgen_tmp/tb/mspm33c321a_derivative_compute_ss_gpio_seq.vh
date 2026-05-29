// Copyright (c) 2026 NC Factory
// License: Apache-2.0
// Scenario: scenario_gpio_basic
// Tests: GPIO0 (GPIOA 0x40000000), GPIO1 (GPIOB 0x40001000), GPIO2 (GPIOC 0x40002000)
// Checks: MODER reset=0 (input), ODR write/read, IDR read, AFRL/AFRH accessibility

    $display("GPIO_SEQ: start");

    // -----------------------------------------------------------------------
    // GPIO0 (GPIOA) @ 0x40000000
    // -----------------------------------------------------------------------
    // CHK-GPIO-07: MODER reset state = 0x00000000 (all inputs / Hi-Z)
    smoke_read32(32'h40000100, rd_data);   // MODER
    smoke_expect_eq(32'h40000100, rd_data, 32'h00000000);
    // CHK-GPIO-01: Write alternating pattern to ODR and read back
    smoke_write32(32'h40000100, 32'hFFFFFFFF); // set all pins output
    smoke_read32(32'h40000100, rd_data);
    smoke_write32(32'h40000108, 32'hAAAAAAAA); // ODR
    smoke_read32(32'h40000108, rd_data);
    smoke_expect_eq(32'h40000108, rd_data, 32'hAAAAAAAA);
    smoke_write32(32'h40000108, 32'h55555555); // ODR complement
    smoke_read32(32'h40000108, rd_data);
    smoke_expect_eq(32'h40000108, rd_data, 32'h55555555);
    // IDR (read-only, driven by pads)
    smoke_read32(32'h40000104, rd_data);   // IDR
    // AFRL / AFRH
    smoke_write32(32'h40000118, 32'h12345678); // AFRL
    smoke_read32(32'h40000118, rd_data);
    smoke_expect_eq(32'h40000118, rd_data, 32'h12345678);
    smoke_write32(32'h4000011C, 32'h9ABCDEF0); // AFRH
    smoke_read32(32'h4000011C, rd_data);
    smoke_expect_eq(32'h4000011C, rd_data, 32'h9ABCDEF0);
    // Restore MODER to input
    smoke_write32(32'h40000100, 32'h00000000);
    $display("GPIO_SEQ: GPIOA done");

    // -----------------------------------------------------------------------
    // GPIO1 (GPIOB) @ 0x40001000
    // -----------------------------------------------------------------------
    smoke_read32(32'h40001100, rd_data);   // MODER
    smoke_expect_eq(32'h40001100, rd_data, 32'h00000000);
    smoke_write32(32'h40001100, 32'hFFFFFFFF);
    smoke_write32(32'h40001108, 32'hAAAAAAAA); // ODR
    smoke_read32(32'h40001108, rd_data);
    smoke_expect_eq(32'h40001108, rd_data, 32'hAAAAAAAA);
    smoke_write32(32'h40001100, 32'h00000000);
    $display("GPIO_SEQ: GPIOB done");

    // -----------------------------------------------------------------------
    // GPIO2 (GPIOC) @ 0x40002000
    // -----------------------------------------------------------------------
    smoke_read32(32'h40002100, rd_data);   // MODER
    smoke_expect_eq(32'h40002100, rd_data, 32'h00000000);
    smoke_write32(32'h40002100, 32'hFFFFFFFF);
    smoke_write32(32'h40002108, 32'hAAAAAAAA); // ODR
    smoke_read32(32'h40002108, rd_data);
    smoke_expect_eq(32'h40002108, rd_data, 32'hAAAAAAAA);
    smoke_write32(32'h40002100, 32'h00000000);
    $display("GPIO_SEQ: GPIOC done");

    // -----------------------------------------------------------------------
    // ID registers for all three ports
    // -----------------------------------------------------------------------
    smoke_read32(32'h40000FFC, rd_data); // GPIO0 ID
    smoke_read32(32'h40001FFC, rd_data); // GPIO1 ID
    smoke_read32(32'h40002FFC, rd_data); // GPIO2 ID

    if (smoke_errors == 0)
        $display("GPIO_SEQ: PASS");
    else
        $display("GPIO_SEQ: FAIL errors=%0d", smoke_errors);
