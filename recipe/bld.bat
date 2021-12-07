:: Install the Python portions too.
cd %SRC_DIR%
if errorlevel 1 exit 1
cd python
if errorlevel 1 exit 1

"%PYTHON%" setup.py build --cpp_implementation
if errorlevel 1 exit 1
"%PYTHON%" setup.py test --cpp_implementation
if errorlevel 1 exit 1
"%PYTHON%" setup.py install --cpp_implementation
