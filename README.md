# binary-converter

A small Verilog project for the Digilent Basys 3 FPGA board. Reads a 16-bit binary number from the onboard switches and displays its decimal value on the 4-digit 7-segment display.

## How it works

- `SW[15:0]` sets a 16-bit unsigned binary value (0–65535).
- Since the board only has 4 seven-segment digits, only values 0–9999 can be displayed.
- If the switch value exceeds 9999, the display blanks and `LED[1]` turns on to flag the overflow.

## Modules

- **`top.v`** — top-level module. Wires switches, clock, and outputs together; handles the overflow check and LED indicator.
- **`binary_to_bcd.v`** — converts a binary value (0–9999) into 4 BCD digits using the shift-and-add-3 ("double dabble") algorithm.
- **`display_mux.v`** — drives the 4-digit multiplexed 7-segment display, cycling through digits fast enough to appear simultaneously lit.

## Hardware

- Board: Digilent Basys 3 (Artix-7 FPGA)
- Inputs: `SW[15:0]` (16 slide switches)
- Outputs: `SEG[6:0]`, `DP`, `AN[3:0]` (7-seg display), `LED[1]` (overflow indicator)
- Clock: 100 MHz onboard oscillator

## Setup

1. Open the project in Vivado.
2. Add `top.v`, `binary_to_bcd.v`, and `display_mux.v` as design sources.
3. Add the Basys 3 master XDC constraints file, uncommenting the pins used in this project (`clk`, `SW`, `SEG`, `DP`, `AN`, `LED[1]`).
4. Generate bitstream and program the board.

## Status

Work in progress — currently building and testing the module skeletons.