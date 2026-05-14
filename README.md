# RISC-V CPU Implementations in Verilog

Two RISC-V CPU implementations written in Verilog HDL, progressing from a minimal single-cycle design to a classic five-stage pipeline.

---

## Project Overview

|                | Mini-RISC-V                        | Five-Period Pipeline              |
| -------------- | ---------------------------------- | --------------------------------- |
| **目录**       | `Mini-RISC-V/`                     | `five_period/`                    |
| **执行模型**   | 单周期 (single-cycle)              | 五级流水线 (five-stage pipeline)  |
| **指令集**     | RV32I (2 条指令)                   | RV32I (18 条 ALU 指令)            |
| **流水线寄存器** | 无                               | IF/ID, ID/EX, EX/MEM, MEM/WB      |
| **数据转发**   | 不需要                             | 转发单元, 解决 RAW 冒险           |
| **指令存储器** | 64×32-bit ROM (硬编码)             | 256×32-bit ROM (从 hex 文件加载)   |
| **数据存储器** | 无                                 | 1024×8-bit (字节寻址)             |
| **适用场景**   | 入门学习, 理解 CPU 基本原理         | 理解流水线, 冒险与转发机制         |

---

## Mini-RISC-V — 最简单周期 CPU

一个极简的 RISC-V CPU, 每条指令在一个时钟周期内完成取指、译码、执行、写回。

### 架构

```
PC → 指令存储器 → 译码器 + 立即数生成 → 寄存器文件 → ALU → 写回寄存器文件
```

单周期内完成从 PC 输出到寄存器写回的全部组合逻辑路径。

### 已实现指令

| 指令 | 类型  | 说明          |
| ---- | ----- | ------------- |
| ADDI | I-type | 立即数加法   |
| ADD  | R-type | 寄存器加法   |

### 模块清单

| 模块          | 文件            | 功能                |
| ------------- | --------------- | ------------------- |
| PC            | `pc.v`          | 程序计数器, 每周期 +4 |
| 指令存储器    | `inst_mem.v`    | 64×32-bit ROM       |
| 译码器        | `decoder.v`     | 操作码/功能码译码   |
| 立即数生成    | `imm_gen.v`     | 12-bit 立即数符号扩展 |
| 寄存器文件    | `register.v`    | 32×32-bit, x0 硬连线为 0 |
| ALU           | `alu.v`         | 32-bit, 6 种运算    |
| 顶层          | `rv_32i_top.v`  | CPU 顶层集成        |

### 测试程序

```asm
addi x1, x0, 10    # x1 = 10
addi x2, x0, 20    # x2 = 20
add  x3, x1, x2    # x3 = 30
nop
```

---

## Five-Period Pipeline — 五级流水线 CPU

经典的经典五级流水线 RISC-V 处理器, 实现了完整的 RV32I 整数 ALU 指令子集, 并带有数据转发机制。

### 流水线架构

```
IF ──── ID ──── EX ──── MEM ──── WB
 |       |       |        |        |
[IMEM]  [RF]   [ALU]   [DMEM]   [MUX]
 |       |       |        |        |
pipeline_if_id  pipeline_id_ex  pipeline_ex_mem  pipeline_mem_wb
```

五条指令可以同时在流水线中执行。

### 已实现指令 (全部 RV32I 整数 ALU)

**I-type ALU (opcode 0010011):** ADDI, SLLI, SLTI, SLTIU, XORI, SRLI/SRAI, ORI, ANDI

**R-type ALU (opcode 0110011):** ADD, SUB, SLL, SLT, SLTU, XOR, SRL/SRA, OR, AND

### 数据转发

`forwarding_unit.v` 检测 RAW (read-after-write) 数据冒险:

- **MEM 级冒险 (优先):** `forward_a/b = 2'b10` — 转发 `mem_alu_result`
- **WB 级冒险:** `forward_a/b = 2'b01` — 转发 `wb_reg_write_data`
- **无冒险:** `forward_a/b = 2'b00` — 使用寄存器文件输出

EX 级使用两个 3-to-1 MUX 在寄存器数据、MEM 转发数据、WB 转发数据之间选择。

### 模块清单

