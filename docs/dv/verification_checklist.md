# Verification Checklist — MSPM33C321A Derivative MCU

**Design:** `mspm33c321a_derivative` (`mspm33c321a_deriv`)
**Generated:** 2026-05-29
**Spec Refs:** `docs/requirements.md`, `docs/specifications.md`, `docs/padframe_requirements.md`, `config/soc_config.yaml`
**Status Legend:** `[ ]` = Not Run | `[P]` = Pass | `[F]` = Fail | `[W]` = Waived

---

## Domain Key

| Prefix | Domain |
|--------|--------|
| SYS | System — reset, clock, boot |
| XIP | Execute-in-Place Flash Controller |
| MEM | SRAM Memory |
| GPIO | General-Purpose IO (Ports A/B/C) |
| UART | UART Instances (0–3) |
| SPI | SPI Instances (0–1) |
| I2C | I2C Instances (0–2, where I2C2 is derivative addition) |
| TMR | Timers (TMR0–TMR5) |
| PWM | PWM Instances (0–1) |
| DMA | DMA Controller (8-channel) |
| CRC | CRC Accelerator |
| AES | AES Accelerator (128/256-bit) |
| WWDT | Windowed Watchdog Timer |
| RTC | Real-Time Clock |
| SYSTICK | SysTick Timer |
| IRQ | Interrupt Controller / PLIC |
| DBG | SWD Debug Port |
| INT | Integration / System-Level |

---

## SYS — System Reset & Clock

- [ ] [SYS-01] Power-on reset holds all peripherals in reset state until release | Test: test_sys_por_state | Priority: P0 | Scenario: scenario_sys_reset_clock
- [ ] [SYS-02] External nRESET pad assertion de-asserts the compute_ss reset_n correctly | Test: test_sys_external_reset | Priority: P0 | Scenario: scenario_sys_reset_clock
- [ ] [SYS-03] Software reset (SYSRESETREQ) resets CPU core and all peripherals | Test: test_sys_sw_reset | Priority: P0 | Scenario: scenario_sys_reset_clock
- [ ] [SYS-04] System clock reaches 80 MHz target after reset release and PLL lock | Test: test_sys_clock_freq | Priority: P0 | Scenario: scenario_sys_reset_clock
- [ ] [SYS-05] WWDT timeout causes a full chip reset (reset propagation path) | Test: test_sys_wwdt_reset_path | Priority: P1 | Scenario: scenario_sys_reset_clock

---

## XIP — Execute-in-Place Flash Controller

- [ ] [XIP-01] System boots from XIP flash at base address 0x00000000 and fetches first instruction correctly | Test: test_xip_boot_fetch | Priority: P0 | Scenario: scenario_xip_flash
- [ ] [XIP-02] XIP controller CSR smoke test — all readable registers return valid reset values | Test: test_xip_reg_smoke | Priority: P0 | Scenario: scenario_xip_flash
- [ ] [XIP-03] XIP read data integrity — known pattern in flash image is read back without corruption | Test: test_xip_data_integrity | Priority: P0 | Scenario: scenario_xip_flash
- [ ] [XIP-04] XIP address boundary — access at top of 512 KB range (0x0007_FFFF) succeeds; access at 0x0008_0000 wraps or faults | Test: test_xip_addr_boundary | Priority: P1 | Scenario: scenario_xip_flash

---

## MEM — SRAM Memory

- [ ] [MEM-01] SRAM write and read-back at base address 0x20000000 returns correct data | Test: test_mem_base_rw | Priority: P0 | Scenario: scenario_sram_memory
- [ ] [MEM-02] SRAM full 128 KB address walking test (all word addresses written and verified) | Test: test_mem_addr_walk | Priority: P0 | Scenario: scenario_sram_memory
- [ ] [MEM-03] SRAM read-after-write data integrity — sequential and random patterns | Test: test_mem_data_integrity | Priority: P0 | Scenario: scenario_sram_memory
- [ ] [MEM-04] SRAM simultaneous access by CPU and DMA — no data corruption | Test: test_mem_cpu_dma_concurrent | Priority: P1 | Scenario: scenario_sram_memory

