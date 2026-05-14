module register (
    input clk,
    input [4:0] raddr1, raddr2, waddr,// 3位地址线，最多8个寄存器 //读地址raddr1和raddr2，写地址waddr，写入数据wdata，写入使能we
    input [31:0] wdata,
    input we,
    output [31:0] rdata1,
    output [31:0] rdata2
);
    reg[31:0] rf [31:0];//定义寄存器文件，32个寄存器，每个寄存器32位宽  
    // --- 读逻辑 (组合逻辑) ---
    // 使用三元运算符：如果地址是 0，输出 0；否则输出寄存器堆里的值
    assign rdata1 = (raddr1 == 5'b0) ? 32'b0 : rf[raddr1];
    assign rdata2 = (raddr2 == 5'b0) ? 32'b0 : rf[raddr2];
    // 写逻辑（时序逻辑）
    always @(posedge clk) begin
        if (we && (waddr != 5'b0))//写使能且写地址不为0
            rf[waddr] <= wdata;//不用=，因为是时序逻辑，使用非阻塞赋值<=
    end
    // 为了防止仿真时看到一片红色 (未知态 x)，给寄存器赋初值 0
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1) rf[i] = 32'b0;
    end
endmodule