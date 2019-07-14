#!/usr/bin/env bash

#
# Makes running some, one, or all test.sh files easy
#  • finds a directory which matches $1 (blank will match every directory)
#  • cd's into that directory and executes ./test.sh with the remaining arguments
#

dir_name_pattern=$1
shift 1

# encapsulate the test.sh "runner" behavior in a function and export it
testdotsh_runner() {
   local dir_name
   dir_name="${1#*/}" # omit everything before the first slash since find prepends './…' to relative paths
   shift 1

   # skip directories that start with a dot (.git etc)
   ! [[ "$dir_name" =~ ^\. ]] && cd "$dir_name" && {
      echo "💨 $dir_name"
      ./test.sh "$@"
   }
}
export -f testdotsh_runner

# use find -exec to execute test.sh in specific directories
#  • `bash -c '…'` executes a string of bash code (cleanest way use -exec with a shell-function)
#  • `testdotsh_runner "$@"` executes our function with all passed arguments (recall $@ omits $0)
#  • `_` occupies $0 in the string of bash code context so the find-result can be $1
#  • `{}` is the placeholder for each find-result, passed as $1 to testdotsh_runner
#  • `"$@"` expands the remaining positional arguments from $2 onward to testdotsh_runner
find . -depth 1 -type d -iname "*${dir_name_pattern}*" -exec bash -c 'testdotsh_runner "$@"' _ {} "$@" \;
