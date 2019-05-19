#!/usr/bin/env bash

echo 'run style | pwd | «$0» | «$BASH_SOURCE» | ls dir-stub'

echo
echo '--- same directory as script'
echo -n 'exec script   '
./pwd0bashsourcels.sh

echo -n 'source script '
source pwd0bashsourcels.sh

echo -n 'exec command  '
pwd0bashsourcels

echo -n 'exec string   '
bash -c "$(cat pwd0bashsourcels.sh)"

echo
echo '--- from another directory'
in_another_directory=$(mktemp)
cat <<- 'EOF' >"$in_another_directory"
   echo -n 'exec script   '
   ./pwd0bashsourcels.sh

   echo -n 'source script '
   source pwd0bashsourcels.sh

   echo -n 'exec command  '
   pwd0bashsourcels

   echo -n 'exec string   '
   bash -c "$(cat pwd0bashsourcels.sh)"
EOF
bash "$in_another_directory"
rm "$in_another_directory"
