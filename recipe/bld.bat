@echo on
setlocal enabledelayedexpansion

md py_toolchain

xcopy /s /y /i %PREFIX%\libs %SRC_DIR%\py_toolchain\libs
if %ERRORLEVEL% neq 0 exit 1

xcopy /s /y /i %PREFIX%\include %SRC_DIR%\py_toolchain\include
if %ERRORLEVEL% neq 0 exit 1

set "PYTHON_CYGPATH=%PYTHON:\=/%"
set "PY_VER_NO_DOT=%PY_VER:.=%"

for /f "tokens=1,2 delims=." %%a in ("%PY_VER%") do (
    set PY_VER_MAJOR=%%a
    set PY_VER_MINOR=%%b
)

set

@rem for /f "delims=" %%i in (%RECIPE_DIR%\py_toolchain_win.bzl) do (
@rem     set line=%%i
@rem     set "line=!line:PYTHON_EXE=%PYTHON_CYGPATH%!"
@rem     echo !line! >> %SRC_DIR%\py_toolchain\BUILD
@rem )

copy %RECIPE_DIR%\py_toolchain_win.bzl %SRC_DIR%\py_toolchain\BUILD
if %ERRORLEVEL% neq 0 exit 1

sed -i "s;PYTHON_EXE;%PYTHON_CYGPATH%;g" %SRC_DIR%\py_toolchain\BUILD
if %ERRORLEVEL% neq 0 exit 1

sed -i "s;PY_VER_NO_DOT;%PY_VER_NO_DOT%;g" %SRC_DIR%\py_toolchain\BUILD
if %ERRORLEVEL% neq 0 exit 1

sed -i "s;PY_VER_MAJOR;%PY_VER_MAJOR%;g" %SRC_DIR%\py_toolchain\BUILD
if %ERRORLEVEL% neq 0 exit 1

sed -i "s;PY_VER_MINOR;%PY_VER_MINOR%;g" %SRC_DIR%\py_toolchain\BUILD
if %ERRORLEVEL% neq 0 exit 1

sed -i "s;PY_VER;%PY_VER%;g" %SRC_DIR%\py_toolchain\BUILD
if %ERRORLEVEL% neq 0 exit 1

type %SRC_DIR%\py_toolchain\BUILD

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

..\bazel %OUTPUT_BASE% build --subcommands --action_env PYTHON_BIN_PATH=%PYTHON% --extra_toolchains=//py_toolchain:py_cc --extra_toolchains=//py_toolchain:py_toolchain //python/dist:binary_wheel --define=use_fast_cpp_protos=true
if %ERRORLEVEL% neq 0 exit 1

:: `pip install dist\protobuf*.whl` does not work on windows,
:: so use a loop; there's only one wheel in dist/ anyway
for /f %%f in ('dir /b /S .\bazel-bin\python\dist') do (
    python -m pip install %%f==%PKG_VERSION%
    if %ERRORLEVEL% neq 0 exit 1
)
