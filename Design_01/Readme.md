# SPI Communication System between DE10-Lite and nRF24L01 Transceivers  
**Date:** 07-07-2025

## 📡 Overview

This project implements SPI communication between the DE10-Lite FPGA and two nRF24L01+ modules operating in the 2.4 GHz ISM band. The system supports separate transmit and receive channels using individual SPI cores (`spi_tx`, `spi_rx`) and a unified controller.

---

## 🔧 Specifications

- **Platform:** Terasic DE10-Lite FPGA  
- **Transceiver:** nRF24L01+  
- **Frequency Band:** 2.4 GHz ISM (Unlicensed)  
- **SPI Mode:** Mode 0 (CPOL = 0, CPHA = 0)  
- **Bit Order:** MSB First  
- **Transaction Width:** 8-bit  
- **SPI Clock Frequency:** 10 MHz (generated via divider)

> ⚠️ Note: DE10-Lite PLL uses internal 10 MHz clock. A separate clock divider is used to generate 10 MHz for SPI.

---

## 🔌 nRF24L01 Pin Connections

| nRF Pin | Name   | Function         | FPGA Connection (GPIO) |
|---------|--------|------------------|-------------------------|
| 01      | VCC    | +3.3V Power      | 3.3V                    |
| 02      | GND    | Ground           | GND                     |
| 03      | CSN    | Chip Select      | GPIO (csn_tx / csn_rx)  |
| 04      | CE     | Chip Enable      | GPIO (ce_tx / ce_rx)    |
| 05      | SCK    | Serial Clock     | GPIO (sck_tx / sck_rx)  |
| 06      | MOSI   | Master Out       | GPIO (mosi_tx / mosi_rx)|
| 07      | MISO   | Master In        | GPIO (miso_tx / miso_rx)|
| 08      | IRQ    | Interrupt        | Not Used (NC)           |

---

## 🧩 Module Structure

### 01. `spi_top` – Top-Level Integration

**Function:** Integrates all submodules, routes FPGA inputs/outputs, and connects to nRF transceivers.

#### Inputs:
- `clk_in`: 50 MHz input clock from DE10-Lite (Pin P11)
- `key[0]`: Reset button
- `sw[9]`: Enable Transmit
- `sw[8]`: Enable Receive
- `sw[7:0]`: Data to transmit

#### Outputs:
- SPI Lines to nRF TX: `CSN_tx`, `SCK_tx`, `MOSI_tx`, `MISO_tx`, `CE_tx`
- SPI Lines to nRF RX: `CSN_rx`, `SCK_rx`, `MOSI_rx`, `MISO_rx`, `CE_rx`
- Status LEDs: `LEDR[9]` (TX), `LEDR[8]` (RX), `LEDR[7:0]` (Received Data)

---

### 02. `spi_clock_divider`

**Function:** Converts 50 MHz system clock to 10 MHz SPI clock.

#### Inputs:
- `clk_50`: 50 MHz input clock
- `rst`: Active-high reset

#### Output:
- `clk_10`: 10 MHz clock for SPI modules

---

### 03. `spi_controller`

**Function:** Manages SPI transactions and control flow between TX and RX modules.

#### Inputs:
- `clk_10`: 10 MHz SPI clock
- `rst`: Reset signal
- `done_tx`: SPI TX transaction complete
- `done_rx`: SPI RX transaction complete
- `data_out[7:0]`: Received data from RX

#### Outputs:
- `start_tx`: Trigger signal for `spi_tx`
- `start_rx`: Trigger signal for `spi_rx`
- `data_in[7:0]`: Data to be transmitted
- `csn_tx`, `csn_rx`: Chip select signals for nRF modules

---

### 04. `spi_tx`

**Function:** Handles SPI transmission to nRF TX module.

#### Inputs:
- `clk_10`: 10 MHz SPI clock
- `rst`: Reset
- `start_tx`: Start signal from controller
- `data_in[7:0]`: Data to send
- `miso_tx`: Data received from slave (optional)

#### Outputs:
- `spi_clk`: SPI clock output
- `mosi_tx`: Data to nRF TX
- `csn_tx`: Chip Select
- `data_out[7:0]`: Data returned (optional)
- `done_tx`: Transfer complete

---

### 05. `spi_rx`

**Function:** Handles SPI reception from nRF RX module.

#### Inputs:
- `clk_10`: 10 MHz SPI clock
- `rst`: Reset
- `start_rx`: Start signal from controller
- `data_in[7:0]`: Dummy byte to send
- `miso_rx`: Data received from slave

#### Outputs:
- `spi_clk`: SPI clock output
- `mosi_rx`: Dummy data to slave
- `csn_rx`: Chip Select
- `data_out[7:0]`: Received data
- `done_rx`: Transfer complete

---

### 06. `spi_tb` – Testbench Module

**Function:** Simulates user inputs to `spi_top` and observes outputs.

#### Inputs:
- `clk_in`: 50 MHz test clock
- `key[0]`: Reset
- `sw[9:0]`: Switch inputs for TX, RX, data

#### Outputs:
- SPI outputs: `CSN`, `SCK`, `MOSI`, `MISO`, `CSNN`, `SCKK`, `MOSII`, `MISOO`
- LED Indicators

> Used only in simulation or internal FPGA test.

---

## ✅ Protocol Details

| Parameter     | Value         |
|---------------|---------------|
| SPI Mode      | Mode 0 (CPOL=0, CPHA=0) |
| Clock Speed   | 10 MHz        |
| Data Order    | MSB First     |
| Payload Width | 8 bits        |
| nRF IRQ Pin   | Not Connected |

---

## 📌 Notes

- nRF24L01 requires **configuration over SPI** before TX/RX begins. This must be handled in `spi_controller`.
- Ensure proper **delay after power-up** (>1.5 ms) before SPI access.
- Use **CE pins** to toggle TX/RX modes (logic HIGH to enable).
- The FPGA must **not drive MISO** — it is input-only.

---

## 📁 Future Enhancements

- Add IRQ handling via GPIO (optional)
- Implement FIFO for buffered TX/RX
- Use UART for PC-based debugging
- Expand to multi-node wireless communication

---

