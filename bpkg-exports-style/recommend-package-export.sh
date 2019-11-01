#!/usr/bin/env bash

some_function() {
   if [[ $1 == fail ]]; then
      return 1
   elif [[ $1 == otherfail ]]; then
      return 127
   fi
   return 0
}

# via http://www.bpkg.sh/guidelines/#package-exports
if [[ ${BASH_SOURCE[0]} != $0 ]]; then
  export -f some_function
else
  some_function "${@}"
  exit $?
fi