| 模块           | 文件                     | 功能                    |
| -------------- | ------------------------ | ----------------------- |
| IF 级          | `if_stage.v`             | 取指                    |
| ID 级          | `id_stage.v`             | 译码 + 寄存器读取       |
| EX 级          | `ex_stage.v`             | 执行 (ALU + 转发 MUX)   |
| MEM 级         | `mem_stage.v`            | 存储器访问              |
| WB 级          | `wb_stage.v`             | 写回                    |
| IF/ID 寄存器   | `pipeline_if_id.v`       | IF→ID 流水线寄存器      |
| ID/EX 寄存器   | `pipeline_id_ex.v`       | ID→EX 流水线寄存器      |
| EX/MEM 寄存器  | `pipeline_ex_mem.v`      | EX→MEM 流水线寄存器     |
| MEM/WB 寄存器  | `pipeline_mem_wb.v`      | MEM→WB 流水线寄存器     |
| 转发单元       | `forwarding_unit.v`      | 数据冒险检测与转发      |
| 顶层           | `riscv_pipeline_top.v`   | 流水线 CPU 顶层集成     |

### 测试程序

```asm
addi x1, x0, 5      # x1 = 5
nop                 # 等待 x1 写回
nop
nop
addi x2, x1, 3      # x2 = 8 (依赖于 x1)
nop
nop
addi x3, x0, 10     # x3 = 10
nop
```

---

## 关键差异对比

| 方面             | Mini-RISC-V           | Five-Period Pipeline          |
| ---------------- | --------------------- | ----------------------------- |
| 执行模型         | 单周期                | 五级流水线                    |
| 指令数量         | 2 (ADDI, ADD)         | 18 (全部 I/R-type ALU)        |
| 译码器           | 部分 (仅 funct3=000)  | 完整 (所有 funct3/funct7)     |
| ALU 操作         | 6 种                  | 10 种                         |
| 数据转发         | 无                    | MEM/WB 双源转发               |
| 控制信号         | 2 个                  | 5 个                          |
| 流水线冒险处理   | N/A                   | 转发解决 EX 冒险              |

---

## 已知限制 (两个实现共有)

- 不支持分支/跳转指令 (PC 始终 +4)
- 不支持 load/store 指令 (流水线版本虽有 mem_read/mem_write 信号, 但译码器未拉高)
- 无流水线停顿机制 (五级流水线依赖软件插入 NOP)
- 无异常/中断处理
- 不支持特权 ISA (无机器模式 CSR)
- 指令存储器为 ROM (仅仿真时初始化, 运行时不可写)

---

## 仿真运行

### Mini-RISC-V

```sh
cd Mini-RISC-V
iverilog -o sim rv_32i_top.v pc.v inst_mem.v decoder.v imm_gen.v register.v alu.v top_tb.v
vvp sim
```

### Five-Period Pipeline

```sh
cd five_period
iverilog -o sim riscv_pipeline_top.v if_stage.v id_stage.v ex_stage.v mem_stage.v wb_stage.v \
  pipeline_if_id.v pipeline_id_ex.v pipeline_ex_mem.v pipeline_mem_wb.v forwarding_unit.v tb_pipeline.v
vvp sim
```

> 使用 Icarus Verilog (iverilog) 或 ModelSim 均可。需要将 test_program.hex 放在仿真目录下。

---

## 项目结构

```
RISC-V/
├── README.md
├── Mini-RISC-V/              # 单周期 CPU
│   ├── rv_32i_top.v          # 顶层模块
│   ├── pc.v                  # 程序计数器
│   ├── inst_mem.v            # 指令存储器
│   ├── decoder.v             # 译码器
│   ├── imm_gen.v             # 立即数生成
│   ├── register.v            # 寄存器文件
│   ├── alu.v                 # ALU
│   ├── top_tb.v              # 顶层 testbench
│   ├── alu_tb.v
│   ├── reg_tb.v
│   └── inst_mem_tb.v
│
└── five_period/              # 五级流水线 CPU
    ├── riscv_pipeline_top.v  # 顶层模块
    ├── if_stage.v            # 取指级
    ├── id_stage.v            # 译码级
    ├── ex_stage.v            # 执行级
    ├── mem_stage.v           # 访存级
    ├── wb_stage.v            # 写回级
    ├── pipeline_if_id.v      # IF/ID 流水线寄存器
    ├── pipeline_id_ex.v      # ID/EX 流水线寄存器
    ├── pipeline_ex_mem.v     # EX/MEM 流水线寄存器
    ├── pipeline_mem_wb.v     # MEM/WB 流水线寄存器
    ├── forwarding_unit.v     # 数据转发单元
    ├── tb_pipeline.v         # testbench
    ├── test_program.hex      # 测试机器码
    └── test_instruction.txt  # 测试汇编注释
```
