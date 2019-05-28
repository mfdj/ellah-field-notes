#!/usr/bin/env bash

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

temp_dir=$(mktemp -d)
rm -rf "$temp_dir:?/"*
expected_temp_dir=$(cd "$temp_dir" && pwd -P)

test_suite() {
   test 'absolute call'               "${temp_dir}/demo/test.sh"         "${expected_temp_dir}/demo"
   test 'via symlinked dir'           "${temp_dir}/current/test.sh"      "${expected_temp_dir}/demo"
   test 'via symlinked file'          "${temp_dir}/test.sh"              "${expected_temp_dir}/demo"
   test 'via multiple symlinked dirs' "${temp_dir}/current/loop/test.sh" "${expected_temp_dir}/demo"
   test 'with space in dir'           "${temp_dir}/12 34/test.sh"        "${expected_temp_dir}/demo"
   test 'with space in file'          "${temp_dir}/demo/te st.sh"        "${expected_temp_dir}/demo"
   pushd "${temp_dir}" >/dev/null && {
      test 'relative call'            ./demo/test.sh                     "${expected_temp_dir}/demo"
   }
   echo
}

setup() {
   local demodir dirwithspace

   demodir="${temp_dir}/demo"
   dirwithspace="${temp_dir}/12 34"
   file=test.sh
   file_with_space='te st.sh'

   mkdir "$demodir"
   touch "$demodir/$file"
   ln -s "$demodir/$file"  "$temp_dir"
   ln -s "$demodir"        "$temp_dir/current"
   ln -s "$demodir"        "$temp_dir/current/loop"
   mkdir "$dirwithspace"
   ln -s "$demodir/$file"  "$demodir/$file_with_space"
   ln -s "$demodir/$file"  "$dirwithspace/$file"
   ln -s "$demodir/$file"  "$dirwithspace/$file_with_space"
}

cd_dirname_pwd() {
   echo 'Test via pwd'
   cat <<- 'EOF' > "${temp_dir}/demo/test.sh"
      current_dir="$(cd -P "$(dirname "$0")" && pwd)"
      echo "$current_dir"
EOF
   test_suite
}

complicated_so_solution() {
   echo 'Test complicated stackoverflow solution'
   cat <<- 'EOF' > "${temp_dir}/demo/test.sh"
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
   cat <<- 'EOF' > "${temp_dir}/demo/test.sh"
      readlink_program=$(which greadlink readlink | head -n1)
      dirname "$("$readlink_program" -f "$0")"
EOF
   test_suite
}

cd_dirname_pwd() {
   echo 'Test via pwd'
   cat <<- 'EOF' > "${temp_dir}/demo/test.sh"
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
