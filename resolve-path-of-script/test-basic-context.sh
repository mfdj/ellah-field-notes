#!/usr/bin/env bash

echo -n 'exec script   '
./lsla.sh

echo -n 'source script '
source lsla.sh

echo -n 'exec command  '
lsla

echo -n 'exec string   '
bash -c "$(cat lsla.sh)"

another_script=$(mktemp)
cat <<- 'EOF' >"$another_script"
   echo -n 'exec script   '
   ./lsla.sh

   echo -n 'source script '
   source lsla.sh

   echo -n 'exec command  '
   lsla

   echo -n 'exec string   '
   bash -c "$(cat lsla.sh)"
EOF
bash "$another_script"
rm "$another_script"
