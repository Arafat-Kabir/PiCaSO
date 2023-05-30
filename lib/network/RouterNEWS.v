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
  Date  : Thu, Dec 22, 05:48 PM CST 2022

  Description:
  This module implements the logic for NEWS routing. The basic architecture
  is to read from N,E,W, and S, then broadcast the selected channel to the
  output port (a basic mux).

================================================================================*/


/*
Usage: 
  Instantiate the router in different modes based on the requirement. 
  You must specify an instance mode (INST_MODE).

    northIn   :  input stream from north
    eastIn    :  input stream from south
    westIn    :  input stream from west
    southIn   :  input stream from south
    routeConf :  selects the router configuration
    outStream :  selected output stream
*/


module RouterNEWS #(
// Parameters
    parameter STREAM_WIDTH = 1,
    parameter INST_MODE    = 0        // by default, selects the invalid mode (0)
)  (
    northIn,      // input stream from north
    eastIn,       // input stream from east
    westIn,       // input stream from west
    southIn,      // input stream from south
    routeConf,    // selects the router configuration
    outStream     // selected output stream
);


`include "RouterNEWS_modes_param.v"

localparam CONF_WIDTH = getConfWidthNEWS_fn(INST_MODE);     // compile-time constant


// IO ports
input  [STREAM_WIDTH-1:0]  northIn;
input  [STREAM_WIDTH-1:0]  eastIn;
input  [STREAM_WIDTH-1:0]  westIn;
input  [STREAM_WIDTH-1:0]  southIn;
input  [CONF_WIDTH-1:0]    routeConf;
output [STREAM_WIDTH-1:0]  outStream;


// Routing logic for ES mode
function automatic [STREAM_WIDTH-1:0] routerES_fn;
    input                      routeConf;   // for this mode, the configuration is always 1-bit wide
    input  [STREAM_WIDTH-1:0]  eastIn;
    input  [STREAM_WIDTH-1:0]  southIn;

    // Extracting lsb of the routing codes
    localparam [0:0] FN_RT_E = NEWS_RT_E,
                     FN_RT_S = NEWS_RT_S;

    // routing logic
    (* full_case, parallel_case *)
    case (routeConf) 
        FN_RT_E: routerES_fn = eastIn;
        FN_RT_S: routerES_fn = southIn;
    endcase
endfunction


// Function for ESW mode
// TO-DO


// Function for NEWS mode
// TO-DO


// Use the appropriate function based on the requested instance mode
generate
    if(INST_MODE == NEWS_INST_ES) begin: instES
        assign outStream = routerES_fn(routeConf[0], eastIn, southIn);
    end
    else if(INST_MODE == NEWS_INST_ESW) begin: instESW
        // TO-DO
    end
    else if(INST_MODE == NEWS_INST_NEWS) begin: instNEWS
        // TO-DO
    end
    else initial begin
        $display("ERROR: This line should not execute (RouterNEWS-generate)");
        $finish();
    end
endgenerate


endmodule

