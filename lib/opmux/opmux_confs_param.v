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
  Date  : Tue, Dec 13, 01:43 PM CST 2022

  Description:
  Named configurations for the opmux module (all versions).
  This file should be included in the modules where the opmux module is used.

================================================================================*/


/*
Usage: 
    The names of the configuration codes are meaningful in the context of the
    alu_serial design that is used in this version of the SPAR.  
    The actual muxing operations corresponding to these codes are included as
    in-line comments.

    Naming notes:
        X   = output operand X
        Y   = output operand Y
        A   = register-file port-A
        B   = register-file port-B
        net = net_stream
        0   = all zeros
        
        lq/2  = lower half of lower-quarter
        lq/2u = upper half of the lower-quarter
        lq/4  = lower quarter of lower-quarter
        lq/4u = 2nd quarter of the lower-quarter
*/


localparam OPMUX_CONF_WIDTH = 3;
       
localparam OPMUX_A_OP_B   = 3'd0,       // X[i] = A[i], Y[i] = B[i]
           OPMUX_A_FOLD_1 = 3'd1,       // X[i] = A[i], Y[lower-half] = A[upper-half],     Y[remain] = 0
           OPMUX_A_FOLD_2 = 3'd2,       // X[i] = A[i], Y[lower-quarter] = A[2nd-quarter], Y[remain] = 0
           OPMUX_A_FOLD_3 = 3'd3,       // X[i] = A[i], Y[lq/2] = A[lq/2u],                Y[remain] = 0
           OPMUX_A_FOLD_4 = 3'd4,       // X[i] = A[i], Y[lq/4] = A[lq/4u],                Y[remain] = 0
           OPMUX_A_OP_NET = 3'd5,       // X[i] = A[i], Y[lower-bits] = net,               Y[upper-bits] = 0
           OPMUX_0_OP_B   = 3'd6;       // X = 0      , Y[i] = B[i]
           
