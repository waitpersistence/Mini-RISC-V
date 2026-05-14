# Mini-RISC-V Core
基于 Verilog 实现的简易 RISC-V (RV32I) 单周期 CPU 核心。

## 已实现的指令
- [x] **ADDI**: 立即数加法
- [x] **ADD**: 寄存器加法

## 项目结构
- `pc.v`: 程序计数器
- `inst_mem.v`: 指令存储器（硬编码指令序列）
- `decoder.v`: 指令译码与控制单元
- `imm_gen.v`: 立即数扩展（支持 I-Type/S-Type）
- `register.v`: 32x32 位通用寄存器组（x0 恒为 0）
- `alu.v`: 32 位算术逻辑单元
- `rv32i_top.v`: 顶层模块集成

## 仿真验证
使用 iverilog 和 GTKWave 进行验证。通过 `top_tb.v` 验证了 $10 + 20 = 30$ 的计算逻辑。

<img width="880" height="219" alt="image" src="https://github.com/user-attachments/assets/b2a0cf21-296a-4304-a1fe-a4e615087438" />
