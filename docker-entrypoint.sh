#!/usr/bin/env bash
# vim:sw=4:ts=4:et
# shellcheck source=/dev/null
# set -x 
# shellcheck disable=SC2034,SC2059,SC2016
cecho(){
    RED="\033[0;31m"
    GREEN="\033[0;32m"
    YELLOW="\033[1;33m"
    BLUE="\033[1;34m"
    PURPLE="\033[1;35m"
    CYAN="\033[1;36m"
    NC="\033[0m" # No Color
    printf "${!1}${2} ${NC}\n"
}

case $(uname -s) in
    Linux*)     machine=Linux;;
    Darwin*)    machine=Mac;;
    CYGWIN*)    machine=Cygwin;;
    MINGW*)     machine=MinGw;;
    *)          machine="UNKNOWN"
esac

EXEC=""

exec ${EXEC} "$@"
