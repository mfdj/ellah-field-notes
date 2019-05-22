#!/usr/bin/env bash

echo 'run style'
echo ' • 0'
echo ' • BASH_SOURCE[0]'
echo ' • BASH_SOURCE[1]'
echo ' • …'

echo
echo '--- same directory as script'
echo 'string-argument'
bash -c "$(cat 0bashsource.sh)"

echo 'file-argument'
bash 0bashsource.sh

echo 'exec script'
./0bashsource.sh

echo 'exec command'
0bashsource

echo 'source script'
source 0bashsource.sh

echo 'source a script that sources another'
source_a_source=$(mktemp -d)
source_with_a_source="$source_a_source/source-with-a-source"
copy_of_0bashsource="$source_a_source/0bashsource"
cat 0bashsource.sh > "$copy_of_0bashsource"
echo "source '$copy_of_0bashsource'" > "$source_with_a_source"
# shellcheck disable=SC1090
source "$source_with_a_source"

echo
echo '--- from another directory'
in_another_directory=$(mktemp)
cat <<- 'EOF' >"$in_another_directory"
   echo 'string-argument'
   bash -c "$(cat 0bashsource.sh)"

   echo 'file-argument'
   bash 0bashsource.sh

   echo 'exec script'
   ./0bashsource.sh

   echo 'exec command'
   0bashsource

   echo 'source script'
   source 0bashsource.sh
EOF
bash "$in_another_directory"
rm "$in_another_directory"
