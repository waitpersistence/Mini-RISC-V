module imm_gen (
    input  [31:0] inst,    // 32位原始指令
    output reg [31:0] imm  // 拼好的32位立即数
);
    wire [6:0] opcode = inst[6:0];//中间
    always@(*) begin
        case (opcode)
            7'b0010011,7'b0000011,7'b1100111:begin
                imm={{20{inst[31]}},inst[31:20]};
            end
            7'b0100011:begin
                imm={{20{inst[31]}},inst[31:25],inst[11:7]};
            end
            default: imm=32'b0;
        endcase
    end

endmodule
