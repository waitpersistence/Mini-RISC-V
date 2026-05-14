//=============================================================================
// wb_stage.v - Write Back Stage
//=============================================================================

`timescale 1ns / 1ps

module wb_stage (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [31:0] mem_read_data,
    input  wire [31:0] alu_result,
    input  wire        mem_to_reg,
    output wire [31:0] reg_write_data
);

    assign reg_write_data = mem_to_reg ? mem_read_data : alu_result;

endmodule
