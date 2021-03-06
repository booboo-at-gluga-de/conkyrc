#!/bin/bash

# 2019-07-18 booboo
# this script returns from a ping command only the average roundtrip time
# it is basically designed for use within conky but might be useful elsewhere

PING_DEST="www.heise.de"
TIMEOUT="10s"
PING_CMD="ping6 -q"
PING_COUNT=3
NORMALIZE=0
NORMALIZE_MAX=1000
COLOR_RED=""
COLOR_ORANGE=""
COLOR_RESET=""
DEBUG=0

function help {
    cat <<EOH

call using:
$0 -h
    to display this help screen

$0 [-4|-w] [-t <timeout>] [-p <ping_destination>] [-m <max_value>] [-c] [-d]
    with:
        -4  use IPv4 for ping - means: use good old ping command
            (if you do not give this parameter: use IPv6 by default -
            ping6 command)
        -w  use httping (Port 80, www)
            httping needs to be installed
        -t <timeout>
            set the timeout for the ping command, e. g. 8s
            defaults to 10s
        -p <ping_destination>
            give the host you want to ping
            defaults to www.heise.de
        -m <max_value>
            if you want to print graphs or bar charts in conky
            (conky objects execbar / execibar / ...)
            the script must report a number between 0 and 100.
            Which value is considered to be 100%? Give this value
            as <max_value>.
            e. g. if you give -m 1000
            1000 ms of round trip time (and any value above) lead to
            a 100% completely filled bar
        -c  enable colored output
            (to be used with conky objects execp / execpi)
        -d  to enable debug output

EOH
}

function debug {
    if [[ $DEBUG -gt 0 ]]; then
        echo DEBUG: $* >&2
    fi
}

while getopts ":h4wt:p:m:cd" opt; do
    case ${opt} in
        h )
            help
            exit 0
            ;;
        4 )
            PING_CMD="ping -4 -q"
            ;;
        w )
            PING_CMD="httping -r"
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
        m )
            NORMALIZE=1
            NORMALIZE_MAX=$OPTARG
            ;;
        c )
            COLOR_RED='${color red}'
            COLOR_ORANGE='${color orange}'
            COLOR_RESET='${color}'
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
mapfile -t SCRIPT_OUT < <( timeout $TIMEOUT $PING_CMD -c $PING_COUNT $PING_DEST 2>&1; echo TIMEOUT_RC: $? )

# debug info
for (( i=0; i<${#SCRIPT_OUT[@]}; i++ )); do
    debug SCRIPT_OUT $i: ${SCRIPT_OUT[i]}
done

if [[ ${SCRIPT_OUT[-1]} = "TIMEOUT_RC: 124" ]]; then
    RESULT="${COLOR_RED}timed out${COLOR_RESET}"
    echo timeout abortet ping command after $TIMEOUT >&2
elif [[ ${SCRIPT_OUT[0]} =~ unknown\ host ]]; then
    RESULT="${COLOR_RED}unknown host${COLOR_RESET}"
    echo ${SCRIPT_OUT[0]} >&2
elif [[ ${SCRIPT_OUT[0]} =~ Network\ is\ unreachable ]]; then
    RESULT="${COLOR_RED}network unreachable${COLOR_RESET}"
    echo ${SCRIPT_OUT[0]} >&2
elif [[ ${SCRIPT_OUT[-3]} =~ 100%\ packet\ loss ]]; then
    RESULT="${COLOR_RED}loss 100%${COLOR_RESET}"
else
    if [[ ${SCRIPT_OUT[-2]} =~ ^(rtt|round-trip)\ min/avg/max ]]; then
        RESULT=$( echo ${SCRIPT_OUT[-2]} | cut -d'=' -f2 | cut -d'/' -f2)

        if [[ $NORMALIZE -eq 0 ]]; then
            # the standard case: just report the concrete value
            RESULT=$(printf "%1.2f" $RESULT)
            RESULT="$RESULT ms"
        else
            # normalize to values 0 to 100 (for graphing)
            debug RESULT, ms: $RESULT
            RESULT=$( printf "%1.0f" $(echo "scale=3; $RESULT / $NORMALIZE_MAX * 100" | bc -l) )
            if [[ $RESULT -gt 100 ]]; then
                RESULT=100
            fi
            debug RESULT, normalized: $RESULT
        fi
    else
        RESULT="${COLOR_ORANGE}unknown${COLOR_RESET}"
        echo the output of the ping command was in an unexpected format >&2
        echo and therefor could not be parsed >&2
    fi
fi

echo $RESULT
