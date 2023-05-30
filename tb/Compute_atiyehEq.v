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
  Date  : Tue, Dec 27, 04:59 PM CST 2022

  Description: 
  This version is equivalent of Atiyeh's implementation.

================================================================================*/


/*
Usage: 
    This is equivalent of Atiyeh's PE-16 because,
      - Supports all operations (MLP, CNN, LSTM)
      - No pipeline between RF->ALU->RF path
      - BRAM in write-first mode without and output-FF
*/


module Compute_atiyehEq #(
// Parameters
    parameter CB_ROW = 7,               // row-ID of the compute block (processing block)
    parameter CB_COL = 8,               // colum-ID of the compute block (processing block)
    parameter PE_CNT = 16,              // Number of Processing-Elements in each block
    parameter RF_DEPTH = 1024,          // Depth of the register-file (usually it's equal to register-widht * register-count)
    parameter NET_STREAM_WIDTH = 1,     // Width of the network input/output stream
    parameter SHIFT_STREAM_WIDTH = 15,  // width of shift movement stream
    parameter MAX_NET_LEVEL = 8,        // how many levels of the binary tree to support
    parameter ID_WIDTH  = 8             // width of the row/colum IDs
) (
    clk,

    netLevel,       // selects the current tree level
    netDirection,   // selects the network direction
    netConfLoad,    // load network configuration
    netCaptureEn,   // enable network capture registers
   
    northIn,        // input stream from north
    northOut,       // output stream to north
    eastIn,         // input stream from east
    eastOut,        // output stream to east
    westIn,         // input stream from west
    westOut,        // output stream to west
    southIn,        // input stream from south
    southOut,       // output stream to south
    shiftIn,        // shift input channel
    shiftOut,       // shift output channel

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
    addrB           // address of operand B
);


