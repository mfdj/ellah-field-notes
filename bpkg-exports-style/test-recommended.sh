#!/usr/bin/env bash

./recommend-package-export.sh
assert_return_code 0 './recommend-package-export.sh returned 0'

./recommend-package-export.sh fail
assert_return_code 1 './recommend-package-export.sh fail returned 1'

./recommend-package-export.sh otherfail
assert_return_code 127 './recommend-package-export.sh otherfail returned 127'

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

source ./recommend-package-export.sh

type some_function | head -n1 | grep -q 'is a function'
assert_return_code 0 'some_function is a function'

some_function
assert_return_code 0 'some_function returned 0'

some_function fail
assert_return_code 1 'some_function fail returned 1'

some_function otherfail
assert_return_code 127 'some_function otherfail returned 127'

./proxy-runner.sh some_function
assert_return_code 0 'some_function by proxy returned 0'

./proxy-runner.sh some_function fail
assert_return_code 1 'some_function by proxy fail returned 1'

./proxy-runner.sh some_function otherfail
assert_return_code 127 'some_function by proxy otherfail returned 127'
