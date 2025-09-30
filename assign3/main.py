# Utility function
def fixed_point(x, int_bits, frac_bits):
    scale_factor = 2 ** frac_bits  # Scale up
    total_bits = int_bits + frac_bits  # Total bits (sign included in int_bits)
    max_val = 2 ** (total_bits - 1) - 1  # Max range
    min_val = -2 ** (total_bits - 1)  # Min range

    # Convert to fixed-point integer representation
    x_fixed = np.round(x * scale_factor).astype(int)  # Scale & round
    x_fixed = np.clip(x_fixed, min_val, max_val)  # Clip to avoid overflow

    # Convert to binary (Two’s Complement)
    binary_repr = np.vectorize(lambda num: format(num & (2**total_bits - 1), f'0{total_bits}b'))

    return x_fixed/scale_factor, binary_repr(x_fixed)

import numpy as np

# Utility function
def fixed_point_to_num(bin_string, int_bits, frac_bits):
    total_bits = int_bits + frac_bits  # Total number of bits
    is_negative = bin_string[0] == '1'  # Check if it's negative (MSB is 1)

    # Convert binary string to integer
    int_value = int(bin_string, 2)

    # Handle two’s complement for negative numbers
    if is_negative:
        int_value -= 2 ** total_bits  # Convert from two’s complement

    # Scale down to get the actual value
    return int_value / (2 ** frac_bits)











# For single value
def newton_raphson_iterative(nr, dr, init_guess, eps=1e-5):
  x_init = init_guess

  for i in range(100):
    x_ipp = x_init*(2-dr*x_init)
    x_init = x_ipp

  x_optim = x_init
  return nr*x_optim

print(newton_raphson_iterative(15, 23, 0.08))




# For array of values
nr = np.array([15, 2, 15, 29, 9, 19, 2, 18, 19])
dr = np.array([23, 11, 13, 17, 19, 29, 7, 2, 3])
# Using formula for initial guesses
initial_guess = 2 ** (-np.ceil(np.log2(dr)))

nr_Q6_10, nr_10_bin = fixed_point(nr, 6, 10)
dr_Q6_10, dr_10_bin = fixed_point(dr, 6, 10)
guess_Q6_10, guess_10_bin = fixed_point(initial_guess, 6, 10)

div_res = np.zeros(nr.shape)

for i in range(len(nr)):
  div_res[i] = newton_raphson_iterative(nr[i], dr[i], initial_guess[i])



# Saving numerator, denominator, initial guesses as text files to load in verilog
with open("nr.txt", "w") as f:
  ind = 0
  for bin in nr_10_bin:
    if(ind == len(nr_10_bin)-1):
      f.write(bin)
    else:
      f.write(bin+"\n")
    ind+=1

with open("dr.txt", "w") as f:
  ind = 0
  for bin in dr_10_bin:
    if(ind == len(dr_10_bin)-1):
      f.write(bin)
    else:
      f.write(bin+"\n")
    ind+=1

with open("initial_guess.txt", "w") as f:
  ind = 0
  for bin in guess_10_bin:
    if(ind == len(guess_10_bin)-1):
      f.write(bin)
    else:
      f.write(bin+"\n")
    ind+=1




# For verifying verilog outputs
fpga_res = []
with open('div_res.txt', encoding='utf8') as file:
    for line in file:
        fpga_res.append(fixed_point_to_num(line.strip(), 6, 10))

fpga_res = np.array(fpga_res)
print(np.mean(np.abs(div_res - fpga_res)))