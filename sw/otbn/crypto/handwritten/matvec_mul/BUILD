load("//rules:otbn.bzl", "otbn_library", "otbn_binary","otbn_sim_test")
package(default_visibility = ["//visibility:public"])



otbn_library(
    name = "gf16_matvec_mul",         # The library/app containing just gf16_mul
    srcs = ["gf16_matvec_mul.s"],     # Only the multiplication code
)


otbn_binary(
    name="gf16_matvec_mul_test",
    srcs=["gf16_matvec_mul_test.s"],
    deps=["//sw/otbn/crypto/handwritten/gf16:gf16_mul","//sw/otbn/crypto/handwritten/matvec_mul:gf16_matvec_mul"],
)