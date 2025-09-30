module convolve#(parameter LEN = 19, SIGNAL_LENGTH_1=2400)(
    input clk,
    input load,
    input signed [(LEN+1)*16:0] flaten_filter_coeff,
    input signed [(SIGNAL_LENGTH_1+1)*16:0] flaten_signal,
    output reg signed [(LEN+SIGNAL_LENGTH_1+2-1)*16:0] flatten_conv_result,
    output reg is_completed
);

    reg [15:0] filter_coeff [LEN:0], signal [SIGNAL_LENGTH_1:0];
    integer i, count, j;
    reg load_flag, process_flag, completed_flag;

    reg signed [32:0] result [LEN+SIGNAL_LENGTH_1+2-1:0] ;
    parameter TOTAL_LENGTH = SIGNAL_LENGTH_1+LEN+2-1;

    always@(posedge clk) begin
        load_flag = load;
        if(load == 1'b1)    begin
            // $display($time," Pre-Processing Started !!!");
            count=1'b0;
            for (i = 0; i <= LEN; i = i + 1) begin
                filter_coeff[i] = flaten_filter_coeff[i*16 +: 16];
                // $display("i=%d, filter[i]=%b",i, filter_coeff[i]);
            end
            for (i = 0; i <= SIGNAL_LENGTH_1; i = i + 1) begin
                signal[i] = flaten_signal[i*16 +: 16];
                // $display("i=%d, signal[i]=%b",i, signal[i]);
            end
            for (i = 0; i <LEN+SIGNAL_LENGTH_1+2-1; i = i + 1) begin
                result[i] = 32'b0;
                // $display("i=%d, result[i]=%b",i, result[i]);
            end
            process_flag=1'b1;
            load_flag=1'b0;
            completed_flag=1'b0;
            // $display($time," Pre-Processing Completed !!!");
        end
        else if(process_flag==1'b1) begin
            // $display($time, " In process count=%d, completed_flag=%b", count, completed_flag);
            if(count<LEN+1)    begin
                if(count==0)
                    $display($time," Convolution Started !!!");


                for(j=0; j<=count; j=j+1)    begin
                    result[count] = result[count] + (filter_coeff[count-j]*signal[j]);
                    // $display(" count=%d   j=%d result[i]=%d",count, j, result[count]>>14);
                end
                $display("count=%d    result[i]=%b",count, result[count]>>14);


                count <= count + 1;
            end
            else if(count < TOTAL_LENGTH) begin


                for(j=count-LEN; j<=count; j=j+1)    begin
                    if(SIGNAL_LENGTH_1 - j >= 0)  begin
                        result[count] = result[count] + (filter_coeff[count-j]*signal[j]);
                    end
                    // $display(" count=%d  j=%d  result[i]=%d",count, j, result[count]>>14);
                end
                // $display("count = %d    res[i]=%b", count, result[count]>>14);


                count <= count + 1;
            end
            else    begin
                completed_flag=1'b1;
                process_flag=1'b0;
                // $display($time," Convolution Completed !!!");
            end
        end
        else if(completed_flag==1'b1)   begin
            // $display($time," Post-Processing Started !!!");
            // $display("flatten_conv_result bit width = %d", $bits(flatten_conv_result));

            for (i = 0; i <LEN+SIGNAL_LENGTH_1+2-1 ; i=i+1) begin
                flatten_conv_result[i*16 +: 16] = result[i]>>14;
                // $display("i=%d, res[i]=%d", i, result[i]>>14);
                // $display("i=%d, res[i]=%b", i, flatten_conv_result[i*16 +: 16]);
            end
            //  $display($time," Post-Processing Completed !!!");
             is_completed = 1'b1;
        end

    end
endmodule