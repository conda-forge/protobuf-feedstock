#!/bin/bash


chmod +x ./configure

# Rebuild configure/Makefile.am as they are broken.
aclocal
automake
autoconf

# For gtest rebuild configure/Makefile.am as they are broken.
pushd ./gtest
aclocal
automake
autoconf
popd

./configure --prefix=$PREFIX

make
make check
make install
(cd python && python setup.py install --single-version-externally-managed --record record.txt && cd ..)
