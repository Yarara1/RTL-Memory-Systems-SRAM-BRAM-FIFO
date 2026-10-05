# RTL Memory Systems — SRAM, BRAM & FIFO

This repository contains RTL memory-system designs implemented in Verilog, covering **SRAM control, dual-port BRAM operation, and FIFO-based line buffering**.

## Projects

### SRAM Controller
Implements a finite-state memory controller that transfers data between two SRAM blocks.

- 16-bit source SRAM
- 32-bit destination SRAM
- Packs consecutive 16-bit words into 32-bit output words
- FSM-based read/write sequencing
- Self-checking testbench with reference-memory comparison

The controller handles address generation, memory-access timing, data-width conversion, and completion signaling. :chatgpt-content-reference{index="0"}

### Dual-Port BRAM Controller
Implements a BRAM-based memory-processing system using independent read and write ports.

- Reads data through Port B
- Computes a running accumulation
- Writes the accumulated value back through Port A
- Handles synchronous BRAM read latency
- Supports external memory access after processing is complete

The design uses an FSM to coordinate read, capture, accumulate, and write operations. :chatgpt-content-reference{index="1"}

### FIFO Line Buffer
Implements a **three-line FIFO buffer** for streaming image-processing applications.

```text
Input Stream
    ↓
 FIFO 0 ─┐
 FIFO 1 ─┼─→ Synchronized 3-Line Output
 FIFO 2 ─┘
```

Each FIFO stores one image row. Once all three buffers contain valid data, they are read simultaneously to provide vertically aligned pixels for operations such as 2D convolution. :chatgpt-content-reference{index="2"}

## Verification

The designs include self-checking testbenches that verify memory contents and output ordering against expected reference data.

Simulation results confirmed:

- Correct SRAM data-width conversion
- Correct BRAM read/accumulate/write behavior
- Correct FIFO ordering and synchronized multi-line output
- Proper full, empty, ready, and done signaling :chatgpt-content-reference{index="3"}

## Technologies

`Verilog` · `Vivado` · `SRAM` · `BRAM` · `FIFO` · `FSM` · `RTL Design` · `Testbench Verification`
