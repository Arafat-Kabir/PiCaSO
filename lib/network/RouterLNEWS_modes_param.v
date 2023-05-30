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
  Date  : Wed, Dec 21, 03:47 PM CST 2022

  Description:
  Declares the named constans for the modes of the RouterLNEWS module.
  This file should be included where the RouterLNEWS module is used.

================================================================================*/

// Instance selection modes
localparam LNEWS_INST_NONE  = 0,      // Invalid mode
           LNEWS_INST_LE    = 1,      // input channels: Local and East
           LNEWS_INST_LES   = 2,      // input channels: Local, East, and South
           LNEWS_INST_LESW  = 3,      // input channels: Local, East, and South
           LNEWS_INST_LNEWS = 4;      // input channels: All channels


/* Routing configurations: 
*     Rationale:
*       LE    fits in 1-bit, which is the most common connection.
*       LES   fits in 2-bits, which is the second most common connection.
*       LESW  fits in 2-bits, which might be needed for CNNs.
*       LNEWS fits in 3-bits, which the minimum no. of bits needed.
*/
localparam LNEWS_RT_L = 0,      // select local stream
           LNEWS_RT_E = 1,      // select east input stream
           LNEWS_RT_S = 2,      // select south input stream 
           LNEWS_RT_W = 3,      // select west input stream
           LNEWS_RT_N = 5;      // select north input stream


// following constant function computes the width of the routeConf port
function automatic integer getConfWidthLNEWS_fn;
	input integer INST_MODE;
    // compute the configuration width for the given mode
    localparam CONF_WIDTH = (INST_MODE == LNEWS_INST_LE)    ? 1 :          // for LE mode, we need 1-bit to select from 2 channels
                            (INST_MODE == LNEWS_INST_LES)   ? 2 :          // for LES mode, we need 2-bits to select from 3 channels
                            (INST_MODE == LNEWS_INST_LESW)  ? 2 :          // for LES mode, we need 2-bits to select from 4 channels
                            (INST_MODE == LNEWS_INST_LNEWS) ? 3 :          // for NEWS mode, we need 3-bits to select from 5 channels
                            -1;         // Invalid mode
    // return the computed width
    getConfWidthLNEWS_fn = CONF_WIDTH;
endfunction
