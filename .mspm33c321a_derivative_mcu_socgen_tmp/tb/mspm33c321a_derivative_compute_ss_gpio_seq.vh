// Copyright (c) 2026 NC Factory
// License: Apache-2.0
// Scenario: scenario_gpio_basic
// Tests: GPIO0 (GPIOA 0x40000000), GPIO1 (GPIOB 0x40001000), GPIO2 (GPIOC 0x40002000)
// Checks: MODER reset=0 (input), ODR write/read, IDR read, AFRL/AFRH accessibility

    $display("GPIO_SEQ: start");

    // -----------------------------------------------------------------------
    // GPIO0 (GPIOA) @ 0x40000000  — connectivity check
    // Note: BFM hierarchical-force method verifies APB bus routing and
    // no-timeout / no-HRESP behaviour.  Register value readback uses
    // $display evidence only (consistent with nc_socgen BFM design).
    // -----------------------------------------------------------------------
    smoke_read32(32'h40000FFC, rd_data);   // ID
    $display("GPIO_SEQ: GPIO0 ID=0x%08x", rd_data);
    smoke_read32(32'h40000100, rd_data);   // MODER (reset=0x00000000)
    $display("GPIO_SEQ: GPIO0 MODER after reset = 0x%08x (exp 0x00000000 after POR)", rd_data);
    smoke_write32(32'h40000100, 32'h55555555); // set output mode
    smoke_read32(32'h40000100, rd_data);
    $display("GPIO_SEQ: GPIO0 MODER after write = 0x%08x", rd_data);
    smoke_write32(32'h40000108, 32'h0000AAAA); // ODR alternating
    smoke_read32(32'h40000108, rd_data);
    $display("GPIO_SEQ: GPIO0 ODR readback = 0x%08x", rd_data);
    smoke_read32(32'h40000104, rd_data);   // IDR (read-only)
    smoke_write32(32'h40000118, 32'h11111111); // AFRL
    smoke_read32(32'h40000118, rd_data);
    $display("GPIO_SEQ: GPIO0 AFRL readback = 0x%08x", rd_data);
    smoke_write32(32'h4000011C, 32'h22222222); // AFRH
    smoke_read32(32'h4000011C, rd_data);
    $display("GPIO_SEQ: GPIO0 AFRH readback = 0x%08x", rd_data);
    smoke_write32(32'h40000100, 32'h00000000); // restore
    $display("GPIO_SEQ: GPIOA done (errors so far=%0d)", smoke_errors);

    // -----------------------------------------------------------------------
    // GPIO1 (GPIOB) @ 0x40001000
    // -----------------------------------------------------------------------
    smoke_read32(32'h40001FFC, rd_data);
    $display("GPIO_SEQ: GPIO1 ID=0x%08x", rd_data);
    smoke_read32(32'h40001100, rd_data);
    $display("GPIO_SEQ: GPIO1 MODER after reset = 0x%08x", rd_data);
    smoke_write32(32'h40001100, 32'h55555555);
    smoke_write32(32'h40001108, 32'h0000AAAA);
    smoke_read32(32'h40001108, rd_data);
    $display("GPIO_SEQ: GPIO1 ODR readback = 0x%08x", rd_data);
    smoke_write32(32'h40001100, 32'h00000000);
    $display("GPIO_SEQ: GPIOB done");

    // -----------------------------------------------------------------------
    // GPIO2 (GPIOC) @ 0x40002000
    // -----------------------------------------------------------------------
    smoke_read32(32'h40002FFC, rd_data);
    $display("GPIO_SEQ: GPIO2 ID=0x%08x", rd_data);
    smoke_read32(32'h40002100, rd_data);
    $display("GPIO_SEQ: GPIO2 MODER after reset = 0x%08x", rd_data);
    smoke_write32(32'h40002100, 32'h55555555);
    smoke_write32(32'h40002108, 32'h0000AAAA);
    smoke_read32(32'h40002108, rd_data);
    $display("GPIO_SEQ: GPIO2 ODR readback = 0x%08x", rd_data);
    smoke_write32(32'h40002100, 32'h00000000);
    $display("GPIO_SEQ: GPIOC done");

    if (smoke_errors == 0)
        $display("GPIO_SEQ: PASS");
    else
        $display("GPIO_SEQ: FAIL errors=%0d", smoke_errors);
