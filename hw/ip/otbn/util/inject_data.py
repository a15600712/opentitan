#!/usr/bin/env python3
# Copyright lowRISC contributors.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

'''
OTBN Data Injection and Register Dump Script

This script runs an OTBN ELF file with custom data injected into memory
locations and dumps register values after execution for analysis.
'''

import os
import sys
import struct
from typing import List, Tuple, Dict, TextIO

# Add OTBN tools to the Python path
# Adjust these paths based on your OpenTitan repository location
OPENTITAN_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..', '..'))
sys.path.insert(0, OPENTITAN_ROOT)

###########################################
# CONFIGURATION SECTION - MODIFY AS NEEDED
###########################################

# Path to the ELF file to execute (relative to OPENTITAN_ROOT)
ELF_FILE = "/home/anon/Chelpis_intern/otbn-mq/opentitan/bazel-out/k8-fastbuild-ST-1df456420242/bin/sw/otbn/crypto/handwritten/gf16/gf16_mul_test.elf"

# Data injections as a list of (offset, data) tuples
# Each tuple specifies:
#   - offset: memory offset in bytes (integer)
#   - data: hex string representing bytes to inject
DATA_INJECTIONS = [
    # Example: Inject 32-bit word 0x12345678 at offset 0x100
    (0x00, "1111111111111111111111111111111111111111111111111111111111111112"),
    
    # Example: Inject a 64-bit value at offset 0x200
    (0x20, "A"),
]

# Display verbose execution output
VERBOSE = False

# Register dump settings
DUMP_ALL_REGISTERS = True  # Set to False to only dump registers that changed
REG_DUMP_FILE = None  # Set to a filename to write register dump to a file
                     # Example: "registers.txt"

# Additional output files (None means don't output)
STATS_FILE = None  # e.g., "stats.txt"
DMEM_DUMP_FILE = None  # e.g., "dmem.bin"

###########################################
# IMPLEMENTATION
###########################################

def parse_hex_bytes(hex_str: str) -> bytes:
    """Parse a hex string into bytes."""
    # Remove '0x' prefix if present
    if hex_str.startswith('0x'):
        hex_str = hex_str[2:]
    
    # Handle odd-length hex strings by padding with leading zero
    if len(hex_str) % 2 != 0:
        hex_str = '0' + hex_str
    
    return bytes.fromhex(hex_str)

def dump_registers(sim, output_file: TextIO = None):
    """Dump all register values to the specified output file or stdout."""
    out = output_file if output_file else sys.stdout
    
    # Dump special registers
    for reg in ['ERR_BITS', 'INSN_CNT', 'STOP_PC']:
        value = sim.state.ext_regs.read(reg, False)
        print(f" {reg} = 0x{value:08x}", file=out)
    
    # Dump general purpose registers (x0-x31)
    for idx, value in enumerate(sim.state.gprs.peek_unsigned_values()):
        print(f" x{idx:<2} = 0x{value:08x}", file=out)
    
    # Dump wide data registers (w0-w31)
    for idx, value in enumerate(sim.state.wdrs.peek_unsigned_values()):
        print(f" w{idx:<2} = 0x{value:064x}", file=out)

