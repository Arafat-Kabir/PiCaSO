/*********************************************************************************
* Copyright (c) 2022, Computer Systems Design Lab, University of Arkansas        *
*                                                                                *
* All rights reserved.                                                           *
*                                                                                *
* Permission is hereby granted, free of charge, to any person obtaining a copy   *
* of this software and associated documentation files (the "Software"), to deal  *
* in the Software without restriction, including without limitation the rights   *
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell      *
* copies of the Software, and to permit persons to whom the Software is          *
* furnished to do so, subject to the following conditions:                       *
*                                                                                *
* The above copyright notice and this permission notice shall be included in all *
* copies or substantial portions of the Software.                                *
*                                                                                *
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR     *
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,       *
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE    *
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         *
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  *
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE  *
* SOFTWARE.                                                                      *
**********************************************************************************

==================================================================================

  Author: MD Arafat Kabir
  Email : arafat.sun@gmail.com
  Date  : Tue, Nov 22, 05:47 PM CST 2022

  Description: 
  BRAM configured in write-first mode with output register

================================================================================*/


/*
Usage: <Change it>
    clk         : clock
*/

module bram_wrfirst_ff #(
// Parameters
    parameter RAM_WIDTH = 16,
    parameter RAM_DEPTH = 1024
)(
// Ports
    clk,
    wea,
    web,
    addra,
    addrb,
    dia,
    dib,
    doa,
    dob
);

// Utility includes and derived parameters
`include "clogb2_func.v"

localparam  ADDR_WIDTH = clogb2(RAM_DEPTH-1);


// IO ports
input  wire                     clk, wea, web;
input  wire  [ADDR_WIDTH-1:0]   addra,addrb;
input  wire  [RAM_WIDTH-1 :0]   dia, dib;
output reg   [RAM_WIDTH-1 :0]   doa,dob;

// Internal signals
reg [RAM_WIDTH-1:0] doaR, dobR;    // BRAM output registers

// Memory
(* ram_style = "block" *) 
reg[RAM_WIDTH-1:0] ram[RAM_DEPTH-1:0];   // * synthesis syn_ramstyle=no_rw_check */ // this meta-comment's effect needs to be tested	




// Port-A
always @(posedge clk) 
begin
	if (wea) begin
        doaR <= dia;        // write-first mode: HDL coding practices page-12 pdf
	    ram[addra] <= dia;
	end else
        doaR <= ram[addra];
end


// Port-B
always @(posedge clk) 
begin  
    if (web) begin
        dobR <= dib;
	    ram[addrb] <= dib;
	end else
        dobR <= ram[addrb];
end


// Output registers
always @(posedge clk) 
begin  
 	doa <= doaR;
 	dob <= dobR;
end

`include "undef_clogb2_func.v"
endmodule

