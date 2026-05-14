//=============================================================================
// tb_pipeline.v - Testbench for 5-stage pipeline RISC-V CPU
//=============================================================================

`timescale 1ns / 1ps

module tb_pipeline;

    reg clk;
    reg rst_n;
    wire [31:0] debug_pc;
    wire [31:0] debug_instruction;
    wire [31:0] debug_reg_write_data;
    wire [ 4:0] debug_reg_write_dest;
    wire        debug_reg_write_en;
    integer      cycle_count;

    riscv_pipeline_top u_cpu (
        .clk                 (clk),
        .rst_n               (rst_n),
        .debug_pc            (debug_pc),
        .debug_instruction   (debug_instruction),
        .debug_reg_write_data(debug_reg_write_data),
        .debug_reg_write_dest(debug_reg_write_dest),
        .debug_reg_write_en  (debug_reg_write_en)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) cycle_count <= 0;
        else        cycle_count <= cycle_count + 1;
    end

    initial begin
        $readmemh("test_program.hex", u_cpu.u_if_stage.imem);
        $dumpfile("tb_pipeline.vcd");
        $dumpvars(0, tb_pipeline);

        rst_n = 1'b0;
        #15;
        rst_n = 1'b1;
        #200;

        $display("==============================");
        $display("x1 = %0d (exp 5)",  u_cpu.u_id_stage.regfile[1]);
        $display("x2 = %0d (exp 8)",  u_cpu.u_id_stage.regfile[2]);
        $display("x3 = %0d (exp 10)", u_cpu.u_id_stage.regfile[3]);

        if (u_cpu.u_id_stage.regfile[1] === 32'd5 &&
            u_cpu.u_id_stage.regfile[2] === 32'd8 &&
            u_cpu.u_id_stage.regfile[3] === 32'd10)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end

endmodule
