#!/bin/bash

echo "Entering"

read -n1 -s -r key

if [ "$key" = 'x' ]; then
    echo "x pressed - correct"
else
    echo "$key pressed"
fi

echo "Done"

exit 0
