#!/usr/bin/env bash

echo 'run style | 0 | BASH_SOURCE[i]'

echo
echo '--- same directory as script'
echo -n 'source script '
source 0bashsource.sh

echo -n 'exec string   '
bash -c "$(cat 0bashsource.sh)"

echo -n 'exec script   '
./0bashsource.sh

echo -n 'exec command  '
0bashsource

echo
echo '--- from another directory'
in_another_directory=$(mktemp)
cat <<- 'EOF' >"$in_another_directory"
   echo -n 'source script '
   source 0bashsource.sh

   echo -n 'exec string   '
   bash -c "$(cat 0bashsource.sh)"

   echo -n 'exec script   '
   ./0bashsource.sh

   echo -n 'exec command  '
   0bashsource
EOF
bash "$in_another_directory"
rm "$in_another_directory"
