# RISC-V 五级流水线 CPU 实现报告

## 概述

本项目实现了一个完整的 RISC-V 五级流水线 CPU，支持 RV32I 基础整数指令集。原始代码存在多个语法错误，导致无法编译和运行。通过系统性地修复这些问题，我们成功实现了一个功能完整的五级流水线处理器。

## 主要问题分析

原始代码存在以下关键问题：

1. **语法错误**：多个变量被错误地声明为 `wire` 类型，但在 `always` 块中被赋值，这在 Verilog 中是不允许的。
2. **架构设计问题**：寄存器文件的写回逻辑位置不正确。
3. **测试文件语法问题**：测试平台中的 for 循环语法不符合 Verilog 标准。

## 具体更改详情

### 1. id_stage.v 文件修复

**问题**：`imm_out`、`forwarded_rs1`、`forwarded_rs2` 被声明为 `wire`，但在 `always` 块中被赋值。

**修复**：
- 将 `wire [31:0] imm_out;` 改为 `reg [31:0] imm_out;`
- 将 `wire [31:0] forwarded_rs1, forwarded_rs2;` 改为 `reg [31:0] forwarded_rs1, forwarded_rs2;`

**架构改进**：
- 在 ID 阶段正确实例化寄存器文件
- 添加了从 MEM/WB 阶段到 ID 阶段的写回信号连接
- 实现了正确的寄存器写回逻辑

### 2. ex_stage.v 文件修复

**问题**：`branch_taken` 被声明为 `wire`，但在 `always` 块中被赋值。

**修复**：
- 将 `wire branch_taken;` 改为 `reg branch_taken;`

### 3. mem_stage.v 文件修复

**问题**：`mem_read_data` 被声明为 `wire`，但在 `always` 块中被赋值。

**修复**：
- 将 `wire [31:0] mem_read_data;` 改为 `reg [31:0] mem_read_data;`

### 4. wb_stage.v 文件简化

**改进**：
- 移除了 WB 阶段的寄存器文件实例化
- 简化为只传递信号的阶段模块
- 符合标准五级流水线架构（寄存器文件在 ID 阶段）

### 5. riscv_pipeline_top.v 文件更新

**改进**：
- 正确连接了所有新增的信号端口
- 确保 ID 阶段能够接收来自 MEM/WB 阶段的写回信号
- 完善了模块间的信号连接

### 6. 测试文件修复

**riscv_pipeline_comprehensive_tb.v**：
- 修复了 for 循环的语法，使用命名块 `begin: init_mem` 和 `begin: init_data_mem`
- 确保符合 Verilog 语法标准

## 功能验证

修复后的代码通过了以下测试：

1. **基本测试** (`riscv_pipeline_tb.v`)：
   - 执行 ADDI、ADD、SW、LW 指令序列
   - 验证数据内存写入和读取功能
   - 成功完成测试并输出结果

2. **综合测试** (`riscv_pipeline_comprehensive_tb.v`)：
   - 测试多种指令类型：算术运算、逻辑运算、移位、比较、分支、跳转等
   - 包含 Load/Store 操作
   - 验证流水线正确执行复杂指令序列
   - 成功完成所有测试用例

## 架构特点

### 五级流水线结构

1. **IF (Instruction Fetch)**：指令获取
2. **ID (Instruction Decode)**：指令译码 + 寄存器读取
3. **EX (Execute)**：执行算术逻辑运算
4. **MEM (Memory Access)**：内存读写操作
5. **WB (Write Back)**：结果写回（信号传递）

### 关键特性

- **数据前递 (Data Forwarding)**：解决 RAW (Read After Write) 数据冒险
- **冒险检测 (Hazard Detection)**：处理 Load-Use 冒险
- **分支处理**：支持条件分支和无条件跳转
- **完整 RV32I 支持**：包括 R-type、I-type、S-type、B-type、U-type、J-type 指令

### 寄存器文件设计

- 寄存器文件实例化在 ID 阶段，便于实现数据前递
- x0 寄存器硬连线为 0，忽略写入操作
- 写回操作在时钟上升沿执行，确保时序正确

## 性能与正确性

- **功能正确性**：通过基本和综合测试验证
- **流水线效率**：通过前递和冒险检测机制最大化指令吞吐量
- **资源利用**：模块化设计，便于维护和扩展

## 总结

通过对原始代码的系统性修复和架构优化，我们成功实现了一个功能完整、符合标准的 RISC-V 五级流水线 CPU。修复后的代码不仅解决了所有语法错误，还改进了架构设计，使其更符合经典的五级流水线处理器实现规范。该实现能够正确执行 RV32I 指令集的各种指令，并通过了全面的功能测试。