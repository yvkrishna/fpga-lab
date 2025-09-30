module prn_code_generator(
		input clk,
		input load_init
		
	);
	// Each register has size of 19 in octal = 19*3 = 57
	// Total of 55 registers for each r1, r2
	
	  /*reg r0_50 [0:55];
	  reg r0_45 [0:55];
	  reg r0_40 [0:55];
	  reg r0_20 [0:55];
	  reg r0_10 [0:55];
	  reg r0_5 [0:55];
	  reg r0_0 [0:55];
	  
	  reg r1_50 [0:55];
	  reg r1_45 [0:55];
	  reg r1_40 [0:55];
	  reg r1_20 [0:55];
	  reg r1_10 [0:55];
	  reg r1_5 [0:55];
	  reg r1_0 [0:55];
	  
	  reg c_0 [0:4];*/
	  
	reg [0:4] r0 [0:55];
	reg [0:4] r1 [0:55];
	reg [0:4] c [0:4];
		
	integer counter1, counter2;
	reg r0_fb [0:55];
	reg r1_fb [0:55];
	
	always@(posedge clk)	begin
		if(load_init == 1'b1)	begin
			// Load the registers with initial values
			/*r0_50 <= 56'o0762173527246302776;
			r0_45 <= 56'o1137431557133151004;
			r0_40 <= 56'o0224022145647544263;
			r0_20 <= 56'o1225124173720602330;
			r0_10 <= 56'o1632356715721616750;
			r0_5 <= 56'o1446113457553463523;
			r0_0 <= 56'o0061727026503255544;
			
			r1_50 <= 56'o1274167141162675644;
			r1_45 <= 56'o1222265021477405004;
			r1_40 <= 56'o0140216674314371011;
			r1_20 <= 56'o0337367500320303262;
			r1_10 <= 56'o0337367500320303262;
			r1_5 <= 56'o0337367500320303262;
			r1_0 <= 56'o0337367500320303262;			
			
			c_0 <= 5'b10100;*/
			
			R0[0] <= 56'o ;
			R0[1] <= 56'o ;
			R0[2] <= 56'o ;
			R0[3] <= 56'o ;
			R0[4] <= 56'o ;
			
			R1[0] <= 56'o ;
			R1[1] <= 56'o ;
			R1[2] <= 56'o ;
			R1[3] <= 56'o ;
			R1[4] <= 56'o ;
			
			c[0] <= 5'b ;
			c[2] <= 5'b ;
			c[3] <= 5'b ;
			c[3] <= 5'b ;
			c[4] <= 5'b ;
			
			counter1 <= 0;
			counter2 <= 0;
		end
		else	begin
			// Start generating
			
			if(counter1 < 5)begin
				if (counter2 < 10231)	begin
				
					chip = C[counter1][0] ^ R1[counter1][0];
				
					// Feedback for R0
					r0_fb <= R0[counter1][50] ^ R0[counter1][45] ^ R0[counter1][40] ^ R0[counter1][20] ^ R0[counter1][10] ^ R0[counter1][5] ^ R0[counter1][0];
					
					// σ2 feedback logic
					s2A <= (R0[counter1][50] ^ R0[counter1][45] ^ R0[counter1][40]) & (R0[counter1][20] ^ R0[counter1][10] ^ R0[counter1][5] ^ R0[counter1][0]);
					s2B <= ((R0[counter1][50] ^ R0[counter1][45]) & R0[counter1][40]) ^ ((R0[counter1][20] ^ R0[counter1][10]) & (R0[counter1][5] ^ R0[counter1][0]));
					s2C <= (R0[counter1][50] & R0[counter1][45]) ^ ((R0[counter1][20] & R0[counter1][10]) ^ (R0[counter1][5] & R0[counter1][0]));
					sigma2 <= s2A ^ s2B ^ s2C;
					
					// Feedback for R1
					R1A <= sigma2 ^ (R0[counter1][40] ^ R0[counter1][35] ^ R0[counter1][30] ^ R0[counter1][25] ^ R0[counter1][15] ^ R0[counter1][0]);
					R1B <= R1[counter1][50] ^ R1[counter1][45] ^ R1[counter1][40] ^ R1[counter1][20] ^ R1[counter1][10] ^ R1[counter1][5] ^ R1[counter1][0];
					r1_fb <= R1A ^ R1B;
					
					// Feedback for C
					c_fb <= c_0;
				end
				counter2 = counter + 1; 
			end
			
			
		end
	end
endmodule