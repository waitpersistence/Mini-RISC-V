module decoder (
    input [31:0] inst,
    // 拆解出的寄存器索引
    output [4:0]  rs1,
    output [4:0]  rs2,
    output [4:0]  rd,
    
    // 控制信号
    output reg    reg_write_en,   // 是否要写寄存器
    output reg [3:0] alu_op,       // 给 ALU 的操作码
    output reg alu_src // 0:来自寄存器, 1:来自立即数//
    );
    // 基础拆解是固定的
    assign rd  = inst[11:7];
    assign rs1 = inst[19:15];
    assign rs2 = inst[24:20];
// 内部临时变量
    wire [6:0] opcode = inst[6:0];
    wire [2:0] funct3 = inst[14:12];
    wire [6:0] funct7 = inst[31:25];

    always @(*) begin
        //初始默认值，防止产生不该有的锁存器 (Latch)
        reg_write_en = 1'b0;
        alu_op = 4'b1111; // 无效操作
        alu_src      = 1'b0;
        case (opcode)
            7'b0110011: begin // R-Type 指令 (如 add, sub, and, or)
                alu_src=0;
                reg_write_en = 1; 
                if (funct3 == 3'b000) begin
                    if (funct7 == 7'b0000000) alu_op = 4'b0000; // ADD
                    else if (funct7 == 7'b0100000) alu_op = 4'b0001; // SUB
                end
                // 这里还可以继续写 AND, OR, XOR...
            end
            7'b0010011: begin // I-Type 指令 (如 addi)
                alu_src=1;
                reg_write_en = 1; 
                if (funct3 == 3'b000) alu_op = 4'b0000; // ADDI
                // 这里还可以继续写 ANDI, ORI, XORI...
            end
        endcase
    end
endmodule