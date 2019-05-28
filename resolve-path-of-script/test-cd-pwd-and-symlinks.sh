#!/usr/bin/env bash

cd_pwd_pwd_ls() {
   [[ $# == 0 ]] && {
      echo 'need an argument'
      exit 1
   }

   echo
   echo "$*"

   # 💿  don't follow symlinks
   cd "$@" || { echo "cd failed with: $*"; exit 1; }
   echo '  ☽'
   echo -n '    '; pwd
   echo    "    $PWD"
   echo -n '    '; pwd -P
   cd - &> /dev/null || { echo "cd failed with: $*"; exit 1; }

   # 💿  follow symlinks
   cd -P "$@" || { echo "cd failed with: $*"; exit 1; }
   echo '  𐄾'
   echo -n '    '; pwd
   echo    "    $PWD"
   echo -n '    '; pwd -P
   cd - &> /dev/null || { echo "cd failed with: $*"; exit 1; }
}

echo "<directory to test>"
echo '  ☽ cd'
echo '    pwd'
echo '    $PWD'
echo '    pwd -P'
echo '  𐄾 cd -P'
echo '    pwd'
echo '    $PWD'
echo '    pwd -P'

cd_pwd_pwd_ls dir-stub
cd_pwd_pwd_ls dir-stub/symlink-dir1
cd_pwd_pwd_ls dir-stub/symlink-dir1/sub
cd_pwd_pwd_ls dir-stub/symlink-dir1/symlink-dir2
