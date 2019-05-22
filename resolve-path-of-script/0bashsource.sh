#!/usr/bin/env bash
echo " • «${0}» "

if [[ ${#BASH_SOURCE[@]} == 0 ]]; then
   echo ' • (BASH_SOURCE is empty)'
fi

i=0
for item in "${BASH_SOURCE[@]}"; do
   echo " • [$i] «${item}»"
   ((i++))
done

echo
