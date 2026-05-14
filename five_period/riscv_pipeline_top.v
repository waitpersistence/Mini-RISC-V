//=============================================================================
// riscv_pipeline_top.v - 5-stage pipeline RISC-V CPU (no forwarding/hazard)
// Stages: IF -> ID -> EX -> MEM -> WB
// Pipeline registers: IF/ID, ID/EX, EX/MEM, MEM/WB
//=============================================================================

`timescale 1ns / 1ps

module riscv_pipeline_top (
    input  wire        clk,
    input  wire        rst_n,
    output wire [31:0] debug_pc,
    output wire [31:0] debug_instruction,
    output wire [31:0] debug_reg_write_data,
    output wire [ 4:0] debug_reg_write_dest,
    output wire        debug_reg_write_en
);

    // --- IF signals ---
    wire [31:0] if_pc;
    wire [31:0] if_instruction;

    // --- ID signals ---
    wire [31:0] id_pc;
    wire [31:0] id_instruction;
    wire [31:0] id_reg_read_data1;
    wire [31:0] id_reg_read_data2;
    wire [31:0] id_immediate;
    wire [ 3:0] id_alu_op;
    wire [ 4:0] id_rs1;
    wire [ 4:0] id_rs2;
    wire        id_alu_src;
    wire        id_mem_read;
    wire        id_mem_write;
    wire        id_reg_write;
    wire [ 4:0] id_reg_write_dest;

    // --- EX signals ---
    wire [31:0] ex_pc;
    wire [31:0] ex_reg_read_data1;
    wire [31:0] ex_reg_read_data2;
    wire [31:0] ex_immediate;
    wire [ 3:0] ex_alu_op;
    wire        ex_alu_src;
    wire [ 4:0] ex_rs1;
    wire [ 4:0] ex_rs2;
    wire        ex_mem_read;
    wire        ex_mem_write;
    wire        ex_reg_write;
    wire [ 4:0] ex_reg_write_dest;
    wire [31:0] ex_alu_result;

    // --- MEM signals ---
    wire [31:0] mem_pc;
    wire [31:0] mem_alu_result;
    wire [31:0] mem_reg_write_data_in;
    wire        mem_mem_read;
    wire        mem_mem_write;
    wire        mem_reg_write;
    wire [ 4:0] mem_reg_write_dest;
    wire [31:0] mem_read_data;

    // --- WB signals ---
    wire [31:0] wb_mem_read_data;
    wire [31:0] wb_alu_result;
    wire        wb_reg_write;
    wire [ 4:0] wb_reg_write_dest;
    wire        wb_mem_to_reg;
    wire [31:0] wb_reg_write_data;

    // --- Forwarding signals ---
    wire [1:0]  forward_a;
    wire [1:0]  forward_b;

    // IF stage
    if_stage u_if_stage (
        .clk          (clk),
        .rst_n        (rst_n),
        .pc_next      (),
        .pc           (if_pc),
        .instruction  (if_instruction)
    );

    // IF/ID register
    pipeline_if_id u_pipeline_if_id (
        .clk            (clk),
        .rst_n          (rst_n),
        .if_pc          (if_pc),
        .if_instruction (if_instruction),
        .id_pc          (id_pc),
        .id_instruction (id_instruction)
    );

    // ID stage
    id_stage u_id_stage (
        .clk            (clk),
        .rst_n          (rst_n),
        .instruction    (id_instruction),
        .pc             (id_pc),

        .wb_reg_write_en   (wb_reg_write),
        .wb_reg_write_dest (wb_reg_write_dest),
        .wb_reg_write_data (wb_reg_write_data),

        .reg_read_data1 (id_reg_read_data1),
        .reg_read_data2 (id_reg_read_data2),
        .id_rs1         (id_rs1),
        .id_rs2         (id_rs2),
        .immediate      (id_immediate),
        .alu_op         (id_alu_op),
        .alu_src        (id_alu_src),
        .mem_read       (id_mem_read),
        .mem_write      (id_mem_write),
        .reg_write      (id_reg_write),
        .reg_write_dest (id_reg_write_dest)
    );

    // ID/EX register
    pipeline_id_ex u_pipeline_id_ex (
        .clk               (clk),
        .rst_n             (rst_n),
        .id_pc             (id_pc),
        .id_reg_read_data1 (id_reg_read_data1),
        .id_reg_read_data2 (id_reg_read_data2),
        .id_immediate      (id_immediate),
        .id_alu_op         (id_alu_op),
        .id_alu_src        (id_alu_src),
        .id_mem_read       (id_mem_read),
        .id_mem_write      (id_mem_write),
        .id_reg_write      (id_reg_write),
        .id_reg_write_dest (id_reg_write_dest),
        .id_rs1            (id_rs1),
        .id_rs2            (id_rs2),
        .ex_pc             (ex_pc),
        .ex_reg_read_data1 (ex_reg_read_data1),
        .ex_reg_read_data2 (ex_reg_read_data2),
        .ex_immediate      (ex_immediate),
        .ex_alu_op         (ex_alu_op),
        .ex_alu_src        (ex_alu_src),
        .ex_mem_read       (ex_mem_read),
        .ex_mem_write      (ex_mem_write),
        .ex_reg_write      (ex_reg_write),
        .ex_reg_write_dest (ex_reg_write_dest),
        .ex_rs1            (ex_rs1),
        .ex_rs2            (ex_rs2)
    );

    // Forwarding Unit
    forwarding_unit u_forwarding_unit (
        .ex_rs1        (ex_rs1),
        .ex_rs2        (ex_rs2),
        .mem_rd        (mem_reg_write_dest),
        .mem_reg_write (mem_reg_write),
        .wb_rd         (wb_reg_write_dest),
        .wb_reg_write  (wb_reg_write),
        .forward_a     (forward_a),
        .forward_b     (forward_b)
    );

    // EX stage
    ex_stage u_ex_stage (
        .clk              (clk),
        .rst_n            (rst_n),
        .reg_read_data1   (ex_reg_read_data1),
        .reg_read_data2   (ex_reg_read_data2),
        .immediate        (ex_immediate),
        .alu_op           (ex_alu_op),
        .alu_src          (ex_alu_src),
        .forward_data_mem (mem_alu_result),
        .forward_data_wb  (wb_reg_write_data),
        .forward_a        (forward_a),
        .forward_b        (forward_b),
        .alu_result       (ex_alu_result)
    );

    // EX/MEM register
    pipeline_ex_mem u_pipeline_ex_mem (
        .clk                   (clk),
        .rst_n                 (rst_n),
        .ex_pc                 (ex_pc),
        .ex_alu_result         (ex_alu_result),
        .ex_reg_write_data2    (ex_reg_read_data2),
        .ex_mem_read           (ex_mem_read),
        .ex_mem_write          (ex_mem_write),
        .ex_reg_write          (ex_reg_write),
        .ex_reg_write_dest     (ex_reg_write_dest),
        .mem_pc                (mem_pc),
        .mem_alu_result        (mem_alu_result),
        .mem_reg_write_data_in (mem_reg_write_data_in),
        .mem_mem_read          (mem_mem_read),
        .mem_mem_write         (mem_mem_write),
        .mem_reg_write         (mem_reg_write),
        .mem_reg_write_dest    (mem_reg_write_dest)
    );

    // MEM stage
    mem_stage u_mem_stage (
        .clk               (clk),
        .rst_n             (rst_n),
        .alu_result        (mem_alu_result),
        .reg_write_data_in (mem_reg_write_data_in),
        .mem_read          (mem_mem_read),
        .mem_write         (mem_mem_write),
        .read_data         (mem_read_data)
    );

    // MEM/WB register
    pipeline_mem_wb u_pipeline_mem_wb (
        .clk               (clk),
        .rst_n             (rst_n),
        .mem_read_data     (mem_read_data),
        .mem_alu_result    (mem_alu_result),
        .mem_reg_write     (mem_reg_write),
        .mem_reg_write_dest(mem_reg_write_dest),
        .mem_to_reg        (mem_mem_read),
        .wb_read_data      (wb_mem_read_data),
        .wb_alu_result     (wb_alu_result),
        .wb_reg_write      (wb_reg_write),
        .wb_reg_write_dest (wb_reg_write_dest),
        .wb_mem_to_reg     (wb_mem_to_reg)
    );

    // WB stage
    wb_stage u_wb_stage (
        .clk            (clk),
        .rst_n          (rst_n),
        .mem_read_data  (wb_mem_read_data),
        .alu_result     (wb_alu_result),
        .mem_to_reg     (wb_mem_to_reg),
        .reg_write_data (wb_reg_write_data)
    );

    // Debug outputs
    assign debug_pc             = if_pc;
    assign debug_instruction    = if_instruction;
    assign debug_reg_write_data = wb_reg_write_data;
    assign debug_reg_write_dest = wb_reg_write_dest;
    assign debug_reg_write_en   = wb_reg_write;

endmodule
