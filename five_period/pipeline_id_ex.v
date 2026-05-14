//=============================================================================
// pipeline_id_ex.v - ID/EX Pipeline Register
//=============================================================================

`timescale 1ns / 1ps

module pipeline_id_ex (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [31:0] id_pc,
    input  wire [31:0] id_reg_read_data1,
    input  wire [31:0] id_reg_read_data2,
    input  wire [31:0] id_immediate,
    input  wire [ 3:0] id_alu_op,
    input  wire        id_alu_src,
    input  wire        id_mem_read,
    input  wire        id_mem_write,
    input  wire        id_reg_write,
    input  wire [ 4:0] id_reg_write_dest,
    output reg  [31:0] ex_pc,
    output reg  [31:0] ex_reg_read_data1,
    output reg  [31:0] ex_reg_read_data2,
    output reg  [31:0] ex_immediate,
    output reg  [ 3:0] ex_alu_op,
    output reg         ex_alu_src,
    output reg         ex_mem_read,
    output reg         ex_mem_write,
    output reg         ex_reg_write,
    output reg  [ 4:0] ex_reg_write_dest,
    input  wire [ 4:0] id_rs1,
    input  wire [ 4:0] id_rs2,
    output reg  [ 4:0] ex_rs1,
    output reg  [ 4:0] ex_rs2
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ex_pc              <= 32'd0;
            ex_reg_read_data1  <= 32'd0;
            ex_reg_read_data2  <= 32'd0;
            ex_immediate       <= 32'd0;
            ex_alu_op          <= 4'b0000;
            ex_alu_src         <= 1'b0;
            ex_mem_read        <= 1'b0;
            ex_mem_write       <= 1'b0;
            ex_reg_write       <= 1'b0;
            ex_reg_write_dest  <= 5'd0;
            ex_rs1             <= 5'd0;
            ex_rs2             <= 5'd0;
        end else begin
            ex_pc              <= id_pc;
            ex_reg_read_data1  <= id_reg_read_data1;
            ex_reg_read_data2  <= id_reg_read_data2;
            ex_immediate       <= id_immediate;
            ex_alu_op          <= id_alu_op;
            ex_alu_src         <= id_alu_src;
            ex_mem_read        <= id_mem_read;
            ex_mem_write       <= id_mem_write;
            ex_reg_write       <= id_reg_write;
            ex_reg_write_dest  <= id_reg_write_dest;
            ex_rs1             <= id_rs1;
            ex_rs2             <= id_rs2;
        end
    end

endmodule
