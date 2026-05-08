# RISC-V 5-Stage Pipeline CPU - Usage Guide

## Directory Structure
```
RISC-V/
├── alu.v                    # ALU module
├── ex_stage.v               # Execute stage
├── forwarding_unit.v        # Forwarding unit
├── hazard_detection_unit.v  # Hazard detection unit
├── id_stage.v               # Instruction decode stage
├── if_stage.v               # Instruction fetch stage
├── mem_stage.v              # Memory access stage
├── wb_stage.v               # Write back stage
├── riscv_pipeline_top.v     # Top-level module
├── riscv_pipeline_tb.v      # Basic testbench
├── riscv_pipeline_comprehensive_tb.v  # Comprehensive testbench
├── run_test.bat             # Windows test script
├── run_test.sh              # Linux/Mac test script
└── README.md                # This file
```

## Windows PowerShell Usage

### 1. Ensure Required Tools are Installed
- **Icarus Verilog**: https://iverilog.fandom.com/wiki/Installation_Guide
- **GTKWave**: Usually installed with Icarus Verilog

### 2. Run Tests in PowerShell
```powershell
# Navigate to project directory
cd e:\verilog\RISC-V

# Run test script (note the .\ prefix)
.\run_test.bat
```

### 3. If You Get Execution Policy Error
If you see "cannot load file... because running scripts is disabled", run:
```powershell
# Temporarily allow script execution for current user
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## Command Prompt (CMD) Usage
```cmd
cd e:\verilog\RISC-V
run_test.bat
```

## Test Content Description

### Basic Test (riscv_pipeline_tb.v)
- Instructions tested: `addi`, `add`, `sw`, `lw`
- Expected result: Memory address 0 contains value 30

### Comprehensive Test (riscv_pipeline_comprehensive_tb.v)
- Tests all RV32I instruction types:
  - R-type: ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU
  - I-type: ADDI, ANDI, ORI, XORI, SLLI, SRLI, SRAI, SLTI, SLTIU, JALR
  - S-type: SW
  - B-type: BEQ, BNE, BLT, BGE, BLTU, BGEU
  - U-type: LUI, AUIPC
  - J-type: JAL

## Waveform Viewing
- Tests automatically launch GTKWave when completed
- Waveform files saved in `waveforms/` directory
- If GTKWave doesn't auto-start, manually run:
  ```cmd
  gtkwave waveforms\comprehensive_test.lxt
  ```

## Troubleshooting

### Common Issue 1: "CommandNotFoundException"
**Error**: `The term 'run_test.bat' is not recognized`
**Solution**: Use `.\run_test.bat` instead of `run_test.bat`

### Common Issue 2: Tools Not Found
**Error**: `'iverilog' is not recognized as an internal or external command`
**Solution**: 
1. Verify Icarus Verilog is properly installed
2. Add Icarus Verilog bin directory to system PATH environment variable
3. Restart PowerShell or Command Prompt

### Common Issue 3: No Waveform Generated
**Possible cause**: Simulation errors during execution
**Solution**: 
1. Check console output for error messages
2. Verify all Verilog files have correct syntax
3. Manually debug compilation:
   ```cmd
   iverilog -o test.vvp riscv_pipeline_top.v if_stage.v id_stage.v ex_stage.v alu.v mem_stage.v wb_stage.v hazard_detection_unit.v forwarding_unit.v riscv_pipeline_tb.v
   vvp -n test.vvp -lxt2
   ```

## Supported RISC-V Features
- ✅ RV32I base integer instruction set
- ✅ 5-stage pipeline architecture (IF/ID/EX/MEM/WB)
- ✅ Data forwarding
- ✅ Load-Use hazard detection
- ✅ Branch handling
- ✅ Complete register file (x0-x31)

---
**Note**: Register x0 is hardwired to 0 and ignores write operations.