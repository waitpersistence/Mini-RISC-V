# 五级流水线 RISC-V CPU

经典五级流水线 RISC-V 处理器实现，支持 RV32I 整型指令子集，采用 Verilog 硬件描述语言编写。

## 流水线架构

```
IF  ──►  ID  ──►  EX  ──►  MEM  ──►  WB
 │        │        │         │         │
[IMEM]  [RegFile] [ALU]    [DMEM]   [MUX]
```

五级流水线阶段：

| 阶段 | 模块 | 功能 |
|------|------|------|
| **IF** (Instruction Fetch) | `if_stage.v` | 从指令存储器取指，PC 自增 +4 |
| **ID** (Instruction Decode) | `id_stage.v` | 指令译码、立即数生成、寄存器堆读取 |
| **EX** (Execute) | `ex_stage.v` | ALU 运算，含前向转发多路选择 |
| **MEM** (Memory Access) | `mem_stage.v` | 数据存储器读写 |
| **WB** (Write Back) | `wb_stage.v` | 结果写回寄存器堆 |

## 流水线寄存器

| 寄存器 | 模块 | 位置 |
|--------|------|------|
| IF/ID | `pipeline_if_id.v` | IF → ID，传递 PC 和指令字 |
| ID/EX | `pipeline_id_ex.v` | ID → EX，传递控制信号、寄存器值、立即数、rs1/rs2 地址 |
| EX/MEM | `pipeline_ex_mem.v` | EX → MEM，传递 ALU 结果和访存控制信号 |
| MEM/WB | `pipeline_mem_wb.v` | MEM → WB，传递读数据和 ALU 结果 |

## 数据冒险与前向转发

```
                    ┌──────────────────────────┐
                    │     forwarding_unit.v     │
                    │  MEM/WB → EX 转发判断     │
                    └────────────┬─────────────┘
                                 │ forward_a / forward_b
                                 ▼
                    ┌──────────────────────────┐
                    │  EX Stage 3 选 1 MUX      │
                    │  00: 寄存器堆              │
                    │  01: WB 阶段结果 (旧指令)  │
                    │  10: MEM 阶段结果 (新指令) │
                    └──────────────────────────┘
```

- **MEM 级转发** 优先于 **WB 级转发**（越新的指令数据越优先）
- 前向路径将 MEM/WB 阶段的 ALU 结果直接送回 EX 阶段的操作数输入端
- 测试程序中通过插入 `NOP` 指令避免 Load-Use 型冒险（本设计中 load 指令未实现，预留该机制）

## 支持的指令

### I-type ALU
| 指令 | 功能 | funct3 |
|------|------|--------|
| ADDI | 立即数加法 | 000 |
| SLLI | 立即数逻辑左移 | 001 |
| SLTI | 带符号小于置 1 | 010 |
| SLTIU | 无符号小于置 1 | 011 |
| XORI | 立即数异或 | 100 |
| SRLI / SRAI | 逻辑 / 算术右移 | 101 |
| ORI | 立即数或 | 110 |
| ANDI | 立即数与 | 111 |

### R-type ALU
| 指令 | 功能 | funct7 + funct3 |
|------|------|-----------------|
| ADD | 加法 | 0000000_000 |
| SUB | 减法 | 0100000_000 |
| SLL | 逻辑左移 | 0000000_001 |
| SLT | 带符号小于置 1 | 0000000_010 |
| SLTU | 无符号小于置 1 | 0000000_011 |
| XOR | 异或 | 0000000_100 |
| SRL / SRA | 逻辑 / 算术右移 | 0000000_101 / 0100000_101 |
| OR | 或 | 0000000_110 |
| AND | 与 | 0000000_111 |

### ALU 操作码编码

| ALU 功能 | 编码 |
|----------|------|
| ADD | 0000 |
| SLL | 0001 |
| SLT | 0010 |
| SLTU | 0011 |
| XOR | 0100 |
| SRL | 0101 |
| SRA | 0110 |
| OR | 0111 |
| AND | 1000 |
| SUB | 1001 |

## 文件结构

```
five_period/
├── riscv_pipeline_top.v    # 顶层模块，实例化全部子模块并连线
├── if_stage.v              # IF 取指阶段 (PC + 指令存储器)
├── id_stage.v              # ID 译码阶段 (译码器 + 寄存器堆 32×32)
├── ex_stage.v              # EX 执行阶段 (ALU + 前向 MUX)
├── mem_stage.v             # MEM 访存阶段 (数据存储器 1024×8)
├── wb_stage.v              # WB 写回阶段 (结果选择 MUX)
├── forwarding_unit.v       # 前向转发单元 (冒险判断)
├── pipeline_if_id.v        # IF/ID 流水线寄存器
├── pipeline_id_ex.v        # ID/EX 流水线寄存器
├── pipeline_ex_mem.v       # EX/MEM 流水线寄存器
├── pipeline_mem_wb.v       # MEM/WB 流水线寄存器
├── tb_pipeline.v           # 测试平台
├── test_program.hex        # 测试程序 (十六进制)
└── test_instruction.txt    # 测试程序 (汇编注释)
```

## 测试程序

```
addi x1, x0, 5      # x1 = 5
nop                 # 等待 x1 写回
nop
nop
addi x2, x1, 3      # x2 = x1 + 3 = 8
nop
nop
addi x3, x0, 10     # x3 = 10
nop
```

测试程序中，`x1=5`、`x1+3` 写入 `x2=8`、直接写入 `x3=10`。`addi x2, x1, 3` 中 x1 依赖上一条指令的结果──如果无转发或无 NOP 间隔，将读到旧值。

## 仿真流程

使用 Icarus Verilog 进行仿真：

```bash
# 编译
iverilog -o sim.out \
  if_stage.v id_stage.v ex_stage.v mem_stage.v wb_stage.v \
  forwarding_unit.v \
  pipeline_if_id.v pipeline_id_ex.v pipeline_ex_mem.v pipeline_mem_wb.v \
  riscv_pipeline_top.v tb_pipeline.v

# 运行
vvp sim.out

# 查看波形
gtkwave tb_pipeline.vcd
```

## 参数规格

| 参数 | 值 |
|------|-----|
| ISA | RV32I (整型子集) |
| 流水线深度 | 5 级 |
| 指令存储器 | 256 × 32-bit |
| 数据存储器 | 1024 × 8-bit |
| 寄存器堆 | 32 × 32-bit (x0 硬连线为 0) |
| PC 初始值 | 0x00000000 |
| 复位 | 低电平有效 (rst_n) |

## 当前局限

- 不支持分支 / 跳转指令（PC 仅顺序递增）
- 不支持 Load / Store 访存指令
- 无硬件流水线停顿（stall）机制，仅在测试软件层面用 NOP 解决部分数据冒险
- 无异常 / 中断处理
- 指令存储器通过 `$readmemh` 初始化，不支持运行时修改
