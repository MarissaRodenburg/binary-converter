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
    
    always @(posedge clk) begin
        refresh_counter <= refresh_counter + 1;
        digit_sel <= refresh_counter[16:15]; // top 2 bits ~ slow enough
    end

    // select which nibble and which AN line based on digit_sel
    // then feed that nibble into your bcd_to_7seg logic to drive SEG
endmodule

