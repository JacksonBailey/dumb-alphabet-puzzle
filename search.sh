#!/usr/bin/env bash

set -euo pipefail

###############################################################################

# TODO Manually find primes, for now hard code ones less than 100
primes=( 2 3 5 7 11 13 17 19 23 29 31 37 41 43 47 53 59 61 67 71 73 79 83 89 97 )

max_length=$(awk 'length > max_length { max_length = length } END { print max_length }' ./words_alpha.txt)

echo "Max length of any word: ${max_length}"

###############################################################################

possible_primes=()

for x in "${primes[@]}"; do
    if [ $(( x * 2 )) -le ${max_length} ]; then
        possible_primes+=($x)
    fi
done

echo "Possible primes based on that: ${possible_primes[*]}"

###############################################################################

possible_primes_plus_one=()

for x in "${possible_primes[@]}"; do
    possible_primes_plus_one+=( $(( x + 1 )) )
done

echo "Those plus one: ${possible_primes_plus_one[*]}"

###############################################################################

# "Criteria" meaning they are one plus a prime (meaning the array possible_primes_plus_one)
# and that they are twice a prime
nums_that_fit_criteria=()

for x in "${possible_primes_plus_one[@]}"; do
    for y in "${possible_primes[@]}"; do
        if [ $(( y * 2 )) -eq $x ]; then
            nums_that_fit_criteria+=( $(( y * 2 )) )
            break
        fi
    done
done

echo "These are numbers that are one plus a prime and equal to a doubled prime: ${nums_that_fit_criteria[*]}"

###############################################################################

vowels=( 'a' 'e' 'i' 'o' 'u' )
colors=('red' 'orange' 'yellow' 'green' 'blue' 'indigo' 'violet')
color_letter_sets=()

for i in "${!colors[@]}"; do
    for j in "${!colors[@]}"; do
        if [ $i -le $j ]; then
            continue
        fi
        color_letter_sets+=( "$(echo "${colors[$i]}${colors[$j]}" | grep -o . | sort | tr -d "\n")" )
    done
done

IFS=$'\n' sorted_color_letter_sets=( $( sort <<< "${color_letter_sets[*]}" ) )
unset IFS
echo "These are the possible letter sets (each can also have two wild cards):
    ${sorted_color_letter_sets[*]}"

IFS=$'\n' shortest_color_set_length="$(echo "${sorted_color_letter_sets[*]}" | awk 'NR==1 || length < min_length { min_length = length } END { print min_length }')"
unset IFS

# Contains 4 of 5 vowels, so length must be at least 4.
# Contains letters of 2 colors of rainbow (plus 2 more letters) so must be at that

min_length=$(( shortest_color_set_length + 2 < 4 ? 4 : shortest_color_set_length + 2 ))

lengths=()

for x in "${nums_that_fit_criteria[@]}"; do
    if [ $x -ge ${min_length} ]; then
        lengths+=($x)
    fi
done

echo "Of those, they must be at least ${min_length} characters (2 colors + 2 letters or 4 vowels): ${lengths[*]}"

###############################################################################

color_letter_sets_with_valid=()

# Check wildcards
for x in "${sorted_color_letter_sets[@]}"; do
    for len in "${lengths[*]}"; do
        if [ $(( ${#x} + 2 )) -eq "${len}" ]; then
            color_letter_sets_with_valid+=($x)
            break
        fi
    done
done

# Note, if the color sets contain unique letters (to be used multiple times) the code breaks here

echo "Color sets with valid lengths (due to wildcards): ${color_letter_sets_with_valid[*]}"

###############################################################################

expressions=()

for x in "${lengths[@]}"; do
    expressions+=("/^.{$x}\$/p ;")
done

echo "sed expressions to run: ${expressions[*]}"

IFS=' ' words_with_valid_lengths="$(sed -n -E "${expressions[*]}" words_alpha.txt)"

echo "Found $(echo "${words_with_valid_lengths}" | wc -l) words with valid lengths!"

###############################################################################

# ggrep because mac's grep does not have -P. see here: https://stackoverflow.com/a/45534127/1858327

words_without_a="$(echo "${words_with_valid_lengths}" | ggrep -vE '^([^e]*|[^i]*|[^o]*|[^u]*)$' | ggrep -v 'a')"
words_without_e="$(echo "${words_with_valid_lengths}" | ggrep -vE '^([^a]*|[^i]*|[^o]*|[^u]*)$' | ggrep -v 'e')"
words_without_i="$(echo "${words_with_valid_lengths}" | ggrep -vE '^([^a]*|[^e]*|[^o]*|[^u]*)$' | ggrep -v 'i')"
words_without_o="$(echo "${words_with_valid_lengths}" | ggrep -vE '^([^a]*|[^e]*|[^i]*|[^u]*)$' | ggrep -v 'o')"
words_without_u="$(echo "${words_with_valid_lengths}" | ggrep -vE '^([^a]*|[^e]*|[^i]*|[^o]*)$' | ggrep -v 'u')"

words_with_4_vowels="${words_without_a}
${words_without_e}
${words_without_i}
${words_without_o}
${words_without_u}"

# No need to make sure these are unique, a word having exactly 4 vowels cannot have a different 4

echo "Found $(echo "${words_with_4_vowels}" | wc -l) words with 4 vowels and valid lengths!"

###############################################################################

letters=( 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 'p' 'q' 'r' 's' 't' 'u' 'v' 'w' 'x' 'y' 'z' )
color_sets_plus_wildcards=()

for l1 in "${letters[@]}"; do
    for l2 in "${letters[@]}"; do
        for set in "${color_letter_sets_with_valid[@]}"; do
            color_sets_plus_wildcards+=( "$(echo "${set}${l1}${l2}" | grep -o . | sort | tr -d "\n")" )
        done
    done
done

echo "Calculated all color sets plus their wild cards"

###############################################################################

while IFS= read -r word; do
    sorted_word="$(echo "${word}" | grep -o . | sort | tr -d "\n")"
    for set in "${color_sets_plus_wildcards[@]}"; do
        if [ "${sorted_word}" == ${set} ]; then
            echo "${word}"
        fi
    done
done <<< "${words_with_4_vowels}"
