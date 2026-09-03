`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Marissa Rodenburg
// 
// Create Date: 07/17/2026 10:09:00 AM
// Design Name: 
// Module Name: binary_to_bcd
// Project Name: Binary Converter
// Target Devices: 
// Tool Versions: 
// Description: 
// Converts an unsigned binary value into 4 BCD digits using the
// shift-and-add-3 ("double dabble") algorithm: the binary value
// is shifted in one bit at a time, and any BCD nibble that would
// reach 10 or more is corrected by adding 3 before the next shift.
//
// Free-running: continuously reconverts every WIDTH+1 clock cycles,
// so bcd_out tracks binary_in with a small, constant lag. No
// start/done handshake needed at this clock speed and bit width.
//
// Dependencies: 
// Revision:
// Revision 0.01 - File Created
// Additional Comments: 
// 
//////////////////////////////////////////////////////////////////////////////////

module binary_to_bcd #(
    parameter WIDTH = 14   // enough bits for 0-9999
)(    input  wire             clk,
    input  wire [WIDTH-1:0] binary_in,
    output reg  [15:0]      bcd_out   // {thousands, hundreds, tens, ones}, 4 bits each
);

    // Shift register holding the binary value as it's consumed bit by bit
    reg [WIDTH-1:0] shift_reg;

    // accumulator holding the BCD digits as they're built up
    reg [15:0] acc;
    
    // Counter tracking how many bits have been shifted so far
    reg [4:0] counter;
    
    // Combinational add-3 correction: for each BCD nibble >= 5, add 3
    // before the next shift (this is the "double dabble" trick)
    wire [3:0] ones_adj      = (acc[3:0]   >= 5) ? acc[3:0]   + 4'd3 : acc[3:0];
    wire [3:0] tens_adj      = (acc[7:4]   >= 5) ? acc[7:4]   + 4'd3 : acc[7:4];
    wire [3:0] hundreds_adj  = (acc[11:8]  >= 5) ? acc[11:8]  + 4'd3 : acc[11:8];
    wire [3:0] thousands_adj = (acc[15:12] >= 5) ? acc[15:12] + 4'd3 : acc[15:12];
    wire [15:0] acc_adj = {thousands_adj, hundreds_adj, tens_adj, ones_adj};

    // Main clocked block:
    //   - if we're at the start of a conversion, load a fresh binary_in
    //     and reset the accumulator
    //   - otherwise, shift {corrected bcd, remaining binary} left by 1
    //   - once all bits have been shifted, publish the result to bcd_out
    //     and loop back to reload
    always @(posedge clk) begin
        if (counter == 0) begin
            shift_reg <= binary_in;
            acc        <= 16'd0;
            counter    <= counter + 1'b1;
        end
        else if (counter <= WIDTH) begin
            {acc, shift_reg} <= {acc_adj, shift_reg} << 1;
            counter <= counter + 1'b1;
        end
        else begin
            bcd_out <= acc;
            counter <= 5'd0;
        end
    end

endmodule
