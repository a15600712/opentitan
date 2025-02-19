load("//rules:otbn.bzl", "otbn_library", "otbn_binary","otbn_sim_test")

otbn_library(
    name = "add",
    srcs = ["add.s"],
)

otbn_sim_test(
    name = "add_sim_test",
    srcs = [
        "add_sim_test.s"
    ],
    exp = "add_sim_test.exp",
    deps = [
        ":add"
    ],
)