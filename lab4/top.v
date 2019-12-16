`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/18 13:20:44
// Design Name: 
// Module Name: top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module top(
    clk, 
	rst,
	result1,
	result2,
	
    AN,
    A,
    B,
    C,
    D,
    E,
    F,
    G
);

input clk, rst;
input [31:0] result1, result2;

output A, B, C, D, E, F, G;
output reg [7:0] AN;
reg [20:0] counter;
reg [2:0] state;
reg [6:0] seg_number,seg_data;
reg [12:0] answer_number1, answer_number2;

always@(posedge clk)begin
	if(rst) begin
		answer_number1 <= 13'd0;
		answer_number2 <= 13'd0;
	end
	else begin
		  answer_number1 <= result1[12:0];
		  answer_number2 <= result2[12:0];
	end
end

// Anode control signal
always@(posedge clk) begin
  counter <= (counter<=100000) ? (counter + 1) : 0;
  state   <= (counter==100000) ? (state + 1)  : state;
    // maximum input is 2^13 - 1 = 8191
	case(state)
		0:begin
			seg_number <= answer_number1/1000;
			AN <= 8'b0111_1111;
		end
		1:begin
			seg_number <= (answer_number1/100)%10;
			AN <= 8'b1011_1111;
		end
		2:begin
			seg_number <= (answer_number1/10)%10;
			AN <= 8'b1101_1111;
		end
		3:begin
			seg_number <= answer_number1%10;
			AN <= 8'b1110_1111;
		end
		4:begin
			seg_number <= answer_number2/1000;
			AN <= 8'b1111_0111;
		end
		5:begin
			seg_number <= (answer_number2/100)%10;
			AN <= 8'b1111_1011;
		end
		6:begin
			seg_number <= (answer_number2/10)%10;
			AN <= 8'b1111_1101;
		end
		7:begin
			seg_number <= answer_number2%10;
			AN <= 8'b1111_1110;
		end
		default: state <= state;
	endcase 
end  

//7-segment display control cathode
assign {G,F,E,D,C,B,A} = seg_data;
always@(posedge clk) begin  
  case(seg_number)
	16'd0:seg_data <= 7'b1000000;
	16'd1:seg_data <= 7'b1111001;
	16'd2:seg_data <= 7'b0100100;
	16'd3:seg_data <= 7'b0110000;
	16'd4:seg_data <= 7'b0011001;
	16'd5:seg_data <= 7'b0010010;
	16'd6:seg_data <= 7'b0000010;
	16'd7:seg_data <= 7'b1011000;
	16'd8:seg_data <= 7'b0000000;
	16'd9:seg_data <= 7'b0010000;
	default: seg_number <= seg_number;
  endcase
end
endmodule
