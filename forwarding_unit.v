`timescale 1ns / 1ps

module forwarding_unit (
    input  wire        ex_mem_reg_write,
    input  wire [4:0]  ex_mem_rd,
    input  wire        mem_wb_reg_write,
    input  wire [4:0]  mem_wb_rd,
    input  wire [4:0]  id_ex_rs1,
    input  wire [4:0]  id_ex_rs2,
    
    output reg  [1:0]  forward_a,
    output reg  [1:0]  forward_b
);

always @(*) begin
    // Initialize to no forwarding
    forward_a = 2'b00;
    forward_b = 2'b00;
    
    // Forwarding for rs1 (operand A)
    if (ex_mem_reg_write && (ex_mem_rd == id_ex_rs1) && (ex_mem_rd != 5'h00)) begin
        forward_a = 2'b10; // Forward from EX/MEM
    end else if (mem_wb_reg_write && (mem_wb_rd == id_ex_rs1) && (mem_wb_rd != 5'h00)) begin
        forward_a = 2'b01; // Forward from MEM/WB
    end
    
    // Forwarding for rs2 (operand B)
    if (ex_mem_reg_write && (ex_mem_rd == id_ex_rs2) && (ex_mem_rd != 5'h00)) begin
        forward_b = 2'b10; // Forward from EX/MEM
    end else if (mem_wb_reg_write && (mem_wb_rd == id_ex_rs2) && (mem_wb_rd != 5'h00)) begin
        forward_b = 2'b01; // Forward from MEM/WB
    end
end

endmodule