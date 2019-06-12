#!/usr/bin/env bash

# Test A: basic usage

in_another_directory=$(mktemp -d)/in-another-directory
cat <<- 'EOF' >"$in_another_directory"
   echo "$0"
   dirname "$0"
   echo "${0%/*}" # string substituton method means one less subshell
EOF
bash "$in_another_directory"
rm "$in_another_directory"

# Test B: comparing dirname and string-substituton

compare_dirname_stringsub() {
   echo "--- '$1'"
   dirname "$1"
   echo "${1%/*}"
}

compare_dirname_stringsub .
compare_dirname_stringsub ./
compare_dirname_stringsub /asdf
compare_dirname_stringsub /asdf/\ /
compare_dirname_stringsub /asdf///
compare_dirname_stringsub asdf/ghjk
compare_dirname_stringsub ./asdf/ghjk
