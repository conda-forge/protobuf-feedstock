@echo on
setlocal enabledelayedexpansion

@rem Create python3.exe symlink for rules_python compatibility
@rem On Windows, only python.exe exists, but rules_python looks for python3
@rem see https://github.com/conda-forge/python-feedstock/pull/640
copy "%PREFIX%\python.exe" "%PREFIX%\python3.exe"
if %ERRORLEVEL% neq 0 exit 1

@rem Use correct C++17 option
sed -i "s/\(cxxopt=\)-std=c++17/\1\/std:c++17/g" .bazelrc
if %ERRORLEVEL% neq 0 exit 1

set "BAZEL_LLVM=%BUILD_PREFIX%\Library"

md py_toolchain

set "PYTHON_CYGPATH=%PYTHON:\=/%"
set "PY_VER_NO_DOT=%PY_VER:.=%"

sed -i "s/ SYSTEM_PYTHON_VERSION/ %PY_VER_NO_DOT%/g" python\dist\dist.bzl
if %ERRORLEVEL% neq 0 exit 1

sed -i "s;PYTHON_EXE;%PYTHON_CYGPATH%;g" %SRC_DIR%\python\dist\system_python.bzl
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

set "PY_VER_NODOT=%PY_VER:.=%"

for %%f in ("dist\BUILD.bazel" "dist\dist.bzl") do (
  sed -i "/@system_python\/\/:version\.bzl/d" "%%~f"
   if %ERRORLEVEL% neq 0 exit 1
  sed -i "s|SYSTEM_PYTHON_VERSION|\"%PY_VER_NODOT%\"|g" "%%~f"
  if %ERRORLEVEL% neq 0 exit 1
)

:: protobuf misuses `SUPPORTED_PYTHON_VERSIONS[-1]` to mean "default python", see
:: https://github.com/protocolbuffers/protobuf/issues/22313
sed -i "s|SUPPORTED_PYTHON_VERSIONS\[-1\]|\"%PY_VER%\"|g" "..\MODULE.bazel"
if %ERRORLEVEL% neq 0 exit 1
:: and somehow hasn't added SUPPORTED_PYTHON_VERSIONS to the list of supported versions yet, see
:: https://github.com/protocolbuffers/protobuf/blob/v31.1/MODULE.bazel#L112-L117
sed -i "/SUPPORTED_PYTHON_VERSIONS *= *\[/,/]/ s/^\( *\]\)/    \"3.14\",\n\1/" "..\MODULE.bazel"
if %ERRORLEVEL% neq 0 exit 1
sed -i 's/\(bazel_dep(name *= *"rules_python", *version *= *"\)[^"]*\(")\)/\11.6.0\2/' ../MODULE.bazel
if %ERRORLEVEL% neq 0 exit 1

..\bazel %OUTPUT_BASE% build ^
    --linkopt "/LIBPATH:%PREFIX%\libs" ^
    --action_env PYTHON_BIN_PATH=%PYTHON% ^
    //python/dist:binary_wheel ^
    --define=use_fast_cpp_protos=true
if %ERRORLEVEL% neq 0 exit 1

%PYTHON% -m pip install ..\bazel-bin\python\dist\protobuf-%PKG_VERSION%-cp%PY_VER_NO_DOT%-abi3-win_amd64.whl
if %ERRORLEVEL% neq 0 exit 1

..\bazel clean --expunge
if %ERRORLEVEL% neq 0 exit 1

..\bazel shutdown
if %ERRORLEVEL% neq 0 exit 1

@rem remove extraneous python3 again (see above)
del /s /q %PREFIX%\python3.exe
