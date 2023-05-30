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
  Date  : Fri, Dec 23, 12:04 PM CST 2022

  Description:
  This is the transmitter part of the network node. This is not designed to be
  reuable across different network architecture. It used to modularize the
  network module code.

================================================================================*/


/*
Usage: Implements the transmitter logic (combinatorial module)
    dirReg_Q     : connect the direction-register output of the network node
    levelReg_Q   : connect the level-register output of the network node
    captureReg_Q : connect the network capture-register output of the node
    localIn      : local data stream to be transmitted
*/


module Transmitter #(
// Paramters
    parameter NEWS_STREAM_WIDTH     =  1,
    parameter NODE_DIR_WIDTH        = -1,      // default value means nothing (should generate error)
    parameter NODE_LEVEL_WIDTH      = -1,      // default value means nothing (should generate error)
    parameter ID_WIDTH              =  4,      // width of the row/colum IDs
    parameter [ID_WIDTH-1:0] ROW_ID =  0,      // row-ID of the node
    parameter [ID_WIDTH-1:0] COL_ID =  0       // column-ID of the node
) (
    dirReg_Q,
    levelReg_Q,
    captureReg_Q,
    localIn,
    txOut
);


`include "DataNetNode_dir_param.v"

// IO Ports
input  [NODE_DIR_WIDTH-1:0]     dirReg_Q;
input  [NODE_LEVEL_WIDTH-1:0]   levelReg_Q;
input  [NEWS_STREAM_WIDTH-1:0]  captureReg_Q;
input  [NEWS_STREAM_WIDTH-1:0]  localIn;
output [NEWS_STREAM_WIDTH-1:0]  txOut;


// Multiplexter to select between local data and network data
localparam TX_CNT = 2,      // There are only 2 options to transmit from
           TX_ALL_WIDTH = TX_CNT*NEWS_STREAM_WIDTH;

wire                         txSelect;     // Mux selection bit, handled by the decoder
wire [TX_ALL_WIDTH-1:0]      txAll = {captureReg_Q, localIn};  // Concatenation of all channels (in-order)
bus_muxp #(.BUS_WIDTH(NEWS_STREAM_WIDTH), .BUS_CNT(TX_CNT))
        transmitMux (
            .bus_all(txAll),
            .select(txSelect),
            .bus_out(txOut)
        );


/* Function to map network-node level and direction to transmitMux selection bit
*  Required mapping: (draw a 2D Array diagram to understand)
*   E -> W uses column-ID, S-> uses row-ID
*   level | selection
*   ------|-----------
*     0   | all blocks : transmit local           
*     1   | even blocks: transmit local, others: passthrough             
*     2   | multiple of 4   blocks: transmit local, others: passthrough                       
*     3   | multiple of 8   blocks: transmit local, others: passthrough                        
*     4   | multiple of 16  blocks: transmit local, others: passthrough                       
*     5   | multiple of 32  blocks: transmit local, others: passthrough                       
*     6   | multiple of 64  blocks: transmit local, others: passthrough                      
*     7   | multiple of 128 blocks: transmit local, others: passthrough                       
*  Based on the width of direction and level, this function should map to
*  one LUTs. For example, a 1-bit direction with support for 16-levels (0-15),
*  it can be mapped into a LUT5. This can support an array with 2**15 = 32k rows/cols.
*/
function automatic mapTxSelect_fn;
    input [NODE_DIR_WIDTH-1:0]    direction;
    input [NODE_LEVEL_WIDTH-1:0]  level;

    reg selectEW, selectSN;  // internal variables

    begin
        // compute the selection table based on level: if divisible by power of 2, transmit local (select = 0)
        selectEW = |(COL_ID%(1<<level));   // reduction-or operator to make select=0 if remainter=0, select=1 otherwise
        selectSN = |(ROW_ID%(1<<level));
        // select the option for the given direction
        if(direction == NET_DIR_EW)      mapTxSelect_fn = selectEW;
        else if(direction == NET_DIR_SN) mapTxSelect_fn = selectSN;
        else begin
            $display("ERROR: This line should not execute (Transmitter-mapTxSelect_fn)");
            //$finish();
        end
    end
endfunction


assign txSelect = mapTxSelect_fn(dirReg_Q, levelReg_Q);


endmodule
