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


module BRAM
	(	
		clk,
		reset,
		wea,
		web,
		addra,
		addrb,
		dia,
		dib,
		doa,
		dob
	);
input clk, reset, wea, web;
input [9:0] addra,addrb;
input [15:0] dia, dib;
output reg [15:0] doa,dob;

(* ram_style = "block" *) reg[15:0] ram[1023:0] ;

always @(posedge clk) 
begin
	if (wea) begin
	    ram[addra] = dia;
	end
	doa = ram[addra];
	
end
always @(posedge clk) 
begin  
    if (web) begin
	    ram[addrb] = dib;
	end
	dob = ram[addrb];
end

endmodule
