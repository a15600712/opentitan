#!/usr/bin/env python3

import re
import subprocess

# Files in your GF256 directory
EXPECTED_OUTPUT_FILE = "expected_output.txt"
GF256_MUL_TEST_S     = "gf256_mul_test.s"
GF256_MUL_TEST_EXP   = "gf256_mul_test.exp"

# Bazel command
BAZEL_CMD = [
    "../../../../../bazelisk.sh",
    "test",
    "//sw/otbn/crypto/handwritten/gf256:gf256_mul_test"
]

###############################################################################
# 1) Read pairs (b, w0) from expected_output.txt
###############################################################################
def read_pairs_from_expected(file_path):
    """
    Expects lines in expected_output.txt like:
        b = 0x56
        w0 = 0x85449addbb7aa4e3...
    Yields tuples of (b_hex_string, w0_hex_string).
    """
    pairs = []
    with open(file_path, "r") as f:
        b_val = None
        w0_val = None
        for line in f:
            line = line.strip()
            if line.startswith("b ="):
                b_val = line.split('=')[1].strip()   # e.g. "0x56"
            elif line.startswith("w0 ="):
                w0_val = line.split('=')[1].strip() # e.g. "0x85449add..."
                # Now we have one b/w0 pair
                pairs.append((b_val, w0_val))
                b_val = None
                w0_val = None
    return pairs

###############################################################################
# 2) Update gf256_mul_test.s to set val_b with the new 'b' value
###############################################################################
def update_b_in_test_s(file_path, new_b_hex):
    """
    Replaces the line under val_b: so that the first word is .word 0x???????? , 0, 0, 0, ...
    If your existing line looks like:
        val_b:
            .word 0x00000001, 0, 0, 0, 0, 0, 0, 0
    we'll rewrite it as something like:
        .word 0x00000056, 0, 0, 0, 0, 0, 0, 0
    where '56' comes from the user-supplied hex string (b).
    """
    b_stripped = new_b_hex.replace("0x", "").upper()
    # Pad to 8 hex digits (32 bits). If your 'b' can be multiple bytes, this is fine;
    # if you only use 1 byte, it's still correct to store in the lowest byte of that word.
    b_stripped = b_stripped.rjust(8, '0')
    new_word_line = f".word 0x{b_stripped}, 0, 0, 0, 0, 0, 0, 0"

    with open(file_path, "r") as f:
        lines = f.readlines()

    new_lines = []
    in_val_b_block = False
    for line in lines:
        # If we find "val_b:", the next line that has ".word" should be replaced
        if "val_b:" in line:
            in_val_b_block = True
            new_lines.append(line)
            continue

        if in_val_b_block and ".word" in line:
            new_lines.append(f"    {new_word_line}\n")
            in_val_b_block = False
            continue

        # Otherwise, leave the line unchanged
        new_lines.append(line)

    with open(file_path, "w") as f:
        f.writelines(new_lines)

###############################################################################
# 3) Update gf256_mul_test.exp with new_w0
###############################################################################
def update_w0_in_exp(file_path, new_w0_hex):
    """
    Example: we look for a line that says:
        w0 = 0x12345678...
    and replace it with the new w0:
        w0 = 0xDEADBEEF...
    Adjust the pattern to match how gf256_mul_test.exp is structured.
    """
    # This pattern looks for lines that contain "w0 = 0x" followed by hex digits.
    pattern_w0 = re.compile(r"(w0\s*=\s*0x[0-9A-Fa-f]+)")
    # We'll replace the entire match with:
    #   w0 = <new_w0_hex>
    # e.g. w0 = 0x000000000000....
    replacement = f"w0 = {new_w0_hex}"

    with open(file_path, "r") as f:
        contents = f.read()

    new_contents = pattern_w0.sub(replacement, contents)

    with open(file_path, "w") as f:
        f.write(new_contents)

###############################################################################
# 4) Run Bazel test
###############################################################################
def run_bazel_test():
    result = subprocess.run(BAZEL_CMD, capture_output=True, text=True)
    return result

###############################################################################
# main
###############################################################################
def main():
    # 1) Read b/w0 pairs from expected_output.txt
    pairs = read_pairs_from_expected(EXPECTED_OUTPUT_FILE)
    print(f"Found {len(pairs)} pairs in {EXPECTED_OUTPUT_FILE}")

    # 2) Iterate over each pair
    for i, (b_val, w0_val) in enumerate(pairs, start=1):
        print(f"\n=== Iteration {i} ===")
        print(f"  b = {b_val}, w0 = {w0_val}")

        # 3) Update gf256_mul_test.s for the new b
        update_b_in_test_s(GF256_MUL_TEST_S, b_val)

        # 4) Update gf256_mul_test.exp with the new w0
        update_w0_in_exp(GF256_MUL_TEST_EXP, w0_val)

        # 5) Run Bazel
        print("  Running Bazel test...")
        result = run_bazel_test()
        print("  Bazel return code:", result.returncode)
        if result.stdout:
            print("  STDOUT:\n", result.stdout)
        if result.stderr:
            print("  STDERR:\n", result.stderr)

        # If you only want to test the first pair, you can break here.
        # break

if __name__ == "__main__":
    main()
