#!/usr/bin/env bash

cd_pwd_ls() {
   [[ $# == 0 ]] && {
      echo 'need an argument'
      exit 1
   }

   echo
   echo "$*"

   # set a: don't follow symlinks
   cd "$@" || { echo "cd failed with: $*"; exit 1; }
   echo '  ☽' # set a: same result
   echo -n '    '; pwd
   echo    "    $PWD"

   # set b: follow symlinks
   echo '  𐄾'
   echo -n '    '; pwd -P
   cd - &> /dev/null || { echo "cd failed with: $*"; exit 1; }
   cd -P "$@" || { echo "cd failed with: $*"; exit 1; }
   echo -n '    '; pwd
   echo    "    $PWD"
   echo -n '    '; pwd -P
   cd - &> /dev/null || { echo "cd failed with: $*"; exit 1; }
}

echo "<directory to test>"
echo '  ☽'
echo '    cd + pwd'
echo '    cd + $PWD'
echo '  𐄾'
echo '    cd + pwd -P'
echo '    cd -P + pwd'
echo '    cd -P + $PWD'
echo '    cd -P + pwd -P'

cd_pwd_ls dir-stub
cd_pwd_ls dir-stub/symlink-dir1
cd_pwd_ls dir-stub/symlink-dir1/sub
cd_pwd_ls dir-stub/symlink-dir1/symlink-dir2

temp_dir=$(mktemp -d)
mkdir -p "$temp_dir/transporter"
ln -s "$PWD/dir-stub"                     "$temp_dir"
ln -s "$PWD/dir-stub/symlink-dir1"        "$temp_dir/symlink-to-symlink-dir1"
ln -s "$temp_dir/symlink-to-symlink-dir1" "$temp_dir/transporter/"
ln -s "$temp_dir/transporter"             "$temp_dir/transporter-symlink"

cd_pwd_ls "$temp_dir"
cd_pwd_ls "$temp_dir/dir-stub"
cd_pwd_ls "$temp_dir/dir-stub/symlink-dir1"
cd_pwd_ls "$temp_dir/dir-stub/symlink-dir1/sub"
cd_pwd_ls "$temp_dir/dir-stub/symlink-dir1/symlink-dir2"
cd_pwd_ls "$temp_dir/symlink-to-symlink-dir1"
cd_pwd_ls "$temp_dir/transporter-symlink/symlink-to-symlink-dir1"
