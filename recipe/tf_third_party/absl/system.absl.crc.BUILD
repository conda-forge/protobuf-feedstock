load("@rules_cc//cc:defs.bzl", "cc_library")

package(default_visibility = ["//visibility:public"])

cc_library(
    name = "crc32c",
    linkopts = [
        "-labsl_crc32c",
        "-labsl_crc_cord_state",
        "-labsl_crc_cpu_detect",
        "-labsl_crc_internal",
    ],
    deps = [
        ":cpu_detect",
        ":crc_internal",
        ":non_temporal_memcpy",
        "//absl/base:config",
        "//absl/base:core_headers",
        "//absl/base:endian",
        "//absl/base:prefetch",
        "//absl/strings",
        "//absl/strings:str_format",
    ],
)

cc_library(
    name = "cpu_detect",
    visibility = ["//visibility:private"],
    deps = [
        "//absl/base",
        "//absl/base:config",
    ],
)

cc_library(
    name = "crc_internal",
    visibility = ["//visibility:private"],
    deps = [
        ":cpu_detect",
        "//absl/base:config",
        "//absl/base:core_headers",
        "//absl/base:endian",
        "//absl/base:prefetch",
        "//absl/base:raw_logging_internal",
        "//absl/memory",
        "//absl/numeric:bits",
    ],
)

cc_library(
    name = "non_temporal_memcpy",
    visibility = [
        ":__pkg__",
    ],
    deps = [
        ":non_temporal_arm_intrinsics",
        "//absl/base:config",
        "//absl/base:core_headers",
    ],
)

cc_library(
    name = "non_temporal_arm_intrinsics",
    visibility = [
        ":__pkg__",
    ],
    deps = [
        "//absl/base:config",
    ],
)
