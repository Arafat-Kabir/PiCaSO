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
  This is a basic N-to-1 multiplexer module with parameters for width controls.

================================================================================*/


/*
Usage:
    channels : Connect inputs
    select   : Connect selection bits
    out      : Connect output
*/


module mux #(
// Parameters
    parameter CHANNEL_CNT = 2     // Number of inputs to select from
)(
    channels,    // input channels
    select,      // selection bits
    out          // output channel
);


`include "clogb2_func.v"

localparam SELECT_WIDTH = clogb2(CHANNEL_CNT-1);


// IO Ports
input [CHANNEL_CNT-1:0]   channels;
input [SELECT_WIDTH-1:0]  select;
output                    out;

assign out = channels[select];

`include "undef_clogb2_func.v"
endmodule
