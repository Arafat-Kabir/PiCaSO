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
  This module uses the fullAddSub function with a FF connected to carry/borrow
  to implement a serialized ALU for booth's radix-2 multiplication.

================================================================================*/


/*
Usage:
    x    : Connect operand-1 stream
    y    : Connect operand-2 stream
    ce   : Clock-enable for registers
    op   : Use it to specify the opcode (use fullAddSub_opcodes_param.v)
    reset: Use it to reset the registers
    out  : Connect the output stream

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


module boothR2_serial_alu (
    clk,    // clock
    x,      // operand-1 stream
    y,      // operand-2 stream
    ce,     // clock enable
    op,     // op-code
    reset,  // reset registers
    out     // ALU output stream
);


`include "fullAddSub_func.v"
`include "boothR2_alu_param.v"


localparam OP_WIDTH = BOOTHR2_OP_WIDTH;


// IO ports
input                  clk;   
input                  x;   
input                  y;  
input                  ce;
input  [OP_WIDTH-1:0]  op;
input                  reset;
output                 out;


// Internal Signals
(* extract_enable = "yes", extract_reset = "yes" *)
reg  cb_reg = 0;    // initially starts as 0
wire cb;


// Assign output stream
assign {cb, out} = fullAddSub(x, y, cb_reg, op);


// Store the current carry/borrow for the next cycle
always @(posedge clk) begin
    if(reset)    cb_reg <= 0;       // reset
    else if(ce)  cb_reg <= cb;      // save cb if clock-enable is set 
    else         cb_reg <= cb_reg;  // hold the current value if clock-enable not set
end


endmodule
