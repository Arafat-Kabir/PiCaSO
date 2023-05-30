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
  Date  : Mon, Dec 19, 06:35 PM CST 2022

  Description:
  Control module for the Compute block (Processing Block). Takes in all the
  control signals from the interface, then generates the control signals
  for individual modules of the Compute block. It can have states (reg).

================================================================================*/


/*
Usage: Converts the interface controls to internal module controls.
       For now, I am trying to avoid adding additional logic between
       the FSM signals and the target submodule. This somewhat breaks
       the modularity of the code-base/design. This is okay for
       this specific design because I don't have enough information to
       make the right design choice. 
*/


module ComputeControl #(
// Parameters: These default values are meaningless
    parameter ALU_CONF_WIDTH   = 8,
    parameter OPMUX_CONF_WIDTH = 8,
    parameter NET_LEVEL_WIDTH  = 8,
    parameter NET_DIR_WIDTH    = 8
) (
    clk,

    // ---- Interface signals ----
    netLevel,       // selects the current tree level
    netDirection,   // selects the network direction
    netConfLoad,    // load network configuration
    netCaptureEn,   // enable network capture registers

    aluConfLoad,    // load alu configurations
    aluConf,        // configuration for ALU
    aluEn,          // enable ALU for computation (holds the ALU state if aluEN=0)
    aluReset,       // reset alu state

    opmuxConfLoad,  // load opmux configurations
    opmuxConf,      // configuration for opmux module

    extDataSave,    // save external data into BRAM (uses addrA)
    saveAluOut,     // save the output of ALU (uses addrB)

    // ---- Internal control signals ----
    // alu
    alu_ce,
    alu_opConfig,
    alu_opLoad,
    alu_reset,

    // opmux
    opmux_confSig,
    opmux_confLoad,

    // regfile
    regfile_wea,
    regfile_web,

    // network
    netnode_level,
    netnode_direction,
    netnode_confLoad,
    netnode_captureEn
);




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

output wire  alu_ce;
output wire  alu_opLoad;
output wire  alu_reset;
output wire  opmux_confLoad;
output wire  regfile_wea;
output wire  regfile_web;

output wire  [ALU_CONF_WIDTH-1:0]   alu_opConfig;
output wire  [OPMUX_CONF_WIDTH-1:0] opmux_confSig;

output wire [NET_LEVEL_WIDTH-1:0] netnode_level;
output wire [NET_DIR_WIDTH-1:0]   netnode_direction;
output wire                       netnode_confLoad;
output wire                       netnode_captureEn;



// Controls for alu
assign alu_ce       = aluEn;
assign alu_opConfig = aluConf;
assign alu_opLoad   = aluConfLoad;
assign alu_reset    = aluReset;


// Controls for opmux
assign opmux_confSig  = opmuxConf;
assign opmux_confLoad = opmuxConfLoad;


// Controls for register-file
assign regfile_wea = extDataSave; 
assign regfile_web = saveAluOut;


// Controls for network module
assign netnode_level = netLevel;
assign netnode_direction = netDirection;
assign netnode_confLoad = netConfLoad;
assign netnode_captureEn = netCaptureEn;


endmodule
