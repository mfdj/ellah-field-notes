#!/usr/bin/env bash

in_another_directory=$(mktemp -d)/in-another-directory
cat <<- 'EOF' >"$in_another_directory"
   echo "$0"
   dirname "$0"
EOF
bash "$in_another_directory"
rm "$in_another_directory"
