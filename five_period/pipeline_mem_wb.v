//=============================================================================
// pipeline_mem_wb.v - MEM/WB Pipeline Register
//=============================================================================

`timescale 1ns / 1ps

module pipeline_mem_wb (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [31:0] mem_read_data,
    input  wire [31:0] mem_alu_result,
    input  wire        mem_reg_write,
    input  wire [ 4:0] mem_reg_write_dest,
    input  wire        mem_to_reg,
    output reg  [31:0] wb_read_data,
    output reg  [31:0] wb_alu_result,
    output reg         wb_reg_write,
    output reg  [ 4:0] wb_reg_write_dest,
    output reg         wb_mem_to_reg
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wb_read_data      <= 32'd0;
            wb_alu_result     <= 32'd0;
            wb_reg_write      <= 1'b0;
            wb_reg_write_dest <= 5'd0;
            wb_mem_to_reg     <= 1'b0;
        end else begin
            wb_read_data      <= mem_read_data;
            wb_alu_result     <= mem_alu_result;
            wb_reg_write      <= mem_reg_write;
            wb_reg_write_dest <= mem_reg_write_dest;
            wb_mem_to_reg     <= mem_to_reg;
        end
    end

endmodule
