#!/usr/bin/env bash

# be chill about expanding variable in the alias cause that's the point
# shellcheck disable=SC2139
alias custom_alias="echo custom alias from $0"

# won't work - "…line 8: custom_alias: command not found"
custom_alias

# will work
shopt -s expand_aliases
custom_alias