---

## GPIO — General-Purpose IO

- [ ] [GPIO-01] GPIOA output: set direction to output, write data register, verify toggling on each of 16 pins | Test: test_gpio_porta_output | Priority: P0 | Scenario: scenario_gpio_basic
- [ ] [GPIO-02] GPIOA input: drive pads externally, read input data register on each of 16 pins | Test: test_gpio_porta_input | Priority: P0 | Scenario: scenario_gpio_basic
- [ ] [GPIO-03] GPIOB output: set direction to output, write and verify all 16 pins | Test: test_gpio_portb_output | Priority: P0 | Scenario: scenario_gpio_basic
- [ ] [GPIO-04] GPIOB input: drive pads externally, read back on all 16 pins | Test: test_gpio_portb_input | Priority: P0 | Scenario: scenario_gpio_basic
- [ ] [GPIO-05] GPIOC output: set direction to output, write and verify all 16 pins | Test: test_gpio_portc_output | Priority: P0 | Scenario: scenario_gpio_basic
- [ ] [GPIO-06] GPIOC input: drive pads externally, read back on all 16 pins | Test: test_gpio_portc_input | Priority: P0 | Scenario: scenario_gpio_basic
- [ ] [GPIO-07] GPIO reset state: all pins default to input (Hi-Z) direction after power-on reset | Test: test_gpio_reset_state | Priority: P0 | Scenario: scenario_gpio_basic
- [ ] [GPIO-08] GPIO alternate function selection via pinmux — UART AF on GPIOA, I2C AF on GPIOB | Test: test_gpio_af_pinmux | Priority: P1 | Scenario: scenario_gpio_af_irq
- [ ] [GPIO-09] GPIO edge interrupt — rising and falling edge triggers on GPIOA pin, ISR fires and clears | Test: test_gpio_edge_irq | Priority: P1 | Scenario: scenario_gpio_af_irq

---

## UART — Universal Asynchronous Receiver-Transmitter

- [ ] [UART-01] UART0 TX/RX loopback at 115200 baud — transmit and receive single byte correctly | Test: test_uart0_loopback_115200 | Priority: P0 | Scenario: scenario_uart_loopback
- [ ] [UART-02] UART1 TX/RX loopback at 115200 baud — transmit and receive single byte correctly | Test: test_uart1_loopback_115200 | Priority: P0 | Scenario: scenario_uart_loopback
- [ ] [UART-03] UART2 TX/RX loopback at 115200 baud — transmit and receive single byte correctly | Test: test_uart2_loopback_115200 | Priority: P0 | Scenario: scenario_uart_loopback
- [ ] [UART-04] UART3 TX/RX loopback at 115200 baud — transmit and receive single byte correctly | Test: test_uart3_loopback_115200 | Priority: P0 | Scenario: scenario_uart_loopback
- [ ] [UART-05] UART0 TX FIFO fill: write 8 bytes to TX FIFO, verify TX-empty IRQ fires after drain | Test: test_uart0_fifo_txrx | Priority: P1 | Scenario: scenario_uart_advanced
- [ ] [UART-06] UART0 framing error detection — inject invalid stop bit, verify FERR flag and IRQ | Test: test_uart0_framing_error | Priority: P1 | Scenario: scenario_uart_advanced
- [ ] [UART-07] UART0 multi-baud rate configuration — 9600, 115200, 921600 baud correctness | Test: test_uart0_baud_rates | Priority: P1 | Scenario: scenario_uart_advanced
- [ ] [UART-08] UART register smoke test — all four instances, readable CSRs return reset values | Test: test_uart_reg_smoke | Priority: P0 | Scenario: scenario_uart_advanced

---

