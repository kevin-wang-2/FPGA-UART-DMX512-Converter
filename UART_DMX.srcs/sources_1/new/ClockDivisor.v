`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/07/15 18:05:53
// Design Name: 
// Module Name: ClockDivisor
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


module ClockDivisor(
    input clk_in,
    input rst,
    output clk_out
    );
    parameter PR = 1000;
    
    reg [31:0] counter;
    
    always @(posedge clk_in or posedge rst) begin
        if (rst) begin
            counter = 0;
        end else begin
            if (counter == PR - 1) begin
                counter = 0;
            end else begin
                counter = counter + 1;
            end
        end
    end
    
    assign clk_out = counter == 0;
    
endmodule
