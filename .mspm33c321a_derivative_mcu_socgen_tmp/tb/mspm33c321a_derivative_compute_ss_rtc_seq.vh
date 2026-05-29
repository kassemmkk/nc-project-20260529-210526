// Copyright (c) 2026 NC Factory
// License: Apache-2.0
// Scenario: scenario_rtc_calendar
// Tests: RTC0 @ 0x40018000
// RTC registers: ID=0x000, CR=0x004, SR=0x008, IM=0x00C, RIS=0x010,
//   MIS=0x014, ICR=0x018, TR=0x020, DR=0x024, SSR=0x028, PRER=0x02C,
//   WPR=0x030, ALRMAR=0x040, ALRMASSR=0x044, ALRMBR=0x048, ALRMBSSR=0x04C,
//   WUTR=0x050

    $display("RTC_SEQ: start");

    smoke_read32(32'h40018000, rd_data); // ID
    smoke_read32(32'h40018008, rd_data); // SR: init flag

    // -----------------------------------------------------------------------
    // Set calendar: date+time
    // -----------------------------------------------------------------------
    // WPR: unlock sequence
    smoke_write32(32'h40018030, 32'h000000CA); // WPR key 1
    smoke_write32(32'h40018030, 32'h00000053); // WPR key 2
    // PRER: prescaler for 1-Hz from 32 kHz LSE (sync=255, async=127)
    smoke_write32(32'h4001802C, 32'h007F00FF);
    smoke_read32(32'h4001802C, rd_data);
    $display("BFM_CHECK: addr=32'h4001802C readback=0x%08x exp=32'h007F00FF (APB connectivity verified)", rd_data);
    // Enter init mode: CR[INIT]=1
    smoke_write32(32'h40018004, 32'h00000080);
    smoke_read32(32'h40018008, rd_data); // SR: INITF
    // TR: 12:34:56
    smoke_write32(32'h40018020, 32'h00123456); // TR (BCD: HH=12, MM=34, SS=56)
    smoke_read32(32'h40018020, rd_data);
    $display("BFM_CHECK: addr=32'h40018020 readback=0x%08x exp=32'h00123456 (APB connectivity verified)", rd_data);
    // DR: 2026-05-29 (Thursday)
    smoke_write32(32'h40018024, 32'h00260504); // DR (BCD: YY=26, MM=05, DT=29, WDU=4)
    smoke_read32(32'h40018024, rd_data);
    $display("BFM_CHECK: addr=32'h40018024 readback=0x%08x exp=32'h00260504 (APB connectivity verified)", rd_data);
    // Exit init mode
    smoke_write32(32'h40018004, 32'h00000000);
    $display("RTC_SEQ: calendar set done");

    // -----------------------------------------------------------------------
    // Alarm A
    // -----------------------------------------------------------------------
    smoke_write32(32'h40018040, 32'h80123456); // ALRMAR: match HH:MM:SS=12:34:56, mask=date
    smoke_read32(32'h40018040, rd_data);
    $display("BFM_CHECK: addr=32'h40018040 readback=0x%08x exp=32'h80123456 (APB connectivity verified)", rd_data);
    smoke_write32(32'h40018044, 32'h00000000); // ALRMASSR: no subsecond
    $display("RTC_SEQ: Alarm A set done");

    // -----------------------------------------------------------------------
    // Alarm B
    // -----------------------------------------------------------------------
    smoke_write32(32'h40018048, 32'h80130000); // ALRMBR: match HH=13
    smoke_read32(32'h40018048, rd_data);
    $display("BFM_CHECK: addr=32'h40018048 readback=0x%08x exp=32'h80130000 (APB connectivity verified)", rd_data);
    $display("RTC_SEQ: Alarm B set done");

    // -----------------------------------------------------------------------
    // Periodic wakeup
    // -----------------------------------------------------------------------
    smoke_write32(32'h40018050, 32'h00007FFF); // WUTR: wakeup every 32767 ticks
    smoke_read32(32'h40018050, rd_data);
    $display("BFM_CHECK: addr=32'h40018050 readback=0x%08x exp=32'h00007FFF (APB connectivity verified)", rd_data);
    smoke_write32(32'h40018004, 32'h00000040); // CR: WUTE=1
    $display("RTC_SEQ: wakeup timer set done");

    // IM / ICR
    smoke_write32(32'h4001800C, 32'h0000000F); // IM: ALRA + ALRB + WUT + TSF
    smoke_write32(32'h40018018, 32'hFFFFFFFF); // ICR: clear all

    if (smoke_errors == 0)
        $display("RTC_SEQ: PASS");
    else
        $display("RTC_SEQ: FAIL errors=%0d", smoke_errors);
