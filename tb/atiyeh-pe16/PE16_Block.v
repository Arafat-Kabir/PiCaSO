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


module PE16_Block #(parameter SIZE = 1, parameter MAX_WORD_LENGTH = 32)
	(
		input clk,
		input reset,
		// input[5:0] LENGTH,
		
		//alu control
		input[3:0] alu_op,

		//bram control
		input wea,
		input web,
		input[9:0] addra,
		input[9:0] addrb,
		input[15:0] DINA,
        input[15:0] DINB,
		output[15:0] DOUTA,
        output[15:0] DOUTB,
        input external,

		//other helper signals
		input[7:0] count, //debug: was [6:0]
		// input bram_init_flag,
		// input[15:0]  bram_init_d,
		input[2:0] state, //debug:
		
		//move control
		input east,
		input west,
		input south,
		input north,
		//move data
		input[7:0] Ein,
		input[7:0] Win,
		input[7:0] Nin,
		input[7:0] Sin,
		output[7:0] Eout,
		output[7:0] Wout,
		output[7:0] Nout,
		output[7:0] Sout

		
	);

//Bram data
wire[15:0] DIA; 
wire[15:0] DIB;
wire[15:0] DOB;
wire[15:0] DOA;
//move data
wire[15:0] W1, W2;
wire[15:0] E1, E2;
wire[15:0] N1, N2;
wire[15:0] S1, S2;

//alu signals
wire[15:0] alu_out;	
reg[15:0] q1_reg, q0_reg;
wire[15:0] q0;
wire[15:0] q1;

wire[1:0] Q [15:0];

generate 
genvar g;
	for (g=0; g<16; g=g+1) begin
		assign Q[g] = {q1[g],q0[g]};
	end
endgenerate

//booth comparison variable
assign q0 = (state != 2)? q0_reg : 16'hFFFF; //debug: was q0 = state != 2? q0_reg : 16'hFFFF not 4, 5
assign q1 = (state != 2)? q1_reg : 16'h0000; //debug: was q1 = state != 2? q1_reg : 16'h0000

always@(posedge clk) begin
	if(!reset) begin
		q0_reg <= 0;
		q1_reg <= 0;
	end
	else begin
		if(count==2 && state != 2) q1_reg	<= DOB; //debug: was count==2 && state != 2 changed to count==3
		if(count==2 && state != 2) q0_reg	<= q1_reg;  //debug: was count==2 && state != 2 changed to count==3
	end
end

assign E1 = {	
				DOA[14],DOA[13],DOA[12],Win[0],
				DOA[10],DOA[9 ],DOA[8 ],Win[2],
				DOA[6 ],DOA[5 ],DOA[4 ],Win[4],
				DOA[2 ],DOA[1 ],DOA[0 ],Win[6]	
			};                          
				                        
assign E2 = {	                        
				DOB[14],DOB[13],DOB[12],Win[1],
				DOB[10],DOB[9 ],DOB[8 ],Win[3],
				DOB[6 ],DOB[5 ],DOB[4 ],Win[5],
				DOB[2 ],DOB[1 ],DOB[0 ],Win[7]	
			};

assign W1 = {	
				Ein[0],DOA[15],DOA[14],DOA[13],
				Ein[2],DOA[11],DOA[10],DOA[9 ],
				Ein[4],DOA[7 ],DOA[6 ],DOA[5 ],
				Ein[6],DOA[3 ],DOA[2 ],DOA[1 ]	
			};
				
assign W2 = {	
				Ein[1],DOB[15],DOB[14],DOB[13],
				Ein[3],DOB[11],DOB[10],DOB[9 ],
				Ein[5],DOB[7 ],DOB[6 ],DOB[5 ],
				Ein[7],DOB[3 ],DOB[2 ],DOB[1 ]	
			};
				
				
assign S1 = {	
				DOA[11],DOA[10],DOA[9 ],DOA[8],
				DOA[7 ],DOA[6 ],DOA[5 ],DOA[4],
				DOA[3 ],DOA[2 ],DOA[1 ],DOA[0],
				Nin[0 ],Nin[2 ],Nin[4 ],Nin[6]
			};
				
