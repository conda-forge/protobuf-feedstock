load("@bazel_tools//tools/python:toolchain.bzl", "py_runtime_pair")
load("@rules_python//python/cc:py_cc_toolchain.bzl", "py_cc_toolchain")

py_runtime(
    name = "python3",
    python_version = "PY3",
    interpreter_path = "PYTHON_EXE",
    interpreter_version_info = {
        "major": "PY_VER_MAJOR",
        "minor": "PY_VER_MINOR",
    },
)

py_runtime_pair(
    name = "py_runtime_pair",
    py3_runtime = ":python3",
)

toolchain(
    name = "py_toolchain",
    toolchain = ":py_runtime_pair",
    toolchain_type = "@bazel_tools//tools/python:toolchain_type",
)

toolchain(
    name = "py_cc",
    toolchain = ":py_cc_toolchain",
    toolchain_type = "@rules_python//python/cc:toolchain_type",
)

py_cc_toolchain(
    name = "py_cc_toolchain",
    headers = ":headers",
    # Newer versions of rules_python will require this
    # libs = ":libraries",
    python_version = "PY_VER",
)

cc_library(
    name = "headers",
    hdrs = glob(["include/**/*.h"]),
    includes = ["include"],
    deps = select({
        "@platforms//os:windows": [":interface_library"],
        "//conditions:default": [],
    }),
)

cc_import(
    name = "interface_library",
    interface_library = select({
        "@platforms//os:windows": "libs/pythonPY_VER_NO_DOT.lib",
        "//conditions:default": None,
    }),
    system_provided = True,
)

cc_library(
    name = "libraries",
)
