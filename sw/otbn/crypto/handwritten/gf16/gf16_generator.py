#!/usr/bin/env python3

import re
import subprocess

###############################################################################
# Configurable file names and Bazel target
###############################################################################
EXPECTED_OUTPUT_FILE = "expected_output.txt"
GF16_MUL_TEST_S      = "gf16_mul_test.s"
GF16_MUL_TEST_EXP    = "gf16_mul_test.exp"

# Adjust to your actual Bazel command and target
BAZEL_CMD = [
    "../../../../../bazelisk.sh",
    "test",
    "//sw/otbn/crypto/handwritten/gf16:gf16_mul_test"
]

###############################################################################
# 1) Read (b, w0) pairs from expected_output.txt
###############################################################################
def read_pairs_from_expected(file_path):
    """
    Expects lines in expected_output.txt like:
        b  = 0x0
        w0 = 0x000000000000...
        b  = 0x1
        w0 = ...
        ...
    Returns a list of tuples [(b_hex, w0_hex), ...].
    """
    pairs = []
    with open(file_path, "r") as f:
        b_val = None
        w0_val = None
        for line in f:
            line = line.strip()
            if line.startswith("b  ="):
                # e.g. line: "b  = 0x2"
                b_val = line.split('=')[1].strip()  # "0x2"
            elif line.startswith("b ="):
                # In case your file sometimes uses "b =" vs. "b  ="
                b_val = line.split('=')[1].strip()
            elif line.startswith("w0 ="):
                # e.g. line: "w0 = 0x85449add..."
                w0_val = line.split('=')[1].strip()
                # Once we have both, store and reset
                pairs.append((b_val, w0_val))
                b_val, w0_val = None, None

    return pairs

###############################################################################
# 2) Update gf16_mul_test.s to set `val_b` with the new `b`
###############################################################################
def update_b_in_test_s(file_path, new_b_hex):
    """
    Your gf16_mul_test.s might look like:
      val_b:
          .word 0x0000000F, 0, 0, 0, ...
    We'll replace that first word with your new `b`.

    If you need a single nibble, or single byte, or multiple bytes, 
    just ensure you format it properly for a 32-bit word (8 hex digits).
    """
    # Convert "0xF" -> "0000000F", so we produce ".word 0x0000000F, 0, ..."
    b_stripped = new_b_hex.replace("0x", "").upper()
    b_stripped = b_stripped.rjust(8, '0')  # up to 32 bits
    new_word_line = f".word 0x{b_stripped}, 0, 0, 0, 0, 0, 0, 0"

    with open(file_path, "r") as f:
        lines = f.readlines()

    new_lines = []
    in_val_b_block = False
    for line in lines:
        if "val_b:" in line:
            # Next line that contains .word is the one we update
            in_val_b_block = True
            new_lines.append(line)
            continue

        if in_val_b_block and ".word" in line:
            new_lines.append(f"    {new_word_line}\n")
            in_val_b_block = False
            continue

        new_lines.append(line)

    with open(file_path, "w") as f:
        f.writelines(new_lines)

###############################################################################
# 3) Update gf16_mul_test.exp with the new `w0`
###############################################################################
def update_w0_in_exp(file_path, new_w0_hex):
    """
    Suppose gf16_mul_test.exp contains a line like:
      w0 = 0xec3875a0fd2964b1...
    We'll replace that with w0 = {new_w0_hex}.
    """
    pattern_w0 = re.compile(r"(w0\s*=\s*0x[0-9A-Fa-f]+)")
    replacement = f"w0 = {new_w0_hex}"

    with open(file_path, "r") as f:
        contents = f.read()

    new_contents = pattern_w0.sub(replacement, contents)

    with open(file_path, "w") as f:
        f.write(new_contents)

###############################################################################
# 4) Run the Bazel test
###############################################################################
def run_bazel_test():
    result = subprocess.run(BAZEL_CMD, capture_output=True, text=True)
    return result

###############################################################################
# main
###############################################################################
def main():
    # Read all (b, w0) pairs from the expected_output.txt
    pairs = read_pairs_from_expected(EXPECTED_OUTPUT_FILE)
    print(f"Found {len(pairs)} pairs in {EXPECTED_OUTPUT_FILE}")

    for i, (b_val, w0_val) in enumerate(pairs, start=1):
        print(f"\n=== Iteration {i} ===")
        print(f"  b = {b_val}, w0 = {w0_val}")

        # 1) Update gf16_mul_test.s for the new b
        update_b_in_test_s(GF16_MUL_TEST_S, b_val)

        # 2) Update gf16_mul_test.exp for the new w0
        update_w0_in_exp(GF16_MUL_TEST_EXP, w0_val)

        # 3) Run Bazel
        print("  Running Bazel test...")
        result = run_bazel_test()
        print("  Bazel return code:", result.returncode)
        if result.stdout:
            print("  STDOUT:\n", result.stdout)
        if result.stderr:
            print("  STDERR:\n", result.stderr)

        # Optional: if you only want one iteration at a time, uncomment below
        # break

if __name__ == "__main__":
    main()
