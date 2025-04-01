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
OPENTITAN_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..', '..', '..'))
sys.path.insert(0, OPENTITAN_ROOT)

###########################################
# CONFIGURATION SECTION - MODIFY AS NEEDED
###########################################

# Path to the ELF file to execute (relative to OPENTITAN_ROOT)
ELF_FILE = "/home/anon/otbn-mq/opentitan/bazel-bin/sw/otbn/crypto/handwritten/matvec_mul/gf16_matvec_mul_test.elf"

# Data injections as a list of (offset, data) tuples
# Each tuple specifies:
#   - offset: memory offset in bytes (integer) - must be word-aligned (multiple of 4)
#   - data: hex string representing bytes to inject
DATA_INJECTIONS = [
 (0x20,"0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"),
 (0x60,"0x111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777"),
 (0x860,"0x40"),
 (0x864,"0x20"),
 (0x880,"0x0000000000000000000000000000000000000000000000000000000000008422"),
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
def dump_dmem_hex(sim, start_addr=0, length=None, output_file=None):
    """Dump DMEM contents in a human-readable hex format.

    Args:
        sim: The simulator instance
        start_addr: Starting address to dump (default: 0)
        length: Number of bytes to dump (default: all)
        output_file: File to write to (default: stdout)
    """
    out = output_file if output_file else sys.stdout
    dmem_bytes = bytearray(sim.dump_data())

    # Each word in DMEM dump has 1 validity byte + 4 data bytes
    words_per_line = 4
    addr = start_addr
    end_addr = len(dmem_bytes) // 5 * 4  # Convert to actual address space
    if length is not None:
        end_addr = min(end_addr, start_addr + length)

    print(f"\n====== DMEM CONTENTS ({start_addr:#x}-{end_addr-1:#x}) ======", file=out)

    while addr < end_addr:
        # Print address at start of line
        line = f"{addr:#08x}:"

        # Print up to words_per_line words
        for i in range(words_per_line):
            if addr + i*4 >= end_addr:
                break

            word_addr = addr + i*4
            dmem_offset = (word_addr // 4) * 5

            # Check validity byte
            if dmem_bytes[dmem_offset] == 1:
                # Extract the word (4 bytes)
                word = struct.unpack_from("<I", dmem_bytes, dmem_offset + 1)[0]
                line += f" {word:08x}"
            else:
                line += " xxxxxxxx"

        print(line, file=out)
        addr += words_per_line * 4

def hex_string_to_words(hex_str: str) -> List[int]:
    """Convert a hex string to a list of 32-bit words.

    The words are returned in the correct order for OTBN memory layout
    (LSB word first).
    """
    # Remove '0x' prefix if present
    if hex_str.startswith('0x'):
        hex_str = hex_str[2:]

    # Pad with zeros to ensure it's a multiple of 8 chars (32 bits)
    while len(hex_str) % 8 != 0:
        hex_str = '0' + hex_str

    # Convert to list of 32-bit words
    words = []
    for i in range(0, len(hex_str), 8):
        word_hex = hex_str[i:i+8]
        word = int(word_hex, 16)
        words.append(word)

    # Reverse the list since OTBN memory has the least significant
    # word (LSW) first in memory
    return list(reversed(words))

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
    elf_path = os.path.abspath(ELF_FILE)
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

        # Get the current DMEM contents
        dmem_bytes = bytearray(sim.dump_data())

        # For each injection, update the valid byte (1) and word value
        for offset, hex_data in DATA_INJECTIONS:
            words = hex_string_to_words(hex_data)
            print(f"  - Injecting {len(words)} words at offset 0x{offset:x}")

            # Each word in DMEM is represented by 5 bytes:
            # 1 validity byte followed by 4 bytes for the word
            for i, word in enumerate(words):
                word_offset = offset + (i * 4)
                dmem_offset = (word_offset // 4) * 5

                # Ensure we're within bounds
                if dmem_offset + 4 >= len(dmem_bytes):
                    print(f"Warning: Offset 0x{word_offset:x} is out of bounds")
                    continue

                # Set validity byte to 1 (valid)
                dmem_bytes[dmem_offset] = 1

                # Set the word value (little-endian)
                struct.pack_into("<I", dmem_bytes, dmem_offset + 1, word)

        # Load the modified DMEM back into the simulator
        sim.load_data(bytes(dmem_bytes), has_validity=True)

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

    # Add this after the final register values section
    print("\n========== DMEM CONTENTS ==========")

    dump_dmem_hex(sim, 0x0, 0x8000)

    return 0

if __name__ == "__main__":
    sys.exit(main())