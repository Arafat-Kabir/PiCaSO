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
  Date  : Mon, Dec 5, 05:08 PM CST 2022

  Description: 
  Full-Adder/Subtractor function that can be mapped to a single LUT-6 (2xLUT-5). 
  Apart from add/subtract, It can copy one of the inputs, which is needed for
  booth's multiplication.

================================================================================*/


/*
Usage:
-------------------------------------
  op  |  sum (func[0]) . cb (func[1])
------|----------------.--------------
 ADD  |     x + y      .   carry    
 SUB  |     x - y      .   borrow   
 CPX  |       x        .   0  
 CPY  |       y        .   0 
-------------------------------------
*/


`ifndef FUNC_fullAddSub
`define FUNC_fullAddSub


function automatic [1:0] fullAddSub;
  input x, y, cb;
  input [1:0] op;

  // Internal Signals
  reg sum, carry, borrow;

  `include "fullAddSub_opcodes_param.v"
  begin
    sum    = x ^ y ^ cb;
    carry  = (x & y)  | (x & cb)  | (y & cb);
    borrow = (!x & y) | (!x & cb) | (y & cb);
    
    // Assign outputs
    (* full_case *)
    case (op) 
        FULLADDSUB_ADD: begin
            fullAddSub[0] = sum;
            fullAddSub[1] = carry;
        end
        FULLADDSUB_SUB: begin
            fullAddSub[0] = sum;
            fullAddSub[1] = borrow;
        end
        FULLADDSUB_CPX: begin
            fullAddSub[0] = x;
            fullAddSub[1] = 0;
        end
        FULLADDSUB_CPY: begin
            fullAddSub[0] = y;
            fullAddSub[1] = 0;
        end
    endcase
  end
endfunction


`endif // FUNC_fullAddSub
