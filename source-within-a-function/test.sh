#!/usr/bin/env bash

source_hello() {
   source ./defines-hello-function.sh
}

uses_hello() {
   hello
}

type hello 2>&1 | grep -q 'type: hello: not found'
assert_return_code 0 'hello is not a function yet'

source_hello
type hello 2>&1 | grep -q 'is a function'
assert_return_code 0 'hello is a function'

uses_hello
