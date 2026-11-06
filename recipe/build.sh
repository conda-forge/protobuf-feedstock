#!/bin/bash
set -ex

# Workaround missing leading whitespace for mcpu stripping in bazel-toolchain
export CFLAGS=" ${CFLAGS}"
export CXXFLAGS=" ${CXXFLAGS}"
# Re-add Python include path lost by overwriting CFLAGS above
PYTHON_INCLUDE=$(python -c 'import sysconfig; print(sysconfig.get_path("include"))')
export CFLAGS="${CFLAGS} -I${PYTHON_INCLUDE}"

# Keep the array nonempty: macOS Bash 3.2 treats empty arrays as unset under -u.
# This is also Protobuf's default for regular Python builds.
# https://github.com/protocolbuffers/protobuf/blob/35cd01f9fe9afbeea38cc7b979a3b6bfcde82c03/python/BUILD.bazel#L26-L29
PYTHON_ABI_ARGS=(--//python:limited_api=true)
if [[ $(python -c 'import sysconfig; print(int(bool(sysconfig.get_config_var("Py_GIL_DISABLED"))))') == 1 ]]; then
  PYTHON_EXT_SUFFIX=$(python -c 'import sysconfig; print(sysconfig.get_config_var("EXT_SUFFIX"))')
  PYTHON_ABI_ARGS=(
    --//python:free_threaded=true
    --//python:limited_api=false
    "--//python:extension_suffix=${PYTHON_EXT_SUFFIX}"
  )
fi
export CONDA_BAZEL_TOOLCHAIN_PPC64LE_CPU=ppc

source gen-bazel-toolchain
chmod +x bazel
chmod +x bazel-standalone-*

if [[ "${target_platform}" == linux-* ]]; then
  $RECIPE_DIR/add_py_toolchain.sh
  EXTRA_BAZEL_ARGS="--extra_toolchains=//py_toolchain:py_toolchain"
fi

cd python

export PROTOC=$PREFIX/bin/protoc
if [[ "$build_platform" != "$target_platform" ]]; then
    export PROTOC=$BUILD_PREFIX/bin/protoc
fi

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
# protobuf misuses `SUPPORTED_PYTHON_VERSIONS[-1]` to mean "default python", see
# https://github.com/protocolbuffers/protobuf/issues/22313
sed -i "s|SUPPORTED_PYTHON_VERSIONS\[-1\]|\"${PY_VER}\"|g" ../MODULE.bazel

# Upgrade to a newer rules_python (required for 3.14 support)
sed -i 's/\(bazel_dep(name *= *"rules_python", *version *= *"\)[^"]*\(")\)/\11.6.0\2/' ../MODULE.bazel

export BAZEL="$(pwd)/../bazel-standalone"
../bazel-standalone-* build \
    --action_env TF_SYSTEM_LIBS=$TF_SYSTEM_LIBS \
    --action_env CFLAGS \
    --platforms=//bazel_toolchain:target_platform \
    --host_platform=//bazel_toolchain:build_platform \
    --extra_toolchains=//bazel_toolchain:cc_cf_toolchain \
    --extra_toolchains=//bazel_toolchain:cc_cf_host_toolchain \
    --crosstool_top=//bazel_toolchain:toolchain \
    ${EXTRA_BAZEL_ARGS:-} \
    "${PYTHON_ABI_ARGS[@]}" \
    --cpu=${TARGET_CPU} \
    --local_resources=cpu=${CPU_COUNT} \
    //python/dist:binary_wheel \
    --define=use_fast_cpp_protos=true

python -m pip install ../bazel-bin/python/dist/protobuf-${PKG_VERSION}-*.whl
