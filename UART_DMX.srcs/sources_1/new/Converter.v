module Converter(
    input clk,
    input rst,
    input [7:0] value,
    output reg [8:0] address,
    output reg dmx
    );
    
    reg [2:0] state;
    
    parameter state_MTBP = 3'h0;
    parameter state_break = 3'h1;
    parameter state_MAB = 3'h2;
    parameter state_SC_start = 3'h3;
    parameter state_SC_data = 3'h4;
    parameter state_SC_stop = 3'h5;
    
    reg [2:0] data_bit;
    
    reg [31:0] counter;
    
    initial begin
        state = state_MTBP;
    end
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state = state_MTBP;
        end else begin
            case (state)
                state_MTBP: begin
                    dmx = 1;
                    counter = 0;
                    state = state_break;
                end
                state_break: begin
                    dmx = 0;
                    counter = counter + 1;
                    if (counter == 8800) begin
                        counter = 0;
                        state = state_MAB;
                    end
                end
                state_MAB: begin
                    dmx = 1;
                    counter = counter + 1;
                    if (counter == 1200) begin
                        counter = 0;
                        address = 9'h00;
                        state = state_SC_start;
                    end
                end
                state_SC_start: begin
                    dmx = 0;
                    data_bit = 0;
                    counter = counter + 1;
                    if (counter == 400) begin
                        counter = 0;
                        state = state_SC_data;
                    end
                end
                state_SC_data: begin
                    dmx = value[data_bit];
                    counter = counter + 1;
                    if (counter == 400) begin
                        counter = 0;
                        if (data_bit == 3'h7) begin
                            state = state_SC_stop;
                        end else begin
                            data_bit = data_bit + 1;
                        end
                    end
                end
                state_SC_stop: begin
                    dmx = 1;
                    counter = counter + 1;
                    if (counter == 800) begin
                        counter = 0;
                        if (address == 9'h1f) begin
                            state = state_MTBP;
                        end else begin
                            address = address + 1;
                            state = state_SC_start;
                        end
                    end
                end
            endcase
        end
    end
    
endmodule