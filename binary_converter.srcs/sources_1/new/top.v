`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Marissa Rodenburg
// 
// Create Date: 07/17/2026 10:02:17 AM
// Design Name: 
// Module Name: top
// Project Name: Binary Converter
// Target Devices: Basys 3
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments: Top-level module controlling the project
// 
//////////////////////////////////////////////////////////////////////////////////


module top (
    input  wire        clk,
    input  wire [15:0] SW,
    output wire [3:0]  AN,
    output wire [6:0]  SEG,
    output wire        DP,
    output wire [15:0] LED
);

    // overflow check + clamp - when over 9999, we display nothing and turn on LED 1
    wire overflow = (SW > 16'd9999);

    // binary_to_bcd instance
    wire [15:0] bcd_value;

    binary_to_bcd #(.WIDTH(14)) bcd_converter (
        .clk       (clk),
        .binary_in (SW[13:0]),
        .bcd_out   (bcd_value)
    );
    
    // display_mux instance
    wire [3:0] AN_from_mux;
    
    display_mux disp (
        .clk (clk),
        .bcd (bcd_value),
        .AN  (AN_from_mux),
        .SEG (SEG),
        .DP  (DP)
    );

    assign AN = overflow ? 4'b1111 : AN_from_mux;

    // LED[1] turns lights on overflow
    assign LED[1] = overflow;

endmodule

