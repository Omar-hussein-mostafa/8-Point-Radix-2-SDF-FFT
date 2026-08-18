function T = fft_sdf_core_types(dataType)
    
    % Define strict RTL behavior: Truncate (Floor) and Wrap
    rtl_math = fimath('RoundingMethod', 'Floor', 'OverflowAction', 'Wrap');
    
    switch dataType
        case 'double'
            % --- Inputs & Twiddles ---
            T.DIN_STREAM = double([]);
            T.ROM_OUT_1  = double([]);
            T.ROM_OUT_2  = double([]);
            T.W2         = double([]);
            
            % --- Stage 1 ---
            T.ADD1       = double([]);
            T.SUB1       = double([]);
            T.MULT1      = double([]);
            
            % --- Stage 2 ---
            T.ADD2       = double([]);
            T.SUB2       = double([]);
            T.MULT2      = double([]);
            
            % --- Stage 3 ---
            T.ADD3       = double([]);
            T.SUB3       = double([]);
            T.MULT3      = double([]);
            
        case 'single'
            % --- Inputs & Twiddles ---
            T.DIN_STREAM = single([]);
            T.ROM_OUT_1  = single([]);
            T.ROM_OUT_2  = single([]);
            T.W2         = single([]);
            
            % --- Stage 1 ---
            T.ADD1       = single([]);
            T.SUB1       = single([]);
            T.MULT1      = single([]);
            
            % --- Stage 2 ---
            T.ADD2       = single([]);
            T.SUB2       = single([]);
            T.MULT2      = single([]);
            
            % --- Stage 3 ---
            T.ADD3       = single([]);
            T.SUB3       = single([]);
            T.MULT3      = single([]);
            
        case 'FxPt'
            % --- Inputs & Twiddles ---
            % DIN Q4.8 (12 bits total: 4 int, 8 frac)
            T.DIN_STREAM = fi([], 1, 4 + 8, 8, rtl_math); 
            
            % Twiddles Q2.10 (12 bits total: 2 int, 10 frac)
            T.ROM_OUT_1  = fi([], 1, 2 + 10, 10, rtl_math); 
            T.ROM_OUT_2  = fi([], 1, 2 + 10, 10, rtl_math);
            T.W2         = fi([], 1, 2 + 10, 10, rtl_math);
            
            % --- Stage 1 ---
            % ADD1 aligned to MULT1 for seamless Stage 2 array concatenation
            T.ADD1       = fi([], 1, 6 + 6, 6, rtl_math);
            T.SUB1       = fi([], 1, 5 + 7, 7, rtl_math);
            T.MULT1      = fi([], 1, 6 + 6, 6, rtl_math);
            
            % --- Stage 2 ---
            % ADD2, SUB2, MULT2 are all Q6.6
            T.ADD2       = fi([], 1, 6 + 6, 6, rtl_math);
            T.SUB2       = fi([], 1, 6 + 6, 6, rtl_math);
            T.MULT2      = fi([], 1, 6 + 6, 6, rtl_math);
            
            % --- Stage 3 ---
            % ADD3, SUB3, MULT3 are all Q7.5
            T.ADD3       = fi([], 1, 7 + 5, 5, rtl_math);
            T.SUB3       = fi([], 1, 7 + 5, 5, rtl_math);
            T.MULT3      = fi([], 1, 7 + 5, 5, rtl_math);
            
        case 'FxPt_16'
            % --- Inputs & Twiddles ---
            % 12-bit total input to match system interface (4 int, 8 frac)
            T.DIN_STREAM = fi([], 1, 4 + 8, 8, rtl_math); 
            
            % Twiddles (2 int, 14 frac = 16 bits total)
            T.ROM_OUT_1  = fi([], 1, 2 + 14, 14, rtl_math); 
            T.ROM_OUT_2  = fi([], 1, 2 + 14, 14, rtl_math);
            T.W2         = fi([], 1, 2 + 14, 14, rtl_math);
            
            % --- Stage 1 (Total 16 bits) ---
            % Aligned ADD1 and MULT1 to 10 fractional bits (Requires 6 int bits)
            T.ADD1       = fi([], 1, 6 + 10, 10, rtl_math);
            T.SUB1       = fi([], 1, 5 + 11, 11, rtl_math); % Requires 5 int bits
            T.MULT1      = fi([], 1, 6 + 10, 10, rtl_math); 
            
            % --- Stage 2 (Total 16 bits) ---
            % Requires 6 int bits -> 10 fractional bits
            T.ADD2       = fi([], 1, 6 + 10, 10, rtl_math);
            T.SUB2       = fi([], 1, 6 + 10, 10, rtl_math);
            T.MULT2      = fi([], 1, 6 + 10, 10, rtl_math); 
            
            % --- Stage 3 (Total 16 bits) ---
            % Requires 7 int bits -> 9 fractional bits
            T.ADD3       = fi([], 1, 7 + 9, 9, rtl_math);
            T.SUB3       = fi([], 1, 7 + 9, 9, rtl_math);
            T.MULT3      = fi([], 1, 7 + 9, 9, rtl_math);
            
        otherwise
            error('Invalid data type specified. Use ''double'', ''single'', ''FxPt'', or ''FxPt_16''.');
    end
end