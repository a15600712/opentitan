load("//rules:otbn.bzl", "otbn_library", "otbn_binary","otbn_sim_test")
package(default_visibility = ["//visibility:public"])


otbn_library(
    name = "gf16_mul",         
    srcs = ["gf16_mul.s"],     
)

otbn_binary(
    name="matvec_mul_test",
    srcs=["matvec_mul.s"],
    deps=[":gf16_mul"],
)