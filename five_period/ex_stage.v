//=============================================================================
// ex_stage.v - Execute Stage (ALU)
//=============================================================================

`timescale 1ns / 1ps

module ex_stage (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [31:0] reg_read_data1,
    input  wire [31:0] reg_read_data2,
    input  wire [31:0] immediate,
    input  wire [ 3:0] alu_op,
    input  wire        alu_src,
    input  wire [31:0] forward_data_mem,
    input  wire [31:0] forward_data_wb,
    input  wire [1:0]  forward_a,
    input  wire [1:0]  forward_b,
    output reg  [31:0] alu_result
);

    // 1. 定义经过“截胡”之后真正要用的操作数信号
    wire [31:0] real_val_a;
    wire [31:0] real_val_b_pre; // 尚未考虑立即数之前的 rs2 真实值

    // 2. 操作数 A 的 3 选 1 MUX (Forwarding 核心)
    assign real_val_a = (forward_a == 2'b10) ? forward_data_mem : // 拿 MEM 阶段的
                        (forward_a == 2'b01) ? forward_data_wb  : // 拿 WB 阶段的
                                               reg_read_data1;    // 拿寄存器堆的

    // 3. 操作数 B 的 3 选 1 MUX
    assign real_val_b_pre = (forward_b == 2'b10) ? forward_data_mem :
                            (forward_b == 2'b01) ? forward_data_wb  :
                                                   reg_read_data2;

    // 4. 最后决定 ALU 的第二个输入是来自寄存器(或前向)还是立即数
    wire [31:0] operand_b = alu_src ? immediate : real_val_b_pre;

    // ALU 计算逻辑 (保持不变，但输入换成了 real_val_a 和 operand_b)
    always @(*) begin
        case (alu_op)
            4'b0000: alu_result = real_val_a + operand_b;
            4'b0001: alu_result = real_val_a << operand_b[4:0];
            4'b0010: alu_result = ($signed(real_val_a) < $signed(operand_b)) ? 32'd1 : 32'd0;
            4'b0011: alu_result = (real_val_a < operand_b) ? 32'd1 : 32'd0;
            4'b0100: alu_result = real_val_a ^ operand_b;
            4'b0101: alu_result = real_val_a >> operand_b[4:0];
            4'b0110: alu_result = $signed(real_val_a) >>> operand_b[4:0];
            4'b0111: alu_result = real_val_a | operand_b;
            4'b1000: alu_result = real_val_a & operand_b;
            4'b1001: alu_result = real_val_a - operand_b;
            default: alu_result = 32'd0;
        endcase
    end

endmodule
