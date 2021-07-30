`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/07/15 21:34:38
// Design Name: 
// Module Name: UART_Parser
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


module UART_Parser(
    input clk,
    input rst,
    input [7:0] data,
    input IF,
    input [8:0] address,
    output [7:0] value,
    output error
    );
    
    reg processed;
    reg [7:0] MEM [0:511];
    
    reg [1:0] state;
    reg [1:0] error_tick;
    reg [8:0] write_addr;
    reg data_temp;
    parameter state_add1 = 2'h0;
    parameter state_add2 = 2'h1;
    parameter state_value = 2'h2;
    parameter state_error = 2'h3;
    
    assign error = state == state_error;
    
    assign value = MEM[address];
    
    integer i;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state = state_add1;
            processed = 1'b1;
            for (i = 0; i < 512; i = i + 1) begin
                MEM[i] = 0;
            end
        end else begin
            case (state)
                state_add1: begin
                        if (~IF) begin
                            processed = 0;
                        end else if (IF & ~processed) begin
                            if (data[7]) begin
                                processed = 1;
                                state = state_error;
                                error_tick = 2;
                            end else begin
                                processed = 1;
                                write_addr[8:6] = data[2:0];
                                state = state_add2;
                            end
                        end
                    end
                state_add2: begin
                        if (~IF) begin
                            processed = 0;
                        end else if (IF & ~processed) begin
                            if (data[7]) begin
                                processed = 1;
                                state = state_error;
                                error_tick = 1;
                            end else begin
                                processed = 1;
                                write_addr[5:0] = data[6:1];
                                data_temp = data[0];
                                state = state_value;
                            end
                        end
                    end
                state_value: begin
                        if (~IF) begin
                            processed = 0;
                        end else if (IF & ~processed) begin
                            if (~data[7]) begin
                                processed = 1;
                                state = state_error;
                                error_tick = 0;
                            end else begin
                                processed = 1;
                                MEM[write_addr] = {data_temp, data[6:0]};
                                state = state_add1;
                            end
                        end
                    end
                state_error: begin
                    if (~IF) begin
                        processed = 0;
                    end else if (IF & ~processed) begin
                        processed = 1;
                        if (data[7]) begin
                            state = state_add1;
                        end
                    end
                end
            endcase
        end
    end
endmodule
