//=============================================================================
// mem_stage.v - Memory Access Stage
//=============================================================================

`timescale 1ns / 1ps

module mem_stage (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [31:0] alu_result,
    input  wire [31:0] reg_write_data_in,
    input  wire        mem_read,
    input  wire        mem_write,
    output reg  [31:0] read_data
);

    reg [7:0] dmem [0:1023];

    always @(posedge clk) begin
        if (mem_write) begin
            dmem[alu_result + 0] <= reg_write_data_in[7:0];
            dmem[alu_result + 1] <= reg_write_data_in[15:8];
            dmem[alu_result + 2] <= reg_write_data_in[23:16];
            dmem[alu_result + 3] <= reg_write_data_in[31:24];
        end
    end

    always @(*) begin
        if (mem_read)
            read_data = { dmem[alu_result + 3], dmem[alu_result + 2],
                          dmem[alu_result + 1], dmem[alu_result + 0] };
        else
            read_data = 32'd0;
    end

endmodule