## SPI — Serial Peripheral Interface

- [ ] [SPI-01] SPI0 master-mode full-duplex transfer, mode 0 (CPOL=0, CPHA=0), 8-bit frame | Test: test_spi0_mode0_transfer | Priority: P0 | Scenario: scenario_spi_transfer
- [ ] [SPI-02] SPI0 master-mode full-duplex transfer, mode 3 (CPOL=1, CPHA=1), 8-bit frame | Test: test_spi0_mode3_transfer | Priority: P1 | Scenario: scenario_spi_transfer
- [ ] [SPI-03] SPI1 master-mode full-duplex transfer — data integrity verified against reference | Test: test_spi1_transfer | Priority: P0 | Scenario: scenario_spi_transfer
- [ ] [SPI-04] SPI0 16-bit frame mode — transmit and receive 16-bit word correctly | Test: test_spi0_16bit_frame | Priority: P1 | Scenario: scenario_spi_transfer
- [ ] [SPI-05] SPI register smoke test — both instances, all CSRs readable at reset values | Test: test_spi_reg_smoke | Priority: P0 | Scenario: scenario_spi_transfer

---

## I2C — Inter-Integrated Circuit

- [ ] [I2C-01] I2C0 7-bit address write transaction to slave model — ACK verified | Test: test_i2c0_7bit_write | Priority: P0 | Scenario: scenario_i2c_transfer
- [ ] [I2C-02] I2C0 7-bit address read transaction from slave model — data verified | Test: test_i2c0_7bit_read | Priority: P0 | Scenario: scenario_i2c_transfer
- [ ] [I2C-03] I2C1 7-bit address write/read transaction — ACK and data verified | Test: test_i2c1_transfer | Priority: P0 | Scenario: scenario_i2c_transfer
- [ ] [I2C-04] I2C2 7-bit address write/read transaction — new derivative instance functional verification | Test: test_i2c2_transfer | Priority: P0 | Scenario: scenario_i2c_transfer
- [ ] [I2C-05] I2C0 10-bit address mode write/read — extended address space verified | Test: test_i2c0_10bit_addr | Priority: P1 | Scenario: scenario_i2c_transfer
- [ ] [I2C-06] I2C0 fast-mode (400 kHz) transaction completes successfully | Test: test_i2c0_fast_mode | Priority: P1 | Scenario: scenario_i2c_transfer
- [ ] [I2C-07] I2C0 fast-plus-mode (1 MHz) transaction completes successfully | Test: test_i2c0_fast_plus | Priority: P2 | Scenario: scenario_i2c_transfer
- [ ] [I2C-08] I2C register smoke test — all three instances (I2C0, I2C1, I2C2) CSRs at reset values | Test: test_i2c_reg_smoke | Priority: P0 | Scenario: scenario_i2c_transfer

---

## TMR — General-Purpose and Advanced Timers

- [ ] [TMR-01] TMR0 up-count overflow interrupt fires at correct period; ISR acknowledges | Test: test_tmr0_overflow_irq | Priority: P0 | Scenario: scenario_timer_basic
- [ ] [TMR-02] TMR1 input capture mode — capture event latches timer value correctly | Test: test_tmr1_input_capture | Priority: P1 | Scenario: scenario_timer_basic
- [ ] [TMR-03] TMR2 compare-match interrupt fires when count reaches compare register value | Test: test_tmr2_compare_irq | Priority: P0 | Scenario: scenario_timer_basic
- [ ] [TMR-04] TMR3 prescaler configuration — multiple prescale values produce correct period | Test: test_tmr3_prescaler | Priority: P1 | Scenario: scenario_timer_basic
- [ ] [TMR-05] TMR4 advanced control up/down count mode with configurable period | Test: test_tmr4_updown_count | Priority: P1 | Scenario: scenario_timer_basic
- [ ] [TMR-06] TMR5 advanced control center-aligned count mode | Test: test_tmr5_center_aligned | Priority: P1 | Scenario: scenario_timer_basic
- [ ] [TMR-07] Timer register smoke test — all six instances (TMR0–TMR5) CSRs at reset values | Test: test_tmr_reg_smoke | Priority: P0 | Scenario: scenario_timer_basic

