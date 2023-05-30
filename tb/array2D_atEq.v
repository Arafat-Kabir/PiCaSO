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
  This module instantiates a 2D array of Compute_allff for empirical study.

================================================================================*/


/*
Usage:
*/


module array2D_atEq (
    clk,

    // control-signals as global IO (OOC)
    netLevel,       // selects the current tree level
    netDirection,   // selects the network direction
    netConfLoad,    // load network configuration
    netCaptureEn,   // enable network capture registers
   
    aluConfLoad,    // load operation configurations
    aluConf,        // configuration for ALU
    aluEn,          // enable ALU for computation (holds the ALU state if aluEN=0)
    aluReset,       // reset ALU state

    opmuxConfLoad,  // load operation configurations
    opmuxConf,      // configuration for opmux module

    extDataSave,    // save external data into BRAM (uses addrA)
    extDataIn,      // external data input port
    extDataOut,     // external data output port

    saveAluOut,     // save the output of ALU (uses addrB)
    addrA,          // address of operand A
    addrB,          // address of operand B

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
localparam PE_COL_CNT = 16*4,     // it's the number of PEs, not PE-Blocks
           PE_ROW_CNT = 4;

// PE-Block properties
localparam PBLK_DIM_COL = 16,     // PE-columns per PE-block
           PBLK_DIM_ROW = 1;      // PE-rows per PE-block
localparam PBLK_E2W_WIDTH = 1,    // bus-width for East-out to West-in port
           PBLK_W2E_WIDTH = 1,
           PBLK_N2S_WIDTH = 16,   // 1-bit NEWS stream and 15-bit shift stream
           PBLK_S2N_WIDTH = 1;    // South-out port to North-in port (data movement north-to-south)

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


// other PE-Block parameters (copied)
localparam PE_CNT = 16;              // Number of Processing-Elements in each block
localparam RF_DEPTH = 1024;          // Depth of the register-file (usually it's equal to register-widht * register-count)
localparam NET_STREAM_WIDTH = 1;     // Width of the network input/output stream
localparam SHIFT_STREAM_WIDTH = 15;  // width of shift movement stream
localparam MAX_NET_LEVEL = 8;        // how many levels of the binary tree to support
localparam ID_WIDTH  = 8;            // width of the row/colum IDs
localparam NET_LEVEL_WIDTH = 3;      // log2(MAX_NET_LEVEL)
localparam NET_DIR_WIDTH = 1;        // width of "direction"  port of the DataNetNode is 1
localparam ALU_STREAM_WIDTH = PE_CNT;
localparam BOOTHR2_OP_WIDTH = 2;
localparam ALU_CONF_WIDTH   = BOOTHR2_OP_WIDTH+1;    // 1-bit wider than the boothR2_serial_alu op-code
localparam OPMUX_CONF_WIDTH = 3;
localparam REGFILE_RAM_WIDTH  = PE_CNT,
           REGFILE_RAM_DEPTH  = RF_DEPTH,
           REGFILE_ADDR_WIDTH = 10;     // log2(RF_DEPTH)


// IO Ports
input        clk;

input  wire  aluConfLoad;
input  wire  aluEn;
input  wire  aluReset;
input  wire  opmuxConfLoad;
input  wire  extDataSave;
input  wire  saveAluOut;

input  [NET_LEVEL_WIDTH-1:0] netLevel;
input  [NET_DIR_WIDTH-1:0]   netDirection;
input                        netConfLoad;
input                        netCaptureEn;

input  wire  [ALU_CONF_WIDTH-1:0]    aluConf;
input  wire  [OPMUX_CONF_WIDTH-1:0]  opmuxConf;

input  wire  [REGFILE_RAM_WIDTH-1:0]  extDataIn; 

input  wire  [REGFILE_ADDR_WIDTH-1:0] addrA;    
input  wire  [REGFILE_ADDR_WIDTH-1:0] addrB;   

input  [EDGE_WIN_WIDTH-1:0]   westEdgeIn;       // dummy IOs for OOC
output [EDGE_WOUT_WIDTH-1:0]  westEdgeout;
input  [EDGE_EIN_WIDTH-1:0]   eastEdgeIn;
output [EDGE_EOUT_WIDTH-1:0]  eastEdgeOut;
input  [EDGE_NIN_WIDTH-1:0]   northEdgeIn;
output [EDGE_NOUT_WIDTH-1:0]  northEdgeOut;
input  [EDGE_SIN_WIDTH-1:0]   southEdgeIn;
output [EDGE_SOUT_WIDTH-1:0]  southEdgeOut;

// This is done to avoid multi-driver output error
localparam EXTDATA_WIDTH = REGFILE_RAM_WIDTH*PBLK_ROW_CNT*PBLK_COL_CNT,
           EXTDATA_ROW_WIDTH = REGFILE_RAM_WIDTH*PBLK_COL_CNT,    // size of an entire row: used in generate loop later
           EXTDATA_COL_WIDTH = REGFILE_RAM_WIDTH;                  // sieze of a single column within a row
output wire [EXTDATA_WIDTH-1:0]  extDataOut;
wire [REGFILE_RAM_WIDTH-1:0] extDataOut_wire[0:PBLK_ROW_CNT-1][0:PBLK_COL_CNT-1];   // wires to be connected to the PE-blocks


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
        //Compute_allff #(.CB_ROW(gr), .CB_COL(gc))
        Compute_atiyehEq #(.CB_ROW(gr), .CB_COL(gc))
            block (
                .clk(clk),

                // Connect global IOs
                .netLevel(netLevel),     
                .netDirection(netDirection), 
                .netConfLoad(netConfLoad),  
                .netCaptureEn(netCaptureEn), 
                .aluConfLoad(aluConfLoad),  
                .aluConf(aluConf),      
                .aluEn(aluEn),        
                .aluReset(aluReset),     
                .opmuxConfLoad(opmuxConfLoad),
                .opmuxConf(opmuxConf),    
                .extDataSave(extDataSave),  
                .extDataIn(extDataIn),    
                .extDataOut(extDataOut_wire[gr][gc]),   
                .saveAluOut(saveAluOut),   
                .addrA(addrA),        
                .addrB(addrB),         

                //  Connect network IOs (+: wires, PB: PE-Block, (row, col)
                //  +(0,0) PB(0,0) +(0,1) PB(0,1) +(0,2) PB(0,2) +(0,3)
                //  +(1,0) PB(1,0) +(1,1) PB(1,1) +(1,2) PB(1,2) +(1,3)
                //  +(2,0) PB(2,0) +(2,1) PB(2,1) +(2,2) PB(2,2) +(2,3)
                .westIn(e2w_wires[gr][gc]),         // input stream from west
                .westOut(w2e_wires[gr][gc]),        // output stream to west
                .eastIn(w2e_wires[gr][gc+1]),         // input stream from east
                .eastOut(e2w_wires[gr][gc+1]),        // output stream to east

                .northIn(s2n_wires[gr][gc]),        // input stream from north
                .northOut(n2s_wires[gr][gc][0]),    // 0-th bit is the NEWS stream
                .southIn(n2s_wires[gr+1][gc][0]),   // 0-th bit is the NEWS stream
                .southOut(s2n_wires[gr+1][gc]),     // output stream to south

                .shiftIn(n2s_wires[gr+1][gc][1 +: SHIFT_STREAM_WIDTH]),     // shift-in from south
                .shiftOut(n2s_wires[gr][gc] [1 +: SHIFT_STREAM_WIDTH])      // shift-out to north
            );
            // make connection to extDataOut top-level port
            assign extDataOut[ (gr*EXTDATA_ROW_WIDTH + gc*EXTDATA_COL_WIDTH) +: EXTDATA_COL_WIDTH ] = extDataOut_wire[gr][gc];
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
