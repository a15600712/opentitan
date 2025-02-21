load("//rules:otbn.bzl", "otbn_library", "otbn_binary","otbn_sim_test")

otbn_library(
    name = "gf16_mul",
    srcs = ["gf16_mul.s"],
)

# otbn_binary(
#     name="gf16_mul_test",
#     srcs=["gf16_mul_test.s"],
#     deps=[":gf16_mul"],
    

# )

otbn_sim_test(
    name="gf16_mul_test",
    
    srcs=["gf16_mul_test.s"],
    exp="gf16_mul_test.exp",
    deps=[":gf16_mul"],
    

)