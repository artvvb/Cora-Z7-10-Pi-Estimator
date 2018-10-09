`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/05/2018 11:20:46 AM
// Design Name: 
// Module Name: piEstimator
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


module piEstimator(
    input wire clk,
    input wire reset,
    input wire set_seed,
    input wire [31:0] seed,
    input wire enable,
    output wire [31:0] result,
    output wire done
    );
    wire [15:0] rand_x, rand_y;
    wire rand_valid;
    lfsr32 rand (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .seed(seed),
        .set_seed(set_seed),
        .dout({rand_x, rand_y}),
        .valid(rand_valid)
    );
    wire cc_valid, cc_data;
    circleChecker cc (
        .clk(clk),
        .input_valid(rand_valid),
        .x(rand_x),
        .y(rand_y),
        .output_valid(cc_valid),
        .dout(cc_data)
    );
    result_accumulator acc (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .l_enable(rand_valid),
        .din_valid(cc_valid),
        .din(cc_data),
        .result(result),
        .done(done)
    );
endmodule
