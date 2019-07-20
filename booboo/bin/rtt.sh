#!/bin/bash

# 2019-07-18 booboo
# this script returns from a ping command only the average roundtrip time
# it is basically designed for use within conky but might be useful elsewhere

PING_DEST="www.heise.de"
TIMEOUT="10s"
PING_CMD="ping6"
PING_COUNT=3
DEBUG=0

function help {
    cat <<EOH

call using:
$0 -h
    to display this help screen

$0 [-4] [-t <timeout>] [-p <ping_destination>] [-d]
    with:
        -4  use IPv4 for ping - means: use good old ping command
            (if you do not give this parameter: use IPv6 by default -
            ping6 command)
        -t <timeout>
            set the timeout for the ping command, e. g. 8s
            defaults to 10s
        -p <ping_destination>
            give the host you want to ping
            defaults to www.heise.de
        -d  to enable debug output

EOH
}

function debug {
    if [[ $DEBUG -gt 0 ]]; then
        echo DEBUG: $* >&2
    fi
}

while getopts ":h4t:p:d" opt; do
    case ${opt} in
        h )
            help
            exit 0
            ;;
        4 )
            PING_CMD="ping"
            ;;
        t )
            TIMEOUT=$OPTARG
            ;;
        p )
            PING_DEST=$OPTARG
            ;;
        d )
            DEBUG=1
            ;;
        \? )
            echo "Invalid Option: -$OPTARG" >&2
            echo >&2
            help >&2
            exit 1
            ;;
    esac
done

debug PING_DEST=$PING_DEST
debug TIMEOUT=$TIMEOUT
debug PING_CMD=$PING_CMD
debug PING_COUNT=$PING_COUNT

RESULT=""
declare -a SCRIPT_OUT
export LANG=C
# write command output into an array (one entry per line)
# check if timeout aborted the command
mapfile -t SCRIPT_OUT < <( timeout $TIMEOUT $PING_CMD -q -c $PING_COUNT $PING_DEST 2>&1; echo TIMEOUT_RC: $? )

# debug info
for (( i=0; i<${#SCRIPT_OUT[@]}; i++ )); do
    debug SCRIPT_OUT $i: ${SCRIPT_OUT[i]}
done

if [[ ${SCRIPT_OUT[-1]} = "TIMEOUT_RC: 124" ]]; then
    RESULT="timed out"
    echo timeout abortet ping command after $TIMEOUT >&2
elif [[ ${SCRIPT_OUT[0]} =~ unknown\ host ]]; then
    RESULT="unknown host"
    echo ${SCRIPT_OUT[0]} >&2
elif [[ ${SCRIPT_OUT[0]} =~ Network\ is\ unreachable ]]; then
    RESULT="network unreachable"
    echo ${SCRIPT_OUT[0]} >&2
else
    if [[ ${SCRIPT_OUT[-2]} =~ ^rtt\ min/avg/max/mdev ]]; then
        RESULT=$( echo ${SCRIPT_OUT[-2]} | cut -d'=' -f2 | cut -d'/' -f2)
        RESULT="$RESULT ms"
    else
        RESULT="unknown"
        echo the output of the ping command was in an unexpected format >&2
        echo and therefor could not be parsed >&2
    fi
fi

echo $RESULT
