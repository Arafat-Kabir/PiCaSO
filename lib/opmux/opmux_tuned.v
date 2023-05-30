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
  Date  : Tue, Dec 13, 05:45 PM CST 2022

  Description:
  This module sets the operands for the alu-array based on the given 
  configuration. The operands are selected from the different streams like
  Register-File, the data-network, etc. within the compute block.

================================================================================*/


/*
Usage:
    This version is a fine-tuned implemented using several modules.
    
    rf_portA     : Connect port-A of the register-file
    rf_portB     : Connect port-B of the register-file
    net_stream   : Connect data stream coming from the network module
    confSig      : Connect operand-selection configuration signals from FSM
    confLoad     : Connect clock-enable coming from FSM
    opnX         : Connect operand-X of ALU
    opnY         : Connect operand-Y of the ALU
*/


module opmux_tuned #(
// Parameters
    parameter RF_STREAM_WIDTH = 16,
    parameter NET_STREAM_WIDTH = 1
) (
    clk,            // clock
    rf_portA,       // Port-A of the register-file
    rf_portB,       // Port-B of the register-file
    net_stream,     // data stream coming from the network module
    confSig,        // operand-selection configuration signals
    confLoad,       // clock-enable for configuration register

    opnX,            // Operand-X output
    opnY             // Operand-Y output
);


