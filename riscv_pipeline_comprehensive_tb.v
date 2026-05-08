`timescale 1ns / 1ps

module riscv_pipeline_comprehensive_tb;

// Clock and reset
reg clk;
reg rst;

// Memory interface
wire [31:0] imem_addr;
reg  [31:0] imem_data;
wire [31:0] dmem_addr;
wire [31:0] dmem_wdata;
wire        dmem_we;
reg  [31:0] dmem_rdata;

// Instruction memory (simple ROM)
reg [31:0] instr_mem [0:255];

// Data memory (simple RAM)
reg [31:0] data_mem [0:255];

// Clock generation
always begin
    clk = 1'b0;
    #5;
    clk = 1'b1;
    #5;
end

// Memory read logic
always @(imem_addr) begin
    imem_data = instr_mem[imem_addr[9:2]]; // Word-aligned access
end

always @(dmem_addr or dmem_wdata or dmem_we) begin
    if (dmem_we) begin
        data_mem[dmem_addr[9:2]] = dmem_wdata;
    end
    dmem_rdata = data_mem[dmem_addr[9:2]];
end

// Initialize comprehensive test program
initial begin
    // Reset
    rst = 1'b1;
    #20;
    rst = 1'b0;
    
    // Load comprehensive test program
    begin: init_mem
        integer i;
        for (i = 0; i < 256; i = i + 1) begin
            instr_mem[i] = 32'h00000013; // nop (addi x0, x0, 0)
        end
    end
    
    // Test program:
    // 0: addi x1, x0, 10        -> x1 = 10
    // 1: addi x2, x0, 20        -> x2 = 20  
    // 2: add x3, x1, x2         -> x3 = 30
    // 3: sub x4, x3, x1         -> x4 = 20
    // 4: andi x5, x3, 15        -> x5 = 14 (30 & 15 = 14)
    // 5: ori x6, x1, 5          -> x6 = 15 (10 | 5 = 15)
    // 6: slli x7, x1, 2         -> x7 = 40 (10 << 2 = 40)
    // 7: srli x8, x7, 1         -> x8 = 20 (40 >> 1 = 20)
    // 8: slti x9, x1, x2        -> x9 = 1 (10 < 20 = true)
    // 9: sw x3, 0(x0)           -> mem[0] = 30
    // 10: lw x10, 0(x0)         -> x10 = 30
    // 11: beq x1, x1, 2         -> branch to instruction 13 (pc + 8)
    // 12: addi x11, x0, 99      -> should be skipped
    // 13: jal x12, 2            -> jump to instruction 15, x12 = return address
    // 14: addi x13, x0, 88      -> should be executed after jump
    // 15: jalr x14, x12, 0      -> return from subroutine
    // 16: lui x15, 0x12345      -> x15 = 0x12345000
    // 17: auipc x16, 0x1000     -> x16 = pc + 0x1000000
    // 18: nop
    // 19: nop
    // 20: jal x0, 0             -> infinite loop
    
    instr_mem[0]  = 32'h00a00093; // addi x1, x0, 10
    instr_mem[1]  = 32'h01400113; // addi x2, x0, 20
    instr_mem[2]  = 32'h002081b3; // add x3, x1, x2
    instr_mem[3]  = 32'h40118233; // sub x4, x3, x1
    instr_mem[4]  = 32'h00f1f293; // andi x5, x3, 15
    instr_mem[5]  = 32'h0050e313; // ori x6, x1, 5
    instr_mem[6]  = 32'h00209393; // slli x7, x1, 2
    instr_mem[7]  = 32'h0013d413; // srli x8, x7, 1
    instr_mem[8]  = 32'h0140a493; // slti x9, x1, 20
    instr_mem[9]  = 32'h00302023; // sw x3, 0(x0)
    instr_mem[10] = 32'h00002503; // lw x10, 0(x0)
    instr_mem[11] = 32'h00108663; // beq x1, x1, 2 (branch to 13)
    instr_mem[12] = 32'h06300593; // addi x11, x0, 99 (skipped)
    instr_mem[13] = 32'h0020066f; // jal x12, 2 (jump to 15)
    instr_mem[14] = 32'h05800693; // addi x13, x0, 88
    instr_mem[15] = 32'h00c60767; // jalr x14, x12, 0 (return)
    instr_mem[16] = 32'h123457b7; // lui x15, 0x12345
    instr_mem[17] = 32'h00100817; // auipc x16, 0x1000
    instr_mem[18] = 32'h00000013; // nop
    instr_mem[19] = 32'h00000013; // nop
    instr_mem[20] = 32'h0000006f; // jal x0, 0
    
    // Initialize data memory
    begin: init_data_mem
        integer i;
        for (i = 0; i < 256; i = i + 1) begin
            data_mem[i] = 32'h00000000;
        end
    end
    
    // Run simulation
    #500;
    
    // Display results
    $display("=== Comprehensive Test Results ===");
    $display("Data memory[0] = %h", data_mem[0]);
    $display("Simulation completed successfully!");
    
    $finish;
end

// Instantiate DUT
riscv_pipeline_top dut (
    .clk        (clk),
    .rst        (rst),
    .imem_addr  (imem_addr),
    .imem_data  (imem_data),
    .dmem_addr  (dmem_addr),
    .dmem_wdata (dmem_wdata),
    .dmem_we    (dmem_we),
    .dmem_rdata (dmem_rdata)
);

endmodule