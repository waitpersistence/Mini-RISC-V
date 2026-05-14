//=============================================================================
// pipeline_if_id.v - IF/ID Pipeline Register
//=============================================================================

`timescale 1ns / 1ps

module pipeline_if_id (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [31:0] if_pc,
    input  wire [31:0] if_instruction,
    output reg  [31:0] id_pc,
    output reg  [31:0] id_instruction
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            id_pc          <= 32'd0;
            id_instruction <= 32'h0000_0013;
        end else begin
            id_pc          <= if_pc;
            id_instruction <= if_instruction;
        end
    end

endmodule
