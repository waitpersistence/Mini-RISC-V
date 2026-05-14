module inst_mem (
    input [31:0] addr,
    output [31:0] inst
);
    reg[31:0] rom[63:0];//存储rom
    assign inst=rom[addr[31:2]];//地址按字对齐，取指时忽略最低两位
    // --- 这里是“剧本”内容 ---
    initial begin
        rom[0] = 32'h00a00093; // addi x1, x0, 10 (把 10 存进 x1)
        rom[1] = 32'h01400113; // addi x2, x0, 20 (把 20 存进 x2)
        rom[2] = 32'h002081b3; // add  x3, x1, x2 (x3 = x1 + x2)
        rom[3] = 32'h00000000; // nop (空指令)
    end
endmodule