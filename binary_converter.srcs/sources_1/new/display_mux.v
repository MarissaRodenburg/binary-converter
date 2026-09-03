`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Marissa Rodenburg
// 
// Create Date: 07/17/2026 09:55:25 AM
// Design Name: 
// Module Name: display_mux
// Project Name: Binary Converter
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments: 7-segment display driver
//  Cycles through the 4 digits at a refresh rate fast enough to look solid, and internally decodes each BCD nibble to a 7-seg pattern. 
//  Doesn't know or care about overflow - just displays whatever BCD value it's handed.
//////////////////////////////////////////////////////////////////////////////////


module display_mux (
    input  wire        clk,
    input  wire [15:0] bcd,
    output reg  [3:0]  AN,
    output wire [6:0]  SEG,
    output wire        DP       // decimal point, tied off
);

    reg [1:0] digit_sel;
    reg [16:0] refresh_counter; // divides 100MHz down to ~1kHz-ish

    assign DP = 1'b1; // (off, active-low)
    
    // Free-running counter divides the 100MHz clock down to a slow
    // 2-bit digit selector (~1.5kHz), cycling through all 4 digits
    // fast enough to look simultaneously lit (display multiplexing).
    always @(posedge clk) begin
        refresh_counter <= refresh_counter + 1;
        digit_sel <= refresh_counter[16:15]; // top 2 bits ~ slow enough
    end

    // Select which nibble and which AN line based on digit_sel
    reg [3:0] digit_bcd;

    always @(*) begin // whenever bcd (input value) or digit_sel (down-sampled clk) change, this fires.
        case (digit_sel)
            2'b00: begin digit_bcd = bcd[3:0];    AN = 4'b1110; end // ones (rightmost)
            2'b01: begin digit_bcd = bcd[7:4];    AN = 4'b1101; end // tens
            2'b10: begin digit_bcd = bcd[11:8];   AN = 4'b1011; end // hundreds
            2'b11: begin digit_bcd = bcd[15:12];  AN = 4'b0111; end // thousands (leftmost)
            default: begin digit_bcd = 4'hF;      AN = 4'b1111; end
        endcase
    end

    // Next feed that nibble into your bcd_to_7seg logic to drive SEG 
    //       aaaa
    //      f    b
    //      f    b
    //       gggg
    //      e    c
    //      e    c
    //       dddd   dp
    //
    // SEG[6:0] = {g, f, e, d, c, b, a}  (active-low: 0 = segment ON)
    reg [6:0] seg_pattern;
    always @(*) begin
        case(digit_bcd)
            4'd0: begin seg_pattern = 7'b1000000; end
            4'd1: begin seg_pattern = 7'b1111001; end
            4'd2: begin seg_pattern = 7'b0100100; end
            4'd3: begin seg_pattern = 7'b0110000; end
            4'd4: begin seg_pattern = 7'b0011001; end
            4'd5: begin seg_pattern = 7'b0010010; end
            4'd6: begin seg_pattern = 7'b0000010; end
            4'd7: begin seg_pattern = 7'b1111000; end
            4'd8: begin seg_pattern = 7'b0000000; end
            4'd9: begin seg_pattern = 7'b0010000; end
            default: begin seg_pattern = 7'b1111111; end
        endcase
    end
    
    assign SEG = seg_pattern;
endmodule

