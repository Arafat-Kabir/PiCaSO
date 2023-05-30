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
  Date  : Mon, Dec 19, 06:44 PM CST 2022

  Description:
  Local interconnect of the Compute block (Processing Block).
  It connects every module to every other module.

================================================================================*/


/*
Usage: <Change it>
    clk         : clock
    x_streams   : Connect operand-1 streams
    y_streams   : Connect operand-2 streams
*/


module ComputeInterconnect #(
// Parameters: These default values are meaningless
    parameter REGFILE_RAM_WIDTH  = 8,
    parameter REGFILE_ADDR_WIDTH = 8,
    parameter ALU_STREAM_WIDTH   = 8,
    parameter NET_STREAM_WIDTH   = 8,
    parameter SHIFT_STREAM_WIDTH = 8
) (
    clk,

    // ---- Interface signals ----
    extDataIn,     // external data input
    extDataOut,    // external data output

    addrA,         // address of operand A
    addrB,         // address of operand B

    northIn,       // input stream from north
    northOut,      // output stream to north
    eastIn,        // input stream from east
    eastOut,       // output stream to east
    westIn,        // input stream from west
    westOut,       // output stream to west
    southIn,       // input stream from south
    southOut,      // output stream to south
    shiftIn,       // shift input channel
    shiftOut,      // shift output channel


    // ---- Internal signals ----
    // alu
    alu_x_streams,
    alu_y_streams,
    alu_out_streams,

    // opmux
    opmux_rf_portA,
    opmux_rf_portB,
    opmux_net_stream,
    opmux_opnX,
    opmux_opnY,

    // regfile
    regfile_addra,
    regfile_addrb, 
    regfile_dia, 
    regfile_dib, 
    regfile_doa, 
    regfile_dob,

    // network
    netnode_localIn,
    netnode_captureOut,
    netnode_northIn,
    netnode_northOut,
    netnode_eastIn,
    netnode_eastOut,
    netnode_westIn,
    netnode_westOut,
    netnode_southIn,
    netnode_southOut,
    netnode_shiftIn,
    netnode_shiftOut
);


/* IO Ports: 
*     Port directions of submodules are reversed because local interconnect
*     reads all of the outputs and writes to all of the input ports of the submodules.
*/
input  wire  clk;

// Interface signals
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

// Internal signals
output wire  [ALU_STREAM_WIDTH-1:0]   alu_x_streams;
output wire  [ALU_STREAM_WIDTH-1:0]   alu_y_streams;
input  wire  [ALU_STREAM_WIDTH-1:0]   alu_out_streams;

output wire  [REGFILE_RAM_WIDTH-1:0]  opmux_rf_portA;
output wire  [REGFILE_RAM_WIDTH-1:0]  opmux_rf_portB;
output wire  [NET_STREAM_WIDTH-1:0]   opmux_net_stream;
input  wire  [ALU_STREAM_WIDTH-1:0]   opmux_opnX;
input  wire  [ALU_STREAM_WIDTH-1:0]   opmux_opnY;

output wire  [REGFILE_ADDR_WIDTH-1:0] regfile_addra;
output wire  [REGFILE_ADDR_WIDTH-1:0] regfile_addrb; 
output wire  [REGFILE_RAM_WIDTH-1:0]  regfile_dia; 
output wire  [REGFILE_RAM_WIDTH-1:0]  regfile_dib; 
input  wire  [REGFILE_RAM_WIDTH-1:0]  regfile_doa; 
input  wire  [REGFILE_RAM_WIDTH-1:0]  regfile_dob;

output wire  [NET_STREAM_WIDTH-1:0]   netnode_localIn;
input  wire  [NET_STREAM_WIDTH-1:0]   netnode_captureOut;
output wire  [NET_STREAM_WIDTH-1:0]   netnode_northIn;
input  wire  [NET_STREAM_WIDTH-1:0]   netnode_northOut;
output wire  [NET_STREAM_WIDTH-1:0]   netnode_eastIn;
input  wire  [NET_STREAM_WIDTH-1:0]   netnode_eastOut;
output wire  [NET_STREAM_WIDTH-1:0]   netnode_westIn;
input  wire  [NET_STREAM_WIDTH-1:0]   netnode_westOut;
output wire  [NET_STREAM_WIDTH-1:0]   netnode_southIn;
input  wire  [NET_STREAM_WIDTH-1:0]   netnode_southOut;
output wire  [SHIFT_STREAM_WIDTH-1:0] netnode_shiftIn;
input  wire  [SHIFT_STREAM_WIDTH-1:0] netnode_shiftOut;


/* Rationale for port connections of RF
*   - The opmux has the basic structure of X op Y
*   - Operand X has connections only to port-A output, to reduce wiring logic
*   - Alu output goes directly to port-B input, to reduce wiring
*   - Network localIn reads from port-A output, because,
*       - port-B address is used for writing Alu output result
*       - We use port-A addres to stream through network
*       - Thus, we can overlap network streaming and computation (shift-add)
*/


// Connect interface output signals
assign extDataOut = regfile_doa;        // port-A output of regfile goes directly to output
assign northOut   = netnode_northOut;   // north network output is driven by the network module
assign eastOut    = netnode_eastOut;    // east network output is driven by the network module
assign westOut    = netnode_westOut;    // west network output is driven by the network module
assign southOut   = netnode_southOut;   // south network output is driven by the network module
assign shiftOut   = netnode_shiftOut;   // shift network output is driven by the network module


// Connect regfile inputs
assign regfile_addra = addrA;            // port-A of regfile streams operand-A
assign regfile_addrb = addrB;            // port-B of regfile streams operand-B
assign regfile_dia   = extDataIn;        // external data input goes directly into regfile port-A
assign regfile_dib   = alu_out_streams;  // alu output connects directly with regfile port-B


// Connect opmux inputs
assign opmux_rf_portA   = regfile_doa;
assign opmux_rf_portB   = regfile_dob;
assign opmux_net_stream = netnode_captureOut;   // connect network capture stream to opmux


// Connect alu inputs
assign alu_x_streams = opmux_opnX;
assign alu_y_streams = opmux_opnY;


// Connect netnode inputs
assign netnode_northIn = northIn;    // north network input goes directly to network module
assign netnode_eastIn  = eastIn;     // east network input goes directly to network module
assign netnode_westIn  = westIn;     // west network input goes directly to network module
assign netnode_southIn = southIn;    // south network input goes directly to network module
assign netnode_shiftIn = shiftIn;    // shift network input goes directly to network module
assign netnode_localIn = regfile_doa[0 +: NET_STREAM_WIDTH];  // port-A output of registerfile is used for network streaming


endmodule
