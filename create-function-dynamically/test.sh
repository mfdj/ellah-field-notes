#!/usr/bin/env bash

create_function_named() {
   local functionName=${1:?}
   eval "${functionName}() { echo 'This function is named ${functionName}'; }"
   # shellcheck disable=SC2163
   export -f "$functionName"
}

create_function_named hi_hello
hi_hello

create_function_named oh_goodbye
end_program() {
   oh_goodbye
}
end_program

bash -c "
  echo in a sub shell
  hi_hello
  end_program() {
     oh_goodbye
  }
  end_program
"