---

## PWM — Pulse-Width Modulation

- [ ] [PWM-01] PWM0 period and duty cycle configuration — output period and high-time measured correctly | Test: test_pwm0_period_duty | Priority: P0 | Scenario: scenario_pwm_output
- [ ] [PWM-02] PWM1 complementary output pair with dead-time insertion — no shoot-through period | Test: test_pwm1_complementary_deadtime | Priority: P1 | Scenario: scenario_pwm_output
- [ ] [PWM-03] PWM0 fault input assertion immediately forces outputs to safe state | Test: test_pwm0_fault_response | Priority: P1 | Scenario: scenario_pwm_output
- [ ] [PWM-04] PWM register smoke test — both instances, all CSRs readable at reset values | Test: test_pwm_reg_smoke | Priority: P0 | Scenario: scenario_pwm_output

---

## DMA — Direct Memory Access Controller

- [ ] [DMA-01] DMA channel 0 memory-to-memory transfer — source and destination data match | Test: test_dma_mem2mem | Priority: P0 | Scenario: scenario_dma_transfer
- [ ] [DMA-02] DMA peripheral-to-memory transfer via UART0 RX — received data stored in SRAM | Test: test_dma_uart_rx_to_mem | Priority: P1 | Scenario: scenario_dma_transfer
- [ ] [DMA-03] DMA memory-to-peripheral transfer via UART0 TX — SRAM data transmitted over UART | Test: test_dma_mem_to_uart_tx | Priority: P1 | Scenario: scenario_dma_transfer
- [ ] [DMA-04] DMA 8-channel concurrent operation — all 8 channels active simultaneously, no data corruption | Test: test_dma_8ch_concurrent | Priority: P1 | Scenario: scenario_dma_transfer
- [ ] [DMA-05] DMA transfer-complete interrupt fires after channel finishes transfer | Test: test_dma_done_irq | Priority: P0 | Scenario: scenario_dma_transfer
- [ ] [DMA-06] DMA error interrupt fires on invalid transfer configuration | Test: test_dma_error_irq | Priority: P1 | Scenario: scenario_dma_transfer
- [ ] [DMA-07] DMA channel priority arbitration — higher-priority channel preempts lower-priority | Test: test_dma_priority_arb | Priority: P2 | Scenario: scenario_dma_transfer

---

## CRC — Cyclic Redundancy Check Accelerator

- [ ] [CRC-01] CRC-32 known-answer test — IEEE 802.3 polynomial, input vector produces expected digest | Test: test_crc32_kat | Priority: P0 | Scenario: scenario_crc_kat
- [ ] [CRC-02] CRC-16 known-answer test — CCITT polynomial, input vector produces expected digest | Test: test_crc16_kat | Priority: P0 | Scenario: scenario_crc_kat
- [ ] [CRC-03] CRC-8 known-answer test — CRC-8/MAXIM polynomial, input vector produces expected digest | Test: test_crc8_kat | Priority: P0 | Scenario: scenario_crc_kat
- [ ] [CRC-04] CRC register smoke test — polynomial selection, data input, and result registers accessible | Test: test_crc_reg_smoke | Priority: P0 | Scenario: scenario_crc_kat

---

## AES — Advanced Encryption Standard Accelerator

