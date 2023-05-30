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
  Date  : Fri, Dec 23, 12:48 PM CST 2022

  Description:
  This is the receiver part of the network node. This is not designed to be
  reuable across different network architecture. It used to modularize the
  network module code.

================================================================================*/


/*
Usage: Implements the receiver logic (combinatorial module)
    dirReg_Q     : connect the direction-register output of the network node
*/


module Receiver #(
// Paramters
    parameter NEWS_STREAM_WIDTH     =  1,
    parameter NODE_DIR_WIDTH        = -1       // default value means nothing (should generate error)
) (
    northIn,      // input stream from north
    eastIn,       // input stream from east
    westIn,       // input stream from west
    southIn,      // input stream from south

    dirReg_Q,
    rxOut
);


`include "RouterNEWS_modes_param.v"
`include "DataNetNode_dir_param.v"

localparam RTR_INST_MODE = NEWS_INST_ES,                         // instantiate the router in ES mode
           RTR_CONF_WIDTH = getConfWidthNEWS_fn(RTR_INST_MODE);  // compile-time constant


// IO ports
input  [NEWS_STREAM_WIDTH-1:0]  northIn;
input  [NEWS_STREAM_WIDTH-1:0]  eastIn;
input  [NEWS_STREAM_WIDTH-1:0]  westIn;
input  [NEWS_STREAM_WIDTH-1:0]  southIn;

input  [NODE_DIR_WIDTH-1:0]     dirReg_Q;
output [NEWS_STREAM_WIDTH-1:0]  rxOut;


// Function to map network-node direction to router configuration
function automatic [RTR_CONF_WIDTH-1:0] mapRouterConf_fn;
    input [NODE_DIR_WIDTH-1:0]   nodeDirection;

    // Extracting least significant bits of the direction codes
    localparam [NODE_DIR_WIDTH-1:0] FN_EW = NET_DIR_EW,
                                    FN_SN = NET_DIR_SN;
    // Mapping
    (* full_case, parallel_case *)
    case (nodeDirection) 
        FN_EW:   mapRouterConf_fn = NEWS_RT_E;
        FN_SN:   mapRouterConf_fn = NEWS_RT_S;
        default: begin
            $display("ERROR: This line should not execute (Receiver-mapRouterConf_fn)");
            //$finish();
        end
    endcase
endfunction


// NEWS router for receiving from neighbors
wire [NEWS_STREAM_WIDTH-1:0] routerOut;
wire [RTR_CONF_WIDTH-1:0]    routeConf;

RouterNEWS #(.STREAM_WIDTH(NEWS_STREAM_WIDTH), .INST_MODE(NEWS_INST_ES))
    router(
        .northIn(northIn),   
        .eastIn(eastIn),    
        .westIn(westIn),    
        .southIn(southIn),   
        .routeConf(routeConf), 
        .outStream(routerOut)  
    );

assign routeConf = mapRouterConf_fn(dirReg_Q);
assign rxOut     = routerOut;   // router output is the receiver module output


endmodule
