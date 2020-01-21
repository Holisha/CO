`timescale 1ns/1ps

module EXECUTION(
	clk,
	rst,
	DX_MemtoReg,
	DX_RegWrite,
	DX_MemRead,
	DX_MemWrite,
	DX_branch,
	ALUctr,
	NPC,
	A,
	B,
	imm,
	DX_RD,
	DX_MD,
	
	JT,
	DX_PC,
	DX_jump,

	XM_FD,
	MW_FD,
	FXM_RD,
	FMW_RD,
	FXM_RegWrite,
	FMW_RegWrite,
	DX_RS,
	DX_RT,

	XM_MemtoReg,
	XM_RegWrite,
	XM_MemRead,
	XM_MemWrite,
	XM_branch,
	ALUout,
	XM_RD,
	XM_MD,
	XM_BT
);

input clk, rst, DX_MemtoReg, DX_RegWrite, DX_MemRead, DX_MemWrite, DX_branch, DX_jump;
input [2:0] ALUctr;
input [31:0]JT, DX_PC, NPC, A, B;
input [15:0]imm;
input [4:0] DX_RD;
input [31:0] DX_MD;

// Forwarding
input FXM_RegWrite, FMW_RegWrite;
input [4:0] FXM_RD, FMW_RD, DX_RS, DX_RT;
input [31:0] XM_FD, MW_FD;	// forwarding ALUout
reg [31:0] tmpA, tmpB;

output reg XM_MemtoReg, XM_RegWrite, XM_MemRead, XM_MemWrite, XM_branch;
output reg [31:0]ALUout, XM_BT;
output reg [4:0] XM_RD;
output reg [31:0] XM_MD;

//set pipeline register
always @(posedge clk or posedge rst)
begin
	if(rst) begin //初始化
		XM_MemtoReg	<= 1'b0;
		XM_RegWrite	<= 1'b0;
		XM_MemRead 	<= 1'b0;
		XM_MemWrite	<= 1'b0;
		XM_RD 	   	<= 5'b0;
		XM_MD 	   	<= 32'b0;
		XM_branch	<= 1'b0;
		XM_BT		<= 32'b0;
	end else begin
		XM_MemtoReg	<= DX_MemtoReg;
		XM_RegWrite	<= DX_RegWrite;
		XM_MemRead 	<= DX_MemRead;
		XM_MemWrite	<= DX_MemWrite;
		XM_RD 	   	<= DX_RD;
		XM_MD 	   	<= DX_MD;
	    XM_branch<=((ALUctr==5) && (A == B) && (DX_branch))? 1'b1: ((ALUctr==6) && (A != B) && (DX_branch))?1'b1:1'b0;
		XM_BT<=NPC+{ { 15{imm[15]}}, imm, 2'b0};  //Branch Target = 當前的PC值 + 相對位址 (EX. beq指令)
		//beq指令在"execution"中所需要的設定其實大多都完成了，各位可以參閱上方兩行指令。但下方ALUout還是記得要給個值，例如：0
	end
end

// forwarding unit
always @(posedge clk)
begin
	if(FXM_RegWrite && FXM_RD != 5'd0) begin
		tmpA = FXM_RD == DX_RS ? XM_FD : A;
		tmpB = FXM_RD == DX_RT ? XM_FD : B;
	end else if(FMW_RegWrite && FMW_RD != 5'd0) begin
		tmpA = FMW_RD == DX_RS ? MW_FD : A;
		tmpB = FMW_RD == DX_RT ? MW_FD : B;
	end else begin
		tmpA = A;
		tmpB = B;
	end
end

always @(posedge clk or posedge rst)
begin
   if(rst) begin
   		ALUout <= 32'b0;
   end else begin
		// forwarding
   		case(ALUctr)
		  	3'd0: //add / lw ...  //在ID階段時已經解碼出指令了，那該指令需要哪一種運算?
		     	ALUout <= tmpA + tmpB;
			3'd1: //sub
				ALUout <= tmpA - tmpB;
			3'd2: //and
				ALUout <= tmpA & tmpB;
			3'd3: //or
				ALUout <= tmpA | tmpB;
			3'd4: begin //slt
				if (tmpA[31] == 1'b0 && tmpB[31] == 1'b0)
					ALUout <= tmpA < tmpB ? 32'd1 : 32'd0;
				else if (tmpA[31] == 1'b0 && tmpB[31] == 1'b1)
					ALUout <= 32'd0;
				else if (tmpA[31] == 1'b1 && tmpB[31] == 1'b0)
					ALUout <= 32'd1;
				else
					ALUout <= ~tmpA + 1'b1 < ~tmpB + 1'b1 ? 32'd1 : 32'd0;
			end
			3'd5:
				ALUout <= 32'b0;
			3'd6:
				ALUout <= 32'b0;
			3'd7:
				ALUout <= 32'b0;


		endcase
   end
end


endmodule
	
