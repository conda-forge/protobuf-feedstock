@echo on
setlocal enabledelayedexpansion

md py_toolchain

set "PYTHON_CYGPATH=%PYTHON:\=/%"
set "PY_VER_NO_DOT=%PY_VER:.=%"

for /f "delims=" %%i in (%RECIPE_DIR%\py_toolchain_win.bzl) do (
    set line=%%i
    set "line=!line:PYTHON_EXE=%PYTHON_CYGPATH%!"
    echo !line! >> %SRC_DIR%\py_toolchain\BUILD
)

sed -i "s/ SYSTEM_PYTHON_VERSION/ %PY_VER_NO_DOT%/g" python\dist\dist.bzl

type python\dist\dist.bzl

cd python

set PROTOC=%LIBRARY_BIN%\protoc

..\bazel query "//python/dist:*"
if %ERRORLEVEL% neq 0 exit 1

..\bazel build --action_env PYTHON_BIN_PATH=%PYTHON% --extra_toolchains=//py_toolchain:py_toolchain //python/dist:binary_wheel
if %ERRORLEVEL% neq 0 exit 1

:: `pip install dist\protobuf*.whl` does not work on windows,
:: so use a loop; there's only one wheel in dist/ anyway
for /f %%f in ('dir /b /S .\bazel-bin\python\dist') do (
    python -m pip install %%f==%PKG_VERSION%
    if %ERRORLEVEL% neq 0 exit 1
)
