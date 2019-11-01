#!/usr/bin/env bash

./minus-export.sh
assert_return_code 0 './minus-export.sh returned 0'

./minus-export.sh fail
assert_return_code 1 './minus-export.sh fail returned 1'

./minus-export.sh otherfail
assert_return_code 127 './minus-export.sh otherfail returned 127'

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

source ./minus-export.sh

type some_function | head -n1 | grep -q 'is a function'
assert_return_code 0 'some_function is a function'

some_function
assert_return_code 0 'some_function returned 0'

some_function fail
assert_return_code 1 'some_function fail returned 1'

some_function otherfail
assert_return_code 127 'some_function otherfail returned 127'

./proxy-runner.sh "type some_function 2> /dev/null | head -n1 | grep -q 'is a function'"
assert_return_code 1 'some_function by proxy is not a function'
