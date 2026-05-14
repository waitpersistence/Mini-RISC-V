module pc (
    input clk,
    input rst_n,
    output reg [31:0] pc_out
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)begin
            //rst_n为0时，复位使能
            pc_out <= 32'b0;
        end
        else begin
            pc_out <= pc_out + 4;
        end
            
        
    end
endmodule