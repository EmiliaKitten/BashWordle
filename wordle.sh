#!/bin/bash

export LC_ALL=C

commando="$(basename "$0")"
declare -r commando

declare -i wordLength=5
declare -i tries=6

declare -A contrast
contrast[RIGHT]=$'\e[32m'
contrast[PLACEMENT]=$'\e[33m'
contrast[WRONG]=$'\e[31m'
contrast[END]=$'\e[0m'

foutmelding() {
    echo "Syntax: ${commando} [-l <int between 3,10>] [-c] FILE" 1>&2
    exit "$1"
}

while getopts ":l:c" opt; do
    case "${opt}" in
        l)
            if ! [[ ${OPTARG} =~ ^[0-9]{1,2}$ ]] || (( 10#${OPTARG} < 3 || 10#${OPTARG} > 10 )); then
                foutmelding 1
            fi
            wordLength=$(( 10#${OPTARG} ))
            ;;
        c)
            contrast[RIGHT]=$'\e[1;38;5;208m'
            contrast[PLACEMENT]=$'\e[1;38;5;39m'
            contrast[WRONG]=$'\e[90m'
            ;;
        :|\?)
            foutmelding 1
            ;;
    esac
done
shift $((OPTIND - 1))

(($# == 1)) || foutmelding 2

wordFile="$1"
if [[ ! -f ${wordFile} || ! -r ${wordFile} ]]; then
    echo "${commando}: cannot read '${wordFile}'" 1>&2
    exit 3
fi

declare -r contrast
declare -r wordLength

tmpfile=$(mktemp) || exit 4
trap 'rm -f "${tmpfile}"' EXIT

tr -d '\r' < "${wordFile}" \
    | grep -E "^[A-Za-z]{${wordLength}}$" \
    | tr '[:lower:]' '[:upper:]' \
    | sort -u > "${tmpfile}"

if [[ ! -s ${tmpfile} ]]; then
    echo "${commando}: no ${wordLength}-letter words found in '${wordFile}'" 1>&2
    exit 5
fi

result=$(shuf -n 1 "${tmpfile}")
declare -r result

validLetters="ABCDEFGHIJKLMNOPQRSTUVWXYZ"

badWord() {
    echo "${1} is invalid!"
    echo "Word has to be ${wordLength} letters long"
    echo "Only alphabetic letters!"
}

score() {
    local g="$1" r="$2" i c
    local -a status=()
    local -A remaining=()

    for ((i = 0; i < ${#g}; i++)); do
        if [[ ${g:i:1} == "${r:i:1}" ]]; then
            status[i]=RIGHT
        else
            status[i]=WRONG
            c="${r:i:1}"
            remaining[$c]=$(( ${remaining[$c]:-0} + 1 ))
        fi
    done

    for ((i = 0; i < ${#g}; i++)); do
        [[ ${status[i]} == RIGHT ]] && continue
        c="${g:i:1}"
        if (( ${remaining[$c]:-0} > 0 )); then
            status[i]=PLACEMENT
            remaining[$c]=$(( remaining[$c] - 1 ))
        fi
    done

    feedback=""
    for ((i = 0; i < ${#g}; i++)); do
        feedback+="${contrast[${status[i]}]}${g:i:1}${contrast[END]}"
    done
}

guess=""
while (( tries > 0 )) && [[ ${result} != "${guess}" ]]; do

    echo "Valid letters: ${validLetters}"
    echo "Tries left: ${tries}"
    read -r guess || { echo; guess=""; break; }
    guess="${guess^^}"

    if [[ ${#guess} -ne ${wordLength} || ! ${guess} =~ ^[A-Z]+$ ]]; then
        badWord "${guess}"
        continue
    fi

    valid=true
    for ((i = 0; i < ${#guess}; i++)); do
        letter="${guess:i:1}"
        if [[ ${validLetters} != *"${letter}"* ]]; then
            echo "Letter ${letter} is not in the word"
            valid=false
        fi
    done
    ${valid} || continue

    if ! grep -qxF -- "${guess}" "${tmpfile}"; then
        echo "${guess} is not a word"
        continue
    fi

    score "${guess}" "${result}"
    printf '%s\n' "${feedback}"
    tries=$(( tries - 1 ))

    for ((i = 0; i < ${#guess}; i++)); do
        letter="${guess:i:1}"
        if [[ ${result} != *"${letter}"* ]]; then
            validLetters="${validLetters//${letter}/}"
        fi
    done
done

if [[ ${result} == "${guess}" ]]; then
    echo "You won!"
else
    echo "You lost!"
fi
echo "The word was: ${result}"
