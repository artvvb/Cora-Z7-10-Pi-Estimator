`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/05/2018 11:20:46 AM
// Design Name: 
// Module Name: lfsr32
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


module lfsr32 #(
    parameter OUTPUT_WIDTH=32
) (
    input wire clk,
    input wire reset,
    input wire enable,
    input wire [31:0] seed,
    input wire set_seed,
    output wire [OUTPUT_WIDTH-1:0] dout,
    output reg valid = 0
);
    reg [31:0] data = 0;
    wire tap;
    xnor xn0(tap, data[31], data[21], data[1], data[0]);
    always@(posedge clk)
        if (reset == 1'b1)
            data <= 'b0;
        else if (set_seed == 1'b1)
            data <= seed;
        else if (enable == 1'b1)
            data <= {data[30:0], tap};
    always@(posedge clk)
        valid <= enable;
    assign dout = data[OUTPUT_WIDTH-1:0];
endmodule
