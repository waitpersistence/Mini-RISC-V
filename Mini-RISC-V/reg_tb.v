`timescale 1ns/1ps
module register_tb;
    reg  clk;
    reg  [2:0] raddr1, raddr2, waddr;
    reg [7:0] wdata;
    reg  we;
    wire [7:0] rdata1, rdata2;//定义wire这是在testBench下，相等于连接电路的输出
    register uut (
        .clk(clk),
        .raddr1(raddr1),
        .raddr2(raddr2),
        .waddr(waddr),
        .wdata(wdata),
        .we(we),
        .rdata1(rdata1),
        .rdata2(rdata2)
    );
    // 3. 时钟生成 (周期 20ns)
    initial clk = 0;
    always #10 clk = ~clk;
    // 4. 测试流程
    initial begin
        // --- 场景 1: 零时刻初始化 ---
        // 消除波形开头的红线 X
        we = 0; waddr = 0; wdata = 0;
        raddr1 = 0; raddr2 = 0;
        
        #20; // 等待两个时钟周期

        // --- 场景 2: 基本写入与读取 ---
        // 在 0 号地址写入 8'hA5
        $display("Task 1: Writing A5 to Addr 0");
        we = 1; waddr = 3'd0; wdata = 8'hA5;
        #20; // 等待上升沿触发写入
        we = 0; 
        #10;
        if (rdata1 == 8'hA5) $display("Result: Addr 0 Success!");
        else $display("Result: Addr 0 Failed! Get %h", rdata1);

        // --- 场景 3: 写使能 (we) 无效测试 ---
        // 尝试在 we=0 时改写 0 号地址
        $display("Task 2: Testing Write Enable (we=0)");
        we = 0; waddr = 3'd0; wdata = 8'hFF;
        #20; 
        if (rdata1 == 8'hA5) $display("Result: WE Test Passed! (Data remained A5)");
        else $display("Result: WE Test Failed! (Data corrupted to %h)", rdata1);

        // --- 场景 4: 双端口同时读取测试 ---
        // 先给 1 号地址写点东西
        $display("Task 3: Dual Port Read Test");
        we = 1; waddr = 3'd1; wdata = 8'h5A;
        #20;
        we = 0;
        // 同时读取 0 号和 1 号地址
        raddr1 = 3'd0; raddr2 = 3'd1;
        #10;
        $display("Read Port 1: %h | Read Port 2: %h", rdata1, rdata2);

        // --- 场景 5: 边界测试 (最后一个寄存器) ---
        $display("Task 4: Boundary Test (Addr 7)");
        we = 1; waddr = 3'd7; wdata = 8'hEF;
        #20;
        we = 0; raddr1 = 3'd7;
        #10;
        $display("Final Check Addr 7: %h", rdata1);
        $finish;
    end

    initial begin
        $dumpfile("register_tb_test.vcd"); // 生成文件的名字
        $dumpvars(0, register_tb);      // 导出所有信号

    end
endmodule