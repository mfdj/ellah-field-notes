#!/usr/bin/env bash

if [[ ${#BASH_SOURCE[@]} == 0 ]]; then
   echo ' • (BASH_SOURCE is empty)'
fi

i=0
for item in "${BASH_SOURCE[@]}"; do
   echo " • [$i] «${item}»"
   ((i++))
done

echo " • «${0}» "
echo
