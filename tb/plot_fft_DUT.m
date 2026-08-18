clear; clc; close all;

% File paths
csv_file = 'fft_first5_compare.csv';
in_file  = 'fft_input_vectors.txt';

if ~isfile(csv_file)
    error('%s was not found. Run the Questa simulation first.', csv_file);
end
if ~isfile(in_file)
    error('%s was not found. Run fft_golden.m first.', in_file);
end

% Read output data (from testbench CSV)
T_out = readtable(csv_file);

% Read input data (from golden vector text file)
% Format: [frame, sample_index, in_re, in_im]
T_in = readmatrix(in_file);

% Frame names from tb_fft.sv
frame_names = { ...
    'ZERO', ...
    'IMPULSE_N0', ...
    'IMPULSE_N3', ...
    'DC_POS_1', ...
    'DC_NEG_1', ...
    'ALTERNATING_1', ...
    'RAMP', ...
    'REAL_COS_BIN1', ...
    'COMPLEX_TONE_BIN1', ...
    'RANDOM_COMPLEX', ...
    'ONE_LSB', ...
    'MAX_POS_IMPULSE', ...
    'MIN_NEG_IMPULSE', ...
    'MAX_MIN_PAIR', ...
    'MIXED_COMPLEX_CORNERS'};

% --- Create directory for exporting plots ---
out_dir = 'fft_plots';
if ~exist(out_dir, 'dir')
    mkdir(out_dir);
end

for frame = 0:14
    % Filter and sort output data for current frame
    D_out = T_out(T_out.frame == frame, :);
    D_out = sortrows(D_out, 'serial_index');
    
    if height(D_out) ~= 8
        error('Frame %d contains %d outputs; expected 8.', frame, height(D_out));
    end
    
    % Filter and sort input data for current frame
    D_in = T_in(T_in(:,1) == frame, :);
    D_in = sortrows(D_in, 2);
    
    % Calculate Complex Inputs & Outputs
    % Inputs are Q4.8 integer format, so divide by 256.0
    in_cplx = complex(D_in(:,3), D_in(:,4)) / 256.0;
    
    in_mag = abs(in_cplx);
    in_phase = angle(in_cplx); % Phase in radians
    
    % Outputs in the CSV are already scaled to decimal format by the testbench
    dut_cplx = complex(D_out.dut_re, D_out.dut_im);
    matlab_cplx = complex(D_out.matlab_re, D_out.matlab_im);
    
    dut_mag = abs(dut_cplx);
    matlab_mag = abs(matlab_cplx);
    
    dut_phase = angle(dut_cplx);
    matlab_phase = angle(matlab_cplx);
    
    % X-axis setup
    x_in = 0:7;  % Native time index for inputs
    x_out = 1:8; % Plot index for outputs
    bins = D_out.fft_bin.';
    
    % Create Figure (Visible set to 'off' for fast background exporting)
    fig = figure('Visible', 'off', 'Position', [100 100 1000 800], 'Name', sprintf('Frame %d', frame));
    tl = tiledlayout(fig, 2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
    title(tl, sprintf('8-Point FFT: %s', frame_names{frame+1}), ...
          'Interpreter', 'none', 'FontWeight', 'bold', 'FontSize', 14);
    
    % --- Tile 1: Input Magnitude ---
    nexttile;
    stem(x_in, in_mag, 'filled', 'LineWidth', 1.5, 'MarkerSize', 6, 'Color', '#0072BD');
    grid on;
    xticks(x_in);
    xlabel('Time Index (n)');
    ylabel('Magnitude |x[n]|');
    title('Input Magnitude');
    
    % --- Tile 2: Input Phase ---
    nexttile;
    stem(x_in, in_phase, 'filled', 'LineWidth', 1.5, 'MarkerSize', 6, 'Color', '#D95319');
    grid on;
    xticks(x_in);
    yticks([-pi -pi/2 0 pi/2 pi]);
    yticklabels({'-\pi', '-\pi/2', '0', '\pi/2', '\pi'});
    ylim([-pi-0.5 pi+0.5]);
    xlabel('Time Index (n)');
    ylabel('Phase (radians)');
    title('Input Phase');
    
    % --- Tile 3: Output Magnitude (DUT vs MATLAB) ---
    nexttile;
    stem(x_out, dut_mag, '-o', 'LineWidth', 1.4, 'MarkerSize', 6); hold on;
    stem(x_out, matlab_mag, '--x', 'LineWidth', 1.4, 'MarkerSize', 7);
    grid on;
    xticks(x_out);
    xticklabels(string(bins));
    xlabel('FFT Bin (Native Serial Order)');
    ylabel('Magnitude |X[k]|');
    title('Output Magnitude');
    legend('DUT', 'MATLAB fft()', 'Location', 'best');
    
    % --- Tile 4: Output Phase (DUT vs MATLAB) ---
    nexttile;
    stem(x_out, dut_phase, '-o', 'LineWidth', 1.4, 'MarkerSize', 6); hold on;
    stem(x_out, matlab_phase, '--x', 'LineWidth', 1.4, 'MarkerSize', 7);
    grid on;
    xticks(x_out);
    xticklabels(string(bins));
    yticks([-pi -pi/2 0 pi/2 pi]);
    yticklabels({'-\pi', '-\pi/2', '0', '\pi/2', '\pi'});
    ylim([-pi-0.5 pi+0.5]);
    xlabel('FFT Bin (Native Serial Order)');
    ylabel('Phase (radians)');
    title('Output Phase');
    legend('DUT', 'MATLAB fft()', 'Location', 'best');
    
    % --- Export to file ---
    png_name = sprintf('Frame_%02d_%s.png', frame, frame_names{frame+1});
    exportgraphics(fig, fullfile(out_dir, png_name), 'Resolution', 300);
    
    % Close figure to free up memory
    close(fig);
end

disp('Generated 15 plots.');
fprintf('Exported 15 high-resolution magnitude/phase plots to: %s\n', out_dir);