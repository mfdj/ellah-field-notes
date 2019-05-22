#!/usr/bin/env bash

echo 'run style | pwd | ls dir-stub'

echo
echo '--- same directory as script'
echo -n 'string-argument '
bash -c "$(cat pwdls.sh)"

echo -n 'file-argument   '
bash pwdls.sh

echo -n 'exec script     '
./pwdls.sh

echo -n 'exec command    '
pwdls

echo -n 'source script   '
source pwdls.sh

echo 'source a script that sources another'
echo -n '                '
source_a_source=$(mktemp -d)
source_with_a_source="$source_a_source/source-with-a-source"
copy_of_pwdls="$source_a_source/pwdls"
cat pwdls.sh > "$copy_of_pwdls"
echo "source '$copy_of_pwdls'" > "$source_with_a_source"
# shellcheck disable=SC1090
source "$source_with_a_source"

echo
echo '--- from another directory'
in_another_directory=$(mktemp)
cat <<- 'EOF' >"$in_another_directory"
   echo -n 'string-argument '
   bash -c "$(cat pwdls.sh)"

   echo -n 'file-argument   '
   bash pwdls.sh

   echo -n 'exec script     '
   ./pwdls.sh

   echo -n 'exec command    '
   pwdls

   echo -n 'source script   '
   source pwdls.sh

   echo 'source a script that sources another'
   echo -n '                '
   source_a_source=$(mktemp -d)
   source_with_a_source="$source_a_source/source-with-a-source"
   copy_of_pwdls="$source_a_source/pwdls"
   cat pwdls.sh > "$copy_of_pwdls"
   echo "source '$copy_of_pwdls'" > "$source_with_a_source"
   # shellcheck disable=SC1090
   source "$source_with_a_source"
EOF
bash "$in_another_directory"
rm "$in_another_directory"
