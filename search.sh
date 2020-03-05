#!/usr/bin/env bash

set -euo pipefail

# TODO Manually find primes, for now hard code ones less than 100
primes=( 2 3 5 7 11 13 17 19 23 29 31 37 41 43 47 53 59 61 67 71 73 79 83 89 97 )

max_length=$(awk 'length > max_length { max_length = length; longest_line = $0 } END { print max_length }' ./words_alpha.txt)

echo "Max length: ${max_length}"

possible_primes=()

for x in "${primes[@]}"; do
    if [ $(( x * 2 )) -le ${max_length} ]; then
        possible_primes+=($x)
    fi
done

echo "Possible primes based on that: ${possible_primes[*]}"

possible_primes_plus_one=()

for x in "${possible_primes[@]}"; do
    possible_primes_plus_one+=( $(( x + 1 )) )
done

echo "Those plus one: ${possible_primes_plus_one[*]}"

# "Criteria" meaning they are one plus a prime (meaning the array possible_primes_plus_one)
# and that they are twice a prime
nums_that_fit_criteria=()

for x in "${possible_primes_plus_one[@]}"; do
    for y in "${possible_primes[@]}"; do
        if [ $(( y * 2 )) -eq $x ]; then
            nums_that_fit_criteria+=($y)
            break
        fi
    done
done

echo "These are numbers that are one plus a prime and equal to a doubled prime: ${nums_that_fit_criteria[*]}"
