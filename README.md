# 5-Stage Pipelined RISC-V Processor

An implementation of a 32-bit pipelined RISC-V (RV32I) processor written in Verilog. This processor features a complete 5-stage pipeline with robust hazard detection and data forwarding to handle data and control dependencies efficiently. 

Designed and verified as part of the EC340 Computer Organisation and Architecture coursework at the National Institute of Technology Karnataka (NITK).

## Features
* **5-Stage Pipeline:** Instruction Fetch (IF), Instruction Decode (ID), Execute (EX), Memory (MEM), and Writeback (WB).
* **Early Branch Resolution:** Branch calculations and comparisons are moved to the ID stage to minimize control hazard penalties.
* **Hazard Detection Unit:** Automatically inserts pipeline bubbles (stalls) for Load-Use hazards and flushes the IF/ID register when branches are taken.
* **Data Forwarding Unit:** Eliminates unnecessary stalls by bypassing data from the EX/MEM and MEM/WB stages directly to the ALU inputs.
* **Internal Register Forwarding:** Implements write-before-read (internal forwarding) in the register file to resolve WB-to-ID stage data hazards.

## Supported Instructions
The CPU datapath supports the following core RISC-V base integer instructions:
* **Arithmetic & Logic:** `add`, `addi`, `sub`, `and`, `andi`, `or`, `ori`, `slt`, `slti`
* **Memory Access:** `lw`, `sw`
* **Control Flow:** `beq`, `bne`, `blt`, `bge`, `jal`, `jalr`

## Simulation and Verification
The design has been verified using a custom assembly test suite that intentionally triggers EX-to-EX forwarding, MEM-to-EX forwarding, Load-Use stalls, and Control flushes. 

Machine code generation was handled via [Ripes](https://github.com/mortbopet/Ripes). Simulation and waveform analysis were performed using Icarus Verilog and GTKWave.

## Team Details:

This project was built as a part of coursework by Teja Sai Sreenivas, Hithin Sai, Sathwik.

### Running the Testbench
To run the simulation using Icarus Verilog:
```bash
# Compile the design and testbench
iverilog -o sim_output tb/tb_riscv_pipeline.v src/*.v

# Execute the simulation
vvp sim_output
