@echo on
setlocal enabledelayedexpansion

md py_toolchain

set "PYTHON_CYGPATH=%PYTHON:\=/%"
set "PY_VER_NO_DOT=%PY_VER:.=%"
set

for /f "delims=" %%i in (%RECIPE_DIR%\py_toolchain_win.bzl) do (
    set line=%%i
    set "line=!line:PYTHON_EXE=%PYTHON_CYGPATH%!"
    echo !line! >> %SRC_DIR%\py_toolchain\BUILD
)

sed -i "s/ SYSTEM_PYTHON_VERSION/ %PY_VER_NO_DOT%/g" python\dist\dist.bzl
if %ERRORLEVEL% neq 0 exit 1

cd python

set PROTOC=%LIBRARY_BIN%\protoc

@rem Shorten path in CI
@rem See https://github.com/bazelbuild/bazel/issues/18683 and https://github.com/protocolbuffers/protobuf/issues/12947
if defined CONDA_BLD_PATH (
  set "OUTPUT_BASE=--output_base=%CONDA_BLD_PATH%bazel"
) else (
  set OUTPUT_BASE=
)

..\bazel %OUTPUT_BASE% build --subcommands --action_env PYTHON_BIN_PATH=%PYTHON% --extra_toolchains=//py_toolchain:py_toolchain //python/dist:binary_wheel --define=use_fast_cpp_protos=true
if %ERRORLEVEL% neq 0 exit 1

:: `pip install dist\protobuf*.whl` does not work on windows,
:: so use a loop; there's only one wheel in dist/ anyway
for /f %%f in ('dir /b /S .\bazel-bin\python\dist') do (
    python -m pip install %%f==%PKG_VERSION%
    if %ERRORLEVEL% neq 0 exit 1
)
