//=============================================================================
// if_stage.v - Instruction Fetch Stage
// IMEM: 256 x 32-bit (64 instructions max)
// PC increments by 4 each cycle (no branches)
//=============================================================================

`timescale 1ns / 1ps

module if_stage (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [31:0] pc_next,
    output reg  [31:0] pc,
    output wire [31:0] instruction
);

    reg [31:0] imem [0:255];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            pc <= 32'h0000_0000;
        else
            pc <= pc + 32'd4;
    end

    assign instruction = imem[pc[31:2]];

    integer i;
    initial begin
        for (i = 0; i < 256; i = i + 1)
            imem[i] = 32'h0000_0013;
    end

endmodule
