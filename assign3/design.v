module division(
    input clk,
    input load,
    input signed [15:0] nr,
    input signed [15:0] dr,
    input signed [15:0] initial_guess,
    output reg signed [15:0] division_res
);
    integer i;
    reg signed [15:0] two_dxi_16, xi2_dxi_16, init_guess;
    reg signed [32:0] dxi, two_dxi, xi2_dxi, division;
    integer iteration_count;

    always @(posedge clk or posedge load) begin
        if (load == 1'b1) begin
            // $display($time, " Starting Newton-Raphson Iteration");
            init_guess <= initial_guess;  // Initialize guess when load is high
            iteration_count <= 0;
        end
        else if (iteration_count < 100) begin
            // $display($time, " Starting Processing");
            dxi = dr * init_guess;
            two_dxi = {13'd2, 20'd0} - dxi;
            // two_dxi_16 = {two_dxi[26:20], two_dxi[20:11]};
            two_dxi_16 = two_dxi >> 10;

            xi2_dxi = init_guess * two_dxi_16;
            // xi2_dxi_16 = {xi2_dxi[26:20], xi2_dxi[20:11]};
            xi2_dxi_16 = xi2_dxi >> 10;

            // $display($time, " i=%d, init_guess=%d, dxi=%d, two_dxi=%d, two_dxi_16=%d, xi2_dxi=%d, xi2_dxi_16=%d sub=%d", iteration_count, init_guess, dxi, two_dxi, two_dxi_16, xi2_dxi, xi2_dxi_16, {13'd2, 20'd0});
            init_guess = xi2_dxi_16;
            iteration_count = iteration_count + 1;
        end
        else begin
            division <= nr * init_guess;
            division_res <= division >> 10;
            // $display($time, " Completed Processing division_res=%d", division_res);
            // $display("init_guess = %d", init_guess);
        end
    end

endmodule