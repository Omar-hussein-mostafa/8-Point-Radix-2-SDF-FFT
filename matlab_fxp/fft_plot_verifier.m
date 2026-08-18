function fft_plot_verifier (natural_order_output,x_valid,N,expected_output,err_double,err_single,err_fxpt,err_fxpt_16,nSeeds,sqnr_fxpt_db,sqnr_fxpt_16_db)

disp('====== Sample Test Case Output (Seed 100) ======');
disp(' Bin |      Input (Time Domain)      |    Output (Frequency Domain)  ');
disp('---------------------------------------------------------------------');
for i = 1:N
    fprintf(' %2d  |  %7.4f %s %7.4fi   |  %9.4f %s %9.4fi\n', ...
        i-1, ...
        real(x_valid(i)), sign_char(imag(x_valid(i))), abs(imag(x_valid(i))), ...
        real(natural_order_output(i)), sign_char(imag(natural_order_output(i))), abs(imag(natural_order_output(i))));
end


% ---------------------------------------------------------
% 6. VISUALIZE RESULTS (Magnitude and Phase)
% ---------------------------------------------------------
figure('Name', 'FFT Output Verification', 'Color', 'w');

% Plot 1: Magnitude
subplot(2, 1, 1);
% Plot the expected output (MATLAB builtin) as blue circles
stem(0:N-1, abs(expected_output), 'b-o', 'LineWidth', 1.5, 'MarkerSize', 8);
hold on;
% Plot the hardware model output as red crosses
stem(0:N-1, abs(natural_order_output), 'r-x', 'LineWidth', 1.5, 'MarkerSize', 8);
grid on;
title('FFT Magnitude: Hardware Model vs. Expected');
xlabel('Frequency Bin (k)');
ylabel('Magnitude |X(k)|');
legend('Expected (Built-in FFT)', 'Hardware Model', 'Location', 'best');

% Plot 2: Phase
subplot(2, 1, 2);
% Plot the expected output phase as blue circles
stem(0:N-1, angle(expected_output), 'b-o', 'LineWidth', 1.5, 'MarkerSize', 8);
hold on;
% Plot the hardware model output phase as red crosses
stem(0:N-1, angle(natural_order_output), 'r-x', 'LineWidth', 1.5, 'MarkerSize', 8);
grid on;
title('FFT Phase: Hardware Model vs. Expected');
xlabel('Frequency Bin (k)');
ylabel('Phase (Radians)');
legend('Expected (Built-in FFT)', 'Hardware Model', 'Location', 'best');


% 3. PLOT THE ERRORS
figure('Name', 'Quantization Error Analysis', 'Color', 'w');
% Using semilogy because double error is ~1e-15, while fixed is ~1e-2
semilogy(1:nSeeds, err_double, '-o', 'DisplayName', 'Double Precision', 'LineWidth', 1.5);
hold on;
grid on;
semilogy(1:nSeeds, err_single, '-s', 'DisplayName', 'Single Precision', 'LineWidth', 1.5);
semilogy(1:nSeeds, err_fxpt, '-^', 'DisplayName', '12 Fixed-Point (Q4.8 Input)', 'LineWidth', 1.5);
semilogy(1:nSeeds, err_fxpt_16, '-^', 'DisplayName', '16 Fixed-Point ', 'LineWidth', 1.5);

title('Maximum FFT Error per Seed Across Data Types');
xlabel('Random Seed Index');
ylabel('Maximum Absolute Error (Log Scale)');
legend('Location', 'best');
hold off;

% 4. VERIFY FIXED POINT (Throw warning if error is catastrophically high)
max_fxpt_error = max(err_fxpt);
disp('--------------------------------------------------');
disp(['Max Double Error: ', num2str(max(err_double))]);
disp(['Max Single Error: ', num2str(max(err_single))]);
disp(['Max FxPt Error:   ', num2str(max_fxpt_error)]);
disp('--------------------------------------------------');

if max_fxpt_error > 0.5 
    warning('Fixed-Point error is larger than expected. Check bit widths for overflow!');
else
    disp('SUCCESS: Fixed-point math tracked expected output perfectly within quantization limits!');
end

%% FINAL SQNR REPORT
disp('==================================================');
disp('              AVERAGE SQNR REPORT                 ');
disp('==================================================');

% Calculate the mean (ignoring Inf if any perfect matches occurred)
avg_sqnr_12 = mean(sqnr_fxpt_db(isfinite(sqnr_fxpt_db)));
avg_sqnr_16 = mean(sqnr_fxpt_16_db(isfinite(sqnr_fxpt_16_db)));

fprintf('Average SQNR (12-bit Datapath): %8.2f dB\n', avg_sqnr_12);
fprintf('Average SQNR (16-bit Datapath): %8.2f dB\n', avg_sqnr_16);
disp('==================================================');

end