def main():
    try:
        # Now import the OTBN simulator modules
        from hw.ip.otbn.dv.otbnsim.sim.standalonesim import StandaloneSim
        from hw.ip.otbn.dv.otbnsim.sim.load_elf import load_elf
        from hw.ip.otbn.dv.otbnsim.sim.stats import ExecutionStatAnalyzer
    except ImportError as e:
        print(f"Error importing OTBN modules: {e}", file=sys.stderr)
        print(f"Make sure OPENTITAN_ROOT is set correctly (currently: {OPENTITAN_ROOT})", 
              file=sys.stderr)
        return 1

    # Validate configuration
    elf_path = os.path.join(OPENTITAN_ROOT, ELF_FILE)
    if not os.path.isfile(elf_path):
        print(f"Error: ELF file '{elf_path}' not found", file=sys.stderr)
        return 1
    
    # Create the simulator
    sim = StandaloneSim()
    
    # Load the ELF file
    try:
        print(f"Loading ELF file: {elf_path}")
        exp_end_addr = load_elf(sim, elf_path)
    except Exception as e:
        print(f"Error loading ELF file: {e}", file=sys.stderr)
        return 1
    
    # Process data injections
    if DATA_INJECTIONS:
        print(f"Injecting data at {len(DATA_INJECTIONS)} location(s)")
        # First get the current DMEM contents
        dmem = sim.dump_data()
        new_dmem = bytearray()
        
        # Extract raw data bytes
        for i in range(0, len(dmem), 5):
            valid_byte = dmem[i]
            data_bytes = dmem[i+1:i+5]
            new_dmem.extend(data_bytes)
        
        # Inject the data
        for offset, data_hex in DATA_INJECTIONS:
            data = parse_hex_bytes(data_hex)
            print(f"  - Injecting {len(data)} bytes at offset 0x{offset:x}")
            
            if offset < 0 or offset + len(data) > len(new_dmem):
                print(f"Warning: Offset 0x{offset:x} may be out of bounds (DMEM size: {len(new_dmem)} bytes)")
            
            # Inject the data
            for i in range(len(data)):
                if offset + i < len(new_dmem):
                    new_dmem[offset + i] = data[i]
        
        # Load the modified DMEM back into the simulator
        sim.load_data(bytes(new_dmem), False)
    
    # Set up simulation with default keys
    key0 = int("deadbeef" * 12, 16)
    key1 = int("baadf00d" * 12, 16)
    sim.state.wsrs.set_sideload_keys(key0, key1)
    sim.state.ext_regs.commit()
    
    # Start the simulation
    sim.start(collect_stats=True)
    
    # Prepare file for register dump during execution if requested
    execution_reg_dump_file = None
    if REG_DUMP_FILE:
        try:
            execution_reg_dump_file = open(REG_DUMP_FILE, 'w')
            print(f"Will write execution register changes to {REG_DUMP_FILE}")
        except Exception as e:
            print(f"Error opening register dump file: {e}", file=sys.stderr)
            return 1
    
    # Run the simulation
    print(f"Running OTBN simulation...")
    sim.run(verbose=VERBOSE, dump_file=execution_reg_dump_file)
    
    # Close register dump file if opened
    if execution_reg_dump_file:
        execution_reg_dump_file.close()
    
    # Check if simulation ended at expected address (if specified)
    if exp_end_addr is not None and sim.state.pc != exp_end_addr:
        print(f"Warning: Simulation stopped at PC {sim.state.pc:#x}, "
              f"but expected end address was {exp_end_addr:#x}")
    
    # Get execution statistics
    if sim.stats is not None:
        analyzer = ExecutionStatAnalyzer(sim.stats, elf_path)
        stats_output = analyzer.dump()
        
        # Write stats to file if requested
        if STATS_FILE:
            try:
                with open(STATS_FILE, 'w') as f:
                    f.write(stats_output)
                print(f"Statistics written to {STATS_FILE}")
            except Exception as e:
                print(f"Error writing statistics file: {e}", file=sys.stderr)
        else:
            # Print stats to console
            print("\nExecution Statistics:")
            print(stats_output)
    
    # Dump DMEM if requested
    if DMEM_DUMP_FILE:
        try:
            with open(DMEM_DUMP_FILE, 'wb') as f:
                f.write(sim.dump_data())
            print(f"DMEM contents written to {DMEM_DUMP_FILE}")
        except Exception as e:
            print(f"Error writing DMEM dump file: {e}", file=sys.stderr)
    
    # Dump final register values
    print("\n========== FINAL REGISTER VALUES ==========")
    if REG_DUMP_FILE:
        print(f"Register values already written to {REG_DUMP_FILE}")
    else:
        # Dump registers to stdout
        dump_registers(sim)
    
    # Print final status summary
    err_bits = sim.state.ext_regs.read('ERR_BITS', False)
    insn_cnt = sim.state.ext_regs.read('INSN_CNT', False)
    stop_pc = sim.state.ext_regs.read('STOP_PC', False)
    
    print(f"\nSimulation summary:")
    print(f"  Instructions executed: {insn_cnt}")
    print(f"  Final PC: {sim.state.pc:#x}")
    print(f"  Stop PC: {stop_pc:#x}")
    print(f"  Error bits: {err_bits:#x}")
    
    if err_bits != 0:
        # Import error bit definitions
        from hw.ip.otbn.dv.otbnsim.sim.constants import ErrBits
        
        # Print names of set error bits
        print("\nErrors detected:")
        for bit_name in dir(ErrBits):
            if bit_name.startswith('_'):
                continue
            bit_value = getattr(ErrBits, bit_name)
            if isinstance(bit_value, int) and (err_bits & bit_value):
                print(f"  {bit_name}")
    
    return 0

if __name__ == "__main__":
    sys.exit(main())