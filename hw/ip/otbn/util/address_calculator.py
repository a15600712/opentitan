#!/usr/bin/env python3
"""
OTBN GF16 Matrix-Vector Data Injection Generator

This script generates DATA_INJECTIONS for GF16 matrices with any number of columns.
Each hex digit in vector B represents one element in GF16.
"""

def align_up(address, alignment):
    """Align address upward to the specified alignment."""
    return (address + alignment - 1) & ~(alignment - 1)

def generate_data_injections(n_A_width=4, vector_value="8421"):
    """
    Generate DATA_INJECTIONS for GF16 matrix-vector multiplication with the specified number of columns.
    
    Args:
        n_A_width: Number of columns in the matrix
        vector_value: Value for vector B, where each hex digit is one GF16 element
    """
    # Fixed parameters
    accumulator_addr = 0x20
    accumulator_size = 64  # Must be at least 32 (256 bits)
    n_A_byte = 64  # Size of each matrix column in bytes, must be at least 32 (256 bits)
    
    # Calculate addresses
    matrix_addr = accumulator_addr + accumulator_size  # 0x60
    matrix_size = n_A_width * n_A_byte
    
    # Parameters address (4-byte aligned after matrix)
    params_addr = align_up(matrix_addr + matrix_size, 4)
    
    # Vector B address (32-byte aligned after parameters)
    vector_b_addr = align_up(params_addr + 8, 32)
    vector_b_size = (n_A_width + 7) // 8  # Size in bytes (8 elements per byte)
    
    # Generate DATA_INJECTIONS
    print("DATA_INJECTIONS = [")
    
    # Accumulator (zeros)
    print(f" (0x{accumulator_addr:x},\"0x{'00' * accumulator_size}\"),")
    
    # Matrix A (all 1s)
    print(f" (0x{matrix_addr:x},\"0x{'11' * matrix_size}\"),")
    
    # Parameters
    print(f" (0x{params_addr:x},\"0x{n_A_byte:x}\"),")
    print(f" (0x{params_addr + 4:x},\"0x{n_A_width:x}\"),")
    
    # Vector B with GF16 elements (each hex digit is one element)
    # Make sure we have enough hex digits for the number of columns
    if len(vector_value) < n_A_width:
        print(f"Warning: Vector value '{vector_value}' has fewer than {n_A_width} hex digits needed for {n_A_width} columns")
        # Pad the value with leading zeros if needed
        vector_value = vector_value.zfill(n_A_width)
    elif len(vector_value) > n_A_width:
        print(f"Warning: Vector value '{vector_value}' has more than {n_A_width} hex digits, using the last {n_A_width} digits")
        vector_value = vector_value[-n_A_width:]
    
    # Ensure the data injection is at least 256 bits (64 hex chars)
    min_hex_chars = 64  # For 256 bits (32 bytes)
    padding_chars = max(0, min_hex_chars - len(vector_value))
    padded_vector = "0" * padding_chars + vector_value
    
    print(f" (0x{vector_b_addr:x},\"0x{padded_vector}\"),")
    
    print("]")
    
    # Also print details about the memory layout
    print("\nMemory Layout Details:")
    print(f"Accumulator: 0x{accumulator_addr:x} - 0x{accumulator_addr + accumulator_size - 1:x} ({accumulator_size} bytes)")
    print(f"Matrix A: 0x{matrix_addr:x} - 0x{matrix_addr + matrix_size - 1:x} ({matrix_size} bytes, {n_A_width} columns × {n_A_byte} bytes)")
    
    print("\nMatrix A Column Addresses:")
    for i in range(min(4, n_A_width)):
        col_addr = matrix_addr + (i * n_A_byte)
        print(f"  Column {i}: 0x{col_addr:x} - 0x{col_addr + n_A_byte - 1:x}")
    
    if n_A_width > 4:
        print("  ...")
        last_cols = min(2, n_A_width - 4)
        for i in range(n_A_width - last_cols, n_A_width):
            col_addr = matrix_addr + (i * n_A_byte)
            print(f"  Column {i}: 0x{col_addr:x} - 0x{col_addr + n_A_byte - 1:x}")
    
    print(f"\nParameters:")
    print(f"  n_A_vec: 0x{params_addr:x} (value: 0x{n_A_byte:x})")
    print(f"  n_A_width: 0x{params_addr + 4:x} (value: 0x{n_A_width:x})")
    
    print(f"\nVector B: 0x{vector_b_addr:x} - 0x{vector_b_addr + max(vector_b_size, 32) - 1:x}")
    print(f"  GF16 elements (each hex digit is one element): {vector_value}")
    print(f"  DATA_INJECTION representation (at least 256 bits): 0x{padded_vector}")
    
    # Display element positions
    print("\nVector B Element Positions (in the GF16 vector):")
    for i in range(min(8, n_A_width)):
        print(f"  Element {i}: {vector_value[i] if i < len(vector_value) else '0'}")
    
    if n_A_width > 8:
        print("  ...")
        last_elems = min(4, n_A_width - 8)
        for i in range(n_A_width - last_elems, n_A_width):
            print(f"  Element {i}: {vector_value[i] if i < len(vector_value) else '0'}")

if __name__ == "__main__":
    # # Generate with 4 columns (matches the original example)
    # print("=== DATA_INJECTIONS for 4 columns ===")
    # generate_data_injections(n_A_width=4, vector_value="8421")
    
    # Generate with 32 columns
    print("\n\n=== DATA_INJECTIONS for 32 columns ===")
    generate_data_injections(n_A_width=64, vector_value="0" * 28 + "8421" )
    
    # # Generate with 64 columns
    # print("\n\n=== DATA_INJECTIONS for 64 columns ===")
    # vector64 = "0" * 60+"8421"  # 60 zeros+4 specified digits  = 64 digits
    # generate_data_injections(n_A_width=64, vector_value=vector64)


    