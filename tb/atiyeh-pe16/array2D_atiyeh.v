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
  Date  : Fri, Dec 30, 11:09 AM CST 2022

  Description:
  This module instantiates a 2D array of PE16_Block for empirical study.

================================================================================*/


/*
Usage:
*/


module array2D_atiyeh (
    clk,

    // control-signals as global IO (OOC)
    reset,
    alu_op,
    wea,
    web,
    addra,
    addrb,
    DINA,
    DINB,
    DOUTA,
    DOUTB,
    external,
    count,
    state, 
    east,
    west,
    south,
    north,

    // Array edge wires
    westEdgeIn,       // dummy IOs for OOC
    westEdgeout,
    eastEdgeIn,
    eastEdgeOut,
    northEdgeIn,
    northEdgeOut,
    southEdgeIn,
    southEdgeOut
);


// Array Dimensions
localparam PE_COL_CNT = 4*4,     // it's the number of PEs, not PE-Blocks
           PE_ROW_CNT = 4*4;

// PE-Block properties
localparam PBLK_DIM_COL = 4,      // PE-columns per PE-block
           PBLK_DIM_ROW = 4;      // PE-rows per PE-block
localparam PBLK_E2W_WIDTH = 8,    // bus-width for East-out to West-in port
           PBLK_W2E_WIDTH = 8,
           PBLK_N2S_WIDTH = 8,
           PBLK_S2N_WIDTH = 8;

// Deriving PE-Block array parameters
localparam PBLK_ROW_CNT = PE_ROW_CNT/PBLK_DIM_ROW,     // number of PE-block rows
           PBLK_COL_CNT = PE_COL_CNT/PBLK_DIM_COL;     // number of PE-block columsn
localparam EDGE_WIN_WIDTH  = PBLK_ROW_CNT * PBLK_E2W_WIDTH,
           EDGE_WOUT_WIDTH = PBLK_ROW_CNT * PBLK_W2E_WIDTH;
localparam EDGE_EIN_WIDTH  = PBLK_ROW_CNT * PBLK_W2E_WIDTH,
           EDGE_EOUT_WIDTH = PBLK_ROW_CNT * PBLK_E2W_WIDTH;
localparam EDGE_NIN_WIDTH  = PBLK_COL_CNT * PBLK_S2N_WIDTH,
           EDGE_NOUT_WIDTH = PBLK_COL_CNT * PBLK_N2S_WIDTH;
localparam EDGE_SIN_WIDTH  = PBLK_COL_CNT * PBLK_N2S_WIDTH,
           EDGE_SOUT_WIDTH = PBLK_COL_CNT * PBLK_S2N_WIDTH;


// IO Ports
input         clk;

input         reset;
input  [3:0]  alu_op;
input         wea;
input         web;
input  [9:0]  addra;
input  [9:0]  addrb;
input  [15:0] DINA;
input  [15:0] DINB;
input         external;
input  [7:0]  count;
input  [2:0]  state;
input         east;
input         west;
input         south;
input         north;

input  [EDGE_WIN_WIDTH-1:0]   westEdgeIn;       // dummy IOs for OOC
output [EDGE_WOUT_WIDTH-1:0]  westEdgeout;
input  [EDGE_EIN_WIDTH-1:0]   eastEdgeIn;
output [EDGE_EOUT_WIDTH-1:0]  eastEdgeOut;
input  [EDGE_NIN_WIDTH-1:0]   northEdgeIn;
output [EDGE_NOUT_WIDTH-1:0]  northEdgeOut;
input  [EDGE_SIN_WIDTH-1:0]   southEdgeIn;
output [EDGE_SOUT_WIDTH-1:0]  southEdgeOut;

// This is done to avoid multi-driver output error
localparam PBLK_DOUT_WIDTH = 16,       // DOUT of each PE-Block
           TOP_DOUT_WIDTH = PBLK_DOUT_WIDTH*PBLK_ROW_CNT*PBLK_COL_CNT,
           TOP_DOUT_ROW_WIDTH = PBLK_DOUT_WIDTH*PBLK_COL_CNT,  // size of an entire row: used in generate loop later
           TOP_DOUT_COL_WIDTH = PBLK_DOUT_WIDTH;               // size of a single column within a row

output [TOP_DOUT_WIDTH-1:0] DOUTA;
output [TOP_DOUT_WIDTH-1:0] DOUTB;
wire   [PBLK_DOUT_WIDTH-1:0]    DOUTA_wire[0:PBLK_ROW_CNT-1][0:PBLK_COL_CNT-1];   // wires to be connected to the PE-blocks
wire   [PBLK_DOUT_WIDTH-1:0]    DOUTB_wire[0:PBLK_ROW_CNT-1][0:PBLK_COL_CNT-1];   // wires to be connected to the PE-blocks


