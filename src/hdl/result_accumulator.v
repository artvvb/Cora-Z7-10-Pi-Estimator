`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/05/2018 01:00:52 PM
// Design Name: 
// Module Name: result_accumulator
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module result_accumulator (
    input clk,
    input reset,
    input enable,
    input l_enable,
    input din_valid,
    input din,
    output reg [31:0] result = 0,
    output wire done
    );
    always@(posedge clk)
        if (reset)
            result <= 'b0;
        else if (enable == 1 && l_enable == 0)
            result <= 'b0;
        else if (din_valid == 1)
            result <= result + din;
    assign done = ~din_valid & ~enable;
endmodule
