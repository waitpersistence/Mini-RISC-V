`timescale 1ns / 1ps

module hazard_detection_unit (
    input  wire        id_ex_mem_read,
    input  wire [4:0]  id_ex_rs1,
    input  wire [4:0]  id_ex_rs2,
    input  wire        ex_mem_mem_read,
    input  wire [4:0]  ex_mem_rd,
    input  wire        mem_wb_reg_write,
    input  wire [4:0]  mem_wb_rd,
    
    output reg         stall_if,
    output reg         stall_id,
    output reg         flush_id,
    output reg         flush_ex
);

always @(*) begin
    stall_if = 1'b0;
    stall_id = 1'b0;
    flush_id = 1'b0;
    flush_ex = 1'b0;
    
    // Load-use hazard detection
    if (id_ex_mem_read && ex_mem_mem_read) begin
        if ((id_ex_rs1 == ex_mem_rd && ex_mem_rd != 5'h00) || 
            (id_ex_rs2 == ex_mem_rd && ex_mem_rd != 5'h00)) begin
            stall_if = 1'b1;
            stall_id = 1'b1;
        end
    end
    
    // Branch misprediction flush (simplified)
    // In a complete implementation, this would be more sophisticated
    // For now, we don't implement dynamic branch prediction
    
    // Forwarding can handle most data hazards, so minimal stalling needed
end

endmodule