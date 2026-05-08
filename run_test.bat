@echo off
REM RISC-V 5-stage Pipeline CPU Test Script for Windows
REM Using Icarus Verilog for compilation and simulation, GTKWave for waveform viewing

echo === RISC-V 5-stage Pipeline CPU Test ===

REM Change to script directory
cd /d "%~dp0"

REM Create output directory
if not exist waveforms mkdir waveforms

REM Clean up any existing files
if exist basic_test.vvp del basic_test.vvp
if exist comprehensive_test.vvp del comprehensive_test.vvp
if exist dump.lxt del dump.lxt

echo.
echo 1. Compiling basic test...
iverilog -o basic_test.vvp ^
    riscv_pipeline_top.v ^
    if_stage.v ^
    id_stage.v ^
    ex_stage.v ^
    alu.v ^
    mem_stage.v ^
    wb_stage.v ^
    hazard_detection_unit.v ^
    forwarding_unit.v ^
    riscv_pipeline_tb.v

if errorlevel 1 (
    echo ERROR: Basic test compilation failed!
    goto end
)

echo 2. Running basic test and generating waveform...
vvp -n basic_test.vvp -lxt2

if not exist dump.lxt (
    echo WARNING: Waveform file dump.lxt was not generated!
) else (
    echo 3. Moving basic test waveform...
    move dump.lxt waveforms\basic_test.lxt
)

echo.
echo 4. Compiling comprehensive test...
iverilog -o comprehensive_test.vvp ^
    riscv_pipeline_top.v ^
    if_stage.v ^
    id_stage.v ^
    ex_stage.v ^
    alu.v ^
    mem_stage.v ^
    wb_stage.v ^
    hazard_detection_unit.v ^
    forwarding_unit.v ^
    riscv_pipeline_comprehensive_tb.v

if errorlevel 1 (
    echo ERROR: Comprehensive test compilation failed!
    goto end
)

echo 5. Running comprehensive test and generating waveform...
vvp -n comprehensive_test.vvp -lxt2

if not exist dump.lxt (
    echo WARNING: Waveform file dump.lxt was not generated!
) else (
    echo 6. Moving comprehensive test waveform...
    move dump.lxt waveforms\comprehensive_test.lxt
)

echo.
echo === Test completed successfully! ===
echo Waveform files are saved in the waveforms\ directory.

REM Check if GTKWave is available and launch it
where gtkwave >nul 2>&1
if %errorlevel% equ 0 (
    echo Launching GTKWave with comprehensive test waveform...
    start gtkwave waveforms\comprehensive_test.lxt
) else (
    echo NOTE: GTKWave not found in PATH.
    echo To view waveforms manually, run:
    echo gtkwave waveforms\comprehensive_test.lxt
)

:end
echo.
pause