module alu (
    input [31:0] a,
    input [31:0] b,
    input [3:0] opcode,
    output reg [31:0] result
);

    // 因为是在 always 块里赋值，result 已经定义为 reg 了
    always @(*) begin
        case (opcode)
            4'b0000: result = a + b;      // ADD
            4'b0001: result = a - b;      // SUB
            4'b0010: result = a & b;      // AND
            4'b0011: result = a | b;      // OR
            4'b0100: result = a ^ b;      // XOR
            4'b0101: result = a << b[4:0]; // SLL (逻辑左移，只看 b 的低 5 位)
            default: result = 32'b0;
        endcase
    end

endmodule