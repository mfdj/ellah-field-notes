#!/usr/bin/env bash

echo 'run style | pwd | ls dir-stub'

echo
echo '--- same directory as script'
echo -n 'source script '
source pwdls.sh

echo -n 'exec string   '
bash -c "$(cat pwdls.sh)"

echo -n 'exec script   '
./pwdls.sh

echo -n 'exec command  '
pwdls

echo
echo '--- from another directory'
in_another_directory=$(mktemp)
cat <<- 'EOF' >"$in_another_directory"
   echo -n 'source script '
   source pwdls.sh

   echo -n 'exec string   '
   bash -c "$(cat pwdls.sh)"

   echo -n 'exec script   '
   ./pwdls.sh

   echo -n 'exec command  '
   pwdls
EOF
bash "$in_another_directory"
rm "$in_another_directory"
