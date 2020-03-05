#!/usr/bin/env bash

set -euo pipefail

max_length=$(awk 'length > max_length { max_length = length; longest_line = $0 } END { print max_length }' ./words_alpha.txt)

echo "Max length: ${max_length}"
