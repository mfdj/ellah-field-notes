# Aliases are weird

Aliases are macro-y shorthands intended to make interactive shell usage more
user friendly.

For this reason you must there are some important limitations to understand:

- in order to use an alias in a non-interactive script you must enable
  `shopt -s expand_aliases`
- you cannot "export" aliases to subshells
- you must define the alias in the script context that uses it; using source to
  "import" the alias definition is acceptable
- to test an alias defined in a script file without using `expand_aliases` option
  you can make make bash run in interactive mode like `bash -i path/to/script-with-alias.sh`
