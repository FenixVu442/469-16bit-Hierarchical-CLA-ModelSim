module GPbit (
	input logic Ai, Bi,
	output logic [1:0] GPii
);
	
	assign GPii[0] = Ai & Bi;
	assign GPii[1] = Ai | Bi;
endmodule // GPii[0] = Gii, GPii[1] = Pii

module GPblk (
	input logic [1:0] GPik, GPkj,
	output logic [1:0] GPij
);
	assign GPij[0] = GPik[0] | (GPik[1] & GPkj[0]);
	assign GPij[1] = GPik[1] & GPkj[1];
endmodule

module CarryBit(
	input logic [1:0] GPij,
	input logic cj,
	output logic c_iPlusOne
);
	assign c_iPlusOne = GPij[0] | (GPij[1] & cj);
endmodule

module SUMbit (
	input logic Ai, Bi, Cin,
	output logic Si
);

	assign Si = Ai ^ Bi ^ Cin;
endmodule

module CLA16Bit (
	input logic [15:0] a, b,
	input logic C0,
	output logic [15:0] sum, 
	output logic OF //, 
);

	logic [15:0] [1:0] GPii;
	logic [1:0] gp10, gp32, gp54, gp76, gp98, gp1110, gp1312, gp1514;
	logic [1:0] gp30, gp74, gp118, gp1512;
	logic [1:0] gp70, gp158;
	logic [1:0] gp150;
	logic [16:0] ci; // 15 ci + carry out
	logic cout;

	// Instantiate GPbit modules using a loop
	genvar i;
	generate
  		for (i = 0; i < 16; i = i + 1) begin : gpbit_instances
    			GPbit gpbit_inst (
      				.Ai(a[i]),
      				.Bi(b[i]),
      				.GPii(GPii[i])
    			);
  		end
	endgenerate

	// Instantiate GPblk modules, 1st-level
	GPblk blk1_0 (GPii[1], GPii[0], gp10);
	GPblk blk3_2 (GPii[3], GPii[2], gp32);
	GPblk blk5_4 (GPii[5], GPii[4], gp54);
	GPblk blk7_6 (GPii[7], GPii[6], gp76);
	GPblk blk9_8 (GPii[9], GPii[8], gp98);
	GPblk blk11_10 (GPii[11], GPii[10], gp1110);
	GPblk blk13_12 (GPii[13], GPii[12], gp1312);
	GPblk blk15_14 (GPii[15], GPii[14], gp1514);

	// Instantiate GPblk modules, 2nd-level
	GPblk blk3_0 (gp32, gp10, gp30);
	GPblk blk7_4 (gp76, gp54, gp74);
	GPblk blk11_8 (gp1110, gp98, gp118);
	GPblk blk15_12 (gp1514, gp1312, gp1512);

	// Instantiate GPblk modules, 3rd-level
	GPblk blk7_0 (gp74, gp30, gp70);
	GPblk blk15_8 (gp1512, gp118, gp158);

	// Instantiate GPblk module, 4th-level
	GPblk blk15_0 (gp158, gp70, gp150);

// Begin: CarryBit generate and find Sum

	// Instantiate CarryBit 1st-level
	assign ci[0] = C0;
	CarryBit cout1 (GPii[0], ci[0], ci[1]);
	CarryBit cout2 (gp10, ci[0], ci[2]);
	CarryBit cout4 (gp30, ci[0], ci[4]);
	CarryBit cout8 (gp70, ci[0], ci[8]);
	CarryBit cout16 (gp150, ci[0], ci[16]);

	// Instantiate CarryBit 2nd-level
	CarryBit cout3 (GPii[2], ci[2], ci[3]);
	CarryBit cout5 (GPii[4], ci[4], ci[5]);
	CarryBit cout6 (gp54, ci[4], ci[6]);
	CarryBit cout9 (GPii[8], ci[8], ci[9]);
	CarryBit cout10 (gp98, ci[8], ci[10]);
	CarryBit cout12 (gp118, ci[8], ci[12]);

	// Instantiate CarryBit 3rd-level
	CarryBit cout7 (GPii[6], ci[6], ci[7]);
	CarryBit cout11 (GPii[10], ci[10], ci[11]);
	CarryBit cout13 (GPii[12], ci[12], ci[13]);
	CarryBit cout14 (gp1312, ci[12], ci[14]);

	// Instantiate CarryBit 4th-level
	CarryBit cout15 (GPii[14], ci[14], ci[15]);

	// Instantiate SUMbit modules using a loop
	genvar k;
	generate
  		for (k = 0; k < 16; k = k + 1) begin : sumbit_instances
   			SUMbit sb_inst (
      				.Ai(a[k]),
      				.Bi(b[k]),
      				.Cin(ci[k]),
      				.Si(sum[k])
    			);
  		end
	endgenerate

	// Determine OF
	assign OF = ci[16] ^ ci[15];
	
endmodule

module top_module (
	input logic [15:0] a, b,
	output logic [15:0] sum, diff,
	output logic OF_S, OF_D, LessThan
);
	logic [15:0] not_b;

	assign not_b = ~b;

	CLA16Bit adder(a, b, 1'b0, sum, OF_S);
	CLA16Bit subtr(a, not_b, 1'b1, diff, OF_D);

	assign LessThan = diff[15] ^ OF_D;
endmodule
