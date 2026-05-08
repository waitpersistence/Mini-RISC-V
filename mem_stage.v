`timescale 1ns / 1ps

module mem_stage (
    input  wire        clk,
    input  wire        rst,
    input  wire [31:0] ex_mem_pc,
    input  wire [31:0] ex_mem_alu_result,
    input  wire [31:0] ex_mem_rs2_data,
    input  wire [4:0]  ex_mem_rd,
    input  wire        ex_mem_reg_write,
    input  wire        ex_mem_mem_read,
    input  wire        ex_mem_mem_write,
    input  wire        ex_mem_valid,
    
    output reg  [31:0] dmem_addr,
    output reg  [31:0] dmem_wdata,
    output reg         dmem_we,
    input  wire [31:0] dmem_rdata,
    
    output reg  [31:0] mem_wb_pc,
    output reg  [31:0] mem_wb_alu_result,
    output reg  [31:0] mem_wb_mem_data,
    output reg  [4:0]  mem_wb_rd,
    output reg         mem_wb_reg_write,
    output reg         mem_wb_valid
);

// Memory interface signals
always @(posedge clk or posedge rst) begin
    if (rst) begin
        dmem_addr <= 32'h00000000;
        dmem_wdata <= 32'h00000000;
        dmem_we <= 1'b0;
    end else if (ex_mem_valid && ex_mem_mem_write) begin
        dmem_addr <= ex_mem_alu_result;
        dmem_wdata <= ex_mem_rs2_data;
        dmem_we <= 1'b1;
    end else begin
        dmem_we <= 1'b0;
    end
end

// Handle memory read operations
reg [31:0] mem_read_data;
always @(*) begin
    if (ex_mem_mem_read && ex_mem_valid) begin
        // For simplicity, we assume word-aligned access
        // In real implementation, would need to handle byte/halfword loads
        mem_read_data = dmem_rdata;
    end else begin
        mem_read_data = ex_mem_alu_result;
    end
end

// Pipeline register update
always @(posedge clk or posedge rst) begin
    if (rst) begin
        mem_wb_pc <= 32'h00000000;
        mem_wb_alu_result <= 32'h00000000;
        mem_wb_mem_data <= 32'h00000000;
        mem_wb_rd <= 5'h00;
        mem_wb_reg_write <= 1'b0;
        mem_wb_valid <= 1'b0;
    end else begin
        if (ex_mem_valid) begin
            mem_wb_pc <= ex_mem_pc;
            mem_wb_alu_result <= ex_mem_alu_result;
            mem_wb_mem_data <= mem_read_data;
            mem_wb_rd <= ex_mem_rd;
            mem_wb_reg_write <= ex_mem_reg_write;
            mem_wb_valid <= 1'b1;
        end else begin
            mem_wb_valid <= 1'b0;
        end
    end
end

endmodule