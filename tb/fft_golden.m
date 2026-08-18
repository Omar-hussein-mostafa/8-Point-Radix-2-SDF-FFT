clear; clc;

% 8-point FFT golden-vector generator
% DUT input : signed 12-bit Q4.8
% DUT output: signed 12-bit Q7.5
% Native serial output order: bins [0 4 2 6 1 5 3 7]
%
% IMPORTANT:
%   fft() is kept as the ideal mathematical reference.
%   Exact DUT checking uses fft8_rtl_fixed(), which mirrors every RTL
%   bit-drop/floor operation and the quantized ROM twiddles.

fprintf('Golden model version: RTL_BIT_ACCURATE_FLOOR_V3\n');

N = 8;
bitrev_bins = [0 4 2 6 1 5 3 7];

num_frames = 15;
in_re = zeros(num_frames, N);
in_im = zeros(num_frames, N);

% 0) All zeros
in_re(1,:) = 0;
in_im(1,:) = 0;

% 1) Unit impulse at n=0
in_re(2,1) = 256;

% 2) Unit impulse at n=3
in_re(3,4) = 256;

% 3) +1 DC
in_re(4,:) = 256;

% 4) -1 DC
in_re(5,:) = -256;

% 5) Alternating +1 / -1
in_re(6,:) = [256 -256 256 -256 256 -256 256 -256];

% 6) Real ramp
in_re(7,:) = round(256 * (-1.00:0.25:0.75));

% 7) Real cosine at FFT bin 1
n = 0:N-1;
in_re(8,:) = q48(cos(2*pi*n/N));

% 8) Complex sinusoid at bin 1, amplitude 0.75
in_re(9,:) = q48(0.75*cos(2*pi*n/N));
in_im(9,:) = q48(0.75*sin(2*pi*n/N));

% 9) Deterministic complex vector
in_re(10,:) = [300 -271 128 -63 377 -345 42 -190];
in_im(10,:) = [-120 333 -384 211 19 -256 301 -77];

% 10) +/- 1-LSB values around zero
in_re(11,:) = [1 -1 1 -1 1 -1 1 -1];
in_im(11,:) = [-1 1 1 -1 1 1 -1 1];

% 11) Maximum-positive Q4.8 impulse
in_re(12,1) = 2047;

% 12) Minimum-negative Q4.8 impulse
in_re(13,1) = -2048;

% 13) Adjacent MAX/MIN pair
in_re(14,1:2) = [2047 -2048];

% 14) Mixed real/imaginary corners
in_re(15,:) = [2047 0 -2048 0 0 0 0 0];
in_im(15,:) = [0 2047 0 -2048 0 0 0 0];

fid_in  = fopen('fft_input_vectors.txt', 'w');
fid_exp = fopen('fft_expected_vectors.txt', 'w');
if fid_in < 0 || fid_exp < 0
    error('Could not open vector files.');
end

for frame = 1:num_frames
    % Built-in FFT: ideal mathematical reference (double precision).
    x = double(in_re(frame,:))/256 + 1j*double(in_im(frame,:))/256;
    X_ideal = fft(x, N); %#ok<NASGU>

    % Bit-accurate fixed-point expected result.
    % Returned order is already the DUT serial DIF order:
    % [bin0 bin4 bin2 bin6 bin1 bin5 bin3 bin7].
    [exp_re, exp_im] = fft8_rtl_fixed(in_re(frame,:), in_im(frame,:));

    for sample = 1:N
        fprintf(fid_in, '%d %d %d %d\n', ...
            frame-1, sample-1, in_re(frame,sample), in_im(frame,sample));
    end

    for out_idx = 1:N
        fprintf(fid_exp, '%d %d %d %d %d\n', ...
            frame-1, out_idx-1, bitrev_bins(out_idx), ...
            exp_re(out_idx), exp_im(out_idx));
    end
end

fclose(fid_in);
fclose(fid_exp);

fprintf('Generated %d FFT frames (%d input samples).\n', num_frames, num_frames*N);
fprintf('Expected model: exact RTL shifts/slices, floor on dropped LSBs.\n');
fprintf('Expected DUT serial bin order: 0 4 2 6 1 5 3 7\n');


