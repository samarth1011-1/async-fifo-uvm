# Asynchronous FIFO

## Overview

This project implements an asynchronous FIFO in Verilog. It safely moves data between two clock domains that run at different speeds.

The write side uses `wr_clk`. The read side uses `rd_clk`. Each side has its own active-low reset.

<img src="image.png" width="700">

## Key Features

- Separate read and write clocks
- Parameter-based data width and FIFO depth
- Gray code pointers for safe clock domain crossing
- Two flip-flop sync stages
- Full and empty flags
- Random SystemVerilog testbench with data checks

## Architecture

The FIFO has three main parts:

1. A memory array stores the data.
2. The write side controls writes and the `full` flag.
3. The read side controls reads and the `empty` flag.

Binary pointers select the memory address. Gray code pointers are sent between the two clock domains.

## CDC and Pointer Synchronization

Binary pointers can change more than one bit at a time, so they are not sent across clock domains. Each binary pointer is first changed to Gray code:

```text
gray = (binary >> 1) ^ binary
```

Gray code changes only one bit for each pointer step. The Gray code pointer then passes through two flip-flops in the other clock domain. This lowers the risk of unstable values being used by the FIFO logic.

## Full and Empty Detection

The FIFO is empty when the next read Gray pointer matches the synced write Gray pointer.

The FIFO is full when the next write Gray pointer matches the synced read Gray pointer with its top two bits inverted. This shows that the write pointer has moved one full buffer length ahead of the read pointer.

Writes are allowed only when `full` is low. Reads are allowed only when `empty` is low.

## Files

- `fifo.v`: FIFO design and two flip-flop sync modules
- `fifotb.sv`: SystemVerilog testbench

## Default Parameters

| Parameter | Default | Meaning |
| --- | ---: | --- |
| `DATA_WIDTH` | 8 | Width of each data entry |
| `ADDR_WIDTH` | 4 | Number of address bits |
| `DEPTH` | 16 | Number of FIFO entries |

`DEPTH` must be equal to `2^ADDR_WIDTH`.

## Verification Strategy

The testbench uses a SystemVerilog queue as a reference FIFO. Every accepted write is added to the queue. Every accepted read is compared with the oldest value in the queue.

The write clock has a 10 ns period. The read clock has a 14 ns period. This checks data transfer between clocks that run at different speeds.

## Test Scenarios

- Reset both clock domains
- Random write enable and write data
- Random read enable
- Writes while the read clock runs at a different speed
- Reads while writes are still taking place
- Data order check for every accepted read
- Stop and report a failure when read data does not match

The random test runs for 5000 ns.

## Simulation

Example using Icarus Verilog:

```sh
iverilog -g2012 -o fifo_sim fifo.v fifotb.sv
vvp fifo_sim
```

The testbench prints write, read, `PASS`, and `FAIL` messages. A successful read shows `PASS` with the data value.

## Design Assumptions

- The FIFO depth is a power of two.
- Write and read clocks may run at different speeds.
- Resets are active low and belong to their own clock domains.
- Input data must be stable when a write is accepted.
- A write is accepted only when `wr_en` is high and `full` is low.
- A read is accepted only when `rd_en` is high and `empty` is low.
