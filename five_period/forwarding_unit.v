//=============================================================================
// forwarding_unit.v - Data Forwarding Unit for Pipeline Hazard Resolution
//=============================================================================

`timescale 1ns / 1ps

module forwarding_unit (
    input  wire [4:0] ex_rs1,
    input  wire [4:0] ex_rs2,
    input  wire [4:0] mem_rd,
    input  wire       mem_reg_write,
    input  wire [4:0] wb_rd,
    input  wire       wb_reg_write,
    output wire [1:0] forward_a,
    output wire [1:0] forward_b
);

    // MEM hazard has priority over WB hazard
    assign forward_a = (mem_reg_write && (mem_rd != 5'd0) && (mem_rd == ex_rs1)) ? 2'b10 :
                       (wb_reg_write  && (wb_rd  != 5'd0) && (wb_rd  == ex_rs1)) ? 2'b01 :
                                                                                    2'b00;

    assign forward_b = (mem_reg_write && (mem_rd != 5'd0) && (mem_rd == ex_rs2)) ? 2'b10 :
                       (wb_reg_write  && (wb_rd  != 5'd0) && (wb_rd  == ex_rs2)) ? 2'b01 :
                                                                                    2'b00;

endmodule