/* These are network connections
//move data
input[7:0] Ein,
input[7:0] Win,
input[7:0] Nin,
input[7:0] Sin,
output[7:0] Eout,
output[7:0] Wout,
output[7:0] Nout,
output[7:0] Sout
*/
// array of wires for inter-PE-Block connections
wire [PBLK_E2W_WIDTH-1:0]  e2w_wires[0:PBLK_ROW_CNT][0:PBLK_COL_CNT];   // connects East-out port to the West-in port of the next PE-block  (data moves in west-to-east direction)
wire [PBLK_W2E_WIDTH-1:0]  w2e_wires[0:PBLK_ROW_CNT][0:PBLK_COL_CNT];   // connects West-out port to the East-in port of the next PE-block 
wire [PBLK_N2S_WIDTH-1:0]  n2s_wires[0:PBLK_ROW_CNT][0:PBLK_COL_CNT];   // North-out -> South-in
wire [PBLK_S2N_WIDTH-1:0]  s2n_wires[0:PBLK_ROW_CNT][0:PBLK_COL_CNT];   // South-out -> North-in


generate
genvar gr,gc;

// instantiate the array PE-Blocks
for(gr=0; gr < PBLK_ROW_CNT; gr = gr+1) begin: row
    for(gc=0; gc < PBLK_COL_CNT; gc = gc+1) begin: col
        PE16_Block block (
            .clk(clk),

            // Connect global IOs
            .reset(reset),
            .alu_op(alu_op),
            .wea(wea),
            .web(web),
            .addra(addra),
            .addrb(addrb),
            .DINA(DINA),
            .DINB(DINB),
            .DOUTA(DOUTA_wire[gr][gc]),
            .DOUTB(DOUTB_wire[gr][gc]),
            .external(external),
            .count(count),
            .state(state),
            .east(east),
            .west(west),
            .south(south),
            .north(north),

            //  Connect network IOs (+: wires, PB: PE-Block, (row, col)
            //  +(0,0) PB(0,0) +(0,1) PB(0,1) +(0,2) PB(0,2) +(0,3)
            //  +(1,0) PB(1,0) +(1,1) PB(1,1) +(1,2) PB(1,2) +(1,3)
            //  +(2,0) PB(2,0) +(2,1) PB(2,1) +(2,2) PB(2,2) +(2,3)
            .Win(e2w_wires[gr][gc]),     // East-out of the left-blcok, West-in of this  
            .Wout(w2e_wires[gr][gc]),  
            .Ein(w2e_wires[gr][gc+1]), 
            .Eout(e2w_wires[gr][gc+1]),  // East-out of this, West-in of right

            .Nin(s2n_wires[gr][gc]),     // North-in of this, South-out of upper 
            .Nout(n2s_wires[gr][gc]), 
            .Sin(n2s_wires[gr+1][gc]), 
            .Sout(s2n_wires[gr+1][gc])   // South-out of this, north-in of below 
        );
        // make connection to top-level DOUT ports
        assign DOUTA[ (gr*TOP_DOUT_ROW_WIDTH + gc*TOP_DOUT_COL_WIDTH) +: TOP_DOUT_COL_WIDTH ] = DOUTA_wire[gr][gc];
        assign DOUTB[ (gr*TOP_DOUT_ROW_WIDTH + gc*TOP_DOUT_COL_WIDTH) +: TOP_DOUT_COL_WIDTH ] = DOUTB_wire[gr][gc];
    end     // col
end     // row


// Connect edge wires
for(gr=0; gr < PBLK_ROW_CNT; gr = gr+1) begin: westEdge
    assign westEdgeout[gr*PBLK_W2E_WIDTH +: PBLK_W2E_WIDTH] = w2e_wires[gr][0];  // Wout of the first column 
    assign e2w_wires[gr][0] = westEdgeIn[gr*PBLK_E2W_WIDTH +: PBLK_E2W_WIDTH];   // Win of the first column
end

for(gr=0; gr < PBLK_ROW_CNT; gr = gr+1) begin: eastEdge
    assign eastEdgeOut[gr*PBLK_E2W_WIDTH +: PBLK_E2W_WIDTH] = e2w_wires[gr][PBLK_COL_CNT];  // Eout of the last column 
    assign w2e_wires[gr][PBLK_COL_CNT] = eastEdgeIn[gr*PBLK_W2E_WIDTH +: PBLK_W2E_WIDTH];   // Ein of the last column
end

for(gc=0; gc < PBLK_COL_CNT; gc = gc+1) begin: northEdge
    assign s2n_wires[0][gc] = northEdgeIn[gc*PBLK_S2N_WIDTH +: PBLK_S2N_WIDTH];     // South-out --> North-in
    assign northEdgeOut[gc*PBLK_N2S_WIDTH +: PBLK_N2S_WIDTH] = n2s_wires[0][gc];    // North-out --> South-in
end

for(gc=0; gc < PBLK_COL_CNT; gc = gc+1) begin: southEdge
    assign southEdgeOut[gc*PBLK_S2N_WIDTH +: PBLK_S2N_WIDTH] = s2n_wires[PBLK_ROW_CNT][gc];     // South-out --> North-in
    assign n2s_wires[PBLK_ROW_CNT][gc] = southEdgeIn[gc*PBLK_N2S_WIDTH +: PBLK_N2S_WIDTH];      // North-out --> South-in
end


endgenerate


endmodule
