// 4位计数器模块
module counter (
    input clk,          // 时钟信号
    input rst_n,        // 异步复位信号（低电平有效）
    output reg [3:0] out // 4位输出
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            out <= 4'b0000;      // 复位时清零
        else
            out <= out + 1'b1;   // 每个时钟上升沿加1
    end

endmodule