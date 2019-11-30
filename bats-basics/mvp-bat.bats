#!/usr/bin/env bats

# BATS-globals
#   BATS_TMPDIR       : /tmp/folders/< random name >
#   BATS_TEST_DIRNAME : the directory of this file

odb=$BATS_TMPDIR/old-dirty-boolean

# BATS-lifecyle hooks
#   setup() { … }
#   teardown() { … }

setup() {
   mkdir -p "$odb"
   touch "$odb"/{eh,bee,see}
   touch ~/Desktop/bats-output
   echo 'setup happens for each test' >&2
}

teardown() {
   echo 'teardown happens for each test' >&2
   :
}

# custom user function

assert_status() {
   if [ "$status" -ne "$1" ]; then
      echo "command failed with exit status $status"
      return 1
   fi
}

# BATS-run
#   run < your test commnad >
# then have access to
#   $status (exit code)
#   $output (contets of STDOUT)
#   $lines  (lines array of STDOUT)
#     "${lines[0]}" is line-1

@test 'echo mvp' {
   run echo mvp
   assert_status 0
   [ "$output" == mvp ]
}

@test 'ls odb' {
   run ls -l1 "$odb"
   assert_status 0
   [ "${lines[0]}" == bee ]
}

@test 'assert failure [ … ]' {
   run false
   assert_status 1
   [ "$status" -eq 1 ]
}

@test 'assert failure [[ … ]]' {
   run false
   assert_status 1
   [[ $status -eq 1 ]]
}

@test 'assert failure (( … ))' {
   run false
   assert_status 1
   (( status == 1 ))
}

@test 'assert success [ … ]' {
   run true
   assert_status 0
   [ "$status" -eq 0 ]
}

@test 'assert success [[ … ]]' {
   run true
   assert_status 0
   [[ $status -eq 0 ]]
}

@test 'assert success (( … ))' {
   run true
   assert_status 0
   (( status == 0 ))
}
