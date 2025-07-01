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
if [[ "$build_platform" != "$target_platform" ]]; then
    export PROTOC=$BUILD_PREFIX/bin/protoc
fi

ls -R ../bazel
ls -R ../bazel-standalone

rm -rf $SRC_DIR/third_party/abseil-cpp
cp -R $RECIPE_DIR/tf_third_party/* $SRC_DIR/third_party/
# reuses infrastructure from tensorflow; in contrast to tensorflow feedstock,
# this must use commas to separate libs, otherwise bazel breaks inscrutably
export TF_SYSTEM_LIBS="com_google_absl,zlib"

# Hacky workaround to fix some dependency issues with bazel
for f in dist/BUILD.bazel dist/dist.bzl; do
  sed -i '/@system_python\/\/:version\.bzl/d' $f
  sed -i "s|SYSTEM_PYTHON_VERSION|\"${PY_VER//./}\"|g" $f
done
# https://github.com/protocolbuffers/protobuf/issues/22313
sed -i "s|SUPPORTED_PYTHON_VERSIONS\[-1\]|\"${PY_VER}\"|g" ../MODULE.bazel
sed -i '/SUPPORTED_PYTHON_VERSIONS *= *\[/,/]/ s/^\( *\]\)/    "3.13",\n\1/' ../MODULE.bazel
if [[ "${target_platform}" == osx-* ]]; then
  # Upgrade to a newer rules_python
  sed -i 's/\(bazel_dep(name *= *"rules_python", *version *= *"\)[^"]*\(")\)/\11.5.0\2/' ../MODULE.bazel
fi

export BAZEL="$(pwd)/../bazel-standalone"
../bazel-standalone build \
    --action_env TF_SYSTEM_LIBS=$TF_SYSTEM_LIBS \
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
