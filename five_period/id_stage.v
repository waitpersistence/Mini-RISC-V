//=============================================================================
// id_stage.v - Decode Stage with RISC-V decoder and register file
//=============================================================================

`timescale 1ns / 1ps

module id_stage (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [31:0] instruction,
    input  wire [31:0] pc,
    input  wire        wb_reg_write_en,
    input  wire [ 4:0] wb_reg_write_dest,//五周期前那条指令执行完、现在要写回的目标寄存器。
    input  wire [31:0] wb_reg_write_data,

    output wire [31:0] reg_read_data1,
    output wire [31:0] reg_read_data2,
    output wire [ 4:0] id_rs1,
    output wire [ 4:0] id_rs2,
    output reg  [31:0] immediate,
    output reg  [ 3:0] alu_op,
    output reg         alu_src,
    output reg         mem_read,
    output reg         mem_write,
    output reg         reg_write,
    output reg  [ 4:0] reg_write_dest//当前正在译码的指令的目标寄存器
);

    reg [31:0] regfile [0:31];

    wire [4:0] rs1 = instruction[19:15];
    wire [4:0] rs2 = instruction[24:20];

    assign id_rs1          = rs1;
    assign id_rs2          = rs2;
    assign reg_read_data1 = (rs1 == 5'd0) ? 32'd0 : regfile[rs1];
    assign reg_read_data2 = (rs2 == 5'd0) ? 32'd0 : regfile[rs2];

    always @(posedge clk) begin
        if (wb_reg_write_en && (wb_reg_write_dest != 5'd0))
            regfile[wb_reg_write_dest] <= wb_reg_write_data;//直接写入寄存器堆，不考虑冒险和转发机制。
    end

    wire [6:0] opcode = instruction[6:0];
    wire [2:0] funct3 = instruction[14:12];
    wire [6:0] funct7 = instruction[31:25];

    always @(*) begin
        immediate       = 32'd0;
        alu_op          = 4'b0000;
        alu_src         = 1'b0;
        mem_read        = 1'b0;
        mem_write       = 1'b0;
        reg_write       = 1'b0;
        reg_write_dest  = 5'd0;

        case (opcode)
            7'b0010011: begin  // I-type ALU (addi, etc.)
                alu_src        = 1'b1;
                reg_write      = 1'b1;
                reg_write_dest = instruction[11:7];
                immediate      = {{20{instruction[31]}}, instruction[31:20]};
                case (funct3)
                    3'b000: alu_op = 4'b0000;  // ADDI
                    3'b001: alu_op = 4'b0001;  // SLLI
                    3'b010: alu_op = 4'b0010;  // SLTI
                    3'b011: alu_op = 4'b0011;  // SLTIU
                    3'b100: alu_op = 4'b0100;  // XORI
                    3'b101: alu_op = (funct7 == 7'b0000000) ? 4'b0101 : 4'b0110; // SRLI/SRAI
                    3'b110: alu_op = 4'b0111;  // ORI
                    3'b111: alu_op = 4'b1000;  // ANDI
                    default: alu_op = 4'b0000;
                endcase
            end

            7'b0110011: begin  // R-type ALU
                alu_src        = 1'b0;
                reg_write      = 1'b1;
                reg_write_dest = instruction[11:7];
                case ({funct7, funct3})
                    {7'b0000000, 3'b000}: alu_op = 4'b0000;  // ADD
                    {7'b0100000, 3'b000}: alu_op = 4'b1001;  // SUB
                    {7'b0000000, 3'b001}: alu_op = 4'b0001;  // SLL
                    {7'b0000000, 3'b010}: alu_op = 4'b0010;  // SLT
                    {7'b0000000, 3'b011}: alu_op = 4'b0011;  // SLTU
                    {7'b0000000, 3'b100}: alu_op = 4'b0100;  // XOR
                    {7'b0000000, 3'b101}: alu_op = 4'b0101;  // SRL
                    {7'b0100000, 3'b101}: alu_op = 4'b0110;  // SRA
                    {7'b0000000, 3'b110}: alu_op = 4'b0111;  // OR
                    {7'b0000000, 3'b111}: alu_op = 4'b1000;  // AND
                    default:              alu_op = 4'b0000;
                endcase
            end

            default: begin
                immediate       = 32'd0;
                alu_op          = 4'b0000;
                alu_src         = 1'b0;
                mem_read        = 1'b0;
                mem_write       = 1'b0;
                reg_write       = 1'b0;
                reg_write_dest  = 5'd0;
            end
        endcase
    end

    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1)
            regfile[i] = 32'd0;
    end

endmodule