- [ ] [AES-01] AES-128 ECB encryption known-answer test — NIST FIPS-197 test vector | Test: test_aes128_ecb_encrypt_kat | Priority: P0 | Scenario: scenario_aes_kat
- [ ] [AES-02] AES-128 ECB decryption known-answer test — ciphertext recovers plaintext | Test: test_aes128_ecb_decrypt_kat | Priority: P0 | Scenario: scenario_aes_kat
- [ ] [AES-03] AES-256 ECB encryption known-answer test — NIST FIPS-197 test vector | Test: test_aes256_ecb_encrypt_kat | Priority: P0 | Scenario: scenario_aes_kat
- [ ] [AES-04] AES-128 CBC mode encryption — chained blocks produce correct output | Test: test_aes128_cbc_encrypt | Priority: P1 | Scenario: scenario_aes_kat
- [ ] [AES-05] AES DMA-assisted bulk encryption — 256-byte block encrypted via DMA, result verified | Test: test_aes_dma_bulk | Priority: P1 | Scenario: scenario_aes_kat
- [ ] [AES-06] AES done interrupt fires after encryption operation completes | Test: test_aes_done_irq | Priority: P0 | Scenario: scenario_aes_kat

---

## WWDT — Windowed Watchdog Timer

- [ ] [WWDT-01] WWDT service within valid window — no reset occurs; watchdog counter reloads | Test: test_wwdt_normal_service | Priority: P0 | Scenario: scenario_wwdt_window
- [ ] [WWDT-02] WWDT early-warning interrupt fires before window opens | Test: test_wwdt_early_warning_irq | Priority: P1 | Scenario: scenario_wwdt_window
- [ ] [WWDT-03] WWDT timeout — service not called; watchdog expires and triggers system reset | Test: test_wwdt_timeout_reset | Priority: P0 | Scenario: scenario_wwdt_window
- [ ] [WWDT-04] WWDT window-violation reset — service attempted outside permitted window triggers reset | Test: test_wwdt_window_violation | Priority: P0 | Scenario: scenario_wwdt_window

---

## RTC — Real-Time Clock

- [ ] [RTC-01] RTC calendar set — write BCD seconds, minutes, hours, day, month, year; read back correct | Test: test_rtc_calendar_set_read | Priority: P0 | Scenario: scenario_rtc_calendar
- [ ] [RTC-02] RTC time advancement — confirm seconds register increments each second | Test: test_rtc_time_advance | Priority: P0 | Scenario: scenario_rtc_calendar
- [ ] [RTC-03] RTC Alarm A fires interrupt at configured time | Test: test_rtc_alarm_a | Priority: P0 | Scenario: scenario_rtc_calendar
- [ ] [RTC-04] RTC Alarm B fires interrupt at configured time (independent of Alarm A) | Test: test_rtc_alarm_b | Priority: P1 | Scenario: scenario_rtc_calendar
- [ ] [RTC-05] RTC periodic wakeup timer fires at configured interval | Test: test_rtc_periodic_wakeup | Priority: P1 | Scenario: scenario_rtc_calendar

---

## SYSTICK — System Tick Timer

- [ ] [SYSTICK-01] SysTick underflow interrupt fires when counter reaches zero from reload value | Test: test_systick_underflow_irq | Priority: P0 | Scenario: scenario_systick_timer
- [ ] [SYSTICK-02] SysTick reload value configures correct tick interval | Test: test_systick_reload_interval | Priority: P0 | Scenario: scenario_systick_timer
- [ ] [SYSTICK-03] SysTick enable and disable — counter stops when disabled, resumes from reload when re-enabled | Test: test_systick_enable_disable | Priority: P1 | Scenario: scenario_systick_timer

---

## IRQ — Interrupt Controller (Hazard3 PLIC)

