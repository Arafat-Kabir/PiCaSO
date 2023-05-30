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
  Date  : Mon, Dec 5, 05:37 PM CST 2022

  Description: 
  This module uses the boothR2_serial_alu module to build the configurable
  alu unit for the Compute-Block.

================================================================================*/


/*
Usage:
    x       : Connect operand-1 stream
    y       : Connect operand-2 stream
    ce      : Clock-enable for registers
    opConfig: Use it to specify a given op or use booth's encoding
    opLoad  : Use to load the specified op
    reset   : Use it to reset the registers
    out     : Connect the output stream

Op-codes (check fullAddSub_func.v for details/updates)
-----------------------
  op  |  out           
------|----------------
 ADD  |     x + y      
 SUB  |     x - y      
 CPX  |       x        
 CPY  |       y        
-----------------------
*/


module alu_serial_unit(
    clk,      // clock
    x,        // operand-1 stream
    y,        // operand-2 stream
    ce_alu,   // clock enable for the ALU registers
    opConfig, // configures op-code register
    opLoad,   // clock-enable for the op-code register
    reset,    // reset registers
    out       // ALU output stream
);


`include "opEncoder_func.v"

localparam OP_WIDTH = 2;    // OP-code width of the boothR2_serial_alu module


// IO ports
input                clk;   
input                x;   
input                y;  
input                ce_alu;
input  [OP_WIDTH:0]  opConfig;  // 1-bit wider than the boothR2_serial_alu op-code
input                opLoad;
input                reset;
output               out;


// Internal Signals
(* extract_enable = "yes", extract_reset = "yes" *)
reg  [OP_WIDTH-1 : 0] op_reg;
wire [OP_WIDTH-1 : 0] op_reg_in;


// Load op-code to the op_reg register based on the requested configuration
assign op_reg_in = opEncoder(opConfig, x, y);   // input to op_reg
always @(posedge clk) begin
    if(reset) 
        op_reg <= 0;            // should correspond to FULLADDSUB_ADD
    else if(opLoad)             // update value only if opLoad requested
        op_reg <= op_reg_in;    // load the op-code for the requested configuration
    else
        op_reg <= op_reg;       // if opLoad not set, hold the current value
end


// The full-adder/subtractor for booth's radix-2 multiplication
boothR2_serial_alu  boothR2_ALU(
    .clk(clk),
    .x(x), 
    .y(y),
    .ce(ce_alu),
    .op(op_reg),
    .reset(reset),
    .out(out)   
);


endmodule
