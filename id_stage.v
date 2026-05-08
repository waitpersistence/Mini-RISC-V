`timescale 1ns / 1ps

module id_stage (
    input  wire        clk,
    input  wire        rst,
    input  wire        stall,
    input  wire        flush,
    input  wire [31:0] instr_in,
    input  wire [31:0] if_id_pc,
    input  wire        if_id_valid,
    
    output reg  [31:0] id_ex_pc,
    output reg  [31:0] id_ex_rs1_data,
    output reg  [31:0] id_ex_rs2_data,
    output reg  [31:0] id_ex_imm,
    output reg  [4:0]  id_ex_rs1,
    output reg  [4:0]  id_ex_rs2,
    output reg  [4:0]  id_ex_rd,
    output reg  [6:0]  id_ex_opcode,
    output reg  [2:0]  id_ex_funct3,
    output reg  [6:0]  id_ex_funct7,
    output reg         id_ex_reg_write,
    output reg         id_ex_mem_read,
    output reg         id_ex_mem_write,
    output reg         id_ex_alu_src,
    output reg  [3:0]  id_ex_alu_op,
    output reg         id_ex_valid,
    
    input  wire [1:0]  forward_a,
    input  wire [1:0]  forward_b,
    
    // Register file interface (for WB stage)
    input  wire [31:0] mem_wb_alu_result,
    input  wire [31:0] mem_wb_mem_data,
    input  wire [4:0]  mem_wb_rd,
    input  wire        mem_wb_reg_write,
    input  wire        mem_wb_valid,
    input  wire        mem_wb_mem_read, // Added to correctly select write-back data
    
    // EX/MEM signals (for forwarding)
    input  wire [31:0] ex_mem_alu_result,
    input  wire [4:0]  ex_mem_rd,
    input  wire        ex_mem_reg_write
);

// Register file
reg [31:0] reg_file [0:31];
wire [31:0] rs1_data_raw, rs2_data_raw;

// Initialize register file
integer i;
initial begin
    for (i = 0; i < 32; i = i + 1) begin
        reg_file[i] = 32'h00000000;
    end
end

// Read registers
assign rs1_data_raw = reg_file[instr_in[19:15]];
assign rs2_data_raw = reg_file[instr_in[24:20]];

// Immediate generation
wire [31:0] imm_i, imm_s, imm_b, imm_u, imm_j;
reg [31:0] imm_out;

// I-type immediate
assign imm_i = {{21{instr_in[31]}}, instr_in[30:20]};

// S-type immediate
assign imm_s = {{21{instr_in[31]}}, instr_in[30:25], instr_in[11:7]};

// B-type immediate
assign imm_b = {{20{instr_in[31]}}, instr_in[7], instr_in[30:25], instr_in[11:8], 1'b0};

// U-type immediate
assign imm_u = {instr_in[31:12], 12'b0};

// J-type immediate
assign imm_j = {{12{instr_in[31]}}, instr_in[19:12], instr_in[20], instr_in[30:21], 1'b0};

// Select immediate based on opcode
always @(*) begin
    case (instr_in[6:0])
        7'b0000011, 7'b0010011, 7'b1100111: imm_out = imm_i; // I-type
        7'b0100011: imm_out = imm_s; // S-type
        7'b1100011: imm_out = imm_b; // B-type
        7'b0110111, 7'b0010111: imm_out = imm_u; // U-type
        7'b1101111: imm_out = imm_j; // J-type
        default: imm_out = 32'h00000000;
    endcase
end

// ALU operation decoding
always @(*) begin
    case ({instr_in[6:0], instr_in[14:12]})
        // R-type operations
        {7'b0110011, 3'b000}: id_ex_alu_op = 4'b0000; // ADD/SUB
        {7'b0110011, 3'b111}: id_ex_alu_op = 4'b0001; // AND
        {7'b0110011, 3'b110}: id_ex_alu_op = 4'b0010; // OR
        {7'b0110011, 3'b100}: id_ex_alu_op = 4'b0011; // XOR
        {7'b0110011, 3'b001}: id_ex_alu_op = 4'b0100; // SLL
        {7'b0110011, 3'b101}: id_ex_alu_op = 4'b0101; // SRL/SRA
        {7'b0110011, 3'b010}: id_ex_alu_op = 4'b0110; // SLT
        {7'b0110011, 3'b011}: id_ex_alu_op = 4'b0111; // SLTU
        
        // I-type operations
        {7'b0010011, 3'b000}: id_ex_alu_op = 4'b0000; // ADDI
        {7'b0010011, 3'b111}: id_ex_alu_op = 4'b0001; // ANDI
        {7'b0010011, 3'b110}: id_ex_alu_op = 4'b0010; // ORI
        {7'b0010011, 3'b100}: id_ex_alu_op = 4'b0011; // XORI
        {7'b0010011, 3'b001}: id_ex_alu_op = 4'b0100; // SLLI
        {7'b0010011, 3'b101}: id_ex_alu_op = 4'b0101; // SRLI/SRAI
        {7'b0010011, 3'b010}: id_ex_alu_op = 4'b0110; // SLTI
        {7'b0010011, 3'b011}: id_ex_alu_op = 4'b0111; // SLTIU
        
        // Load operations
        {7'b0000011, 3'b000},
        {7'b0000011, 3'b001},
        {7'b0000011, 3'b010},
        {7'b0000011, 3'b100},
        {7'b0000011, 3'b101}: id_ex_alu_op = 4'b0000; // ADD for address calculation
        
        // Store operations
        {7'b0100011, 3'b000},
        {7'b0100011, 3'b001},
        {7'b0100011, 3'b010},
        {7'b0100011, 3'b100},
        {7'b0100011, 3'b101}: id_ex_alu_op = 4'b0000; // ADD for address calculation
        
        default: id_ex_alu_op = 4'b0000;
    endcase
end

// Control signals
always @(*) begin
    id_ex_reg_write = 1'b0;
    id_ex_mem_read = 1'b0;
    id_ex_mem_write = 1'b0;
    id_ex_alu_src = 1'b0;
    
    case (instr_in[6:0])
        7'b0110011: begin // R-type
            id_ex_reg_write = 1'b1;
            id_ex_alu_src = 1'b0;
        end
        7'b0010011: begin // I-type
            id_ex_reg_write = 1'b1;
            id_ex_alu_src = 1'b1;
        end
        7'b0000011: begin // Load
            id_ex_reg_write = 1'b1;
            id_ex_mem_read = 1'b1;
            id_ex_alu_src = 1'b1;
        end
        7'b0100011: begin // Store
            id_ex_mem_write = 1'b1;
            id_ex_alu_src = 1'b1;
        end
        7'b1100011: begin // Branch
            id_ex_alu_src = 1'b0;
        end
        7'b1100111: begin // Jalr
            id_ex_reg_write = 1'b1;
            id_ex_alu_src = 1'b1;
        end
        7'b1101111: begin // Jal
            id_ex_reg_write = 1'b1;
            id_ex_alu_src = 1'b1;
        end
        7'b0110111: begin // Lui
            id_ex_reg_write = 1'b1;
            id_ex_alu_src = 1'b1;
        end
        7'b0010111: begin // Auipc
            id_ex_reg_write = 1'b1;
            id_ex_alu_src = 1'b1;
        end
        default: begin
            id_ex_reg_write = 1'b0;
            id_ex_mem_read = 1'b0;
            id_ex_mem_write = 1'b0;
            id_ex_alu_src = 1'b0;
        end
    endcase
end

// Forwarding logic for rs1 and rs2
reg [31:0] forwarded_rs1, forwarded_rs2;

// Forwarding for rs1
always @(*) begin
    case (forward_a)
        2'b00: forwarded_rs1 = rs1_data_raw;
        2'b01: forwarded_rs1 = mem_wb_alu_result; // Forward from MEM/WB
        2'b10: forwarded_rs1 = ex_mem_alu_result; // Forward from EX/MEM
        default: forwarded_rs1 = rs1_data_raw;
    endcase
end

// Forwarding for rs2
always @(*) begin
    case (forward_b)
        2'b00: forwarded_rs2 = rs2_data_raw;
        2'b01: forwarded_rs2 = mem_wb_alu_result; // Forward from MEM/WB
        2'b10: forwarded_rs2 = ex_mem_alu_result; // Forward from EX/MEM
        default: forwarded_rs2 = rs2_data_raw;
    endcase
end

// Pipeline register update
always @(posedge clk or posedge rst) begin
    if (rst) begin
        id_ex_pc <= 32'h00000000;
        id_ex_rs1_data <= 32'h00000000;
        id_ex_rs2_data <= 32'h00000000;
        id_ex_imm <= 32'h00000000;
        id_ex_rs1 <= 5'h00;
        id_ex_rs2 <= 5'h00;
        id_ex_rd <= 5'h00;
        id_ex_opcode <= 7'h00;
        id_ex_funct3 <= 3'h00;
        id_ex_funct7 <= 7'h00;
        id_ex_reg_write <= 1'b0;
        id_ex_mem_read <= 1'b0;
        id_ex_mem_write <= 1'b0;
        id_ex_alu_src <= 1'b0;
        id_ex_alu_op <= 4'h0;
        id_ex_valid <= 1'b0;
    end else if (!stall && !flush) begin
        if (if_id_valid) begin
            id_ex_pc <= if_id_pc;
            id_ex_rs1_data <= forwarded_rs1;
            id_ex_rs2_data <= forwarded_rs2;
            id_ex_imm <= imm_out;
            id_ex_rs1 <= instr_in[19:15];
            id_ex_rs2 <= instr_in[24:20];
            id_ex_rd <= instr_in[11:7];
            id_ex_opcode <= instr_in[6:0];
            id_ex_funct3 <= instr_in[14:12];
            id_ex_funct7 <= instr_in[31:25];
            id_ex_valid <= 1'b1;
        end else begin
            id_ex_valid <= 1'b0;
        end
    end else if (flush) begin
        // Flush the pipeline
        id_ex_valid <= 1'b0;
    end
    // If stalled, hold current values
end

// Write back to register file
// In a standard 5-stage pipeline with register file in ID stage,
// we write back using signals from MEM/WB stage
always @(posedge clk) begin
    if (mem_wb_reg_write && mem_wb_valid && mem_wb_rd != 5'h00) begin
        // Select data source based on whether it was a memory read (Load) or not
        if (mem_wb_mem_read) begin
            reg_file[mem_wb_rd] <= mem_wb_mem_data;
        end else begin
            reg_file[mem_wb_rd] <= mem_wb_alu_result;
        end
    end
end

endmodule