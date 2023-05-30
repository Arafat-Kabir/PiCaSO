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
  Date  : Thu, Dec 29, 04:54 PM CST 2022

  Description:
  This wrapper module is used for out-of-context synthesis of register-file.

================================================================================*/


/*
Usage:
*/




module wrap_bram_wrfirst_ff (
// Ports
    clk,
    wea,
    web,
    addra,
    addrb,
    dia,
    dib,
    doa,
    dob
);

localparam RAM_WIDTH  = 16,
           RAM_DEPTH  = 1024,
           ADDR_WIDTH = 10;


// IO ports
input  wire                     clk, wea, web;
input  wire  [ADDR_WIDTH-1:0]   addra,addrb;
input  wire  [RAM_WIDTH-1 :0]   dia, dib;
output wire  [RAM_WIDTH-1 :0]   doa,dob;


bram_wrfirst_ff #(.RAM_WIDTH(RAM_WIDTH), .RAM_DEPTH(RAM_DEPTH))  
    bram16 (
        .clk(clk),
        .wea(wea),
        .web(web),
        .addra(addra),
        .addrb(addrb),
        .dia(dia),
        .dib(dib),
        .doa(doa),
        .dob(dob)
    );


endmodule
