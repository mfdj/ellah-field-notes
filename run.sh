#!/usr/bin/env bash
#
# • finds a directory which matches $1
# • cd's into that directory and executes ./test.sh with the remaining arguments
#

dir_name_fragment=$1
shift 1

exec_test() {
   local dir_name
   dir_name=$1
   shift 1

   cd "$dir_name" && {
      echo -n '💨 '
      tr -d './' <<< "$dir_name"
      ./test.sh "$@"
   }
}
export -f exec_test

find . -depth 1 -type d -iname "*${dir_name_fragment}*" -exec bash -c 'exec_test "$@"' _ {} "$@" \;
