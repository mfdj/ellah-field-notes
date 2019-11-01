#!/usr/bin/env bash

some_function() {
   if [[ $1 == fail ]]; then
      return 1
   elif [[ $1 == otherfail ]]; then
      return 127
   fi
   return 0
}

# • fixed quoting of "$0" per shellcheck
# • removed exit because I suspect it's redundant
if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
  some_function "${@}"
fi