- [ ] [IRQ-01] All peripheral IRQ vectors assert correctly — each peripheral can raise its IRQ to the PLIC | Test: test_irq_all_sources | Priority: P0 | Scenario: scenario_irq_fabric
- [ ] [IRQ-02] IRQ acknowledgment clears pending flag — PLIC claim/complete handshake tested | Test: test_irq_ack_clear | Priority: P0 | Scenario: scenario_irq_fabric
- [ ] [IRQ-03] IRQ priority arbitration — higher-priority IRQ is handled before lower-priority pending IRQ | Test: test_irq_priority | Priority: P1 | Scenario: scenario_irq_fabric
- [ ] [IRQ-04] IRQ nesting — higher-priority IRQ preempts lower-priority ISR in progress | Test: test_irq_nesting | Priority: P2 | Scenario: scenario_irq_fabric
- [ ] [IRQ-05] GPIO edge interrupt — GPIOA/B/C edge trigger generates correct IRQ vector (IRQ0/1/2) | Test: test_irq_gpio_edge | Priority: P1 | Scenario: scenario_gpio_af_irq

---

## DBG — SWD Debug Port

- [ ] [DBG-01] SWD DAP connection established — DPIDR reads valid Hazard3 Debug Port ID | Test: test_dbg_dap_connect | Priority: P0 | Scenario: scenario_swd_debug
- [ ] [DBG-02] SWD memory read via DAP — read SRAM contents through debug access port | Test: test_dbg_mem_read | Priority: P0 | Scenario: scenario_swd_debug
- [ ] [DBG-03] SWD memory write via DAP — write to SRAM through debug access port, verify via normal read | Test: test_dbg_mem_write | Priority: P0 | Scenario: scenario_swd_debug
- [ ] [DBG-04] SWD halt and resume — CPU halted via debug, GPR read, execution resumed | Test: test_dbg_halt_resume | Priority: P1 | Scenario: scenario_swd_debug

---

## INT — Integration & System-Level

- [ ] [INT-01] Full SoC boot — CPU fetches reset vector from XIP flash, executes firmware, writes signature to SRAM | Test: test_int_full_boot | Priority: P0 | Scenario: scenario_integration_boot
- [ ] [INT-02] Multi-peripheral concurrent operation — UART0 TX, SPI0 transfer, and I2C0 write operate simultaneously without interference | Test: test_int_multiperiph_concurrent | Priority: P1 | Scenario: scenario_integration_multiperiph
- [ ] [INT-03] DMA-assisted UART transmission end-to-end — firmware triggers DMA to push buffer via UART0, remote model receives and verifies | Test: test_int_dma_uart_e2e | Priority: P1 | Scenario: scenario_integration_multiperiph
- [ ] [INT-04] AES + CRC pipeline — encrypt data block with AES-128, compute CRC-32 over ciphertext, results match reference | Test: test_int_aes_crc_pipeline | Priority: P1 | Scenario: scenario_integration_multiperiph
- [ ] [INT-05] GPIO-triggered DMA — GPIO input edge event initiates DMA transfer; DMA moves data, IRQ fires | Test: test_int_gpio_dma_trigger | Priority: P2 | Scenario: scenario_integration_multiperiph

---

## Summary

| Domain | Items | P0 | P1 | P2 |
|--------|-------|----|----|-----|
| SYS | 5 | 4 | 1 | 0 |
| XIP | 4 | 3 | 1 | 0 |
| MEM | 4 | 3 | 1 | 0 |
| GPIO | 9 | 5 | 2 | 0 |
| UART | 8 | 5 | 3 | 0 |
| SPI | 5 | 3 | 2 | 0 |
| I2C | 8 | 5 | 2 | 1 |
| TMR | 7 | 3 | 4 | 0 |
| PWM | 4 | 2 | 2 | 0 |
| DMA | 7 | 3 | 3 | 1 |
| CRC | 4 | 4 | 0 | 0 |
| AES | 6 | 4 | 2 | 0 |
| WWDT | 4 | 3 | 1 | 0 |
| RTC | 5 | 3 | 2 | 0 |
| SYSTICK | 3 | 2 | 1 | 0 |
| IRQ | 5 | 3 | 1 | 1 |
| DBG | 4 | 3 | 1 | 0 |
| INT | 5 | 1 | 3 | 1 |
| **TOTAL** | **97** | **63** | **32** | **3** |

**Scenarios generated:** 21
