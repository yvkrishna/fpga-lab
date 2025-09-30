module test_bench;

    parameter LEN = 19, SIGNAL_LENGTH_1=120; 
    reg [15:0] filter_coeff_mat [LEN:0];
    reg [15:0] test_inp [SIGNAL_LENGTH_1:0];
    reg clk;
    reg load;
    integer i;
    reg load_mem;
    wire is_completed;
    always #10 clk = ~clk;

    reg signed [(LEN+1)*16:0] flaten_filter_coeff;
    reg signed [(SIGNAL_LENGTH_1+1)*16:0] flaten_signal;
    wire signed [(LEN+SIGNAL_LENGTH_1+2-1)*16:0] flatten_conv_result;
    reg [15:0] conv_res [(LEN+SIGNAL_LENGTH_1+2-1):0];

    initial begin
        clk = 1'b0;
        #10 load = 1'b1;
        load_mem=1'b0;

        // Reading values from files
        $readmemb("filter_coeff_bin.txt", filter_coeff_mat, 0, LEN);
        $readmemb("input.txt", test_inp, 0, SIGNAL_LENGTH_1);
        // $display("flaten_filter_coeff width = %d", $bits(flaten_filter_coeff));

        for (i = 0; i <= LEN; i = i + 1) begin
            flaten_filter_coeff[i*16 +: 16] = filter_coeff_mat[i];
            // $display("i=%d, flaten_filter_coeff[i*16 +: 16]=%b    filter_coeff_mat[i]=%b",i, flaten_filter_coeff[i*16 +: 16], filter_coeff_mat[i]);
        end
        for (i = 0; i <= SIGNAL_LENGTH_1; i = i + 1) begin
            flaten_signal[i*16 +: 16] = test_inp[i];
            // $display("i=%d, flaten_signal[i*16 +: 16]=%b    sin_wave_1[i]=%b",i, flaten_signal[i*16 +: 16], sin_wave_1[i]);
        end
        #30 load = 1'b0;
        #48480 $finish;
    end

    convolve C(clk, load, flaten_filter_coeff, flaten_signal, flatten_conv_result, is_completed);
    // convolve_pipelined C(clk, load, flaten_filter_coeff, flaten_signal, flatten_conv_result, is_completed);


    integer c, conv_file;
    always @(posedge clk) begin
        if(load_mem==1'b1)  begin
            conv_file = $fopen("conv_res.txt", "w");
            for (c = 0; c < LEN+SIGNAL_LENGTH_1+2-1; c = c + 1) begin
                // $display("conv_res[i]=%b", conv_res[c]);
                $fwrite(conv_file, "%b\n", conv_res[c]);
            end
            $fclose(conv_file);
            // $display($time, " Comvolution result copied to conv_res.txt file");
        end
        else if(is_completed == 1'b1)   begin
            for (c = 0; c < LEN+SIGNAL_LENGTH_1+2-1; c = c + 1) begin
                conv_res[c] <= flatten_conv_result[c*16 +: 16];
                // $display("conv_res[i]=%b", flatten_conv_result[c*16 +: 16]);
            end
            load_mem = 1'b1;
        end
        // else
            // $display($time, " waiting for convolution result");
    end
endmodule