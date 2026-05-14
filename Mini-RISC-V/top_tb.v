`timescale 1ns/1ps
module top_tb;
  reg clk;
  reg rst_n;
    // 1. 实例化顶层模块
    rv32i_top uut (
        .clk(clk),
        .rst_n(rst_n)
    );

    // 2. 生成时钟 (50MHz, 周期 20ns)
    initial clk = 0;
    always #10 clk = ~clk;

    // 3. 测试流程
    initial begin
        $display("--- start ---");
        
        // 复位系统
        rst_n = 0;
        #25;           // 保持复位一段时间
        rst_n = 1;     // 释放复位
        
        // 运行 100ns，足够跑完上面几条指令
        #100;
        
        $display("--- finish ---");
        $finish;
    end
    // 4. 生成波形文件
    initial begin
        $dumpfile("cpu_sim.vcd");
        $dumpvars(0, top_tb);
        
        // 特别技巧：导出寄存器堆内部的值，方便观察结果
        // 这里的路径取决于你在 top 里的实例化名字
        $dumpvars(1, uut.u_regfile.rf[1]); // 观察 x1
        $dumpvars(1, uut.u_regfile.rf[2]); // 观察 x2
        $dumpvars(1, uut.u_regfile.rf[3]); // 观察 x3
    end

endmodule