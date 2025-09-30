module convolve#(parameter LEN = 19, SIGNAL_LENGTH_1=2400)(
    input clk,
    input load,
    input signed [(LEN+1)*16:0] flaten_filter_coeff,
    input signed [(SIGNAL_LENGTH_1+1)*16:0] flaten_signal,
    output reg signed [(LEN+SIGNAL_LENGTH_1+2-1)*16:0] flatten_conv_result,
    output reg is_completed
);

    reg signed [15:0] filter_coeff [LEN:0], signal [SIGNAL_LENGTH_1:0];
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
                // $display("count=%d    result[i]=%d",count, result[count]>>14);


                count <= count + 1;
            end
            else if(count < TOTAL_LENGTH) begin


                for(j=count-LEN; j<=count; j=j+1)    begin
                    if(SIGNAL_LENGTH_1 - j >= 0)  begin
                        result[count] = result[count] + (filter_coeff[count-j]*signal[j]);
                    end
                    // $display(" count=%d  j=%d  result[i]=%d",count, j, result[count]>>14);
                end
                // $display("count = %d    res[i]=%d", count, result[count]>>14);


                count <= count + 1;
            end
            else    begin
                completed_flag=1'b1;
                process_flag=1'b0;
                $display($time," Convolution Completed !!!");
            end
        end
        else if(completed_flag==1'b1)   begin
            // $display($time," Post-Processing Started !!!");
            // $display("flatten_conv_result bit width = %d", $bits(flatten_conv_result));

            for (i = 0; i <LEN+SIGNAL_LENGTH_1+2-1 ; i=i+1) begin
                flatten_conv_result[i*16 +: 16] = result[i]>>14;
                // $display("i=%d, res[i]=%d", i, result[i]>>14);
                // $display($time, " i=%d, res[i]=%b", i, flatten_conv_result[i*16 +: 16]);
            end
            //  $display($time," Post-Processing Completed !!!");
             is_completed = 1'b1;
        end

    end
endmodule


module convolve_pipelined #(
    parameter LEN = 19, 
    parameter SIGNAL_LENGTH_1 = 2400
)(
    input clk,
    input load,
    input signed [(LEN+1)*16:0] flaten_filter_coeff,
    input signed [(SIGNAL_LENGTH_1+1)*16:0] flaten_signal,
    output reg signed [(LEN+SIGNAL_LENGTH_1+2-1)*16:0] flatten_conv_result,
    output reg is_completed
);

    reg signed [15:0] filter_coeff [0:LEN];  
    reg signed [15:0] signal [0:SIGNAL_LENGTH_1];  
    reg signed [31:0] mult_result [0:LEN+SIGNAL_LENGTH_1+2-1];  
    reg signed [31:0] result [0:LEN+SIGNAL_LENGTH_1+2-1];  
    
    integer i, j;
    reg [11:0] count;
    reg load_flag, process_flag, completed_flag;

    always @(posedge clk) begin
        $display($time, " Multiplication happening at count=%d", count);
    end

    always @(posedge clk) begin
        $display($time, " Addition happening at count=%d", count);
    end

    always @(posedge clk) begin
        if (load) begin
            count = 0;
            is_completed = 0;
            load_flag = 1;
            process_flag = 0;
            completed_flag = 0;
            
            for (i = 0; i <= LEN; i = i + 1) begin
                filter_coeff[i] = flaten_filter_coeff[i*16 +: 16];
            end
            
            for (i = 0; i <= SIGNAL_LENGTH_1; i = i + 1) begin
                signal[i] = flaten_signal[i*16 +: 16];
            end
            
            for (i = 0; i < LEN+SIGNAL_LENGTH_1+2-1; i = i + 1) begin
                result[i] = 0;
                mult_result[i] = 0;
            end
            
            process_flag = 1;
            load_flag = 0;
            $display($time," Convolution Started !!!");
        end 
        else if (process_flag) begin
            if (count < SIGNAL_LENGTH_1 + LEN + 2 - 1) begin
                // Pipeline Stage 1: Compute multiplications
                for (j = 0; j <= LEN; j = j + 1) begin
                    if (count >= j && count - j <= SIGNAL_LENGTH_1) begin
                        mult_result[count] = filter_coeff[j] * signal[count - j];
                    end
                end

                // Pipeline Stage 2: Accumulate results
                if (count > 0) begin
                    result[count] = result[count - 1] + mult_result[count];
                end
                else begin
                    result[count] = mult_result[count];
                end
                
                count = count + 1;
            
                // $display($time, " count=%d, result=%d", count, result[count]);
            end
            else begin
                process_flag = 0;
                completed_flag = 1;
                $display($time," Convolution Completed !!!");
            end
        end 
        else if (completed_flag) begin
            for (i = 0; i < LEN+SIGNAL_LENGTH_1+2-1; i = i + 1) begin
                flatten_conv_result[i*16 +: 16] = result[i] >> 14;
            end
            is_completed = 1;
            completed_flag = 0;
        end
    end
