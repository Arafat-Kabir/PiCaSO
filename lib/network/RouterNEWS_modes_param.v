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
  Date  : Thu, Dec 22, 06:01 PM CST 2022

  Description:
  Declares the named constans for the modes of the RouterNEWS module.
  This file should be included where the RouterNEWS module is used.

================================================================================*/

// Instance selection modes
localparam NEWS_INST_NONE = 0,      // Invalid mode
           NEWS_INST_ES   = 1,      // input channels: East and South
           NEWS_INST_ESW  = 2,      // input channels: East, West, and South
           NEWS_INST_NEWS = 3;      // input channels: All channels


/* Routing configurations: 
*     Rationale:
*       ES   fits in 1-bit, which is the second most common connection, after east-only case for accumulation.
*       ESW  fits in 2-bits, which might be needed for CNNs.
*       NEWS fits in 2-bits, which the minimum no. of bits needed.
*/
localparam NEWS_RT_E = 0,      // select east input stream
           NEWS_RT_S = 1,      // select south input stream 
           NEWS_RT_W = 2,      // select west input stream
           NEWS_RT_N = 3;      // select north input stream


// following constant function computes the width of the routeConf port
function automatic integer getConfWidthNEWS_fn;
	input integer INST_MODE;
    // compute the configuration width for the given mode
    getConfWidthNEWS_fn = (INST_MODE == NEWS_INST_ES)   ? 1 :          // for ES mode, we need 1-bits to select from 2 channels
                          (INST_MODE == NEWS_INST_ESW)  ? 2 :          // for ESW mode, we need 2-bits to select from 3 channels
                          (INST_MODE == NEWS_INST_NEWS) ? 2 :          // for NEWS mode, we need 2-bits to select from 4 channels
                          -1;         // Invalid mode
endfunction
