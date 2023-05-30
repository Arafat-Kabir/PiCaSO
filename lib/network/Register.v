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
  Date  : Wed, Dec 21, 07:55 PM CST 2022

  Description:
  A general purpose N-bit register, with optional clock enable and reset.

================================================================================*/


/*
Usage: A configurable register module
    clk         : clock
    ce          : clock-enable signal
    reset       : active-high reset signal
    inD         : data port (D pin of FF)
    outQ        : output port (Q pin of FF)
*/


module Register #(
// Parameters
    parameter WIDTH     = 8,    // width of the register
    parameter USE_CE    = 0,    // use clock-enable signal
    parameter USE_RESET = 0,    // use reset signal
    parameter RESET_VAL = 0     // specify reset value, by default resets to 0
) (
    clk,        // clock
    ce,         // clock-enable signal
    reset,      // active-high reset signal
    inD,        // data input port
    outQ        // output port
);


// IO Ports
input              clk;
input              ce;
input              reset;
input  [WIDTH-1:0] inD;
output [WIDTH-1:0] outQ;


// Internal signal
(* extract_enable = "yes", extract_reset = "yes" *)
reg [WIDTH-1:0]  data_reg = RESET_VAL;


// assign output
assign outQ = data_reg;


// Use the appropriate behavior of the register based on the requested instance properties
generate

if(USE_RESET) begin

    if(USE_CE) begin
        
        /**** Use Reset and clock-enable ****
        *   This is a more regular register.
        *   Reset has higher priority over clock-enable (FPGA FF behavior).
        */
        always @(posedge clk) begin
            if(reset)
                data_reg <= RESET_VAL;
            else if(ce)
                data_reg <= inD;
            else
                data_reg <= data_reg;
        end  // always

    end 
    else begin

        /**** Use Reset only, and no clock-enable ****
        *   This can be used to implement a always-shifting channel, with
        *   a reset.
        */
        always @(posedge clk) begin
            if(reset)
                data_reg <= RESET_VAL;
            else
                data_reg <= data_reg;
        end  // always

    end
end     // USE_RESET == True
else begin

    if(USE_CE) begin
        
        /**** Use Clock-Enable only, and no reset ****
        *   This is a more utilization and routing friendly for FPGA.
        */
        always @(posedge clk) begin
            if(ce)
                data_reg <= inD;
            else
                data_reg <= data_reg;
        end  // always

    end 
    else begin

        /**** No control signal ****
        *   This can be used to implement a always-shifting channel.
        */
        always @(posedge clk) begin
            data_reg <= data_reg;
        end  // always

    end

end     // USE_RESET == False

endgenerate



endmodule
