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

logger() {
   local level
   local color
   local color_off='\x1B[0m'
   local context="(${0##*/})"
   local grey='\x1B[0;37m'

   (( $# == 0 )) && {
      echo 'log: expecting at least one argument' >&2
      return
   }

   case $1 in
      debug) level=0 ;;
      info)  level=1; context='' ;;
      warn)  level=2 ;;
      error) level=3 ;;
   esac

   [[ $level ]] && shift || level=0

   [[ $# -gt 0 ]] || {
      echo 'log: expecting a message' >&2
      return
   }

   case $level in
      0) color_off=;;
      1) color='\x1B[0;32m';; # Green
      2) color='\x1B[0;33m';; # Yellow
      3) color='\x1B[0;31m';; # Red
   esac

   [[ $VERBOSE || $level -gt 0 ]] &&
      echo -e "${color}${*?}${color_off} ${grey}${context}${color_off}"

   return 0
}
export -f logger

assert_return_code() {
   if (($? == $1)); then
      logger info "$2"
   else
      logger error "$2"
   fi
}
export -f assert_return_code

# use find -exec to execute test.sh in specific directories
#  • `bash -c '…'` executes a string of bash code (cleanest way use -exec with a shell-function)
#  • `testdotsh_runner "$@"` executes our function with all passed arguments (recall $@ omits $0)
#  • `_` occupies $0 in the string of bash code context so the find-result can be $1
#  • `{}` is the placeholder for each find-result, passed as $1 to testdotsh_runner
#  • `"$@"` expands the remaining positional arguments from $2 onward to testdotsh_runner
find . -depth 1 -type d -iname "*${dir_name_pattern}*" -exec bash -c 'testdotsh_runner "$@"' _ {} "$@" \;
