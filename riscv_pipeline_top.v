`timescale 1ns / 1ps

module riscv_pipeline_top (
    input  wire        clk,
    input  wire        rst,
    // Memory interface
    output wire [31:0] imem_addr,
    input  wire [31:0] imem_data,
    output wire [31:0] dmem_addr,
    output wire [31:0] dmem_wdata,
    output wire        dmem_we,
    input  wire [31:0] dmem_rdata
);

// Pipeline registers
wire [31:0] if_id_pc;
wire [31:0] if_id_instr;
wire        if_id_valid;

wire [31:0] id_ex_pc;
wire [31:0] id_ex_rs1_data;
wire [31:0] id_ex_rs2_data;
wire [31:0] id_ex_imm;
wire [4:0]  id_ex_rs1;
wire [4:0]  id_ex_rs2;
wire [4:0]  id_ex_rd;
wire [6:0]  id_ex_opcode;
wire [2:0]  id_ex_funct3;
wire [6:0]  id_ex_funct7;
wire        id_ex_reg_write;
wire        id_ex_mem_read;
wire        id_ex_mem_write;
wire        id_ex_alu_src;
wire [3:0]  id_ex_alu_op;
wire        id_ex_valid;

wire [31:0] ex_mem_pc;
wire [31:0] ex_mem_alu_result;
wire [31:0] ex_mem_rs2_data;
wire [4:0]  ex_mem_rd;
wire        ex_mem_reg_write;
wire        ex_mem_mem_read;
wire        ex_mem_mem_write;
wire        ex_mem_valid;

wire [31:0] mem_wb_pc;
wire [31:0] mem_wb_alu_result;
wire [31:0] mem_wb_mem_data;
wire [4:0]  mem_wb_rd;
wire        mem_wb_reg_write;
wire        mem_wb_valid;

// Hazard detection and forwarding signals
wire        stall_if;
wire        stall_id;
wire        flush_id;
wire        flush_ex;
wire [1:0]  forward_a;
wire [1:0]  forward_b;

// IF Stage
if_stage if_inst (
    .clk           (clk),
    .rst           (rst),
    .stall         (stall_if),
    .pc_out        (imem_addr),
    .if_id_pc      (if_id_pc),
    .if_id_valid   (if_id_valid)
);

// ID Stage
id_stage id_inst (
    .clk           (clk),
    .rst           (rst),
    .stall         (stall_id),
    .flush         (flush_id),
    .instr_in      (imem_data),
    .if_id_pc      (if_id_pc),
    .if_id_valid   (if_id_valid),
    .id_ex_pc      (id_ex_pc),
    .id_ex_rs1_data(id_ex_rs1_data),
    .id_ex_rs2_data(id_ex_rs2_data),
    .id_ex_imm     (id_ex_imm),
    .id_ex_rs1     (id_ex_rs1),
    .id_ex_rs2     (id_ex_rs2),
    .id_ex_rd      (id_ex_rd),
    .id_ex_opcode  (id_ex_opcode),
    .id_ex_funct3  (id_ex_funct3),
    .id_ex_funct7  (id_ex_funct7),
    .id_ex_reg_write(id_ex_reg_write),
    .id_ex_mem_read(id_ex_mem_read),
    .id_ex_mem_write(id_ex_mem_write),
    .id_ex_alu_src (id_ex_alu_src),
    .id_ex_alu_op  (id_ex_alu_op),
    .id_ex_valid   (id_ex_valid),
    .forward_a     (forward_a),
    .forward_b     (forward_b),
    .mem_wb_alu_result(mem_wb_alu_result),
    .mem_wb_mem_data(mem_wb_mem_data),
    .mem_wb_rd     (mem_wb_rd),
    .mem_wb_reg_write(mem_wb_reg_write),
    .mem_wb_valid  (mem_wb_valid),
    .ex_mem_alu_result(ex_mem_alu_result),
    .ex_mem_rd     (ex_mem_rd),
    .ex_mem_reg_write(ex_mem_reg_write)
);

// EX Stage
ex_stage ex_inst (
    .clk           (clk),
    .rst           (rst),
    .flush         (flush_ex),
    .id_ex_pc      (id_ex_pc),
    .id_ex_rs1_data(id_ex_rs1_data),
    .id_ex_rs2_data(id_ex_rs2_data),
    .id_ex_imm     (id_ex_imm),
    .id_ex_rs1     (id_ex_rs1),
    .id_ex_rs2     (id_ex_rs2),
    .id_ex_rd      (id_ex_rd),
    .id_ex_opcode  (id_ex_opcode),
    .id_ex_funct3  (id_ex_funct3),
    .id_ex_funct7  (id_ex_funct7),
    .id_ex_reg_write(id_ex_reg_write),
    .id_ex_mem_read(id_ex_mem_read),
    .id_ex_mem_write(id_ex_mem_write),
    .id_ex_alu_src (id_ex_alu_src),
    .id_ex_alu_op  (id_ex_alu_op),
    .id_ex_valid   (id_ex_valid),
    .ex_mem_pc     (ex_mem_pc),
    .ex_mem_alu_result(ex_mem_alu_result),
    .ex_mem_rs2_data(ex_mem_rs2_data),
    .ex_mem_rd     (ex_mem_rd),
    .ex_mem_reg_write(ex_mem_reg_write),
    .ex_mem_mem_read(ex_mem_mem_read),
    .ex_mem_mem_write(ex_mem_mem_write),
    .ex_mem_valid  (ex_mem_valid)
);

// MEM Stage
mem_stage mem_inst (
    .clk           (clk),
    .rst           (rst),
    .ex_mem_pc     (ex_mem_pc),
    .ex_mem_alu_result(ex_mem_alu_result),
    .ex_mem_rs2_data(ex_mem_rs2_data),
    .ex_mem_rd     (ex_mem_rd),
    .ex_mem_reg_write(ex_mem_reg_write),
    .ex_mem_mem_read(ex_mem_mem_read),
    .ex_mem_mem_write(ex_mem_mem_write),
    .ex_mem_valid  (ex_mem_valid),
    .dmem_addr     (dmem_addr),
    .dmem_wdata    (dmem_wdata),
    .dmem_we       (dmem_we),
    .dmem_rdata    (dmem_rdata),
    .mem_wb_pc     (mem_wb_pc),
    .mem_wb_alu_result(mem_wb_alu_result),
    .mem_wb_mem_data(mem_wb_mem_data),
    .mem_wb_rd     (mem_wb_rd),
    .mem_wb_reg_write(mem_wb_reg_write),
    .mem_wb_valid  (mem_wb_valid)
);

// WB Stage
wb_stage wb_inst (
    .clk           (clk),
    .rst           (rst),
    .mem_wb_pc     (mem_wb_pc),
    .mem_wb_alu_result(mem_wb_alu_result),
    .mem_wb_mem_data(mem_wb_mem_data),
    .mem_wb_rd     (mem_wb_rd),
    .mem_wb_reg_write(mem_wb_reg_write),
    .mem_wb_valid  (mem_wb_valid)
);

// Hazard detection unit
hazard_detection_unit hdu_inst (
    .id_ex_mem_read(id_ex_mem_read),
    .id_ex_rs1     (id_ex_rs1),
    .id_ex_rs2     (id_ex_rs2),
    .ex_mem_mem_read(ex_mem_mem_read),
    .ex_mem_rd     (ex_mem_rd),
    .mem_wb_reg_write(mem_wb_reg_write),
    .mem_wb_rd     (mem_wb_rd),
    .stall_if      (stall_if),
    .stall_id      (stall_id),
    .flush_id      (flush_id),
    .flush_ex      (flush_ex)
);

// Forwarding unit
forwarding_unit fu_inst (
    .ex_mem_reg_write(ex_mem_reg_write),
    .ex_mem_rd     (ex_mem_rd),
    .mem_wb_reg_write(mem_wb_reg_write),
    .mem_wb_rd     (mem_wb_rd),
    .id_ex_rs1     (id_ex_rs1),
    .id_ex_rs2     (id_ex_rs2),
    .forward_a     (forward_a),
    .forward_b     (forward_b)
);

endmodule