#!/usr/bin/env bash

find_exec() {
   cd "$0" && {
      echo -n '💨 '
      tr -d './' <<< "$0"
      ./test.sh
   }
}
export -f find_exec

find . -depth 1 -type d -iname "*${1}*" -exec bash -c find_exec {} \;
