`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/07/15 19:51:36
// Design Name: 
// Module Name: top
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


module top(
    input clk,
    input rst,
    input rxd,
    input [8:0] addr,
    output [7:0] display,
    output signal,
    output dmx
    );
    
    wire [7:0] data;
    wire [9:0] dmx_address;
    wire [8:0] dmx_data;
    wire IF;
    
    UART_RX #500000 (rxd, clk, rst, data, IF);
    UART_Parser (clk, rst, data, IF, dmx_address, dmx_data, signal);
    Converter (clk, rst, dmx_data, dmx_address, dmx);
    
    assign display = dmx_data;
endmodule
