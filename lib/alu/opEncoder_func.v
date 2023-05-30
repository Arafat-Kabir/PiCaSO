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
  Date  : Mon, Dec 5, 06:08 PM CST 2022

  Description: 
  Encoder to generate op-codes for the boothR2_serial_alu module.
  Either loads the given op-code, or
  Uses booth's radix-2 encoding based on x and y.

================================================================================*/

/*
Usage:
This is basically a multiplixer to select between the given op-code or booth's
radix-2 encoding based op-code.  
This function should fit in a LUT-6 (2xLUT5)
------------------------------------------------------
  opConfig |  op-code (func[1:0]) 
------------------------------------------------------
  0xx      |  opConfig[1:0]
  1xx      |  booth's radix-2 encoding using x and y
------------------------------------------------------
*/


`ifndef FUNC_opEncoder
`define FUNC_opEncoder


`include "boothEncode2_func.v"

function automatic [1:0] opEncoder;

  input [2:0] opConfig;
  input       x, y;

  // Internal signals
  reg          booth;
  reg   [1:0]  opBooth;
  reg   [1:0]  opGiven;
  reg   [1:0]  mult;

  begin
    mult    = {y,x};        // concatenate x,y to build the multiplier bit-pair
    booth   = opConfig[2];  // the upper-most bit decides which encoding to use
    opGiven = opConfig[1:0];
    opBooth = boothEncode2(mult);
    
    // Assign output
    if(booth) opEncoder = opBooth;  // set booth's encoding if requested
    else      opEncoder = opGiven;  // otherwise, load the given op-code
  end
endfunction


`endif // FUNC_opEncoder
