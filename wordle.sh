#!/bin/bash

# command name
commando="$(basename "$0")"
declare -r commando

#constants and standard value
declare -i wordLength=5
declare -i tries=6

declare -A contrast
contrast["WRONG"]="\e[31m"
contrast["RIGHT"]="\e[32m"
contrast["PLACEMENT"]="\e[33m"
contrast["END"]="\e[0m"

# hulpfunctie: geef syntaxis weer en stop script met gegeven exit status
foutmelding() {
    echo "Syntax: ${commando} [-l <int between 3,10>] [-c] FILE" 1>&2 && exit "$1"
}

# verwerk opties
while getopts ":l:c" opt; do

    case "${opt}" in

        l)
            if (( ${OPTARG} < 2 || 10 < ${OPTARG} )); then
                foutmelding 1
            fi

            wordLength=${OPTARG}
            ;;

        \?) foutmelding 1
            ;;

    esac
done
shift $((OPTIND -1))

# check if there is excatly 1 argument
(($# == 1)) || foutmelding 2

# vars
declare -r contrast
declare -r wordLength

declare -A validLetters
for char in {A..Z}; do
    validLetters["${char}"]="${char}"
done

# make tmp file with words
tmpfile=$(mktemp)
grep -E "^[[:alpha:]]{${wordLength}}$" "${1}" | tr "[:lower:]" "[:upper:]" > "${tmpfile}"

# pick a random word
result=$(shuf -n 1 ${tmpfile})
declare -r result

badWord() {
    echo "${1} is invalid!"
    echo "Word has to be ${#2} long"
    echo "Only alphabetic letters!"
}

while [[ ${tries} -gt 0 && ${result} != ${guess} ]]; do

    echo "Valid letters: ${validLetters[@]}"
    read guess
    guess="${guess^^}"

    if [[ "${#guess}" != "${#result}" ]]; then
        badWord ${guess} ${result}
    else

        useOfLeters=""
        for ((i=0; i<${#guess}; i++)); do
            if [[ "${validLetters["${guess:${i}:1}"]}" == "" ]]; then
                echo "Letter ${guess:${i}:1} is not in the word"
            else
                useOfLetters+="${validLetters["${guess:${i}:1}"]}"
            fi
        done

        if [[ "${#useOfLetters}" == "${#guess}" ]]; then
            if [[ "$(grep -e "${guess}" "${tmpfile}")" == "" ]]; then
                echo "${guess} is not a word"
            else
                feedback=""
                for ((i=0; i<${#guess}; i++)); do
                    if [[ "${guess:${i}:1}" == "${result:${i}:1}" ]]; then
                        feedback+="${contrast["RIGHT"]}"${guess:${i}:1}"${contrast["END"]}"
                    else
                        if [[ ${result} =~ "${guess:${i}:1}" ]]; then
                            feedback+="${contrast["PLACEMENT"]}"${guess:${i}:1}"${contrast["END"]}"
                        else
                            feedback+="${contrast["WRONG"]}"${guess:${i}:1}"${contrast["END"]}"
                            # delete it out of valid chars
                            unset 'validLetters["${guess:${i}:1}"]'
                            fi
                    fi
                done
                echo -e "${feedback}"
                tries=$((${tries} - 1))
            fi
        fi
    fi
done


# end of game message
if [[ ${result} == ${guess} ]]; then
    echo "You won!"
else
    echo "You lost!"
fi
echo "The word was: ${result}"

# clean up
rm -f "${tmpfile}"
