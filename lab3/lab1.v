`define CYCLE_TIME 20
`define INSTRUCTION_NUMBERS 10000
`timescale 1ns/1ps
`include "CPU.v"

module testbench;
reg Clk, Rst;
reg [31:0] cycles, i;

// Instruction DM initialilation
initial
begin
	/*=================================================     連加     =================================================*/
		//$0 = 0, $1 = 1, $2 = 2, $3 = 3, $4 = 5, $5 = input, ($6,$7) = limit, $8 = TF, ($9,$10) = approx, ($25,$26) = ans
		cpu.IF.instruction[ 0] = 32'b100011_00000_00101_00000_00000_000000;	// lw $5, 0($0)
		cpu.IF.instruction[ 1] = 32'b000000_00000_00011_00110_00000_100000;	// add $6, $0, $3   
		cpu.IF.instruction[ 2] = 32'b000000_00000_00011_00111_00000_100000;	// add $7, $0, $3        
		cpu.IF.instruction[ 3] = 32'b101011_00000_00010_00000_00000_000001;	// sw $2, 1($0)		tmp answer: 2 
		cpu.IF.instruction[ 4] = 32'b000000_00101_00001_01001_00000_100100;	// and $9, $5, $1   even or odd	  pc: 10
		cpu.IF.instruction[ 5] = 32'b000101_00101_00011_00000_00000_000111;	// bne $5, $3, 7	special case: 3	(loop) 
		/*	Input == 3	*/
		cpu.IF.instruction[ 6] = 32'b101011_00000_00100_00000_00000_000010;	// sw $4, 2($0)		tmp answer: 5
		cpu.IF.instruction[ 7] = 32'b000000_00000_00000_00000_00000_100000;	// NOP 
		cpu.IF.instruction[ 8] = 32'b000000_00001_01001_01001_00000_100010;	// sub $9, $1, $9                     20
		cpu.IF.instruction[ 9] = 32'b000010_00000_00000_00000_00001_111011; // j  exit (123)                 
		cpu.IF.instruction[10] = 32'b000000_00000_00000_00000_00000_100000;	// NOP                          
		cpu.IF.instruction[11] = 32'b000000_00000_00000_00000_00000_100000; // NOP                           
		cpu.IF.instruction[12] = 32'b000000_00000_00000_00000_00000_100000; // NOP                                30
		/*	loop (calculate n^-2)	*/
		cpu.IF.instruction[13] = 32'b000000_00110_00101_01000_00000_101010;	// slt $8, $6, $5
		cpu.IF.instruction[14] = 32'b000000_00000_00000_00000_00000_100000;	// NOP		                        
		cpu.IF.instruction[15] = 32'b000000_00000_00000_00000_00000_100000;	// NOP                          
		cpu.IF.instruction[16] = 32'b000000_00110_00111_00110_00000_100000; // add $6, $6, $7   				  40          
		cpu.IF.instruction[17] = 32'b000100_01000_00000_00000_00000_001000; // beq $8, $0, 8                
		cpu.IF.instruction[18] = 32'b000000_00000_00000_00000_00000_100000; // NOP                         
		cpu.IF.instruction[19] = 32'b000000_00000_00000_00000_00000_100000; // NOP                       
		cpu.IF.instruction[20] = 32'b000000_00110_00111_00110_00000_100000; // add $6, $6, $7                     50
		cpu.IF.instruction[21] = 32'b000000_00111_00001_00111_00000_100000; // add $7, $7, $1               
		cpu.IF.instruction[22] = 32'b000010_00000_00000_00000_00000_001101; // j 13	(loop)                   
		cpu.IF.instruction[23] = 32'b000000_00000_00000_00000_00000_100000; // NOP                          
		cpu.IF.instruction[24] = 32'b000000_00000_00000_00000_00000_100000; // NOP                                60                     
		cpu.IF.instruction[25] = 32'b000000_00000_00000_00000_00000_100000; // NOP                           
		/*	A($25) < x, B($26) > x	*/
		cpu.IF.instruction[26] = 32'b000000_00101_01001_11001_00000_100000; // add $25, $5, $9  X<A                         
		cpu.IF.instruction[27] = 32'b000000_00101_01001_11010_00000_100010; // sub $26, $5, $9  X>A
		cpu.IF.instruction[28] = 32'b000000_00000_00000_00000_00000_100000; // NOP                                70                           
		/*	cmpA	*/
		cpu.IF.instruction[29] = 32'b000000_00000_00011_01001_00000_100000; // add $9, $0, $3
		cpu.IF.instruction[30] = 32'b000000_11001_00010_11001_00000_100010; // sub $25, $25, $2
		cpu.IF.instruction[31] = 32'b000000_00000_00000_00000_00000_100000; // NOP
		cpu.IF.instruction[32] = 32'b000000_00000_00000_00000_00000_100000; // NOP                                80
		/*	cmpA1	*/
		cpu.IF.instruction[33] = 32'b000000_01001_00111_01000_00000_101010; // slt $8, $9, $7   			      84
		cpu.IF.instruction[34] = 32'b000000_00000_00000_00000_00000_100000; // NOP
		cpu.IF.instruction[35] = 32'b000000_00000_00000_00000_00000_100000; // NOP                                
		cpu.IF.instruction[36] = 32'b000000_00000_00000_00000_00000_100000; // NOP                                90
		cpu.IF.instruction[37] = 32'b000100_01000_00000_00000_00000_100101; // beq $8, $0, 37	(ansA)
		cpu.IF.instruction[38] = 32'b000000_01001_01001_00110_00000_100000; // add $6, $9, $9
		cpu.IF.instruction[39] = 32'b000000_11001_00000_01010_00000_100000; // add $10, $25, $0
		cpu.IF.instruction[40] = 32'b000000_00000_00000_00000_00000_100000; // NOP                                A0
 		cpu.IF.instruction[41] = 32'b000000_00000_00000_00000_00000_100000; // NOP                                
		cpu.IF.instruction[42] = 32'b000000_00110_00110_00110_00000_100000; // add $6, $6, $6
		cpu.IF.instruction[43] = 32'b000000_00000_00000_00000_00000_100000; // NOP
 		cpu.IF.instruction[44] = 32'b000000_00000_00000_00000_00000_100000; // NOP                                B0
		cpu.IF.instruction[45] = 32'b000000_00000_00000_00000_00000_100000; // NOP
		/*	cmpA2	*/
		cpu.IF.instruction[46] = 32'b000000_01010_00110_01010_00000_100010; // sub $10, $10, $6
		cpu.IF.instruction[47] = 32'b000000_00000_00000_00000_00000_100000; // NOP
		cpu.IF.instruction[48] = 32'b000000_00000_00000_00000_00000_100000; // NOP                                C0
		cpu.IF.instruction[49] = 32'b000000_00000_00000_00000_00000_100000; // NOP
		cpu.IF.instruction[50] = 32'b000000_01001_01010_01000_00000_101010; // slt $8, $9, $10
		cpu.IF.instruction[51] = 32'b000000_00000_00000_00000_00000_100000; // NOP
		cpu.IF.instruction[52] = 32'b000000_00000_00000_00000_00000_100000; // NOP                                D0
		cpu.IF.instruction[53] = 32'b000000_00000_00000_00000_00000_100000; // NOP
		cpu.IF.instruction[54] = 32'b000101_01000_00000_11111_11111_110111; // bne $8, $0, -9	(cmp2)
		cpu.IF.instruction[55] = 32'b000000_00000_00000_00000_00000_100000; // NOP
		cpu.IF.instruction[56] = 32'b000000_00000_00000_00000_00000_100000; // NOP                                E0
		cpu.IF.instruction[57] = 32'b000000_00000_00000_00000_00000_100000; // NOP
		cpu.IF.instruction[58] = 32'b000100_01010_01001_11111_11111_100010; // beq $10, $9, -30	(cmp)
		cpu.IF.instruction[59] = 32'b000000_01001_01010_01010_00000_100000; // add $10, $10, $9
		cpu.IF.instruction[60] = 32'b000000_00000_00000_00000_00000_100000; // NOP                                F0
		cpu.IF.instruction[61] = 32'b000000_00000_00000_00000_00000_100000; // NOP                                
		cpu.IF.instruction[62] = 32'b000000_00000_00000_00000_00000_100000; // NOP
		cpu.IF.instruction[63] = 32'b000100_01010_00000_11111_11111_011101; // beq $10, $0, -35	(cmp)
		cpu.IF.instruction[64] = 32'b000000_00000_00000_00000_00000_100000; // NOP                                100
		cpu.IF.instruction[65] = 32'b000000_00000_00000_00000_00000_100000; // NOP                            
		cpu.IF.instruction[66] = 32'b000000_00000_00000_00000_00000_100000; // NOP
		cpu.IF.instruction[67] = 32'b000000_01001_00010_01001_00000_100000; // add $9, $9, $2
		cpu.IF.instruction[68] = 32'b000000_00000_00000_00000_00000_100000; // NOP                                110
		cpu.IF.instruction[69] = 32'b000000_00000_00000_00000_00000_100000; // NOP                                
		cpu.IF.instruction[70] = 32'b000000_00000_00000_00000_00000_100000; // NOP
		cpu.IF.instruction[71] = 32'b000010_00000_00000_00000_00000_100001; // j 33	(comp1)
		cpu.IF.instruction[72] = 32'b000000_00000_00000_00000_00000_100000; // NOP                                120
		cpu.IF.instruction[73] = 32'b000000_00000_00000_00000_00000_100000; // NOP                                
		cpu.IF.instruction[74] = 32'b000000_00000_00000_00000_00000_100000; // NOP
		/*	ansA	*/
		cpu.IF.instruction[75] = 32'b101011_00000_11001_00000_00000_000001; // sw $25, 1($0)
		/*	compB	*/
		cpu.IF.instruction[76] = 32'b000000_00000_00011_01001_00000_100000; // add $9, $0, $3                     130
		cpu.IF.instruction[77] = 32'b000000_11010_00010_11010_00000_100000; // add $26, $26, $2
		cpu.IF.instruction[78] = 32'b000000_00000_00000_00000_00000_100000; // NOP
		cpu.IF.instruction[79] = 32'b000000_00000_00000_00000_00000_100000; // NOP                 
		/*	comp1B	*/               
		cpu.IF.instruction[80] = 32'b000000_01001_00111_01000_00000_101010; // slt $8, $9, $7          			  140
		cpu.IF.instruction[81] = 32'b000000_00000_00000_00000_00000_100000; // NOP
		cpu.IF.instruction[82] = 32'b000000_00000_00000_00000_00000_100000; // NOP                                
		cpu.IF.instruction[83] = 32'b000000_00000_00000_00000_00000_100000; // NOP                                
		cpu.IF.instruction[84] = 32'b000100_01000_00000_00000_00000_100101; // beq $8, $0, 37   (ansB)            150
		cpu.IF.instruction[85] = 32'b000000_01001_01001_00110_00000_100000; // add $6, $9, $9
		cpu.IF.instruction[86] = 32'b000000_11010_00000_01010_00000_100000; // add $10, $26, $0
		cpu.IF.instruction[87] = 32'b000000_00000_00000_00000_00000_100000; // NOP                                160
 		cpu.IF.instruction[88] = 32'b000000_00000_00000_00000_00000_100000; // NOP                                
		cpu.IF.instruction[89] = 32'b000000_00110_00110_00110_00000_100000; // add $6, $6, $6 
		cpu.IF.instruction[90] = 32'b000000_00000_00000_00000_00000_100000; // NOP
 		cpu.IF.instruction[91] = 32'b000000_00000_00000_00000_00000_100000; // NOP                                
		cpu.IF.instruction[92] = 32'b000000_00000_00000_00000_00000_100000; // NOP
		/*	comp2B	*/
		cpu.IF.instruction[93] = 32'b000000_01010_00110_01010_00000_100010; // sub $10, $10, $6
		cpu.IF.instruction[94] = 32'b000000_00000_00000_00000_00000_100000; // NOP
		cpu.IF.instruction[95] = 32'b000000_00000_00000_00000_00000_100000; // NOP                                
		cpu.IF.instruction[96] = 32'b000000_00000_00000_00000_00000_100000; // NOP
		cpu.IF.instruction[97] = 32'b000000_01001_01010_01000_00000_101010; // slt $8, $9, $10
		cpu.IF.instruction[98] = 32'b000000_00000_00000_00000_00000_100000; // NOP
		cpu.IF.instruction[99] = 32'b000000_00000_00000_00000_00000_100000; // NOP                                
		cpu.IF.instruction[100] = 32'b000000_00000_00000_00000_00000_100000; // NOP
		cpu.IF.instruction[101] = 32'b000101_01000_00000_11111_11111_110111; // bne $8, $0, -9	(comp2B)
		cpu.IF.instruction[102] = 32'b000000_00000_00000_00000_00000_100000; // NOP
		cpu.IF.instruction[103] = 32'b000000_00000_00000_00000_00000_100000; // NOP                                
		cpu.IF.instruction[104] = 32'b000000_00000_00000_00000_00000_100000; // NOP
		cpu.IF.instruction[105] = 32'b000100_01010_01001_11111_11111_100010; // beq $10, $9, -30	(compB)
		cpu.IF.instruction[106] = 32'b000000_01010_01001_01010_00000_100000; // add $10, $10, $9
		cpu.IF.instruction[107] = 32'b000000_00000_00000_00000_00000_100000; // NOP                                
		cpu.IF.instruction[108] = 32'b000000_00000_00000_00000_00000_100000; // NOP                                
		cpu.IF.instruction[109] = 32'b000000_00000_00000_00000_00000_100000; // NOP
		cpu.IF.instruction[110] = 32'b000100_01010_00000_11111_11111_011101; // beq $10, $0, -35 (compB)
		cpu.IF.instruction[111] = 32'b000000_00000_00000_00000_00000_100000; // NOP                                
		cpu.IF.instruction[112] = 32'b000000_00000_00000_00000_00000_100000; // NOP                            
		cpu.IF.instruction[113] = 32'b000000_00000_00000_00000_00000_100000; // NOP
		cpu.IF.instruction[114] = 32'b000000_01001_00010_01001_00000_100000; // add $9, $9, $2
		cpu.IF.instruction[115] = 32'b000000_00000_00000_00000_00000_100000; // NOP                                
		cpu.IF.instruction[116] = 32'b000000_00000_00000_00000_00000_100000; // NOP                                
		cpu.IF.instruction[117] = 32'b000000_00000_00000_00000_00000_100000; // NOP
		cpu.IF.instruction[118] = 32'b000010_00000_00000_00000_00001_010000; // j 80	(comp1B)
		cpu.IF.instruction[119] = 32'b000000_00000_00000_00000_00000_100000; // NOP                                
		cpu.IF.instruction[120] = 32'b000000_00000_00000_00000_00000_100000; // NOP                                
		cpu.IF.instruction[121] = 32'b000000_00000_00000_00000_00000_100000; // NOP
		/*	ansB	*/
		cpu.IF.instruction[122] = 32'b101011_00000_11010_00000_00000_000010; // sw $26, 2($0)
		cpu.IF.instruction[123] = 32'b000000_00000_00000_00000_00000_100000; // NOP                                
		cpu.IF.instruction[124] = 32'b000000_00000_00000_00000_00000_100000; // NOP                                
		cpu.IF.instruction[125] = 32'b000000_00000_00000_00000_00000_100000; // NOP

		for (i=126; i<128; i=i+1)  cpu.IF.instruction[ i] = 32'b000000_00000_00000_00000_00000_100000;	//NOP(add $0, $0, $0)
		cpu.IF.PC = 0;
	
