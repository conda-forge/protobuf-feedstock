#!/bin/bash


if [ "$(uname)" == "Darwin" ];
then
    # Switch to clang with C++11 ASAP.
    export CXXFLAGS="${CXXFLAGS} -stdlib=libc++ -std=c++11"
    export LIBS="-lc++"
fi

if [ `uname` == Linux ]; then
    export CFLAGS="${CFLAGS} --std=c++11"
fi

# Install python package now
cd python

if [[ ${PY_VER} == 3.7 ]]; then
  # https://github.com/google/protobuf/issues/4086
  export CFLAGS="${CFLAGS} -fpermissive"
fi

${PYTHON} setup.py install --cpp_implementation --single-version-externally-managed --record record.txt
