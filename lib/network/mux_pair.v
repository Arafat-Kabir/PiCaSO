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
  Date  : Wed, Dec 07, 04:56 PM CST 2022

  Description:
  This module implements a pair of N-to-1 multiplexer that share the select
  inputs with parameters for width controls. This can help to reduce LUT count.

================================================================================*/


/*
Usage:
    channelsA : Connect inputs of mux-A
    channelsB : Connect inputs of mux-B
    select    : Connect selection bits
    out_pair  : out_pair[0] = channelsA[select]
                out_pair[1] = channelsB[select]
*/


module mux_pair #(
// Parameters
    parameter CHANNEL_CNT = 2     // Number of inputs to select from (for each mux)
)(
    channelsA,
    channelsB,
    select, 
    out_pair
);


`include "clogb2_func.v"

localparam SELECT_WIDTH = clogb2(CHANNEL_CNT-1);


// IO Ports
input  [CHANNEL_CNT-1:0]   channelsA;
input  [CHANNEL_CNT-1:0]   channelsB;
input  [SELECT_WIDTH-1:0]  select;
output [1:0]               out_pair;    // There will always be 2 output bits for a mux-pair


/* This description uses 1 LUT6 to implement 2 2-to-1 MUX
*  This is indirectly saying,
*     set i = select
*     out_pair[0] = channelsA[i]
*     out_pair[1] = channelsB[i]
*/
function automatic [1:0] mux_pair_func;
    input  [CHANNEL_CNT-1:0]   chA;
    input  [CHANNEL_CNT-1:0]   chB;
    input  [SELECT_WIDTH-1:0]  sel;

    // Muxing logic
    integer i;
    for(i=0; i<CHANNEL_CNT; i=i+1)
        if(sel==i) mux_pair_func = {chB[i], chA[i]};

    /* Following condition can be used for the cases where we have less channels than 2^(sel).
    *  I'm not using it right now because it is not essential, and might help with optimization later. */
    // if(sel>=CHANNEL_CNT) out_pair = {chB[CHANNEL_CNT-1], chA[CHANNEL_CNT-1]};
endfunction

assign out_pair = mux_pair_func(channelsA, channelsB, select);


`include "undef_clogb2_func.v"
endmodule
