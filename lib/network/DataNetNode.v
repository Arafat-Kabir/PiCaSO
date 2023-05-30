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
  Date  : Wed, Dec 21, 05:10 PM CST 2022

  Description: 
  This module implements a binary-tree-shift network node for data movement over
  a NEWS network, through Compute Block (processing Block). The tree-level
  and the direction of the data can be specified through configuration ports.

================================================================================*/


/*
Usage: It only supports move-west and move-north.
    clk         : clock
*/


module DataNetNode #(
// Parameters
    parameter NEWS_STREAM_WIDTH     = 1,      // width of NEWS movement stream
    parameter SHIFT_STREAM_WIDTH    = 15,     // width of shift movement stream
    parameter MAX_LEVEL             = 8,      // how many levels of the binary tree to support
    parameter ID_WIDTH              = 8,      // width of the row/colum IDs
    parameter [ID_WIDTH-1:0] ROW_ID = 7,      // row-ID of the node
    parameter [ID_WIDTH-1:0] COL_ID = 16      // column-ID of the node
) (
    clk,

    localIn,      // input stream from the local node itself
    captureOut,   // stream of captured data from network

    northIn,      // input stream from north
    northOut,     // output stream to north

    eastIn,       // input stream from east
    eastOut,      // output stream to east

    westIn,       // input stream from west
    westOut,      // output stream to west

    southIn,      // input stream from south
    southOut,     // output stream to south

    shiftIn,      // shift input channel
    shiftOut,     // shift output channel

    level,        // selects the current tree level
    direction,    // selects the network direction
    confLoad,     // clock enable for configuration registers
    captureEn     // enable network capture registers
);


`include "DataNetNode_dir_param.v"
`include "clogb2_func.v"

localparam LEVEL_WIDTH = clogb2(MAX_LEVEL-1),   // compute the no. of bits needed to represent all levels
           DIR_WIDTH   = 1;                     // no. of bits needed to represent all supported directions (E->W, S->N)


// IO ports
input                           clk;
// data ports
input  [NEWS_STREAM_WIDTH-1:0]  localIn;
output [NEWS_STREAM_WIDTH-1:0]  captureOut;

input  [NEWS_STREAM_WIDTH-1:0]  northIn;
output [NEWS_STREAM_WIDTH-1:0]  northOut;

input  [NEWS_STREAM_WIDTH-1:0]  eastIn;
output [NEWS_STREAM_WIDTH-1:0]  eastOut;

input  [NEWS_STREAM_WIDTH-1:0]  westIn;
output [NEWS_STREAM_WIDTH-1:0]  westOut;

input  [NEWS_STREAM_WIDTH-1:0]  southIn;
output [NEWS_STREAM_WIDTH-1:0]  southOut;

input  [SHIFT_STREAM_WIDTH-1:0] shiftIn;
output [SHIFT_STREAM_WIDTH-1:0] shiftOut;
// configuration ports
input  [LEVEL_WIDTH-1:0]   level;
input  [DIR_WIDTH-1:0]     direction;
input                      confLoad;
input                      captureEn;


// Register to save the requested configuration
(* extract_enable = "yes" *)
reg [LEVEL_WIDTH-1:0]  level_reg = 0;   // default reset value; no explicit reset
(* extract_enable = "yes" *)
reg [DIR_WIDTH-1:0]    dir_reg = 0;     // default reset value; no explicit reset

// Load configurations to the registers when requested
always @(posedge clk) begin
    if(confLoad) begin           // update value only if confLoad set
        level_reg <= level;      // load the requested level
        dir_reg   <= direction;  // load the requested direction
    end 
    else begin
        level_reg <= level_reg;  // otherwise, hold current config
        dir_reg   <= dir_reg; 
    end
end




// ---- Receiver module ----
wire [NEWS_STREAM_WIDTH-1:0]  rxOut;
Receiver #( .NEWS_STREAM_WIDTH(NEWS_STREAM_WIDTH), .NODE_DIR_WIDTH(DIR_WIDTH) )
    nodeRX(
        .northIn(northIn),
        .eastIn(eastIn),
        .westIn(westIn),
        .southIn(southIn),

        .dirReg_Q(dir_reg),
        .rxOut(rxOut)
    );


// Network data capture register
(* extract_enable = "yes" *)
reg [NEWS_STREAM_WIDTH-1:0]  capture_reg = 0;   // default reset value; no explicit reset

// Capture the router output when requested
always @(posedge clk) begin
    if(captureEn)                // update value only if capture requested
        capture_reg <= rxOut;    // capture the receiver module output
    else 
        capture_reg <= capture_reg;  // otherwise, hold the current data
end

assign captureOut = capture_reg;     // expose the captured data



// ---- Transmitter module ----
wire [NEWS_STREAM_WIDTH-1:0]  txOut;
Transmitter #(
    .NEWS_STREAM_WIDTH(NEWS_STREAM_WIDTH),
    .NODE_DIR_WIDTH(DIR_WIDTH),
    .NODE_LEVEL_WIDTH(LEVEL_WIDTH),
    .ID_WIDTH(ID_WIDTH),
    .ROW_ID(ROW_ID),
    .COL_ID(COL_ID)  ) 
    nodeTX(
        .dirReg_Q(dir_reg),
        .levelReg_Q(level_reg),
        .captureReg_Q(capture_reg),
        .localIn(localIn),
        .txOut(txOut)
    );

// Broadcast transmission stream to all cardinal directions
assign eastOut  = txOut;
assign westOut  = txOut;
assign northOut = txOut;
assign southOut = txOut;




// ---- Register for shift-data: Only needed for CNN applications ----
Register #(.WIDTH(SHIFT_STREAM_WIDTH), .USE_CE(1))
    shiftReg (
        .clk(clk),  
        .ce(captureEn),  
        .inD(shiftIn),
        .outQ(shiftOut)
    );



`include "undef_clogb2_func.v"
endmodule
