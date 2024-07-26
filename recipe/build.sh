#!/bin/bash
set -ex

source gen-bazel-toolchain
chmod +x bazel

cd python

export PROTOC=$PREFIX/bin/protoc
if [[ "$build_platform" == "$target_platform" ]]; then
    export PROTOC=$BUILD_PREFIX/bin/protoc
fi

../bazel build //python/dist:binary_wheel --define=use_fast_cpp_protos=true

python -m pip install -f ./bazel-bin/python/dist protobuf==$PKG_VERSION
