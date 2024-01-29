module testbench();

	logic [15:0] a, b, sum, diff;
	logic OF_S, OF_D, LessThan;

	// instantiate device under test
	top_module dut(a, b, sum, diff, OF_S, OF_D, LessThan);

	// apply inputs one at a time
	initial begin
		a = 16'b0111111111111111; b = 16'b1111111111111111; #100; // Test Case 1: +32,767 -1 +Sum OF_D
		a = 16'b1111111111101100; b = 16'b0000000000101000; #100; // Test Case 2: -20 +40 +Sum !OF_D
		a = 16'b0000101110111000; b = 16'b0000011111010000; #100; // Test Case 3: +3,000 +2000 !OF_S !LT
		a = 16'b1000001100000000; b = 16'b1000101011010000 ; #100; // Test Case 4: -32,000 -30,000 OF_S LT
		a = 16'b0000000100010110; b = 16'b1011101101011011; #100; // Test Case 5: +278 -17,573 !OF_D
		a = 16'b1000100110101011; b = 16'b0001011010000010; #100; // Test Case 6: -30,293 +5762 OF_D
		a = 16'b0001100010001000; b = 16'b0111110100000001; #100; // Test Case 7: +6,280 +32,001 OF_S -Diff
		a = 16'b1111111111000100; b = 16'b1111110011100000; #100; // Test Case 8: -60 -800 !OF_S +Diff
	end
endmodule