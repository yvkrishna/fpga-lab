// Test Bench
module MyModule;
    reg [15:0] operand1_q2_14 [239:0]; // 2 integer bits, 14 fractional bits
    reg [15:0] operand2_q4_12 [239:0]; // 4 integer bits, 12 fractional bits

    integer j;
    reg clk;
    reg signed [15:0] add_res [239:0];
  	reg signed [15:0] sub_res [239:0];
  	reg signed [15:0] mul_res [239:0];
    reg cout_add [0:239];
  	reg borrow_sub [0:239];

    wire signed [15:0] sum_res[239:0];
    wire signed [15:0] diff_res [239:0];
    wire signed [15:0] multi_res [239:0];
    wire cout[0:239];
    wire borrow_res[0:239];
    reg is_completed;

    // Clock generation
    always #5 clk = ~clk;

    // Initial block for loading data and instantiating the modules
    initial begin
        clk = 1'b0;
        is_completed = 1'b0;

        // Reading operand values from files
        $readmemb("operand_1.txt", operand1_q2_14, 0, 239);
        $readmemb("operand_2.txt", operand2_q4_12, 0, 239);

        // Printing operand values for debugging
        $display("Operand values 0 to 3:");
        for (j = 0; j < 4; j = j + 1) begin
            $display("%0d: operand1_q2_14[%0d] = %b; operand2_q4_12[%0d] = %b", j, j, operand1_q2_14[j], j, operand2_q4_12[j]);
        end
      
      // $monitor("cout[1] = %d,  add_res[1] = %b,     borrow[1] = %b, diff_res[1] = %b,    product[1] = %b    is_completed = %b", cout_add[1], add_res[1], borrow_sub[1], sub_res[1], mul_res[1], is_completed);
      #200 $finish;
    end

    	generate
        genvar i;
        for(i=0;i<240;i=i+1) begin : ALL_OPS
            do_all_ops OPS(
              .clk(clk),
              .q2_14(operand1_q2_14[i]),
              .q4_12(operand2_q4_12[i]),
              .sum_res(sum_res[i]),
              .diff_res(diff_res[i]),
              .multi_res(multi_res[i]),
              .cout(cout[i]),
              .borrow_res(borrow_res[i])
            );
          end
      endgenerate

      // is_completed = 1'b1;

  // do_all_ops OPS(
  //   .clk(clk),
  //   .q2_14(operand1_q2_14[1]),
  //   .q4_12(operand2_q4_12[1]),
  //   .sum_res(sum_res),
  //   .diff_res(diff_res),
  //   .multi_res(multi_res),
  //   .cout(cout),
  //   .borrow_res(borrow_res)
  // );

  // always@(posedge clk) begin
  //   add_res[i] <= sum_res[i];
  //   sub_res[i] <= diff_res[i];
  //   mul_res[i] <= multi_res[i];
  //   cout_add[i] <= cout[i];
  //   borrow_sub[i] <= borrow_res[i];
  // end

  integer a, s, m, add_file, sub_file, mul_file;
  always @(posedge clk) begin
    add_file = $fopen("add_ops.txt", "w");
        for (a = 0; a < 240; a = a + 1) begin
            add_res[a] <= sum_res[a]; // Non-blocking assignment
            $fwrite(add_file, "%b\n", add_res[a]);
        end
    $fclose(add_file);

    sub_file = $fopen("sub_ops.txt", "w");
        for (s = 0; s < 240; s = s + 1) begin
            sub_res[s] <= diff_res[s]; // Non-blocking assignment
            $fwrite(sub_file, "%b\n", sub_res[s]);
        end
    $fclose(sub_file);

    mul_file = $fopen("mul_ops.txt", "w");
        for (m = 0; m < 240; m = m + 1) begin
            mul_res[m] <= multi_res[m]; // Non-blocking assignment
            $fwrite(mul_file, "%b\n", mul_res[m]);
        end
    $fclose(mul_file);
    end
endmodule