function [o_re, o_im] = fft8_rtl_fixed(x_re, x_im)
    % Bit-accurate model of SDF_STAGE.sv.
    % All variables are integer codes stored in MATLAB doubles.

    % ROM.sv Q2.10 twiddles: W8^0, W8^1, W8^2, W8^3.
    tw_re = [1024,  724,     0, -724];
    tw_im = [   0, -724, -1024, -724];

    s1_re = zeros(1,8); s1_im = zeros(1,8);
    s2_re = zeros(1,8); s2_im = zeros(1,8);
    s3_re = zeros(1,8); s3_im = zeros(1,8);

    % ---------------- Stage 1 ----------------
    % Butterfly spacing = 4.
    % ADD path: temp_ADD1[12:2] with sign extension => arithmetic >> 2.
    % SUB path before twiddle: temp_SUB1[12:1] => arithmetic >> 1.
    % CMULT1 output: temp_mult[22:11] => arithmetic >> 11, then 12-bit wrap.
    for k = 1:4
        add_re = floor((x_re(k) + x_re(k+4)) / 4);
        add_im = floor((x_im(k) + x_im(k+4)) / 4);
        sub_re = floor((x_re(k) - x_re(k+4)) / 2);
        sub_im = floor((x_im(k) - x_im(k+4)) / 2);

        s1_re(k) = wrap12(add_re);
        s1_im(k) = wrap12(add_im);

        sub_re = wrap12(sub_re);
        sub_im = wrap12(sub_im);
        [s1_re(k+4), s1_im(k+4)] = cmult_slice( ...
            sub_re, sub_im, tw_re(k), tw_im(k), 11);
    end

    % ---------------- Stage 2 ----------------
    % Butterfly spacing = 2 inside each 4-point group.
    % ADD/SUB keep bits [11:0] => 12-bit wrap, no fractional-bit drop.
    % CMULT2 output uses temp_mult[21:10] => arithmetic >> 10.
    for base = [1 5]
        for k = 0:1
            ia = base + k;
            ib = base + k + 2;

            add_re = wrap12(s1_re(ia) + s1_re(ib));
            add_im = wrap12(s1_im(ia) + s1_im(ib));
            sub_re = wrap12(s1_re(ia) - s1_re(ib));
            sub_im = wrap12(s1_im(ia) - s1_im(ib));

            s2_re(ia) = add_re;
            s2_im(ia) = add_im;

            if k == 0
                tw_idx = 1;  % W8^0 = 1
            else
                tw_idx = 3;  % W8^2 = -j
            end

            [s2_re(ib), s2_im(ib)] = cmult_slice( ...
                sub_re, sub_im, tw_re(tw_idx), tw_im(tw_idx), 10);
        end
    end

    % ---------------- Stage 3 ----------------
    % Butterfly spacing = 1.
    % Final ADD/SUB use temp_[12:1] => arithmetic >> 1 to Q7.5.
    for base = [1 3 5 7]
        ar = s2_re(base);   ai = s2_im(base);
        br = s2_re(base+1); bi = s2_im(base+1);

        s3_re(base)   = wrap12(floor((ar + br) / 2));
        s3_im(base)   = wrap12(floor((ai + bi) / 2));
        s3_re(base+1) = wrap12(floor((ar - br) / 2));
        s3_im(base+1) = wrap12(floor((ai - bi) / 2));
    end

    % In radix-2 DIF, these positions are already bit-reversed bins:
    % [0 4 2 6 1 5 3 7].
    o_re = s3_re;
    o_im = s3_im;
end


function [c_re, c_im] = cmult_slice(a_re, a_im, b_re, b_im, shift)
    % Mirrors Complex_MULT.sv exactly for the value range used here.
    prod_re = a_re*b_re - a_im*b_im;
    prod_im = a_re*b_im + a_im*b_re;

    % SystemVerilog signed bit-slice after dropping LSBs is equivalent to
    % arithmetic floor division followed by retaining the low 12 bits.
    c_re = wrap12(floor(prod_re / (2^shift)));
    c_im = wrap12(floor(prod_im / (2^shift)));
end


function y = q48(x)
    % Quantize stimulus to the representable 12-bit Q4.8 input grid.
    y = round(x * 256);
    y(y >  2047) =  2047;
    y(y < -2048) = -2048;
end


function y = wrap12(x)
    % Signed 12-bit two's-complement wrap, matching logic signed [11:0].
    y = mod(x, 4096);
    idx = (y >= 2048);
    y(idx) = y(idx) - 4096;
end
