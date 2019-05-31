#!/usr/bin/env bash
#
# Adapted from https://gist.github.com/tvlooy/cbfbdb111a4ebad8b93e
#

temp_dir=$(mktemp -d)
script='test script'
conrete_dir='demo directory'
rm -rf "$temp_dir:?/"*
expected_temp_dir="$(cd "$temp_dir" && pwd -P)/$conrete_dir"

test() {
   local message actual expected
   message=$1
   actual="$(bash "$2")"
   expected=$3

   if [ "$actual" = "$expected" ]; then
      echo -e "\033[32m✔︎ Tested $message"
   else
      echo -e "\033[31m✘ Tested $message"
      echo -e "  Actual   : $actual"
      echo -e "  Expected : $expected"
   fi
   echo -en "\033[0m"
}

test_suite() {
   test 'absolute call'          "$temp_dir/$conrete_dir/$script.sh"                  "$expected_temp_dir"
   test 'via symlinked dir'      "$temp_dir/$conrete_dir-symlink/$script.sh"          "$expected_temp_dir"
   test 'via symlinked file'     "$temp_dir/$script-symlink.sh"                       "$expected_temp_dir"
   test 'via multiple symlinks'  "$temp_dir/$conrete_dir-symlink/loop/$script.sh"     "$expected_temp_dir"
   test 'symlink script + dir'   "$temp_dir/$conrete_dir-symlink/$script-symlink.sh"  "$expected_temp_dir"
   pushd "$temp_dir" > /dev/null && {
      test 'relative call'       "./$conrete_dir/$script.sh"                          "$expected_temp_dir"
   }
   echo
}

setup() {
   mkdir "$temp_dir/$conrete_dir"

   ln -s "$temp_dir/$conrete_dir"             "$temp_dir/$conrete_dir-symlink"
   ln -s "$temp_dir/$conrete_dir"             "$temp_dir/$conrete_dir-symlink/loop"
   ln -s "$temp_dir/$conrete_dir/$script.sh"  "$temp_dir/$script-symlink.sh"
   ln -s "$temp_dir/$conrete_dir/$script.sh"  "$temp_dir/$conrete_dir-symlink/$script-symlink.sh"

   tree "$temp_dir"
}

cd_dirname_pwd() {
   echo 'Test via pwd'
   cat <<- 'EOF' > "$temp_dir/$conrete_dir/$script.sh"
      current_dir="$(cd -P "$(dirname "$0")" && pwd)"
      echo "$current_dir"
EOF
   test_suite
}

complicated_so_solution() {
   echo 'Test complicated stackoverflow solution'
   cat <<- 'EOF' > "$temp_dir/$conrete_dir/$script.sh"
      currentfile="$0"
      while [ -h "$currentfile" ]; do
         currentdir="$(cd -P "$(dirname "$currentfile")" && pwd)"
         currentfile="$(readlink "$currentfile")"
         [[ $currentfile != /* ]] && currentfile="$currentdir/$currentfile"
      done
      finaldir="$(cd -P "$(dirname "$currentfile")" && pwd)"
      echo "$finaldir"
EOF
   test_suite
}

dirname_readlink_0() {
   echo 'Test via readlink'
   cat <<- 'EOF' > "$temp_dir/$conrete_dir/$script.sh"
      readlink_program=$(which greadlink readlink | head -n1)
      dirname "$("$readlink_program" -f "$0")"
EOF
   test_suite
}

cd_dirname_pwd() {
   echo 'Test via pwd'
   cat <<- 'EOF' > "$temp_dir/$conrete_dir/$script.sh"
      current_dir="$(cd -P "$(dirname "$0")" && pwd)"
      echo "$current_dir"
EOF
   test_suite
}

echo
setup
if [ "$1" != "" ]; then
   $1
else
   cd_dirname_pwd
   complicated_so_solution
   dirname_readlink_0
fi