end

// Data Memory & Register Files initialilation
initial
begin
	cpu.MEM.DM[0] = 32'd123;	// input
	for (i=1; i<128; i=i+1) cpu.MEM.DM[i] = 32'b0;
	
	cpu.ID.REG[0] = 32'd0;
	cpu.ID.REG[1] = 32'd1;
	cpu.ID.REG[2] = 32'd2;
	cpu.ID.REG[3] = 32'd3;
	cpu.ID.REG[4] = 32'd5;	// special case answer

	for (i=5; i<32; i=i+1) cpu.ID.REG[i] = 32'b0;


end

//clock cycle time is 20ns, inverse Clk value per 10ns
initial Clk = 1'b1;
always #(`CYCLE_TIME/2) Clk = ~Clk;

//Rst signal
initial begin
	cycles = 32'b0;
	Rst = 1'b1;
	#12 Rst = 1'b0;
end

CPU cpu(
	.clk(Clk),
	.rst(Rst)
);

reg [31:0] tmp;
//display all Register value and Data memory content
always @(posedge Clk) begin
	cycles <= cycles + 1;
	if (cycles == `INSTRUCTION_NUMBERS) $finish; // Finish when excute the 24-th instruction (End label). 
	$display("PC: %d cycles: %d", cpu.FD_PC>>2 , cycles);
	$display("  R00-R07: %08x %08x %08x %08x %08x %08x %08x %08x", cpu.ID.REG[0], cpu.ID.REG[1], cpu.ID.REG[2], cpu.ID.REG[3],cpu.ID.REG[4], cpu.ID.REG[5], cpu.ID.REG[6], cpu.ID.REG[7]);
	$display("  R08-R15: %08x %08x %08x %08x %08x %08x %08x %08x", cpu.ID.REG[8], cpu.ID.REG[9], cpu.ID.REG[10], cpu.ID.REG[11],cpu.ID.REG[12], cpu.ID.REG[13], cpu.ID.REG[14], cpu.ID.REG[15]);
	$display("  R16-R23: %08x %08x %08x %08x %08x %08x %08x %08x", cpu.ID.REG[16], cpu.ID.REG[17], cpu.ID.REG[18], cpu.ID.REG[19],cpu.ID.REG[20], cpu.ID.REG[21], cpu.ID.REG[22], cpu.ID.REG[23]);
	$display("  R24-R31: %08x %08x %08x %08x %08x %08x %08x %08x", cpu.ID.REG[24], cpu.ID.REG[25], cpu.ID.REG[26], cpu.ID.REG[27],cpu.ID.REG[28], cpu.ID.REG[29], cpu.ID.REG[30], cpu.ID.REG[31]);
	$display("  0x00   : %08x %08x %08x %08x %08x %08x %08x %08x", cpu.MEM.DM[0],cpu.MEM.DM[1],cpu.MEM.DM[2],cpu.MEM.DM[3],cpu.MEM.DM[4],cpu.MEM.DM[5],cpu.MEM.DM[6],cpu.MEM.DM[7]);
	$display("  0x08   : %08x %08x %08x %08x %08x %08x %08x %08x", cpu.MEM.DM[8],cpu.MEM.DM[9],cpu.MEM.DM[10],cpu.MEM.DM[11],cpu.MEM.DM[12],cpu.MEM.DM[13],cpu.MEM.DM[14],cpu.MEM.DM[15]);
end

//generate wave file, it can use gtkwave to display
initial begin
	$dumpfile("cpu_hw.vcd");
	$dumpvars;
end
endmodule