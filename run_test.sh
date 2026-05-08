#!/bin/bash

# RISC-V 5-stage Pipeline CPU Test Script
# Using Icarus Verilog for compilation and simulation, GTKWave for waveform viewing

echo "=== RISC-V 5-stage Pipeline CPU Test ==="

# Change to script directory
cd "$(dirname "$0")"

# Create output directory
mkdir -p waveforms

# Clean up any existing files
rm -f basic_test.vvp comprehensive_test.vvp dump.lxt

echo ""
echo "1. Compiling basic test..."
iverilog -o basic_test.vvp \
    riscv_pipeline_top.v \
    if_stage.v \
    id_stage.v \
    ex_stage.v \
    alu.v \
    mem_stage.v \
    wb_stage.v \
    hazard_detection_unit.v \
    forwarding_unit.v \
    riscv_pipeline_tb.v

if [ $? -ne 0 ]; then
    echo "ERROR: Basic test compilation failed!"
    exit 1
fi

echo "2. Running basic test and generating waveform..."
vvp -n basic_test.vvp -lxt2

if [ ! -f "dump.lxt" ]; then
    echo "WARNING: Waveform file dump.lxt was not generated!"
else
    echo "3. Moving basic test waveform..."
    mv dump.lxt waveforms/basic_test.lxt
fi

echo ""
echo "4. Compiling comprehensive test..."
iverilog -o comprehensive_test.vvp \
    riscv_pipeline_top.v \
    if_stage.v \
    id_stage.v \
    ex_stage.v \
    alu.v \
    mem_stage.v \
    wb_stage.v \
    hazard_detection_unit.v \
    forwarding_unit.v \
    riscv_pipeline_comprehensive_tb.v

if [ $? -ne 0 ]; then
    echo "ERROR: Comprehensive test compilation failed!"
    exit 1
fi

echo "5. Running comprehensive test and generating waveform..."
vvp -n comprehensive_test.vvp -lxt2

if [ ! -f "dump.lxt" ]; then
    echo "WARNING: Waveform file dump.lxt was not generated!"
else
    echo "6. Moving comprehensive test waveform..."
    mv dump.lxt waveforms/comprehensive_test.lxt
fi

echo ""
echo "=== Test completed successfully! ==="
echo "Waveform files are saved in the waveforms/ directory."

# Check if GTKWave is available and launch it
if command -v gtkwave &> /dev/null; then
    echo "Launching GTKWave with comprehensive test waveform..."
    gtkwave waveforms/comprehensive_test.lxt &
else
    echo "NOTE: GTKWave not found in PATH."
    echo "To view waveforms manually, run:"
    echo "gtkwave waveforms/comprehensive_test.lxt"
fi