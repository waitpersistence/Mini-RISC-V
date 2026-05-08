`timescale 1ns / 1ps

module if_stage (
    input  wire        clk,
    input  wire        rst,
    input  wire        stall,
    output reg  [31:0] pc_out,
    output reg  [31:0] if_id_pc,
    output reg         if_id_valid
);

always @(posedge clk or posedge rst) begin
    if (rst) begin
        pc_out <= 32'h00000000;
        if_id_pc <= 32'h00000000;
        if_id_valid <= 1'b0;
    end else if (!stall) begin
        // Update PC for next instruction
        pc_out <= pc_out + 4;
        if_id_pc <= pc_out;
        if_id_valid <= 1'b1;
    end
    // If stalled, hold current values
end

endmodule