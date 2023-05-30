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
  Date  : Wed, Dec 21, 03:29 PM CST 2022

  Description:
  This module implements the logic for LNEWS routing. The basic architecture
  is to read from N,E,W,S, and a local signal (L), then broadcast the selected
  channel to the output port (a basic mux).

================================================================================*/


/*
Usage: 
  Instantiate the router in different modes based on the requirement. 
  You must specify an instance mode (INST_MODE).

    localIn   :  input stream from the local node itself
    northIn   :  input stream from north
    eastIn    :  input stream from south
    westIn    :  input stream from west
    southIn   :  input stream from south
    routeConf :  selects the router configuration
    outStream :  selected output stream
*/


module RouterLNEWS #(
// Parameters
    parameter STREAM_WIDTH = 1,
    parameter INST_MODE    = 0        // by default, selects the invalid mode (0)
)  (
    localIn,      // input stream from the local node itself
    northIn,      // input stream from north
    eastIn,       // input stream from east
    westIn,       // input stream from west
    southIn,      // input stream from south
    routeConf,    // selects the router configuration
    outStream     // selected output stream
);


`include "RouterLNEWS_modes_param.v"

localparam CONF_WIDTH = getConfWidthLNEWS_fn(INST_MODE);     // compile-time constant


// IO ports
input  [STREAM_WIDTH-1:0]  localIn;
input  [STREAM_WIDTH-1:0]  northIn;
input  [STREAM_WIDTH-1:0]  eastIn;
input  [STREAM_WIDTH-1:0]  westIn;
input  [STREAM_WIDTH-1:0]  southIn;
input  [CONF_WIDTH-1:0]    routeConf;
output [STREAM_WIDTH-1:0]  outStream;


// Function for LE mode
// TO-DO


// Routing logic for LES mode
function automatic [STREAM_WIDTH-1:0] routerLES_fn;
    input  [1:0]               routeConf;   // for this mode, the configuration is always 2-bits wide
    input  [STREAM_WIDTH-1:0]  localIn;
    input  [STREAM_WIDTH-1:0]  eastIn;
    input  [STREAM_WIDTH-1:0]  southIn;

    // Extracting lower 2-bits of the routing codes
    localparam [1:0] FN_RT_L = LNEWS_RT_L,
                     FN_RT_E = LNEWS_RT_E,
                     FN_RT_S = LNEWS_RT_S;

    // routing logic
    (* full_case, parallel_case *)
    case (routeConf) 
        FN_RT_L: routerLES_fn = localIn;
        FN_RT_E: routerLES_fn = eastIn;
        FN_RT_S: routerLES_fn = southIn;
        default: routerLES_fn = 0;    // for unspecified cases, output stream of zeros
    endcase
endfunction


// Function for LESW mode
// TO-DO


// Function for LNEWS mode
// TO-DO


// Use the appropriate function based on the requested instance mode
generate
    if(INST_MODE == LNEWS_INST_LE) begin: instLE
        // TO-DO
    end
    else if(INST_MODE == LNEWS_INST_LES) begin: instLES
        assign outStream = routerLES_fn(routeConf[1:0], localIn, eastIn, southIn);
    end
    else if(INST_MODE == LNEWS_INST_LESW) begin: instLESW
        // TO-DO
    end
    else if(INST_MODE == LNEWS_INST_LNEWS) begin: instLNEWS
        // TO-DO
    end
    else initial begin
        $display("ERROR: This line should not execute (RouterLNEWS-generate)");
        $finish();
    end
endgenerate


endmodule

