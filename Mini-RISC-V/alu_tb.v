`timescale 1ns/1ps

module alu_tb;

    reg clk;
    reg rst_n;
    reg [7:0] a;
    reg [7:0] b;
    reg [1:0] opcode;
    wire [7:0] result;

    alu uut (
        .result(result),
        .a(a),
        .b(b),
        .opcode(opcode) 
    );
    initial begin
        clk=0;
        rst_n=1;
    end
    always #10 clk = ~clk;//always# 等待
    //always @是触发器
    // 3. 编写测试过程
    initial begin
        // 打印监测（可选，会在终端输出文字结果）
        $monitor("Time=%0t | opcode=%b | a=%d, b=%d | Result=%d", $time, opcode, a, b, result);

        // 测试加法 (00)
        a = 8'd10; b = 8'd5; opcode = 2'b00;
        #10; // 等待 10ns

        // 测试减法 (01)
        a = 8'd20; b = 8'd7; opcode = 2'b01;
        #10;

        // 测试按位与 (10)
        a = 8'b00000001; b = 8'b1111_1111; opcode = 2'b10;
        #10;

        // 测试按位或 (11)
        a = 8'b00000001; b = 8'0000_0000; opcode = 2'b11;
        #10;
        $finish;
    end
    initial begin
        $dumpfile("alu_test.vcd"); // 生成文件的名字
        $dumpvars(0, alu_tb);      // 导出所有信号
    end

endmodule