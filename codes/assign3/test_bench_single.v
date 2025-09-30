module testBench;

    reg signed [15:0] nr, dr, res, initial_guess;
    wire signed [15:0] division_res;
    reg clk;
    reg load;

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        load = 1'b1;
        clk = 1'b0;
        nr = 16'b0011110000000000;             // 15 in Q(6, 10). So max int bit can be 32 1 signed and 5 bits for int
        dr = 16'b0101110000000000;             // 23 in Q(6, 10).
        initial_guess = 16'b0000000001010010;      // 0.08 in Q(6, 10).   0.08*pow(2, 10) = 81.92 = 82 is converted to bin
        $display("nr = %d = %h = %b\ndr = %d = %h = %b\ninitial_guess = %d = %h = %b", nr, nr, nr, dr, dr, dr, initial_guess, initial_guess, initial_guess);
        $monitor($time, " division_res = %d = %h = %b", division_res, division_res, division_res);
        #50 load = 1'b0;

        #1500 load = 1'b1;
        #1500 clk = 1'b0;
        #1500 nr = 16'b0001110000000000;             // 7 in Q(6, 10). So max int bit can be 32 1 signed and 5 bits for int
        #1500 dr = 16'b0011010000000000;             // 13 in Q(6, 10).
        #1500 initial_guess = 16'b0000000000110011;  // 0.05 in Q(6, 10).   0.05*pow(2, 10) = 51.2 = 51 is converted to bin
        #1550 load = 1'b0;

        #2500 $finish;
    end

    division DIV(clk, load, nr, dr, initial_guess, division_res);

    always @(posedge clk) begin
        res <= division_res;
    end
endmodule