`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Syed Ahmed
// 
// Create Date:    16:12:38 10/19/2015 
// Design Name: LBP for image
// Module Name:    mylab5
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module mylab5(
//-------------keyboard-----------------
input wire kb_clock, // This is the clock signal from Keyboard
input wire data, //This is the clock signal from Keyboard
//-------------VGA-----------------
input clk,reset,
output wire vs,hs,pclk,
output wire cs,blnk, 
output wire [7:0] rd,gr,bl

);

keyb KeyboardInterface_unit // calling the keyboard module
(.kb_clock(kb_clock), .data(data), .char(char), .temp_key(temp_key), .clear_key(clear_key)
);


vga vga_unit // calling the VGA module
(.temp_key(temp_key), .clear_key(clear_key),. char_addr(char),. clock(clk),.reset(reset), . hsync (hs) , . vsync (vs), .pixel_clock(pclk),
.comp_sync(cs), .blank(blnk), .red(rd), .green(gr),.blue(bl));

endmodule