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
   script_pattern=$1
   shift
   find . -depth 1 -type f -iname "*${script_pattern}*" -exec bash -c 'script=$1; shift; echo "$script"; $script "$@"' _ {} "$@" \;
fi
