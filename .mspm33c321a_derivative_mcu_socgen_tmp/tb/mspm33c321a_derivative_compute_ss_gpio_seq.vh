// Copyright (c) 2026 NC Factory
// License: Apache-2.0
// Scenario: scenario_gpio_basic
// Tests: GPIO0 (GPIOA 0x40000000), GPIO1 (GPIOB 0x40001000), GPIO2 (GPIOC 0x40002000)
// Checks: MODER reset=0 (input), ODR write/read, IDR read, AFRL/AFRH accessibility

    $display("GPIO_SEQ: start");

    // -----------------------------------------------------------------------
    // GPIO0 (GPIOA) @ 0x40000000
    // Port width: 16 pins. ODR is 16-bit (reads back as zero-padded 32-bit).
    // MODER: 2 bits per pin, 32-bit register. AFRL/AFRH: 4 bits per pin.
    // -----------------------------------------------------------------------
    // CHK-GPIO-07: MODER reset state = 0x00000000 (all inputs / Hi-Z)
    smoke_read32(32'h40000100, rd_data);   // MODER
    smoke_expect_eq(32'h40000100, rd_data, 32'h00000000);
    // CHK-GPIO-01: Write alternating pattern to ODR and read back
    // MODER: set all 16 pins to output (2'b01 per pin = 0x55555555 for 16 pins)
    smoke_write32(32'h40000100, 32'h55555555); // output mode
    smoke_read32(32'h40000100, rd_data);
    smoke_expect_eq(32'h40000100, rd_data, 32'h55555555);
    // ODR is a 16-bit register; reads back as {16'h0, odr_reg[15:0]}
    smoke_write32(32'h40000108, 32'h0000AAAA); // ODR: alternating pattern
    smoke_read32(32'h40000108, rd_data);
    smoke_expect_eq(32'h40000108, rd_data, 32'h0000AAAA);
    smoke_write32(32'h40000108, 32'h00005555); // ODR complement
    smoke_read32(32'h40000108, rd_data);
    smoke_expect_eq(32'h40000108, rd_data, 32'h00005555);
    // IDR (read-only, driven by pad inputs — no check value needed)
    smoke_read32(32'h40000104, rd_data);   // IDR
    // AFRL: alternate function for pins 0-7 (4 bits/pin = 32 bits)
    // Write a simple pattern and verify readback (no lock, so full mask active)
    smoke_write32(32'h40000118, 32'h11111111); // AFRL: AF1 on all lower pins
    smoke_read32(32'h40000118, rd_data);
    smoke_expect_eq(32'h40000118, rd_data, 32'h11111111);
    // AFRH: alternate function for pins 8-15
    smoke_write32(32'h4000011C, 32'h22222222); // AFRH: AF2 on all upper pins
    smoke_read32(32'h4000011C, rd_data);
    smoke_expect_eq(32'h4000011C, rd_data, 32'h22222222);
    // Restore MODER and AFRL/AFRH to reset defaults
    smoke_write32(32'h40000100, 32'h00000000);
    smoke_write32(32'h40000118, 32'h00000000);
    smoke_write32(32'h4000011C, 32'h00000000);
    $display("GPIO_SEQ: GPIOA done");

    // -----------------------------------------------------------------------
    // GPIO1 (GPIOB) @ 0x40001000
    // -----------------------------------------------------------------------
    smoke_read32(32'h40001100, rd_data);   // MODER
    smoke_expect_eq(32'h40001100, rd_data, 32'h00000000);
    smoke_write32(32'h40001100, 32'h55555555); // output mode
    smoke_read32(32'h40001100, rd_data);
    smoke_expect_eq(32'h40001100, rd_data, 32'h55555555);
    smoke_write32(32'h40001108, 32'h0000AAAA); // ODR
    smoke_read32(32'h40001108, rd_data);
    smoke_expect_eq(32'h40001108, rd_data, 32'h0000AAAA);
    smoke_write32(32'h40001100, 32'h00000000);
    $display("GPIO_SEQ: GPIOB done");

    // -----------------------------------------------------------------------
    // GPIO2 (GPIOC) @ 0x40002000
    // -----------------------------------------------------------------------
    smoke_read32(32'h40002100, rd_data);   // MODER
    smoke_expect_eq(32'h40002100, rd_data, 32'h00000000);
    smoke_write32(32'h40002100, 32'h55555555); // output mode
    smoke_read32(32'h40002100, rd_data);
    smoke_expect_eq(32'h40002100, rd_data, 32'h55555555);
    smoke_write32(32'h40002108, 32'h0000AAAA); // ODR
    smoke_read32(32'h40002108, rd_data);
    smoke_expect_eq(32'h40002108, rd_data, 32'h0000AAAA);
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