`include "opmux_confs_param.v"

localparam OPN_WIDTH = RF_STREAM_WIDTH;      // operand width
localparam [OPN_WIDTH-1:0] ZEROS = 0;		 // a combination of all-zeros


// IO Ports
input                           clk;
input   [RF_STREAM_WIDTH-1:0]   rf_portA;
input   [RF_STREAM_WIDTH-1:0]   rf_portB;
input   [NET_STREAM_WIDTH-1:0]  net_stream;    // for bit-serial, this will probably always be 1-bit
input   [OPMUX_CONF_WIDTH-1:0]  confSig;       // OPMUX_CONF_WIDTH defined in the include file
input                           confLoad;
output  [OPN_WIDTH-1:0]         opnX;
output  [OPN_WIDTH-1:0]         opnY;


// Internal signals
(* extract_enable = "yes" *)
reg  [OPMUX_CONF_WIDTH-1:0]  conf_reg = 0;     // default reset value; no explicit reset


// Load configuration to the conf_reg register when requested
always @(posedge clk) begin
    if(confLoad)                // update value only if confLoad set
        conf_reg <= confSig;    // load the requested configruation 
    else
        conf_reg <= conf_reg;   // if confLoad not set, hold the current value
end




/* Operand-X Muxing structure
*  The bus_muxp module is the best choice for 2-to-1 muxing.
*  Behavior:
*    select=0: X = 0
*    select=1: X = A
*/
localparam CNT_X_OPTION = 2,            // There are only 2 options for operand-X
           X_ALL_WIDTH = CNT_X_OPTION*OPN_WIDTH;
wire bus_sel_X;                         // Mux selection bit, handled by the decoder
wire [X_ALL_WIDTH-1:0] bus_all_X = {rf_portA, ZEROS};     // Concatenation of all channels (in-order)
bus_muxp #(.BUS_WIDTH(OPN_WIDTH), .BUS_CNT(CNT_X_OPTION)) 
        busmux_X(
            .bus_all(bus_all_X),
            .select(bus_sel_X),
            .bus_out(opnX)
        );

// bus_sel_X = 0, if 0-op-B requested. Otherwise, bus_sel_X = 1
assign bus_sel_X = (conf_reg == OPMUX_0_OP_B) ? 0 : 1;     // Operand-X selection bit decoder




/******** Operand-Y muxing structures ********/

// Different sub-sizes of the operand widths
localparam HALF    = OPN_WIDTH/2,
           QUART   = OPN_WIDTH/4,
           HQUART  = OPN_WIDTH/8,     // Half-Quarter
           HHQUART = OPN_WIDTH/16;    // Half-Quarter/2



/* Operand-Y[upper-half] muxing structure
*  Behavior:
*    select=0: Y[upper-half] = 0
*    select=1: Y[upper-half] = B[upper-half]
*/
localparam CNT_Y_UH = 2,      // There are only 2 options for operand-Y[upper-half]
           Y_UH_ALL_WIDTH = CNT_Y_UH*HALF;
wire bus_sel_Y_UH;            // Mux selection bit (handled by the decoder)

// Concatenation of all channels (in-order)
wire [Y_UH_ALL_WIDTH-1:0] bus_all_Y_UH = {
    rf_portB[HALF +: HALF], 
    ZEROS[HALF-1:0]
}; 

bus_muxp #(.BUS_WIDTH(HALF), .BUS_CNT(CNT_Y_UH))       // bus_muxp is the best choice for 2-to-1 muxing
        busmux_Y_UH(
            .bus_all(bus_all_Y_UH),
            .select(bus_sel_Y_UH),
            .bus_out(opnY[HALF +: HALF])    // connecting Operand-Y[upper-half]
        );

// bus_sel_Y_UH = 1, if A-op-B or 0-op-B requested. Otherwise, bus_sel_Y_UH = 0
assign bus_sel_Y_UH = (conf_reg == OPMUX_A_OP_B || conf_reg == OPMUX_0_OP_B) ? 1 : 0;     // Operand-X selection bit decoder



/* Operand-Y[fold-1,2 bits] muxing structure
*  Behavior:
*    select=0: Y[fold-1,2 bits] = 0
*    select=1: Y[fold-1,2 bits] = B[i]
*    select=2: Y[fold-1,2 bits] = A[fold-1 bits]
*    select=3: Y[fold-1,2 bits] = A[fold-2 bits]
*/
localparam Y_F12_START = HQUART,        // Fold-1,2 affects 2nd,3rd, and 
           Y_F12_WIDTH = HQUART*3;      // 4th half-quarters of Operand-Y
localparam CNT_Y_F12 = 4,               // There are 4 options for operand-Y[fold-1,2 bits]
           Y_F12_ALL_WIDTH = CNT_Y_F12*Y_F12_WIDTH;
wire [1:0] bus_sel_Y_F12;               // Mux selection bit (handled by the decoder)

// Concatenation of all channels (in-order)
wire [Y_F12_ALL_WIDTH-1:0]  bus_all_Y_F12 = {
    {ZEROS[QUART +: QUART], rf_portA[QUART + Y_F12_START +: HQUART]}, // {0, A[lower-half of 2nd quarter]}
    rf_portA[HALF + Y_F12_START +: Y_F12_WIDTH],    // corresponding bits of A[upper-half]
    rf_portB[Y_F12_START +: Y_F12_WIDTH], 
    ZEROS[Y_F12_WIDTH-1:0]
}; 

bus_mux #(.BUS_WIDTH(Y_F12_WIDTH), .BUS_CNT(CNT_Y_F12)) 
        busmux_Y_F12(
            .bus_all(bus_all_Y_F12),
            .select(bus_sel_Y_F12),
            .bus_out(opnY[Y_F12_START +: Y_F12_WIDTH])    // connecting Operand-Y[fold-1,2 affected bits]
        );

// Y_F12 decoder
function automatic [1:0] decoder_Y_F12;
    input [OPMUX_CONF_WIDTH-1:0]  confSig;

    // Named constants
    localparam  SEL_ZERO = 0,
                SEL_B    = 1,
                SEL_F1   = 2,   // Fold-1 bits
                SEL_F2   = 3;   // Fold-2 bits

    // Decoding logic
    (* full_case, parallel_case *)
    case (confSig)
        OPMUX_A_OP_B   : decoder_Y_F12 = SEL_B;
        OPMUX_A_FOLD_1 : decoder_Y_F12 = SEL_F1;
        OPMUX_A_FOLD_2 : decoder_Y_F12 = SEL_F2;
        OPMUX_0_OP_B   : decoder_Y_F12 = SEL_B; 
        default		   : decoder_Y_F12 = SEL_ZERO; 
    endcase
endfunction

assign bus_sel_Y_F12 = decoder_Y_F12(conf_reg);



/* Operand-Y[lower-half quarter] muxing structure
*  These bits are affected by all folds, as well as, have special cases
*  Behavior:
*    select=0: Y[lhq] = B[lhq]
*    select=1: Y[lhq] = A[half + lhq]        ; Fold-1
*    select=2: Y[lhq] = A[2nd quart + lhq]   ; Fold-2
*    select=3: Y[lhq] = A[2nd lhq]           ; Fold-3
*    select=4: Y[lhq] = {0, A[2nd lhhq]}     ; Fold-4 (2nd lower half-half-quarter)
*    select=5: Y[lhq] = {0, net}
*    select=6: Y[lhq] = B[lhq]
*/
localparam CNT_Y_LHQ = 7,     // There are 7 options for operand-Y[lower-half quarter]
           Y_LHQ_ALL_WIDTH = CNT_Y_LHQ*HQUART;
wire [OPMUX_CONF_WIDTH-1:0] bus_sel_Y_LHQ;       // Mux selection bit (handled by the decoder)

// Concatenation of all channels (in-order)
wire [Y_LHQ_ALL_WIDTH-1:0]  bus_all_Y_LHQ = {
    rf_portB[0 +: HQUART], 
    { ZEROS[HQUART-1:NET_STREAM_WIDTH], net_stream },
    { ZEROS[0 +: HQUART/2], rf_portA[HHQUART +: HHQUART] },     // zero-padded Fold-4

    rf_portA[HQUART +: HQUART],     // Fold-3
    rf_portA[QUART  +: HQUART],     // Fold-2
    rf_portA[HALF   +: HQUART],     // Fold-1
    rf_portB[0 +: HQUART]
}; 

bus_mux #(.BUS_WIDTH(HQUART), .BUS_CNT(CNT_Y_LHQ)) 
        busmux_Y_LHQ(
            .bus_all(bus_all_Y_LHQ),
            .select(bus_sel_Y_LHQ),
            .bus_out(opnY[0 +: HQUART])    // connecting Operand-Y[lower half-quarter]
        );

// conf_reg directly maps to selection of Y_LHQ
assign bus_sel_Y_LHQ = conf_reg;


endmodule