assign S2 = {	
				DOB[11],DOB[10],DOB[9 ],DOB[8],
				DOB[7 ],DOB[6 ],DOB[5 ],DOB[4],
				DOB[3 ],DOB[2 ],DOB[1 ],DOB[0],	
				Nin[1 ],Nin[3 ],Nin[5 ],Nin[7] 	
			};
				
assign N1 = {	
				Sin[0 ],Sin[2 ],Sin[4 ],Sin[6 ],
				DOA[15],DOA[14],DOA[13],DOA[12],
				DOA[11],DOA[10],DOA[9 ],DOA[8 ],
				DOA[7 ],DOA[6 ],DOA[5 ],DOA[4 ]	
			};
				
assign N2 = {	
				Sin[1 ],Sin[3 ],Sin[5 ],Sin[7 ],	
				DOB[15],DOB[14],DOB[13],DOB[12],	
				DOB[11],DOB[10],DOB[9 ],DOB[8 ],
				DOB[7 ],DOB[6 ],DOB[5 ],DOB[4 ]	
			};
				
		
assign Wout = {DOB[0] , DOA[0] , DOB[4] , DOA[4] , DOB[8]  , DOA[8]  , DOB[12] , DOA[12]};//{DOA[15] , DOA[11] , DOA[7] , DOA[3] , DOB[15] , DOB[11] , DOB[7] , DOB[3]};
assign Eout = {DOB[3] , DOA[3] , DOB[7] , DOA[7] , DOB[11] , DOA[11] , DOB[15] , DOA[15]};//{DOA[12] , DOA[8] , DOA[4] , DOA[0] , DOB[12] , DOB[8] , DOB[4] , DOB[0]};
assign Nout = {DOB[0] , DOA[0] , DOB[1] , DOA[1] , DOB[2]  , DOA[2]  , DOB[3]  , DOA[3] }; //{DOA[15] , DOA[14] , DOA[13] , DOA[12] , DOB[15] , DOB[14] , DOB[13] , DOB[12]}; 
assign Sout = {DOB[12], DOA[12], DOB[13], DOA[13], DOB[14] , DOA[14] , DOB[15] , DOA[15]}; //{DOA[3] , DOA[2] , DOA[1] , DOA[0] , DOB[3] , DOB[2] , DOB[1] , DOB[0]}; 

assign DOUTA = DOA;
assign DOUTB = DOB;

//update
assign DIA = external? DINA : east ? E1 : west ? W1 : south ? S1 : north ? N1 : alu_out ; //: north ? N1 : south ? S1 : 0;
assign DIB = external? DINB : east ? E2 : west ? W2 : south ? S2 : north ? N2 : 16'hzzzz;

//Bram temp data
wire[15:0] DOB_temp;
wire[15:0] DOA_temp;

BRAM regfile
(
	clk,
	reset,
	wea,
	web,
	addra,
	addrb,
	DIA,
	DIB,	
	DOA, //DOA_temp //debug: changed to DOA_temp
	DOB  //DOB_temp //debug: changed to DOB_temp
);

generate
genvar gi;
  for (gi=0; gi<16; gi=gi+1) begin : ALU
	Serialized_ALU #(MAX_WORD_LENGTH) alu 
	(
		clk,  
		reset, 
		alu_out[gi],  
		DOA[gi], 
		DOB[gi],   
		alu_op,		
		count,	
		wea,
		Q[gi]
		// LENGTH
	);
  end
  

endgenerate

/*generate
genvar i;
  for (i=0; i<16; i=i+1) begin : criticalPathBreaker
  FDRE #(
      .INIT(1'b0) // Initial value of register (1'b0 or 1'b1)
   ) FDRE_DOA (
      .Q(DOA[i]),      // 1-bit Data output
      .C(clk),      // 1-bit Clock input
      .CE(1),    // 1-bit Clock enable input
      .R(!reset),      // 1-bit Synchronous reset input
      .D(DOA_temp[i])       // 1-bit Data input
   );
   
   
   FDRE #(
      .INIT(1'b0) // Initial value of register (1'b0 or 1'b1)
   ) FDRE_DOB (
      .Q(DOB[i]),      // 1-bit Data output
      .C(clk),      // 1-bit Clock input
      .CE(1),    // 1-bit Clock enable input
      .R(!reset),      // 1-bit Synchronous reset input
      .D(DOB_temp[i])       // 1-bit Data input
   );
end
endgenerate*/

endmodule