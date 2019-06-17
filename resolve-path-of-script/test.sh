#!/usr/bin/env bash

export PATH="./bin:$PATH"

if [[ $# == 0 ]]; then
   echo
   echo '📊 test-current-directory-context'
   ./test-current-directory-context.sh

   echo
   echo '📊 test-0-bashsource'
   ./test-0-bashsource.sh

   echo
   echo '📊 test-dirname'
   ./test-dirname.sh

   echo
   echo '📊 test-cd-pwd-and-symlinks'
   ./test-cd-pwd-and-symlinks.sh

   echo
   echo '📊 test-resolve-script-dir-poc'
   ./test-resolve-script-dir-poc.sh
else
   find . -depth 1 -type f -iname "*${1}*" -exec bash -c 'echo "$1" && $1 "$2"' _ {} "$2" \;
fi
