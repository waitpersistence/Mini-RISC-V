`timescale 1ns/1ps
module inst_mem_tb(); 
    reg clk,rst_n;
    wire [31:0] pc_out;
    wire[31:0] instruction;
    pc uut_pc(
        .clk(clk),
        .rst_n(rst_n),
        .pc_out(pc_out)
    );
    inst_mem uut_im(
        .addr(pc_out),
        .inst(instruction)
    );
    //时钟
    initial begin
        clk=0;
    end
    always #10 clk=~clk;
    //测试流程
    initial begin
        rst_n=0;
        #20;
        rst_n=1;
        #200; // 运行足够的时间观察多条指令的输出
        $finish;
    end
    initial begin
        $dumpfile("fetch_test.vcd"); // 生成波形文件名
        $dumpvars(0, inst_mem_tb);      // 导出所有信号
    end
endmodule