module pc (
    input clk,
    input rst_n,
    input [31:0] pc_next,
    output reg [31:0] pc_out
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            pc_out <= 32'b0;
        else
            pc_out <= pc_next;
    end
endmodule