`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/05/2018 11:20:46 AM
// Design Name: 
// Module Name: circleChecker
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

// II=1 LAT=2
module circleChecker (
    input wire clk,
    input wire input_valid,
    input wire [15:0] x,
    input wire [15:0] y,
    output reg output_valid = 0,
    output reg dout = 0
);
    localparam RAD_SQUARED = 33'h0_FFFE_0001;
    reg [31:0] x_squared = 0, y_squared = 0;
    reg [32:0] squared_sum = 0;
    reg squared_valid = 0;
    always@(posedge clk) begin
        x_squared <= x * x;
        y_squared <= y * y;
        squared_valid <= input_valid;
    end
    always@(*) squared_sum = x_squared + y_squared;
    always@(posedge clk) begin
        dout <= (squared_sum <= RAD_SQUARED) ? 1'b1 : 1'b0;
        output_valid <= squared_valid;
    end
    //assign dout = (squared_sum <= RAD_SQUARED) ? 1'b1 : 1'b0;
endmodule
