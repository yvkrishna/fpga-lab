function [x_fixed_scaled, binary_repr] = fixed_point(x, int_bits, frac_bits)
    scale_factor = 2 ^ frac_bits; % Scale up
    total_bits = int_bits + frac_bits; % Total bits (sign included in int_bits)
    max_val = 2^(total_bits - 1) - 1; % Max range
    min_val = -2^(total_bits - 1); % Min range

    % Convert to fixed-point integer representation
    x_fixed = round(x * scale_factor); % Scale & round
    x_fixed = max(min(x_fixed, max_val), min_val); % Clip to avoid overflow

    % Convert to Two’s Complement binary representation
    binary_repr = arrayfun(@(num) dec2bin(mod(num, 2^total_bits), total_bits), x_fixed, 'UniformOutput', false);

    % Convert back to fixed-point scaled value
    x_fixed_scaled = x_fixed/scale_factor;
end


function num = fixed_point_to_num(bin_string, int_bits, frac_bits)
    total_bits = int_bits + frac_bits; % Total number of bits
    is_negative = (bin_string(1) == '1'); % Check if negative (MSB is 1)

    % Convert binary string to integer
    int_value = bin2dec(bin_string);

    % Handle two’s complement for negative numbers
    if is_negative
        int_value = int_value - 2^total_bits;
    end

    % Scale down to get the actual value
    num = int_value / (2^frac_bits);
end





clear all; close all; clc;
load('filter_coeff.mat');

fir_coeff = filter_coeff(52:71);

[x_scaled, binary] = fixed_point(fir_coeff, 2, 14);
writecell(transpose(binary), 'filter_coeff_bin.txt');


fs = 48000;  
freq = [100, 2000, 6000, 11000]; 
num_cycles = 5;

conv_res = cell(1, length(freq));

% figure()
for i = 1:4
    time_5 = 0:(1/fs):(num_cycles/freq(i));  % Time vector for 5 cycles
    sin_wave = sin(2 * pi * freq(i) * time_5); 

    [sin_scaled, sine_bin] = fixed_point(sin_wave, 2, 14);
    writecell(transpose(sine_bin), "sin_wav_" + num2str(i) + ".txt");

    conv_res{i} = conv(sin_wave, fir_coeff, 'full');    

    fileID = fopen('conv_res_1.txt', 'r'); 
    data = textscan(fileID, '%s');  % Read as cell array of strings
    fclose(fileID);

    bin_res = cell2mat(data{1});
    conv_fpga_res = zeros(size(conv_res{i}));
    
    for i=1:length(conv_fpga_res)
       conv_fpga_res(i) = fixed_point_to_num(bin_res(i,:), 2, 14); 
    end


    % subplot(4,1,i);
    % plot(sin_wave);
    % hold on;
    % plot(conv_fpga_res);
    % hold off;

    % plot(conv_res{1})
    % hold on;
    plot(transpose(conv_fpga_res))
    % hold off;


    % title(sprintf('Sinewave at %d Hz', freq(i)));
    % xlabel('Time (s)');
    % ylabel('Amplitude');
    % grid on;
end


[conv_scaled, conv_binary] = fixed_point(conv_res{1}, 2, 14);

fileID = fopen('conv_res.txt', 'r'); 
data = textscan(fileID, '%s');  % Read as cell array of strings
fclose(fileID);

conv_fpga_res = fixed_point_to_num(cell2mat(data{1}), 2, 14);
mean_error = sum(abs(transpose(conv_fpga_res) - conv_res{1}));


% fileID = fopen('filter_coeff_bin.txt', 'r');
% data = textscan(fileID, '%s');  % Read as cell array of strings
% fclose(fileID);
% a = fixed_point_to_num(cell2mat(data{1}), 2, 14);
% plot(a)
% % % a=fixed_point_to_num('0000000000111010', 2, 14)
% % 
% % % 
% % % [c, d] = fixed_point(2.25, 3, 2)
% % % [c, d] = fixed_point(-2.0, 4, 3)
% % [c, d] = fixed_point(0.0035, 2, 14)
% % e = fixed_point_to_num(cell2mat(d), 2, 14)
% % [c, d] = fixed_point(0.2319, 2, 14)
% % e = fixed_point_to_num(cell2mat(d), 2, 14)
