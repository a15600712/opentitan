load("//rules:otbn.bzl", "otbn_library", "otbn_binary","otbn_sim_test", "otbn_dynamic_tests")

otbn_library(
    name = "gf256_mul",
    srcs = ["gf256_mul.s"],
)

# otbn_binary(
#     name="gf256_mul_test",
#     srcs=["gf256_mul_test.s"],
#     deps=[":gf256_mul"],
    

# )

# otbn_sim_test(
#     name="gf256_mul_test",
    
#     srcs=["gf256_mul_test.s"],
#     exp="gf256_mul_test.exp",
#     deps=[":gf256_mul"],
    

# )


otbn_dynamic_tests(
    name = "gf256_mul_tests",
    srcs = ["gf256_mul_test.s"],
)

