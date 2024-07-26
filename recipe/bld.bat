@echo on

cd python

set PROTOC=%LIBRARY_BIN%\protoc

set "BAZEL_BUILD_OPTS=--platforms=//bazel_toolchain:target_platform --host_platform=//bazel_toolchain:build_platform --extra_toolchains=//bazel_toolchain:cc_cf_toolchain --extra_toolchains=//bazel_toolchain:cc_cf_host_toolchain"
..\bazel build //python/dist:binary_wheel
if %ERRORLEVEL% neq 0 exit 1

:: `pip install dist\protobuf*.whl` does not work on windows,
:: so use a loop; there's only one wheel in dist/ anyway
for /f %%f in ('dir /b /S .\bazel-bin\python\dist') do (
    python -m pip install %%f==%PKG_VERSION%
    if %ERRORLEVEL% neq 0 exit 1
)
