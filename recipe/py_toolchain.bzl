load("@rules_python//python:py_runtime.bzl", "py_runtime")
load("@rules_python//python:py_runtime_pair.bzl", "py_runtime_pair")

py_runtime(
    name = "python3",
    python_version = "PY3",
    interpreter_path = '@@SRC_DIR@@/python.shebang',
    stub_shebang = '#!@@SRC_DIR@@/python.shebang',
)

py_runtime_pair(
    name = "py_runtime_pair",
    py3_runtime = ":python3",
)

toolchain(
    name = "py_toolchain_rules_python",
    toolchain = ":py_runtime_pair",
    toolchain_type = "@rules_python//python:toolchain_type",
)

toolchain(
    name = "py_toolchain_bazel_tools",
    toolchain = ":py_runtime_pair",
    toolchain_type = "@bazel_tools//tools/python:toolchain_type",
)
