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
  Date  : Wed, Dec 7, 12:33 PM CST 2022

  Description: 
  This module instantiates an array of alu_serial_unit module to build the
  compute module to be used in the PE-block16

================================================================================*/


/*
Usage:
    x_streams   : Connect operand-1 streams
    y_streams   : Connect operand-2 streams
    ce          : Clock-enable for registers
    opConfig    : Use it to specify a given op or use booth's encoding
    opLoad      : Use to load the specified op
    reset       : Use it to reset the registers
    out_streams : Connect the output streams
*/


module alu_serial #(
// Parameters
    parameter STREAM_WIDTH = 16   // How many x/y streams are coming
)(
    clk,         // clock
    x_streams,   // operand-1 streams
    y_streams,   // operand-2 streams
    ce_alu,      // clock enable for the ALU registers
    opConfig,    // configures op-code register
    opLoad,      // clock-enable for the op-code register
    reset,       // reset registers
    out_streams, // ALU output stream
);


`include "boothR2_alu_param.v"

localparam OP_WIDTH = BOOTHR2_OP_WIDTH; 


// IO ports
input                      clk;   
input  [STREAM_WIDTH-1:0]  x_streams;   
input  [STREAM_WIDTH-1:0]  y_streams;  
input                      ce_alu;
input  [OP_WIDTH:0]        opConfig;  // 1-bit wider than the boothR2_serial_alu op-code
input                      opLoad;
input                      reset;
output [STREAM_WIDTH-1:0]  out_streams;


/* Array of alu_serial_unit modules
*  Connection summary:
*     alu_unit_arr[i].x   <- x_streams[i]
*     alu_unit_arr[i].y   <- y_streams[i]
*     alu_unit_arr[i].out -> out_streams[i]
*/
alu_serial_unit alu_unit_arr[STREAM_WIDTH-1:0] (
    .clk(clk),      
    .x(x_streams),        
    .y(y_streams),        
    .ce_alu(ce_alu),   
    .opConfig(opConfig), 
    .opLoad(opLoad),   
    .reset(reset),    
    .out(out_streams)       
);


endmodule
