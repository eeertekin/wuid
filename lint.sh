#!/usr/bin/env bash

[[ "$TRACE" ]] && set -x
pushd `dirname $0` > /dev/null
trap __EXIT EXIT

tput setaf 7 > /dev/null 2>&1
colorful=$?

function __EXIT() {
    popd > /dev/null
}

function printError() {
    [[ $colorful -eq 0 ]] && tput setaf 1
    >&2  echo "Error: $@"
    [[ $colorful -eq 0 ]] && tput setaf 7
}

function printImportantMessage() {
    [[ $colorful -eq 0 ]] && tput setaf 3
    echo "$@"
    [[ $colorful -eq 0 ]] && tput setaf 7
}

function printUsage() {
    [[ $colorful -eq 0 ]] && tput setaf 3
    >&2  echo "$@"
    [[ $colorful -eq 0 ]] && tput setaf 7
}

dirs='bench callback internal mongo mysql redis'

go tool vet -all -shadow=true $dirs

errcheck github.com/edwingeng/wuid/... \
    | ag -v '[ \t]*defer'

golint $dirs | ag -v 'receiver name should be a reflection of its identity'