// Local parameter declarations for IO ports and submodules
`include "alu/boothR2_alu_param.v"      // defines BOOTHR2_OP_WIDTH
`include "regfile/clogb2_func.v"
`include "opmux/opmux_confs_param.v"    // defines OPMUX_CONF_WIDTH

localparam ALU_STREAM_WIDTH = PE_CNT,
           ALU_CONF_WIDTH   = BOOTHR2_OP_WIDTH+1;    // 1-bit wider than the boothR2_serial_alu op-code

localparam REGFILE_RAM_WIDTH  = PE_CNT,
           REGFILE_RAM_DEPTH  = RF_DEPTH,
           REGFILE_ADDR_WIDTH = clogb2(REGFILE_RAM_DEPTH-1);

localparam NET_LEVEL_WIDTH = clogb2(MAX_NET_LEVEL-1),   // compute the no. of bits needed to represent all levels
           NET_DIR_WIDTH = 1;       // width of "direction"  port of the DataNetNode is 1


// IO ports
input  wire  clk; 
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
output wire  [REGFILE_RAM_WIDTH-1:0]  extDataOut;

input  wire  [REGFILE_ADDR_WIDTH-1:0] addrA;    
input  wire  [REGFILE_ADDR_WIDTH-1:0] addrB;   

input  wire  [NET_STREAM_WIDTH-1:0]   northIn;
output wire  [NET_STREAM_WIDTH-1:0]   northOut;
input  wire  [NET_STREAM_WIDTH-1:0]   eastIn;
output wire  [NET_STREAM_WIDTH-1:0]   eastOut;
input  wire  [NET_STREAM_WIDTH-1:0]   westIn;
output wire  [NET_STREAM_WIDTH-1:0]   westOut;
input  wire  [NET_STREAM_WIDTH-1:0]   southIn;
output wire  [NET_STREAM_WIDTH-1:0]   southOut;
input  wire  [SHIFT_STREAM_WIDTH-1:0] shiftIn;
output wire  [SHIFT_STREAM_WIDTH-1:0] shiftOut;




// Register-File
wire                             regfile_wea, regfile_web;
wire  [REGFILE_ADDR_WIDTH-1:0]   regfile_addra, regfile_addrb;
wire  [REGFILE_RAM_WIDTH-1 :0]   regfile_dia, regfile_dib;
wire  [REGFILE_RAM_WIDTH-1 :0]   regfile_doa, regfile_dob;

bram_wrfirst_noff #(.RAM_WIDTH(REGFILE_RAM_WIDTH), .RAM_DEPTH(REGFILE_RAM_DEPTH))  
    regfile (
        .clk(clk),
        .wea(regfile_wea),
        .web(regfile_web),
        .addra(regfile_addra),
        .addrb(regfile_addrb),
        .dia(regfile_dia),
        .dib(regfile_dib),
        .doa(regfile_doa),
        .dob(regfile_dob)
    );




// Bit-Serial ALU
wire [ALU_STREAM_WIDTH-1:0]  alu_x_streams;
wire [ALU_STREAM_WIDTH-1:0]  alu_y_streams;
wire                         alu_ce;
wire [ALU_CONF_WIDTH-1:0]    alu_opConfig;
wire                         alu_opLoad;
wire                         alu_reset;
wire [ALU_STREAM_WIDTH-1:0]  alu_out_streams;

alu_serial  #(.STREAM_WIDTH(ALU_STREAM_WIDTH))
            ALU(
                .clk(clk),
                .x_streams(alu_x_streams),
                .y_streams(alu_y_streams),
                .ce_alu(alu_ce),
                .opConfig(alu_opConfig),
                .opLoad(alu_opLoad),
                .reset(alu_reset),
                .out_streams(alu_out_streams)
            );




// Operand-Multiplexer
wire  [REGFILE_RAM_WIDTH-1:0]   opmux_rf_portA;
wire  [REGFILE_RAM_WIDTH-1:0]   opmux_rf_portB;
wire  [NET_STREAM_WIDTH-1:0]    opmux_net_stream;    
wire  [OPMUX_CONF_WIDTH-1:0]    opmux_confSig;      
wire                            opmux_confLoad;
wire  [ALU_STREAM_WIDTH-1:0]    opmux_opnX;
wire  [ALU_STREAM_WIDTH-1:0]    opmux_opnY;

opmux_behav #(.RF_STREAM_WIDTH(REGFILE_RAM_WIDTH), .NET_STREAM_WIDTH(NET_STREAM_WIDTH)) 
	operandMux (
		.clk(clk),        
		.rf_portA(opmux_rf_portA),   
		.rf_portB(opmux_rf_portB),   
		.net_stream(opmux_net_stream), 
		.confSig(opmux_confSig),    
		.confLoad(opmux_confLoad),   
		.opnX(opmux_opnX),       
		.opnY(opmux_opnY)        
	);




// Network module
wire [NET_STREAM_WIDTH-1:0]   netnode_localIn;
wire [NET_STREAM_WIDTH-1:0]   netnode_captureOut;
wire [NET_STREAM_WIDTH-1:0]   netnode_northIn;
wire [NET_STREAM_WIDTH-1:0]   netnode_northOut;
wire [NET_STREAM_WIDTH-1:0]   netnode_eastIn;
wire [NET_STREAM_WIDTH-1:0]   netnode_eastOut;
wire [NET_STREAM_WIDTH-1:0]   netnode_westIn;
wire [NET_STREAM_WIDTH-1:0]   netnode_westOut;
wire [NET_STREAM_WIDTH-1:0]   netnode_southIn;
wire [NET_STREAM_WIDTH-1:0]   netnode_southOut;
wire [SHIFT_STREAM_WIDTH-1:0] netnode_shiftIn;
wire [SHIFT_STREAM_WIDTH-1:0] netnode_shiftOut;

wire [NET_LEVEL_WIDTH-1:0] netnode_level;
wire [NET_DIR_WIDTH-1:0]   netnode_direction;
wire                       netnode_confLoad;
wire                       netnode_captureEn;


DataNetNode #(  .NEWS_STREAM_WIDTH(NET_STREAM_WIDTH),  
                .SHIFT_STREAM_WIDTH(SHIFT_STREAM_WIDTH), 
                .MAX_LEVEL(MAX_NET_LEVEL),     
                .ID_WIDTH(ID_WIDTH),  
                .ROW_ID(CB_ROW),  
                .COL_ID(CB_COL)  ) 
    netnode (
        .clk(clk),

        .localIn(netnode_localIn),    
        .captureOut(netnode_captureOut), 
        .northIn(netnode_northIn),    
        .northOut(netnode_northOut),   
        .eastIn(netnode_eastIn),     
        .eastOut(netnode_eastOut),    
        .westIn(netnode_westIn),     
        .westOut(netnode_westOut),    
        .southIn(netnode_southIn),    
        .southOut(netnode_southOut),   
        .shiftIn(netnode_shiftIn),    
        .shiftOut(netnode_shiftOut),   

        .level(netnode_level),      
        .direction(netnode_direction),  
        .confLoad(netnode_confLoad),   
        .captureEn(netnode_captureEn)   
);




// Control Module
ComputeControl #( .ALU_CONF_WIDTH(ALU_CONF_WIDTH), 
                  .OPMUX_CONF_WIDTH(OPMUX_CONF_WIDTH),
                  .NET_LEVEL_WIDTH(NET_LEVEL_WIDTH),
                  .NET_DIR_WIDTH(NET_DIR_WIDTH)
              ) 
    controller (
        .clk(clk),

        // ---- Interface signals ----
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
        .saveAluOut(saveAluOut),


        // ---- Internal control signals ----
        // alu
        .alu_ce(alu_ce),
        .alu_opConfig(alu_opConfig),
        .alu_opLoad(alu_opLoad),
        .alu_reset(alu_reset),

        // opmux
        .opmux_confSig(opmux_confSig),
        .opmux_confLoad(opmux_confLoad),

        // regfile
        .regfile_wea(regfile_wea),
        .regfile_web(regfile_web),

        // network
        .netnode_level(netnode_level),
        .netnode_direction(netnode_direction),
        .netnode_confLoad(netnode_confLoad),
        .netnode_captureEn(netnode_captureEn)
    );



// Local Interconnect
ComputeInterconnect #( .REGFILE_RAM_WIDTH(REGFILE_RAM_WIDTH), 
                       .REGFILE_ADDR_WIDTH(REGFILE_ADDR_WIDTH),
                       .ALU_STREAM_WIDTH(ALU_STREAM_WIDTH),  
                       .NET_STREAM_WIDTH(NET_STREAM_WIDTH),
                       .SHIFT_STREAM_WIDTH(SHIFT_STREAM_WIDTH)    )
    interconnect (
        .clk(clk),

        // ---- Interface signals ----
        .extDataIn(extDataIn),
        .extDataOut(extDataOut),

        .addrA(addrA),
        .addrB(addrB),

        .northIn(northIn),     
        .northOut(northOut),    
        .eastIn(eastIn),      
        .eastOut(eastOut),     
        .westIn(westIn),      
        .westOut(westOut),     
        .southIn(southIn),     
        .southOut(southOut),    
        .shiftIn(shiftIn),     
        .shiftOut(shiftOut),    

        // ---- Internal signals ----
        // alu
        .alu_x_streams(alu_x_streams),
        .alu_y_streams(alu_y_streams),
        .alu_out_streams(alu_out_streams),

        // opmux
        .opmux_rf_portA(opmux_rf_portA),
        .opmux_rf_portB(opmux_rf_portB),
        .opmux_net_stream(opmux_net_stream),
        .opmux_opnX(opmux_opnX),
        .opmux_opnY(opmux_opnY),

        // regfile
        .regfile_addra(regfile_addra),
        .regfile_addrb(regfile_addrb),
        .regfile_dia(regfile_dia),
        .regfile_dib(regfile_dib),
        .regfile_doa(regfile_doa),
        .regfile_dob(regfile_dob),

        // network
        .netnode_localIn(netnode_localIn),    
        .netnode_captureOut(netnode_captureOut), 
        .netnode_northIn(netnode_northIn),    
        .netnode_northOut(netnode_northOut),   
        .netnode_eastIn(netnode_eastIn),     
        .netnode_eastOut(netnode_eastOut),    
        .netnode_westIn(netnode_westIn),     
        .netnode_westOut(netnode_westOut),    
        .netnode_southIn(netnode_southIn),    
        .netnode_southOut(netnode_southOut),   
        .netnode_shiftIn(netnode_shiftIn),    
        .netnode_shiftOut(netnode_shiftOut)   
    );



`include "regfile/undef_clogb2_func.v"
endmodule
