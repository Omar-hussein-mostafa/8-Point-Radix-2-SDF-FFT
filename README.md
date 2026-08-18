# 8-Point Radix-2 SDF FFT Hardware Accelerator

## Overview
This repository contains the design, mathematical modeling, and verification of an 8-point Fast Fourier Transform (FFT) hardware accelerator. The design utilizes a **Radix-2 Single Delay Feedback (SDF)** pipelined architecture, implemented in synthesizable **SystemVerilog**. 

Prior to RTL development, a bit-true fixed-point model was developed in **MATLAB** to evaluate quantization noise and Signal-to-Quantization-Noise Ratio (SQNR) performance, ensuring optimal word-length sizing for the hardware implementation.

## Key Features
* **Architecture:** Pipelined Radix-2 Single Delay Feedback (SDF).
* **High-Level Modeling:** MATLAB scripts for fixed-point quantization and SQNR evaluation.
* **Hardware Design:** Parameterized SystemVerilog RTL (butterfly units, complex multipliers, delay lines).
* **Verification:** Self-checking SystemVerilog testbench utilizing golden reference vectors generated from the MATLAB model.

## Repository Structure
```text
├── docs/                   # Block diagrams and architecture documentation
├── matlab/                 # Fixed-point modeling and SQNR analysis scripts
├── rtl/                    # Synthesizable SystemVerilog design files
├── tb/                     # Verification environments and golden reference data
└── sim/                    # Simulation scripts (.do/.tcl) and waveform screenshots
