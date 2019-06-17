#!/usr/bin/env bash
#
# Adapted from https://gist.github.com/tvlooy/cbfbdb111a4ebad8b93e
#

test_name=$(basename "$0" .sh) # filename with .sh stripped
temp_dir=$(mktemp -d)
script='test script'
conrete_dir="$test_name demo directory"
adjacent_dir='nested plus/adjacent location'
seperate_root_temp_dir="$HOME/.tmp/$test_name/$temp_dir"
rm -rf "$temp_dir:?/"*
default_expectation="$(cd -P "$temp_dir" && echo "$PWD")/$conrete_dir"

assert() {
   local message actual expected
   message="$1"
   actual="$(bash "$2")"
   expected="${3:-$default_expectation}"

   if [ "$actual" = "$expected" ]; then
      echo -e "\033[32m✔︎ Tested $message"
   else
      echo -e "\033[31m✘ Tested $message"
      echo -e "  Actual   : $actual"
      echo -e "  Expected : $expected"
   fi
   echo -en "\033[0m"
}

assertions() {
   assert 'absolute call'            "$temp_dir/$conrete_dir/$script.sh"
   assert 'via symlinked dir'        "$temp_dir/$conrete_dir-symlink/$script.sh"
   assert 'via symlinked dir #2'     "$seperate_root_temp_dir/$conrete_dir-symlink/$script.sh"
   assert 'via symlinked file'       "$temp_dir/$script-symlink.sh"
   assert 'via symlinked file #2'    "$seperate_root_temp_dir/$script-symlink.sh"
   assert 'via multiple symlinks #1' "$temp_dir/$conrete_dir-symlink/loop/$script.sh"
   assert 'via multiple symlinks #2' "$temp_dir/$adjacent_dir/$conrete_dir-symlink/$script.sh"
   assert 'symlink script + dir #1'  "$temp_dir/$conrete_dir-symlink/$script-symlink.sh"
   assert 'symlink script + dir #2'  "$temp_dir/$adjacent_dir/$script-symlink.sh"
   assert 'symlink script + dir #3'  "$seperate_root_temp_dir/$conrete_dir-symlink/$script-symlink.sh"
   pushd "$temp_dir" > /dev/null && {
      assert 'relative call'         "./$conrete_dir/$script.sh"
   }
   echo
}

setup() {
   mkdir "$temp_dir/$conrete_dir"
   mkdir -p "$seperate_root_temp_dir"
   mkdir -p "$temp_dir/$adjacent_dir"
   touch "$temp_dir/$conrete_dir/$script.sh"

   ln -s  "$temp_dir/$conrete_dir"             "$temp_dir/$conrete_dir-symlink"
   ln -s  "$temp_dir/$conrete_dir"             "$temp_dir/$conrete_dir-symlink/loop"
   ln -s  "$temp_dir/$conrete_dir"             "$temp_dir/$adjacent_dir/$conrete_dir-symlink"
   ln -s  "$temp_dir/$conrete_dir/$script.sh"  "$temp_dir/$script-symlink.sh"
   ln -s  "$temp_dir/$conrete_dir/$script.sh"  "$temp_dir/$conrete_dir-symlink/$script-symlink.sh"
   ln -s  "$temp_dir/$conrete_dir/$script.sh"  "$temp_dir/$adjacent_dir/$script-symlink.sh"

   # seperate_root_temp_dir
   ln -s  "$temp_dir/$conrete_dir"             "$seperate_root_temp_dir/$conrete_dir-symlink"
   ln -s  "$temp_dir/$conrete_dir/$script.sh"  "$seperate_root_temp_dir/$script-symlink.sh"

   echo
   tree "$temp_dir"
   tree "$seperate_root_temp_dir"
   echo
}

test_function() {
   local funcname
   funcname="$1"

   if ! type -t "$funcname" | grep "function" &> /dev/null; then
      echo "'$funcname' is not a function"
      return 1
   fi

   echo "Test: $funcname"
   type "$funcname" | tail -n+2  > "$temp_dir/$conrete_dir/$script.sh"
   echo "$funcname"             >> "$temp_dir/$conrete_dir/$script.sh"

   assertions
}

#
# • `dirname $0` truncates the script file from the path expression (recall,
#   dirname is essentially a string utility)
# • `cd -P` changes into that directory, resolving any symlinks to their
#    physical path
# • `&& pwd` if the cd is successful will print the absolute working directory
#
cd_dirname_pwd() {
   current_dir="$(cd -P "$(dirname "$0")" && pwd)"
   echo "$current_dir"
}

#
# • fork of cd_dirname_pwd
# • plus: has one less subshell!
# • minus: (hard to automate in the suite) will break if the script is at the root
#   like `bash /test.sh`
# • otherwise generally seems to fail at the same cases as cd_dirname_pwd
#
cd_stringsub_pwd() {
   current_dir="$(cd -P "${0%/*}" && pwd)"
   echo "$current_dir"
}

#
# • another fork which swaps `pwd` for the `$PWD` env-variable
# • seems to fail at the same cases as cd_stringsub_pwd
#
cd_stringsub_echo_pwd() {
   current_dir="$(cd -P "${0%/*}" && echo "$PWD")"
   echo "$current_dir"
}

#
# • …
#
readlink_loop() {
   local name currentdir
   name="$0"
   # loop while name is not a symlink
   while [[ -h "$name" ]]; do
      # loop while name is not a symlink
      currentdir="$(cd "$(dirname "$name")" && pwd)"
      name="$(readlink "$name")"
      [[ $name != /* ]] && name="$currentdir/$name"
   done
   finaldir="$(cd "$(dirname "$name")" && pwd -P)"
   echo "$finaldir"
}

#
# • adapted from https://github.com/rbenv/rbenv/blob/master/libexec/rbenv#L34-L50
# • inlined resolve_link to ease integeration with this test runner (doesn't change behavior meaningfully)
# • added `cd … || return 1` because this script doesn't use `set -e`
# • Added `-P` to pwd because it's the result we expect in the suite (more accurate but unncessary for rbenv)
#
rbenv_abs_dirname() {
   local cwd="$PWD"
   local path="$0"

   # loop until path is an empty string
   while [[ -n "$path" ]]; do
      # cd into directory, nearly equivalent to `cd "$(dirname "$path")"` becuase it will fail if
      # directory is the root direcotry like `/foo`
      cd "${path%/*}" || return 1
      # extract filename from path
      local name="${path##*/}"
      # if file is a symlink return the symlink path, otherwise if it's not a symlink then exit the loop
      path="$(readlink "$name")"
   done


   pwd -P
   cd "$cwd" || return 1
}

#
# • …
#
dirname_gnu_readlink() {
   # NOTE: what is the difference between `which` and `type -p`?
   readlink_program=$(which greadlink readlink | head -n1)
   # only works with GNU readlink; won't work with Darwin's BSD readlink
   dirname "$("$readlink_program" --canonicalize "$0")"
}

#
# • …
#
dirname_gnu_realpath() {
   dirname "$(realpath "$0")"
}

# - - -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

setup

if [ "$1" != "" ]; then
   test_function "$1"
else
   all_functions=(
      cd_dirname_pwd
      cd_stringsub_pwd
      cd_stringsub_echo_pwd
      readlink_loop
      rbenv_abs_dirname
      dirname_gnu_readlink
      dirname_gnu_realpath
   )

   for func in "${all_functions[@]}"; do
      test_function "$func"
   done
fi
