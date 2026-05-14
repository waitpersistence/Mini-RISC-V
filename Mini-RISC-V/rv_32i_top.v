module rv32i_top(
    input clk,
    input rst_n
);
// --- 内部连线 (Wires) ---
    wire [31:0] pc_out;
    wire [31:0] inst;
    wire [31:0] imm;
    wire [31:0] rdata1, rdata2;
    wire [31:0] alu_result;
    wire [31:0] alu_b; // ALU 的第二个输入（MUX 后的结果）
 
    // 控制信号
    wire [4:0]  rs1, rs2, rd;
    wire [3:0]  alu_op;
    wire        reg_write_en;
    wire        alu_src_ctrl; // 0:来自寄存器, 1:来自立即数

    pc u_pc(
        .clk(clk),
        .rst_n(rst_n),
        .pc_out(pc_out)
    );
    inst_mem u_imem(
        .addr(pc_out),
        .inst(inst)
    );
    decoder u_decoder(
        .inst(inst),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .reg_write_en(reg_write_en),
        .alu_op(alu_op),
        .alu_src(alu_src_ctrl)
    );
    imm_gen u_immgen (
        .inst(inst),
        .imm(imm)
    );

    // --- 3. 执行阶段 (Execute) ---
    // 实例化寄存器堆
    register u_regfile (
        .clk(clk),
        .we(reg_write_en),
        .raddr1(rs1),
        .raddr2(rs2),
        .waddr(rd),
        .wdata(alu_result), // ALU 的计算结果写回
        .rdata1(rdata1),
        .rdata2(rdata2)
    );
    // MUX: 选择 ALU 的第二个操作数
    assign alu_b = alu_src_ctrl ? imm : rdata2;
    // 实例化 ALU
    alu u_alu (
        .a(rdata1),
        .b(alu_b),
        .opcode(alu_op),
        .result(alu_result)
    );
endmodule