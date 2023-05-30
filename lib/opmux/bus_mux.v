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
  Date  : Wed, Dec 07, 05:10 PM CST 2022

  Description:
  Multiplexes between several buses based on a select port.
  This version uses the plain mux module.

================================================================================*/


/*
Usage:
    bus_all     : concatenation of input buses as this: {bus(n), bus(n-1), ... , bus(3), bus(2), bus(1), bus(0)}
    select      : selects n-th bus
    bus_out     : based on select bus_out signals = n-th bus signals
*/


module bus_mux #(
// Parameters
    parameter BUS_WIDTH = 16,  // Width of each bus (how many muxes)
    parameter BUS_CNT   = 2    // How many buses (how many input channels of each mux)
)(
    bus_all,    // concatenation of all buses
    select,     // selection bits
    bus_out     // output channel
);


`include "clogb2_func.v"

localparam SELECT_WIDTH = clogb2(BUS_CNT-1);
localparam ALL_WIDTH    = BUS_CNT * BUS_WIDTH;


// IO Ports
input  [ALL_WIDTH-1:0]     bus_all;     // concatenation of buses
input  [SELECT_WIDTH-1:0]  select;
output [BUS_WIDTH-1:0]     bus_out;     // bit-index must match with instance-array index


// Internal signals
reg [BUS_WIDTH-1:0] bus_arr[BUS_CNT-1:0];
reg [BUS_CNT-1:0]   channel_arr[BUS_WIDTH-1:0];


// Untangle: Separate the buses from the lump (bus_all) then organize in channels
always @* begin: Untangle
    integer i,j;
    for(i=0; i<BUS_CNT; i=i+1) begin
        bus_arr[i] = bus_all[i*BUS_WIDTH +: BUS_WIDTH];    // assumes {bus3, bus2, bus1, bus0}
    end
    for(i=0; i<BUS_WIDTH; i=i+1) begin
        for(j=0; j<BUS_CNT; j=j+1)
            channel_arr[i][j] = bus_arr[j][i];      // channel_arr[0] = {bus0[2], bus0[1], bus0[0]}
    end
end


// Instantiate a mux for each bit of the buses
generate
    genvar gi;
    for(gi=0; gi<BUS_WIDTH; gi=gi+1) begin: mux_arr
        mux #(.CHANNEL_CNT(BUS_CNT))  m (
            .channels(channel_arr[gi]),
            .select(select), 
            .out(bus_out[gi])    
        );
    end
endgenerate


`include "undef_clogb2_func.v"
endmodule
