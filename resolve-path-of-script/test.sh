#!/usr/bin/env bash

export PATH="./bin:$PATH"

echo
echo '📊 test-current-directory-context'
./test-current-directory-context.sh

echo
echo '📊 test-0-bashsource'
./test-0-bashsource.sh

echo
echo '📊 test-dirname'
./test-dirname.sh
