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
   assert 'absolute call'               "$temp_dir/$conrete_dir/$script.sh"
   assert 'via symlinked dir'           "$temp_dir/$conrete_dir-symlink/$script.sh"
   assert 'via symlinked dir #2'        "$seperate_root_temp_dir/$conrete_dir-symlink/$script.sh"
   assert 'via symlinked file'          "$temp_dir/$script-symlink.sh"
   assert 'via symlinked file #2'       "$seperate_root_temp_dir/$script-symlink.sh"
   assert 'via multiple symlinks #1'    "$temp_dir/$conrete_dir-symlink/loop/$script.sh"
   assert 'via multiple symlinks #2'    "$temp_dir/$adjacent_dir/$conrete_dir-symlink/$script.sh"
   assert 'symlink script in adjacent'  "$temp_dir/$adjacent_dir/$script-symlink.sh"
   assert 'symlink script + dir #1'     "$temp_dir/$conrete_dir-symlink/$script-symlink.sh"
   assert 'symlink script + dir #2'     "$seperate_root_temp_dir/$conrete_dir-symlink/$script-symlink.sh"
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
   ln -s  "$temp_dir/$conrete_dir-symlink"     "$temp_dir/$conrete_dir-symlink/loop"
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
   echo "$funcname \"\$0\""     >> "$temp_dir/$conrete_dir/$script.sh"

   time assertions
   echo
   echo
}

#
# • `dirname $path` truncates the script file from the path expression (recall,
#   dirname is essentially a string utility)
# • `cd -P` changes into that directory, resolving any symlinks to their
#    physical path
# • `&& pwd` if the cd is successful will print the absolute working directory
# • optimization, skip a subshell and use `"${path%/*}"` instead of `dirname "$path"``;
#   will break if the script is at the root like `bash /test.sh`
#
cd_dirname_echo_pwd() {
   current_dir="$(cd -P "$(dirname "$1")" && echo "$PWD")"
   echo "$current_dir"
}

#
# • …
#
readlink_loop() {
   local name currentdir
   name="$1"
   # loop while name is not a symlink
   while [[ -h "$name" ]]; do
      # change into directory and grab the path
      currentdir="$(cd -P "$(dirname "$name")" && echo "$PWD")"
      # grab the value of the symlink
      name="$(readlink "$name")"
      # if the symlink isn't an absolute path create a new path with the symlink
      [[ $name != /* ]] && name="$currentdir/$name"
   done
   # once the  print the final path
   echo "$(cd -P "$(dirname "$name")" && echo "$PWD")"
}

#
# • adapted from https://github.com/rbenv/rbenv/blob/master/libexec/rbenv#L34-L50
# • added `cd … || return 1` because this script doesn't use `set -e`
# • Added `-P` to pwd because it's the result we expect in the suite (more accurate but unncessary for rbenv)
#
rbenv_abs_dirname() {
   local cwd="$PWD"
   local path="$1"

   # loop until path is an empty string
   while [[ -n "$path" ]]; do
      # cd into directory using string-substutuion; nearly equivalent to `cd "$(dirname "$path")"`
      # but different becuase this method will fail if the directory is in the root
      # direcotry like `/foo`
      cd "${path%/*}" || return 1
      # extract filename from path
      local name="${path##*/}"
      # if file is a symlink return the symlink path otherwise return nothing
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
   dirname "$("$readlink_program" --canonicalize "$1")"
}

#
# • …
#
dirname_gnu_realpath() {
   dirname "$(realpath "$1")"
}

#
# • …
#
php_realpath() {
   php -r "echo dirname(realpath('$1'));"
}

#
# • …
#
node_realpath() {
   node -e "console.log(require('path').dirname(require('fs').realpathSync('$1')))"
}

# - - -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

setup

if (( $# > 0 )); then
   for func in "$@"; do
      test_function "$func"
   done
else
   all_functions=(
      cd_dirname_echo_pwd
      readlink_loop
      rbenv_abs_dirname
      dirname_gnu_readlink
      dirname_gnu_realpath
      php_realpath
      node_realpath
   )

   for func in "${all_functions[@]}"; do
      test_function "$func"
   done
fi
