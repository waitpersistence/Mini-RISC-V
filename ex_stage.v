`timescale 1ns / 1ps

module ex_stage (
    input  wire        clk,
    input  wire        rst,
    input  wire        flush,
    input  wire [31:0] id_ex_pc,
    input  wire [31:0] id_ex_rs1_data,
    input  wire [31:0] id_ex_rs2_data,
    input  wire [31:0] id_ex_imm,
    input  wire [4:0]  id_ex_rs1,
    input  wire [4:0]  id_ex_rs2,
    input  wire [4:0]  id_ex_rd,
    input  wire [6:0]  id_ex_opcode,
    input  wire [2:0]  id_ex_funct3,
    input  wire [6:0]  id_ex_funct7,
    input  wire        id_ex_reg_write,
    input  wire        id_ex_mem_read,
    input  wire        id_ex_mem_write,
    input  wire        id_ex_alu_src,
    input  wire [3:0]  id_ex_alu_op,
    input  wire        id_ex_valid,
    
    output reg  [31:0] ex_mem_pc,
    output reg  [31:0] ex_mem_alu_result,
    output reg  [31:0] ex_mem_rs2_data,
    output reg  [4:0]  ex_mem_rd,
    output reg         ex_mem_reg_write,
    output reg         ex_mem_mem_read,
    output reg         ex_mem_mem_write,
    output reg         ex_mem_valid
);

// ALU inputs
wire [31:0] alu_operand_a;
wire [31:0] alu_operand_b;

// Select ALU operands
assign alu_operand_a = id_ex_rs1_data;
assign alu_operand_b = id_ex_alu_src ? id_ex_imm : id_ex_rs2_data;

// ALU module instantiation
wire [31:0] alu_result;
wire        alu_zero;

alu alu_inst (
    .a          (alu_operand_a),
    .b          (alu_operand_b),
    .alu_op     (id_ex_alu_op),
    .funct3     (id_ex_funct3),
    .funct7     (id_ex_funct7),
    .result     (alu_result),
    .zero       (alu_zero)
);

// Branch logic
reg branch_taken;
wire [31:0] next_pc;

// Determine if branch is taken
always @(*) begin
    case ({id_ex_opcode, id_ex_funct3})
        {7'b1100011, 3'b000}: branch_taken = alu_zero;           // BEQ
        {7'b1100011, 3'b001}: branch_taken = ~alu_zero;          // BNE
        {7'b1100011, 3'b100}: branch_taken = ($signed(alu_operand_a) < $signed(alu_operand_b));   // BLT
        {7'b1100011, 3'b101}: branch_taken = ~($signed(alu_operand_a) < $signed(alu_operand_b));  // BGE
        {7'b1100011, 3'b110}: branch_taken = ($unsigned(alu_operand_a) < $unsigned(alu_operand_b)); // BLTU
        {7'b1100011, 3'b111}: branch_taken = ~($unsigned(alu_operand_a) < $unsigned(alu_operand_b)); // BGEU
        default: branch_taken = 1'b0;
    endcase
end

// Calculate next PC for branches and jumps
assign next_pc = id_ex_pc + {{20{id_ex_imm[31]}}, id_ex_imm[30:21], id_ex_imm[20], id_ex_imm[19:12], 1'b0};

// Pipeline register update
always @(posedge clk or posedge rst) begin
    if (rst) begin
        ex_mem_pc <= 32'h00000000;
        ex_mem_alu_result <= 32'h00000000;
        ex_mem_rs2_data <= 32'h00000000;
        ex_mem_rd <= 5'h00;
        ex_mem_reg_write <= 1'b0;
        ex_mem_mem_read <= 1'b0;
        ex_mem_mem_write <= 1'b0;
        ex_mem_valid <= 1'b0;
    end else if (!flush) begin
        if (id_ex_valid) begin
            // Handle branch/jump instructions
            if (id_ex_opcode == 7'b1100011 && branch_taken) begin
                ex_mem_pc <= next_pc;
            end else if (id_ex_opcode == 7'b1101111) begin // JAL
                ex_mem_pc <= next_pc;
            end else if (id_ex_opcode == 7'b1100111) begin // JALR
                ex_mem_pc <= alu_result;
            end else begin
                ex_mem_pc <= id_ex_pc + 4;
            end
            
            ex_mem_alu_result <= alu_result;
            ex_mem_rs2_data <= id_ex_rs2_data;
            ex_mem_rd <= id_ex_rd;
            ex_mem_reg_write <= id_ex_reg_write;
            ex_mem_mem_read <= id_ex_mem_read;
            ex_mem_mem_write <= id_ex_mem_write;
            ex_mem_valid <= 1'b1;
        end else begin
            ex_mem_valid <= 1'b0;
        end
    end else begin
        // Flush the pipeline
        ex_mem_valid <= 1'b0;
    end
end

endmodule