`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/05/2018 01:13:14 PM
// Design Name: 
// Module Name: ctrl
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


module ctrl (
    input wire clk,
    input wire reset,
    input wire start,
    input wire [31:0] duration,
    output reg enable = 1'b0
);
    reg [31:0] counter = 'b0;
    always@(posedge clk)
        if (reset == 1) begin
            counter <= 'b0;
            enable <= 1'b0;
        end else if (start == 1) begin
            counter <= 'b0;
            enable <= 1'b1;
        end else if (counter >= duration) begin
            counter <= 'b0;
            enable <= 1'b0;
        end else
            counter <= counter + 1;
endmodule
