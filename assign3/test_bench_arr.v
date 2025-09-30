module testBench;

    reg signed [15:0] nr [8:0], dr [8:0], initial_guess [8:0], div_res [8:0];
    wire signed [15:0] division_res [8:0];
    reg clk;
    reg load;

    // Clock generation
    always #5 clk = ~clk;
    initial begin
        $readmemb("nr.txt", nr, 0, 8);
        $readmemb("dr.txt", dr, 0, 8);
        $readmemb("initial_guess.txt", initial_guess, 0, 8);
        
        clk = 1'b0;
        load = 1'b1;
        #10 load = 1'b0;

        #2000 load = 1'b1;
        #2010 load = 1'b0;

        #4000 load = 1'b1;
        #4010 load = 1'b0;

        #6000 load = 1'b1;
        #6050 load = 1'b0;

        #8000 load = 1'b1;
        #8050 load = 1'b0;

        #9000 load = 1'b1;
        #9050 load = 1'b0;

        #10000 load = 1'b1;
        #10050 load = 1'b0;

        #12000 load = 1'b1;
        #12050 load = 1'b0;

        #14000 load = 1'b1;
        #14050 load = 1'b0;

        #16000 load = 1'b1;
        #16050 load = 1'b0;

        // $monitor("nr = %d = %h = %b\ndr = %d = %h = %b\ninitial_guess = %d = %h = %b", nr, nr, nr, dr, dr, dr, initial_guess, initial_guess, initial_guess);
        // $monitor("division_res = %d = %h = %b", division_res, division_res, division_res);
        $display("==========================================================");
        // $monitor("nr[0] = %d    dr[0]=%d   division_res[0] = %d", nr[0], dr[0], division_res[0]);
        #15500 $finish;
    end

    generate
        genvar i;
        for(i=0;i<9;i=i+1) begin : DIV
            division DIV(clk, load, nr[i], dr[i], initial_guess[i], division_res[i]);
            initial begin
                #10; //wait for loading everything
                $display($time, " nr[%0d] = %d     dr[%0d]=%d     initial_guess[%0d]=%d", i, nr[i], i, dr[i], i, initial_guess[i]);
                $monitor($time, " division_res[%0d] = %d", i, division_res[i]);
            end
          end
    endgenerate

    integer d, div_file;
    always @(posedge clk) begin
        div_file = $fopen("div_res.txt", "w");
        for (d = 0; d < 9; d = d + 1) begin
            div_res[d] <= division_res[d]; // Non-blocking assignment
            $fwrite(div_file, "%b\n", div_res[d]);
        end
        $fclose(div_file);
    end
endmodule