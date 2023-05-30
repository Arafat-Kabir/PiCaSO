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
  Date  : Tue, Dec 13, 05:42 PM CST 2022

  Description:
  This module sets the operands for the alu-array based on the given 
  configuration. The operands are selected from the different streams like
  Register-File, the data-network, etc. within the compute block.

================================================================================*/


/*
Usage:
    This version is implemented using bus_mux module.
    
    rf_portA     : Connect port-A of the register-file
    rf_portB     : Connect port-B of the register-file
    net_stream   : Connect data stream coming from the network module
    confSig      : Connect operand-selection configuration signals from FSM
    confLoad     : Connect clock-enable coming from FSM
    opnX         : Connect operand-X of ALU
    opnY         : Connect operand-Y of the ALU
*/


module opmux_bus #(
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
*  Behavior:
*    select=0: X = 0
*    select=1: X = A
*/
localparam CNT_X_OPTION = 2,            // There are only 2 options for operand-X
           X_ALL_WIDTH = CNT_X_OPTION*OPN_WIDTH;
wire bus_sel_X;                         // Mux selection bit
wire [X_ALL_WIDTH-1:0] bus_all_X = {rf_portA, ZEROS};     // Concatenation of all channels (in-order)
bus_mux #(.BUS_WIDTH(OPN_WIDTH), .BUS_CNT(CNT_X_OPTION)) 
        busmux_X(
            .bus_all(bus_all_X),
            .select(bus_sel_X),
            .bus_out(opnX)
        );

// bus_sel_X = 0, if 0-op-B requested. Otherwise, bus_sel_X = 1
assign bus_sel_X = (conf_reg == OPMUX_0_OP_B) ? 0 : 1;     // Operand-X selection bit decoder




/* Operand-Y Muxing structure
*  Behavior:
*    select=0: Y = B
*    select=1: Y = Fold-1 of A
*    select=2: Y = Fold-2 of A
*    select=3: Y = Fold-3 of A
*    select=4: Y = Fold-4 of A
*    select=5: Y = Network data
*    select=6: Y = B
*/
// Different sub-sizes of the operand widths
localparam HALF    = OPN_WIDTH/2,
           QUART   = OPN_WIDTH/4,
           HQUART  = OPN_WIDTH/8,     // Half-Quarter
           HHQUART = OPN_WIDTH/16;    // Half-Quarter/2

// Muxing combinations
wire [OPN_WIDTH-1:0] foldA_1  = {ZEROS[HALF +: HALF],         rf_portA[HALF +: HALF]};        // Y[lower-half] = A[upper-half],     Y[remain] = 0
wire [OPN_WIDTH-1:0] foldA_2  = {ZEROS[QUART +: QUART*3],     rf_portA[QUART +: QUART]};      // Y[lower-quarter] = A[2nd-quarter], Y[remain] = 0
wire [OPN_WIDTH-1:0] foldA_3  = {ZEROS[HQUART +: HQUART*7],   rf_portA[HQUART +: HQUART]};    // Y[lq/2] = A[lq/2u],                Y[remain] = 0
wire [OPN_WIDTH-1:0] foldA_4  = {ZEROS[HHQUART +: HHQUART*15], rf_portA[HHQUART +: HHQUART]};  // Y[lq/4] = A[lq/4u],                Y[remain] = 0
wire [OPN_WIDTH-1:0] net_comb = {ZEROS[OPN_WIDTH-1:NET_STREAM_WIDTH], net_stream};            // Y[lower-bits] = net,               Y[upper-bits] = 0

// Concatenation of all channels (in-order)
localparam CNT_Y_OPTION = 7,            // There are 7 options for operand-Y
           Y_ALL_WIDTH  = CNT_Y_OPTION*OPN_WIDTH;    
wire [Y_ALL_WIDTH-1:0] bus_all_Y = {
    rf_portB,
    net_comb,
    foldA_4,
    foldA_3,
    foldA_2,
    foldA_1,
    rf_portB
};

wire [OPMUX_CONF_WIDTH-1:0] bus_sel_Y;  // Mux selection bits
bus_mux #(.BUS_WIDTH(OPN_WIDTH), .BUS_CNT(CNT_Y_OPTION)) 
        busmux_Y(
            .bus_all(bus_all_Y),
            .select(bus_sel_Y),
            .bus_out(opnY)
        );

// conf_reg directly maps to selection of operand-Y
assign bus_sel_Y = conf_reg;


endmodule
