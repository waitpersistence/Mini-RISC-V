`timescale 1ns / 1ps

module riscv_pipeline_tb;

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

// Initialize test program
initial begin
    // Reset
    rst = 1'b1;
    #20;
    rst = 1'b0;
    
    // Load test program into instruction memory
    // Test program: addi x1, x0, 10; addi x2, x0, 20; add x3, x1, x2; sw x3, 0(x0); lw x4, 0(x0)
    instr_mem[0] = 32'h00a00093; // addi x1, x0, 10
    instr_mem[1] = 32'h01400113; // addi x2, x0, 20
    instr_mem[2] = 32'h002081b3; // add x3, x1, x2
    instr_mem[3] = 32'h00302023; // sw x3, 0(x0)
    instr_mem[4] = 32'h00002203; // lw x4, 0(x0)
    instr_mem[5] = 32'h0000006f; // jal x0, 0 (infinite loop)
    
    // Initialize data memory
    data_mem[0] = 32'h00000000;
    
    // Run for enough cycles to complete the test
    #200;
    
    // Check results
    $display("Test completed");
    $display("Data memory[0] = %h", data_mem[0]);
    
    // Finish simulation
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