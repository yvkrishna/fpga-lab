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
        int_value = int_value - (2^total_bits);
    end

    % Scale down to get the actual value
    num = int_value / (2^frac_bits);
end


% clear all; close all; clc;
% load('filter_coeff.mat');
% fs = 48000;  
% freq = 100; 
% num_cycles = 5;
% 
% time_5 = 0:(1/fs):(num_cycles/freq); 
% input = sin(2 * pi * freq * time_5); 
% impulse_filter = filter_coeff(52:71);

input = ones(1, 5);
impulse_filter = ones(1, 3);


[x_scaled, x_binary] = fixed_point(input, 2, 14);
[h_scaled, h_binary] = fixed_point(impulse_filter, 2, 14);
conv_result_m = conv(x_scaled, h_scaled, "full");

writecell(transpose(h_binary), 'filter_coeff_bin.txt');
writecell(transpose(x_binary), 'input.txt');

fileID = fopen('conv_res.txt', 'r'); 
data = textscan(fileID, '%s');  % Read as cell array of strings
fclose(fileID);

bin_res = cell2mat(data{1});
conv_fpga_res = zeros(size(conv_result_m));

for i=1:length(conv_fpga_res)
   conv_fpga_res(i) = fixed_point_to_num(bin_res(i,:), 2, 14); 
end
% conv_fpga_res = transpose(conv_fpga_res);
mean_error = sum(abs(conv_fpga_res - conv_result_m))

plot(conv_result_m)
hold on;
plot(conv_fpga_res)
% legend('matlab_res', 'fpga_res');
hold off;