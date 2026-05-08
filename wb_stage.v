`timescale 1ns / 1ps

module wb_stage (
    input  wire        clk,
    input  wire        rst,
    input  wire [31:0] mem_wb_pc,
    input  wire [31:0] mem_wb_alu_result,
    input  wire [31:0] mem_wb_mem_data,
    input  wire [4:0]  mem_wb_rd,
    input  wire        mem_wb_reg_write,
    input  wire        mem_wb_valid
);

// WB stage in a standard 5-stage pipeline typically just passes signals back
// to the ID stage for register file write-back. The actual register file
// is usually instantiated in the ID stage for forwarding purposes.
// This module serves as a placeholder and can be used for additional 
// write-back logic if needed.

// No internal logic needed - all write-back happens in ID stage

endmodule