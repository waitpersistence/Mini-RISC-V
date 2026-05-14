`timescale 1ns / 1ps  // 时间单位1ns，精度1ps

module counter_tb;

    reg clk;
    reg rst_n;
    wire [3:0] out;

    // 实例化被测模块
    counter uut (
        .clk(clk),
        .rst_n(rst_n),
        .out(out)
    );

    // 生成时钟信号：每10ns翻转一次，周期为20ns
    always #10 clk = ~clk;

    initial begin
        // 初始化信号
        clk = 0;
        rst_n = 0;

        // “释放复位”（Reset Release）。
        #25 rst_n = 1;

        // 运行一段时间后停止
        #3000 $finish;
    end

    // 这一段是 iVerilog 生成波形文件的关键
    initial begin
        $dumpfile("counter_test.vcd"); // 生成文件的名字
        $dumpvars(0, counter_tb);      // 导出所有信号
    end

endmodule