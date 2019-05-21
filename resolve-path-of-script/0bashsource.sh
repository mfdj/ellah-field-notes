#!/usr/bin/env bash
echo -n "«${0}» "

if [[ ${#BASH_SOURCE[@]} == 0 ]]; then
   echo -n '(BASH_SOURCE is empty)'
fi

i=0
for item in "${BASH_SOURCE[@]}"; do
   echo -n "[$i] «${item}» "
   ((i++))
done

echo