endmodule

// module convolve_pipelined #(
//     parameter LEN = 2, 
//     parameter SIGNAL_LENGTH_1 = 4
// )(
//     input clk,
//     input load,
//     input signed [(LEN+1)*16:0] flaten_filter_coeff,
//     input signed [(SIGNAL_LENGTH_1+1)*16:0] flaten_signal,
//     output reg signed [(LEN+SIGNAL_LENGTH_1+2-1)*16:0] flatten_conv_result,
//     output reg is_completed
// );

//     reg signed [15:0] filter_coeff [0:LEN];  
//     reg signed [15:0] signal [0:SIGNAL_LENGTH_1];  
//     reg signed [31:0] mult_add_result [0:LEN];  
//     reg signed [31:0] result [0:LEN+SIGNAL_LENGTH_1+2-1];  
//     reg signed [15:0] shift_reg [0:LEN];
    
//     integer i, j;
//     reg [11:0] count;
//     reg load_flag, process_flag, completed_flag;

//     always @(posedge clk) begin
//         if (load) begin
//             count = 0;
//             is_completed = 0;
//             load_flag = 1;
//             process_flag = 0;
//             completed_flag = 0;
            
//             for (i = 0; i <= LEN; i = i + 1) begin
//                 filter_coeff[i] = flaten_filter_coeff[i*16 +: 16];
//                 shift_reg[i] = 16'b0;
//                 mult_add_result[i] = 16'b0;
//                 // $display($time," filter[%d]=%d", i, filter_coeff[i]);
//             end
            
//             for (i = 0; i <= SIGNAL_LENGTH_1; i = i + 1) begin
//                 signal[i] = flaten_signal[i*16 +: 16];
//                 // $display($time," signal[%d]=%d", i, signal[i]);
//             end
            
//             for (i = 0; i < LEN+SIGNAL_LENGTH_1+2-1; i = i + 1) begin
//                 result[i] = 0;
//             end
            
//             process_flag = 1;
//             load_flag = 0;
//             $display($time," Convolution Started !!!");
//         end
//         else if (process_flag) begin
            
//             if (count < SIGNAL_LENGTH_1 + LEN + 2 - 1) begin

//                 for (j = LEN; j > 0; j = j - 1) begin
//                     shift_reg[j] = shift_reg[j-1];
//                     // $display($time," count=%d shift_reg[%d]=%d", count, j, shift_reg[j]);
//                 end
//                 shift_reg[0] = signal[j];
//                 // $display($time," count=%d shift_reg[%d]=%d", count, j, shift_reg[j]);

//                 if(count == 0)
//                     mult_add_result[0] <= signal[0] * filter_coeff[0];
//                 else    begin

//                     for(j=1;j<LEN;j=j+1)    begin
//                         mult_add_result[j] = mult_add_result[j-1] + (shift_reg[j]*filter_coeff[j]);
//                         $display($time," count=%d j=%d mul_add_res=%d",count, j, mult_add_result[j]>>14);
//                     end
//                 end
//                 count <= count+1;

//             end
//         end
//         else if (completed_flag) begin
//             $display($time," Convolution Completed !!!");
//             for (i = 0; i < LEN+SIGNAL_LENGTH_1+2-1; i = i + 1) begin
//                 flatten_conv_result[i*16 +: 16] = mult_add_result[LEN] >> 14;
//             end
//             is_completed = 1;
//             completed_flag = 0;
//         end
//     end
// endmodule