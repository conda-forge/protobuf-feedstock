#!/bin/bash

# Change the permissions of the protobuf.egg-info directory to be 
# group and world readable
chmod 644 protobuf.egg-info/*
$PYTHON setup.py install --single-version-externally-managed --record record.txt
