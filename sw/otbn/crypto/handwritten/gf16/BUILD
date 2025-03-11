load("//rules:otbn.bzl", "otbn_library", "otbn_binary","otbn_sim_test")
package(default_visibility = ["//visibility:public"])

otbn_library(
    name = "gf16_mul",         # The library/app containing just gf16_mul
    srcs = ["gf16_mul.s"],     # Only the multiplication code
)

otbn_sim_test(
    name = "gf16_mul_test",    # The test with 'main:'
    srcs = ["gf16_mul_test.s"],
    exp = "gf16_mul_test.exp",
    deps = [":gf16_mul"],      # So the test can call gf16_mul
)

