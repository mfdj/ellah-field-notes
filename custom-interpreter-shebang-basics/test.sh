#!/usr/bin/env bash
export PATH="./bin:$PATH"

echo '1️⃣  runner-env'
runner-env

# doen't work as expected, see notes.md
echo
echo '2️⃣  runner-relative'
runner-relative

echo
echo '3️⃣  runner-relative-env'
runner-relative-env
