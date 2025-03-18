load("//rules:otbn.bzl", "otbn_library", "otbn_binary","otbn_sim_test")
package(default_visibility = ["//visibility:public"])


otbn_binary(
    name="matvec_mul_test",
    srcs=["matvec_mul.s"],
    deps=["//sw/otbn/crypto/handwritten/gf16:gf16_mul"],
)