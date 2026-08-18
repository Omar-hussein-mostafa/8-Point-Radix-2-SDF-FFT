# MATLAB Fixed-Point Modeling (`matlab_fxp`)

This directory contains the bit-accurate fixed-point MATLAB model for the 8-Point Radix-2 Single Delay Feedback (SDF) FFT architecture. These scripts are used to model the data flow, evaluate quantization noise, and verify the custom SDF algorithm against ideal mathematical models before moving to hardware (RTL) development.

## File Descriptions

*   **`fft_sdf.m`** 
    The main testbench and wrapper script for running the fixed-point FFT simulation. It orchestrates the input stimulus and calls the core processing functions.
*   **`fft_sdf_core.m`** 
    The core algorithmic implementation of the Radix-2 SDF pipeline architecture. This mirrors the intended hardware's butterfly units, delay lines, and complex multipliers.
*   **`fft_sdf_core_types.m`** 
    Defines the fixed-point data types (e.g., `fi` objects), word lengths, fractional bits, and rounding/overflow modes used across the model to accurately simulate hardware constraints.
*   **`fft_plot_verifier.m`** 
    The verification and visualization script. It plots the magnitude and phase outputs of our custom fixed-point SDF model and compares them directly against MATLAB's built-in ideal `fft()` function to validate algorithmic accuracy and assess quantization errors.
*   **`sign_char.m`** 
    A utility function used for handling signed data conversions or character formatting during the fixed-point data generation and logging process.

## Workflow Integration

1. **Configure Data Types:** Adjust the word lengths and fractional bits in `fft_sdf_core_types.m` to test different hardware precision constraints.
2. **Run the Model:** Execute `fft_sdf.m` to push test stimuli through the custom SDF pipeline.
3. **Verify and Visualize:** Run `fft_plot_verifier.m` to generate magnitude and phase plots, comparing the fixed-point SDF output against MATLAB's floating-point built-in `fft()` to ensure the architecture is mathematically sound prior to RTL implementation.
