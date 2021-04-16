#!/bin/bash

# this is an example for upload package
# usually it doesn't need to modify

TARGET_TYPE=$1

# export PYTHONPATH=./:$PYTHONPATH
# python -c "import dslct; do_upload_package_ui( $TARGET_TYPE )"

python ./dslct.py do_upload_package_ui "mac-arm64-xcode10-release"

