#!/usr/bin/env bash

export PATH="./bin:$PATH"

echo '§ test-current-directory-context'
./test-current-directory-context.sh

echo
echo '§ test-0-bash-source'
./test-0-bashsource.sh
