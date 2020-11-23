#!/bin/bash

# Install python package now
cd python

${PYTHON} setup.py install --cpp_implementation --single-version-externally-managed --record record.txt
