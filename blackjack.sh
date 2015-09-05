#!/bin/bash

# Let's assume that a card is represented numerically like so:
# "11,3" with 11 indicating the card value, (in this case, a jack)
# and the 3 representing the card suit. The card suits and their
# respective values are as follows:
# Spades: 4, Hearts: 3, Diamonds: 2, and Clubs: 1. This follows
# The ordering of [this](https://en.wikipedia.org/wiki/Suit_(cards)#Ranking_of_suits)
# poker suits ranking.

declare -a DECK
declare -a PLAYERS
PLAYERS[0]=""

while getopts ":p:" flag
do
    case $flag in
        p)
            if [[ $OPTARG =~ ^-?[0-9]+$ ]]
            then
                if (( OPTARG>12 || OPTARG<1 ))
                then
                    echo "Maximum of 12 players and minimum of 1 is required." >&2
                    exit 1
                else
                    for (( i=0; i<OPTARG; i++ ))
                    do
                        PLAYERS[$i]="" >&2
                    done
                fi
            else
                echo "Option -p expected number, got $OPTARG" >&2
                exit 1
            fi
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            exit 1
    esac
done

function buildDeck() {
    counter=0
    for (( i=1; i<=13; i++ ))
    do
        for (( c=0; c <= 3; c++))
        do
            DECK[$counter]="$i,$c"
            counter=$((counter+1))
        done
    done
}

function dealCard() {
    card=$(((RANDOM % ${#DECK[@]}) + 1))
    echo "${DECK[$card]}"
    unset DECK[$card]
}

function buildHand() {
    echo "$(dealCard)|$(dealCard)"
}

function hitHand() {
    if [[ $# == 1 && $1 =~ ^-?[0-9]+$ ]]
    then
        PLAYERS[$1]="${PLAYERS[$1]}|$(dealCard)"
    elif [[ $# -gt 1 || $# -lt 1 ]]
    then
        echo "Invalid hit argument."
        exit 1
    fi
}

function calcSum() {
    if [[ $# == 1 && $1 =~ ^-?[0-9]+$ ]]
    then
        sum=0
        cards=(${PLAYERS[$1]//|/ })
        for (( i=0;i<${#cards[@]};i++ ))
        do
            sum=$((sum+${cards[i]%,*}))
        done
        echo $sum
    elif [[ $# -gt 1 || $# -lt 1 ]]
    then
        echo "Invalid hit argument."
        exit 1
    fi
}

function start() {
    buildDeck
    for (( i=0; i<${#PLAYERS[@]}; i++ ))
    do
        PLAYERS[$i]=$(buildHand)
    done
}

start
echo "${PLAYERS[*]}"

while read -rsn1 input
do
    if [ "$input" == "h" ]
    then
        hitHand 0
        echo "${PLAYERS[*]}"
        if [[ $(calcSum 0) -gt 21 ]]
        then
            echo "Busted!"
            exit 1
        fi
    fi
done
