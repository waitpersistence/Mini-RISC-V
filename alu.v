`timescale 1ns / 1ps

module alu (
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire [3:0]  alu_op,
    input  wire [2:0]  funct3,
    input  wire [6:0]  funct7,
    output reg  [31:0] result,
    output wire        zero
);

// Zero flag
assign zero = (result == 32'h00000000);

always @(*) begin
    case (alu_op)
        4'b0000: begin // ADD/SUB
            if (funct3 == 3'b000 && funct7[5] == 1'b1) begin
                result = a - b; // SUB
            end else begin
                result = a + b; // ADD/ADDI
            end
        end
        4'b0001: result = a & b;           // AND/ANDI
        4'b0010: result = a | b;           // OR/ORI
        4'b0011: result = a ^ b;           // XOR/XORI
        4'b0100: result = a << b[4:0];     // SLL/SLLI
        4'b0101: begin // SRL/SRA/SRLI/SRAI
            if (funct3 == 3'b101 && funct7[5] == 1'b1) begin
                result = $signed(a) >>> b[4:0]; // SRA/SRAI
            end else begin
                result = a >> b[4:0];           // SRL/SRLI
            end
        end
        4'b0110: result = ($signed(a) < $signed(b)) ? 32'h00000001 : 32'h00000000; // SLT/SLTI
        4'b0111: result = (a < b) ? 32'h00000001 : 32'h00000000;                   // SLTU/SLTIU
        default: result = a + b;
    endcase
end

endmodule