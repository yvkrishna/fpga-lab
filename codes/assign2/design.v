// Module to convert Q(2, 14) to Q(3, 13)
module q2_14_to_q3_13 (
    input clk,               // Clock input
    input signed [15:0] q2_14_in,  // 16-bit input in Q(2,14)
    output reg signed [15:0] q3_13_out  // 16-bit output in Q(3,13)
);

    always @(posedge clk) begin
        q3_13_out <= q2_14_in >>> 1; // Right shift by 1 on the positive edge of the clock
    end

endmodule


// Module to convert Q(4, 12) to Q(3, 13)
module q4_12_to_q3_13 (
    input clk,               // Clock input
    input signed [15:0] q4_12_in,  // 16-bit input in Q(4,12)
    output reg signed [15:0] q3_13_out  // 16-bit output in Q(3,13)
);

    always @(posedge clk) begin
        q3_13_out <= q4_12_in <<< 1; // Left shift by 1 on the positive edge of the clock
    end

endmodule


// Module to perform operations on converted values
module do_all_ops(
    input clk,
    input signed [15:0] q2_14,
    input signed [15:0] q4_12,
    output reg signed [15:0] sum_res,
  output reg signed [15:0] diff_res,
  output reg signed [15:0] multi_res,
    output reg cout,
  output reg borrow_res  
);
    wire signed [15:0] q13_op_1, q13_op_2;
  output reg signed [32:0] mul_result;
    
    q2_14_to_q3_13 conv1(.clk(clk), .q2_14_in(q2_14), .q3_13_out(q13_op_1));
    q4_12_to_q3_13 conv2(.clk(clk), .q4_12_in(q4_12), .q3_13_out(q13_op_2));
    
    always @(posedge clk) begin
        {cout, sum_res} <= q13_op_1 + q13_op_2;
      	{borrow_res, diff_res} <=  q13_op_1 - q13_op_2;
      	mul_result = q13_op_1 * q13_op_2;
        multi_res = {mul_result[28:26], mul_result[25:13]}; 
    end

endmodule