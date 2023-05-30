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
  Date  : Mon, Dec 5, 06:13 PM CST 2022

  Description: 
  Implements booth's radix-2 encoding for the boothR2_serial_alu module.

================================================================================*/


/*
Usage:
------------------------------------------------
  mult |  op-code  
-------|----------------------------------------
  00   |  Copy-X (no change to partial product)
  01   |  ADD    (X + Y)
  10   |  SUB    (X - Y)
  11   |  COPY-X (no change to partial product)
------------------------------------------------
*/


`ifndef FUNC_boothEncode2
`define FUNC_boothEncode2


function automatic [1:0] boothEncode2;
  input [1:0] mult;

  `include "fullAddSub_opcodes_param.v"
  begin
    // Booth's radix-2 encoding
    (* full_case *)
    case (mult) 
        2'b00: boothEncode2 = FULLADDSUB_CPX;   // NOP
        2'b01: boothEncode2 = FULLADDSUB_ADD;
        2'b10: boothEncode2 = FULLADDSUB_SUB;
        2'b11: boothEncode2 = FULLADDSUB_CPX;   // NOP
    endcase
  end
endfunction


`endif // FUNC_boothEncode2
