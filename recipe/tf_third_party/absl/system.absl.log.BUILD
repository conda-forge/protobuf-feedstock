load("@rules_cc//cc:defs.bzl", "cc_library")

package(default_visibility = ["//visibility:public"])

cc_library(
    name = "check",
    linkopts = [
        "-labsl_vlog_config_internal",
        "-labsl_log_internal_check_op",
        "-labsl_log_internal_message",
        "-labsl_log_internal_nullguard",
    ],
)

alias(
    name = "absl_check",
    actual = ":check",
)

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

cc_library(
    name = "globals",
    linkopts = [
        "-labsl_hash",
        "-labsl_log_globals",
        "-labsl_log_severity",
        "-labsl_raw_logging_internal",
        "-labsl_vlog_config_internal",
    ],
    deps = [
        "//absl/base:config",
        "//absl/base:core_headers",
        "//absl/strings",
    ],
)

cc_library(
    name = "initialize",
    linkopts = [
        "-labsl_log_globals",
        "-labsl_log_initialize",
        "-labsl_log_internal_globals",
    ],
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

alias(
    name = "absl_log",
    actual = ":log",
)
