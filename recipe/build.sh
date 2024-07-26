#!/bin/bash
set -ex

source gen-bazel-toolchain
chmod +x bazel
chmod +x bazel-standalone

cd python

export PROTOC=$PREFIX/bin/protoc
if [[ "$build_platform" == "$target_platform" ]]; then
    export PROTOC=$BUILD_PREFIX/bin/protoc
fi

ls -R ../bazel
ls -R ../bazel-standalone

export BAZEL="$(pwd)/../bazel-standalone"
export BAZEL_BUILD_OPTS="--platforms=//bazel_toolchain:target_platform --host_platform=//bazel_toolchain:build_platform --extra_toolchains=//bazel_toolchain:cc_cf_toolchain --extra_toolchains=//bazel_toolchain:cc_cf_host_toolchain"
../bazel-standalone build //python/dist:binary_wheel --define=use_fast_cpp_protos=true

python -m pip install -f ./bazel-bin/python/dist protobuf==$PKG_VERSION
