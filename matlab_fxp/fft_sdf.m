clear; clc; close all;

%% DESIGN PARAMETERS
N = 8;
nSeeds = 100;

% Twiddle Factors  
W8 = exp(-1i * 2 * pi * (0:3) / 8).';
W4 = exp(-1i * 2 * pi * (0:1) / 4).';
W4 = [W4; W4]; 

%% REPRESENTATION TYPES TASKS
% Error tracking arrays for the plot
err_double = zeros(nSeeds, 1);
err_single = zeros(nSeeds, 1);
err_fxpt   = zeros(nSeeds, 1);
err_fxpt_16= zeros(nSeeds, 1);

sqnr_fxpt_db = zeros(nSeeds, 1);
sqnr_fxpt_16_db = zeros(nSeeds, 1);

% Generate Type Structs for all three formats
T_double   = fft_sdf_core_types('double');
T_single   = fft_sdf_core_types('single');
T_fxpt     = fft_sdf_core_types('FxPt');
T_fxpt_16  = fft_sdf_core_types('FxPt_16');


%% RANDOMIZING ACCROSS DIFFERENT SEEDS 
for seed = 1:nSeeds
    rng(seed);
    
    % Generate strict 12-bit physical integers
    min_val = -2048;
    max_val = 2047;
    real_part = randi([min_val, max_val], N, 1); % RANDOM INTEGERS OF 12 BITS 
    imag_part = randi([min_val, max_val], N, 1); % RANDOM INTEGERS OF 12 BITS 
    
    % Create the Q4.8 fraction (Exactly 8 elements, no zero-padding needed)
    x_double = (real_part + 1i * imag_part) / 256;      
    DIN_STREAM = x_double;  
    
    % The golden reference
    expected_output = fft(x_double);
    
    % ==========================================
    % TEST 1: DOUBLE PRECISION
    % ==========================================
    DIN_dbl = cast(DIN_STREAM, 'like', T_double.DIN_STREAM);
    W8_dbl  = cast(W8, 'like', T_double.ROM_OUT_1);
    W4_dbl  = cast(W4, 'like', T_double.ROM_OUT_2);
    
    % Build MEX on first seed using DOUBLE types to track floating-point ranges
    if seed == 1
        buildInstrumentedMex fft_sdf_core -args {DIN_dbl, W8_dbl, W4_dbl, T_double};
    end
    
    % Run the MEX using DOUBLE inputs
    [~, ~, ~, ~, ~, ~, ADD3_dbl, ~, MULT3_dbl] = fft_sdf_core_mex(DIN_dbl, W8_dbl, W4_dbl, T_double);
    
    % Reconstruct the Bit-Reversed hardware output array and convert to natural order
    out_bitrev_dbl = [ADD3_dbl(1); MULT3_dbl(1); ADD3_dbl(3); MULT3_dbl(3); ADD3_dbl(2); MULT3_dbl(2); ADD3_dbl(4); MULT3_dbl(4)];
    out_dbl = bitrevorder(out_bitrev_dbl);
    err_double(seed) = max(abs(out_dbl - expected_output));
    
    % ==========================================
    % TEST 2: SINGLE PRECISION
    % ==========================================
    DIN_sgl = cast(DIN_STREAM, 'like', T_single.DIN_STREAM);
    W8_sgl  = cast(W8, 'like', T_single.ROM_OUT_1);
    W4_sgl  = cast(W4, 'like', T_single.ROM_OUT_2);
    
    [~, ~, ~, ~, ~, ~, ADD3_sgl, ~, MULT3_sgl] = fft_sdf_core(DIN_sgl, W8_sgl, W4_sgl, T_single);
    
    out_bitrev_sgl = [ADD3_sgl(1); MULT3_sgl(1); ADD3_sgl(3); MULT3_sgl(3); ADD3_sgl(2); MULT3_sgl(2); ADD3_sgl(4); MULT3_sgl(4)];
    out_sgl = bitrevorder(out_bitrev_sgl);
    err_single(seed) = max(abs(out_sgl - expected_output));
    
    % ==========================================
    % TEST 3: FIXED-POINT (Instrumented)
    % ==========================================
    DIN_fxpt = cast(DIN_STREAM, 'like', T_fxpt.DIN_STREAM);
    W8_fxpt  = cast(W8, 'like', T_fxpt.ROM_OUT_1);
    W4_fxpt  = cast(W4, 'like', T_fxpt.ROM_OUT_2);
    
    [~, ~, ~, ~, ~, ~, ADD3_fxpt, ~, MULT3_fxpt] = fft_sdf_core(DIN_fxpt, W8_fxpt, W4_fxpt, T_fxpt);
    
    out_bitrev_fxpt = [ADD3_fxpt(1); MULT3_fxpt(1); ADD3_fxpt(3); MULT3_fxpt(3); ADD3_fxpt(2); MULT3_fxpt(2); ADD3_fxpt(4); MULT3_fxpt(4)];
    out_fxpt_double = double(bitrevorder(out_bitrev_fxpt));

    err_fxpt(seed)  = max(abs(out_fxpt_double - expected_output));
    
    signal_power = sum(abs(expected_output).^2);
    noise_power_12 = sum(abs(expected_output - out_fxpt_double).^2);
    
    % Protect against log(0) if noise is exactly zero
    if noise_power_12 == 0
        sqnr_fxpt_db(seed) = Inf; 
    else
        sqnr_fxpt_db(seed) = 10 * log10(signal_power / noise_power_12);
    end

    % ==========================================
    % TEST 4: FIXED-POINT 16-BIT
    % ==========================================
    DIN_fxpt_16 = cast(DIN_STREAM, 'like', T_fxpt_16.DIN_STREAM);
    W8_fxpt_16  = cast(W8, 'like', T_fxpt_16.ROM_OUT_1);
    W4_fxpt_16  = cast(W4, 'like', T_fxpt_16.ROM_OUT_2);
    
    [~, ~, ~, ~, ~, ~, ADD3_fxpt_16, ~, MULT3_fxpt_16] = fft_sdf_core(DIN_fxpt_16, W8_fxpt_16, W4_fxpt_16, T_fxpt_16);
    
    out_bitrev_fxpt_16 = [ADD3_fxpt_16(1); MULT3_fxpt_16(1); ADD3_fxpt_16(3); MULT3_fxpt_16(3); ADD3_fxpt_16(2); MULT3_fxpt_16(2); ADD3_fxpt_16(4); MULT3_fxpt_16(4)];
    out_fxpt_16_double = double(bitrevorder(out_bitrev_fxpt_16));
    err_fxpt_16(seed)  = max(abs(out_fxpt_16_double - expected_output));
    
    % NEW: Calculate 16-bit SQNR
    noise_power_16 = sum(abs(expected_output - out_fxpt_16_double).^2);
    
    if noise_power_16 == 0
        sqnr_fxpt_16_db(seed) = Inf;
    else
        sqnr_fxpt_16_db(seed) = 10 * log10(signal_power / noise_power_16);
    end
    
end

%% Plots 
% Plot the verifier for the final seed's fixed-point output
fft_plot_verifier(out_fxpt_double, x_double, N, expected_output, err_double, err_single, err_fxpt, err_fxpt_16, nSeeds, sqnr_fxpt_db,sqnr_fxpt_16_db);

% 5. DISPLAY ACCUMULATED INSTRUMENTATION REPORT
showInstrumentationResults fft_sdf_core_mex -proposeFL -defaultDT numerictype(1,32);