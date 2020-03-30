#!/bin/bash

if ! [ -x "$(command -v gcc)" ]; then
  echo 'Error: gcc is not installed.' >&2
  exit 1
fi

echo 'All components are available, continue installation'