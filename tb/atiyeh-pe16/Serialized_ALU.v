/*
 * Copyright (c) 2022, SPAR-Internal
 * All rights reserved.
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
 * of the Software, and to permit persons to whom the Software is furnished to do
 * so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *
 */


//`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/13/2021 10:26:39 AM
// Design Name: 
// Module Name: Serialized_ALU
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


module  Serialized_ALU #(parameter LENGTH = 32)
(
	clk,  
	reset, 
	rd_d,	//alu result will be written to rd (rd_d == rd data)  
	rs1_d,  //data in from rs1
	rs2_d, 	//data in from rs2
	alu_op,//op code
	count,		//signals sent to or from controller
	reg_write,	//signals sent to or from controller
	Q
	// LENGTH
);
input[1:0] Q;
input clk, reset, rs1_d, rs2_d;
input[3:0] alu_op;
input[7:0] count; //debug: was [6:0]
input reg_write;
output rd_d;
reg carry_borrow;
wire [1:0] max;
reg pos;

wire operation = ((alu_op==1) || (alu_op==2 &&(Q>1)))? 1 : 0; //debug: added alu_op==2

wire rs1 = operation? !rs1_d : rs1_d;

always @(posedge clk)
begin	
	carry_borrow 	<= (count == 0 || count == 66) ? 0 : reg_write? ((rs1 & rs2_d) | (rs1 & carry_borrow) | (rs2_d & carry_borrow)) : carry_borrow; 		
	//debug: was 66
end
 
  assign rd_d = ((Q[0]==Q[1]) && alu_op==2? rs1_d : (alu_op==10)? (pos == 1 ? rs1_d : 1'b0) : (rs1_d ^ rs2_d ^ carry_borrow));

always @(count, alu_op, rs1_d)
begin
    if(count == 1 && alu_op==10 && rs1_d == 0)
    begin
        pos = 1'b1;
    end
    else if(count == 1 && alu_op==10 && rs1_d == 1)
    begin
        pos = 1'b0;
    end
    else
    begin
        pos = pos;
    end
//    pos = (count == 3 && alu_op==10) ? ((rs1_d == 0) ? 1: 0): pos;
end

/*FDRE #(
      .INIT(1'b0) // Initial value of register (1'b0 or 1'b1)
   ) FDRE_inst (
      .Q(rd_d),      // 1-bit Data output
      .C(clk),      // 1-bit Clock input
      .CE(1),    // 1-bit Clock enable input
      .R(!reset),      // 1-bit Synchronous reset input
      .D(((Q[0]==Q[1]) && alu_op==2? rs1_d : (alu_op==10)? (pos == 1 ? rs1_d : 1'b0) : (rs1_d ^ rs2_d ^ carry_borrow)))       // 1-bit Data input
   );*/

endmodule
