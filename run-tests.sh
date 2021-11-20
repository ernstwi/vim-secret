#!/usr/bin/env bash

if [[ $1 == "--verbose" || $1 == "-v" ]]; then
    VERBOSE=1
fi

check_results() {
    if [[ $? -eq 0 ]]; then
        echo -e "\e[32m$1: PASS\e[0m"
    else
        echo -e "\e[31m$1: FAIL\e[0m"
    fi

    if [[ $VERBOSE == 1 ]]; then
        sed -n '/^Starting Vader:/,$p' < vader_output
    fi
}

export VADER_OUTPUT_FILE=vader_output

vim.basic --not-a-term -c Vader! test/*.vader &>/dev/null
check_results "VIM" $1
rm vader_output

if [[ $VERBOSE == 1 ]]; then
    echo ""
fi

nvim -es -c Vader! test/*.vader
check_results "NEOVIM" $1
rm vader_output
