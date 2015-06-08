#!/bin/bash

# simple masternode health checker
# run on masternode
# moocowmoo -- moocowmoo@masternode.me -- XmoocowYfrPKUR6p6M5aJZdVntQe71irCX

# -----

C_RED="\e[31m";
C_YELLOW="\e[33m";
C_GREEN="\e[32m";
C_NORM="\e[0m";

# -----

DASH_CLI=''
if   [ -e ./dash-cli ];          then DASH_CLI='./dash-cli';
elif [ -e ~/.dash/dash-cli ] ;   then DASH_CLI='~/.dash/dash-cli';
elif [ ! -z `which dash-cli` ] ; then DASH_CLI=`which dash-cli`;
fi
if [ -z $DASH_CLI ]; then
    echo "cannot find dash-cli in current directory, ~/.dash, or \$PATH";
    exit;
fi

echo -en "${C_YELLOW}collecting info... ";

# -----

DASH_RUNNING=`ps --no-header \`cat ~/.dash/dashd.pid\` | wc -l`;
DASH_LISTENING=`netstat -nat | grep LIST | grep 9999 | wc -l`;
DASH_CONNECTIONS=`netstat -nat | grep ESTA | grep 9999 | wc -l`;
DASH_CURRENT_BLOCK=`$DASH_CLI getblockcount`;
DASH_GETINFO=`$DASH_CLI getinfo`;

# -----

WEB_MNIP=`wget -qO- http://ipecho.net/plain`;
WEB_BLOCK_COUNT=`wget -qO- https://chainz.cryptoid.info/dash/api.dws?q=getblockcount`;

# -----

DASH_MN_STARTED=`$DASH_CLI masternode debug | grep started | wc -l`
DASH_MN_VISIBLE=`$DASH_CLI masternode list | grep $WEB_MNIP | wc -l`
DASH_MN_LIST=`$DASH_CLI masternode list`
DASH_MN_POSE=`$DASH_CLI masternode list pose  | grep $WEB_MNIP | awk '{print $3}' | sed 's/[^0-9]//g'`
DASH_MN_VOTES=`$DASH_CLI masternode list votes`

# -----

if [ $(($WEB_BLOCK_COUNT - 2)) -lt $DASH_CURRENT_BLOCK ]; then
    DASH_CURRENT=1
fi

if [ $DASH_MN_POSE -lt 2 ]; then
    DASH_MN_HEALTHY=1
fi

DASH_MN_ENABLED=$(echo "$DASH_MN_LIST" | grep -c ENABLED)
DASH_MN_UNHEALTHY=$(echo "$DASH_MN_LIST" | grep -c POS_ERROR)
DASH_MN_EXPIRED=$(echo "$DASH_MN_LIST" | grep -c EXPIRED)
DASH_MN_TOTAL=$(( $DASH_MN_ENABLED + $DASH_MN_UNHEALTHY ))

DASH_VERSION="v"$(echo "$DASH_GETINFO" | grep '"version' | sed -e 's/[^0-9]//g' | sed -e 's/\(..\)/\1\./g' | sed -e 's/\.$//')

echo -e "${C_GREEN}DONE${C_NORM}"

# -----

TEXT_RUNNING="${C_RED}NOT-RUNNING${C_NORM}";
TEXT_LISTENING="${C_RED}NOT-LISTENING${C_NORM}";
TEXT_CURRENT="${C_RED}NOT-SYNCED${C_NORM}";
TEXT_ENABLED="${C_RED}NOT-STARTED${C_NORM}";
TEXT_VISIBLE="${C_RED}NOT-VISIBLE${C_NORM}";
TEXT_HEALTHY="${C_RED}NOT-HEALTHY${C_NORM}";

if [ $DASH_RUNNING   -gt 0 ]; then TEXT_RUNNING="${C_GREEN}RUNNING${C_NORM}"; fi
if [ $DASH_LISTENING -gt 0 ]; then TEXT_LISTENING="${C_GREEN}LISTENING${C_NORM}"; fi
if [ $DASH_CURRENT   -gt 0 ]; then TEXT_CURRENT="${C_GREEN}CURRENT${C_NORM}"; fi

if [ $DASH_MN_STARTED -gt 0 ]; then TEXT_ENABLED="${C_GREEN}STARTED${C_NORM}"; fi
if [ $DASH_MN_VISIBLE -gt 0 ]; then TEXT_VISIBLE="${C_GREEN}VISIBLE${C_NORM}"; fi
if [ $DASH_MN_HEALTHY -gt 0 ]; then TEXT_HEALTHY="${C_GREEN}HEALTHY${C_NORM}"; fi

# -----

echo -e "\n ----"

echo -e "      dashd: $TEXT_RUNNING $TEXT_LISTENING $TEXT_CURRENT"
echo -e " masternode: $TEXT_ENABLED $TEXT_VISIBLE   $TEXT_HEALTHY"

echo -e " ----"

echo "   instance information"
echo "     IP Address         $WEB_MNIP"
echo "     dashd version      $DASH_VERSION"
echo "     dashd connections  $DASH_CONNECTIONS"
echo "     service score      $DASH_MN_POSE"
echo "     dashd last block   $DASH_CURRENT_BLOCK"
echo "     chainz last block  $WEB_BLOCK_COUNT"
echo "     masternode total   $DASH_MN_TOTAL"
echo "     masternode healthy $DASH_MN_ENABLED"

echo -e " ----"

echo "   current vote counts"
echo "                   YEA: $(echo "$DASH_MN_VOTES" | grep -c YEA)"
echo "                   NAY: $(echo "$DASH_MN_VOTES" | grep -c NAY)"
echo "               ABSTAIN: $(echo "$DASH_MN_VOTES" | grep -c ABSTAIN)"
echo "             this vote: $(echo "$DASH_MN_VOTES" | grep $WEB_MNIP | awk '{print $3}' | sed -e 's/[",]//g')"

# -----

exit;

