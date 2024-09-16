#!/bin/bash
set -ex

# Workaround missing leading whitespace for mcpu stripping in bazel-toolchain
export CFLAGS=" ${CXXFLAGS}"
export CXXFLAGS=" ${CXXFLAGS}"

source gen-bazel-toolchain
chmod +x bazel
chmod +x bazel-standalone

if [[ "${target_platform}" == linux-* ]]; then
  $RECIPE_DIR/add_py_toolchain.sh
  EXTRA_BAZEL_ARGS="--extra_toolchains=//py_toolchain:py_toolchain"
fi

cd python

export PROTOC=$PREFIX/bin/protoc
if [[ "$build_platform" == "$target_platform" ]]; then
    export PROTOC=$BUILD_PREFIX/bin/protoc
fi

ls -R ../bazel
ls -R ../bazel-standalone

export BAZEL="$(pwd)/../bazel-standalone"
../bazel-standalone build \
    --platforms=//bazel_toolchain:target_platform \
    --host_platform=//bazel_toolchain:build_platform \
    --extra_toolchains=//bazel_toolchain:cc_cf_toolchain \
    --extra_toolchains=//bazel_toolchain:cc_cf_host_toolchain \
    --crosstool_top=//bazel_toolchain:toolchain \
    ${EXTRA_BAZEL_ARGS:-} \
    --cpu=${TARGET_CPU} \
    --local_cpu_resources=${CPU_COUNT} \
    //python/dist:binary_wheel \
    --define=use_fast_cpp_protos=true

python -m pip install ../bazel-bin/python/dist/protobuf-${PKG_VERSION}-*.whl
