load("@rules_cc//cc:defs.bzl", "cc_library")

package(default_visibility = ["//visibility:public"])

cc_library(
    name = "die_if_null",
    linkopts = ["-labsl_die_if_null"],
    deps = [
        ":log",
        "//absl/base:config",
        "//absl/base:core_headers",
        "//absl/strings",
    ],
)

alias(
    name = "absl_log",
    actual = ":log",
)

cc_library(
    name = "log",
    linkopts = [
        "-labsl_vlog_config_internal",
        "-labsl_log_internal_conditions",
        "-labsl_log_internal_check_op",
        "-labsl_log_internal_message",
        "-labsl_log_internal_nullguard",
    ],
)

cc_library(
    name = "check",
    linkopts = [
        "-labsl_vlog_config_internal",
        "-labsl_log_internal_check_op",
        "-labsl_log_internal_message",
        "-labsl_log_internal_nullguard",
    ],
)
