load("//rules:otbn.bzl", "otbn_library", "otbn_binary", "otbn_sim_test")

# Create a library with the GF256 multiplication implementation
otbn_library(
    name = "gf256_mul",
    srcs = ["gf256_mul.s"],
)


otbn_sim_test(
    name="gf256_mul_test",
    srcs=["gf256_mul_test.s"],
    deps=[":gf256_mul"],
    exp="gf256_mul_test.exp",
)