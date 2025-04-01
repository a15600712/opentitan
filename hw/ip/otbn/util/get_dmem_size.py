import os
import sys
import struct
from typing import List, Tuple, Dict, TextIO

# Add OTBN tools to the Python path
# Adjust these paths based on your OpenTitan repository location
OPENTITAN_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..', '..', '..'))
sys.path.insert(0, OPENTITAN_ROOT)

from hw.ip.otbn.dv.otbnsim.sim.standalonesim import StandaloneSim
from hw.ip.otbn.dv.otbnsim.sim.load_elf import load_elf
ELF_FILE = "/home/anon/otbn-mq/opentitan/bazel-bin/sw/otbn/crypto/handwritten/matvec_mul/gf16_matvec_mul_test.elf"

elf_path = os.path.abspath(ELF_FILE)

sim = StandaloneSim()
# Load the ELF file
exp_end_addr = load_elf(sim, elf_path)
data_bytes = len(sim.dump_data())  # total including IMEM and overhead
# Number of 32-bit words stored
num_words = data_bytes // 5
raw_bytes = num_words * 4 /1024
print(f"Usable memory bytes: {raw_bytes}")
