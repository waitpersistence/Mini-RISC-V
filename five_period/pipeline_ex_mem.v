//=============================================================================
// pipeline_ex_mem.v - EX/MEM Pipeline Register
//=============================================================================

`timescale 1ns / 1ps

module pipeline_ex_mem (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [31:0] ex_pc,
    input  wire [31:0] ex_alu_result,
    input  wire [31:0] ex_reg_write_data2,
    input  wire        ex_mem_read,
    input  wire        ex_mem_write,
    input  wire        ex_reg_write,
    input  wire [ 4:0] ex_reg_write_dest,
    output reg  [31:0] mem_pc,
    output reg  [31:0] mem_alu_result,
    output reg  [31:0] mem_reg_write_data_in,
    output reg         mem_mem_read,
    output reg         mem_mem_write,
    output reg         mem_reg_write,
    output reg  [ 4:0] mem_reg_write_dest
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mem_pc                <= 32'd0;
            mem_alu_result        <= 32'd0;
            mem_reg_write_data_in <= 32'd0;
            mem_mem_read          <= 1'b0;
            mem_mem_write         <= 1'b0;
            mem_reg_write         <= 1'b0;
            mem_reg_write_dest    <= 5'd0;
        end else begin
            mem_pc                <= ex_pc;
            mem_alu_result        <= ex_alu_result;
            mem_reg_write_data_in <= ex_reg_write_data2;
            mem_mem_read          <= ex_mem_read;
            mem_mem_write         <= ex_mem_write;
            mem_reg_write         <= ex_reg_write;
            mem_reg_write_dest    <= ex_reg_write_dest;
        end
    end

endmodule
