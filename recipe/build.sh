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

${PYTHON} setup.py install --cpp_implementation --single-version-externally-managed --record record.txt
