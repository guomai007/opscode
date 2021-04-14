#!/bin/sh
# Check DNS query through DNS Servers 
# export LANG="en_US.UTF-8"
# export LC_ALL="en_US.UTF-8"

if [ -z $1 ]
    then
        echo "Usage: query.sh www.alibaba.com"
        exit 1
fi

SUMOK=`expr 0`
SUMFAIL=`expr 0`
echo "Query start..."
echo "---------------------------------------------------------------------------"
while read LINE
do
    if [ -z "$LINE" ]; then
             continue
    fi
    if ( echo "$LINE" | grep "#" >/dev/null )
    then
         ZONE="$LINE"
         continue
    fi
    for DNSSERVER in `echo $LINE`;do
    RESULT=`dig +short +time=2 +tries=2 @$DNSSERVER $1 |tr -d "\n\r"`
    if [ -n "$RESULT" ]
        then
            SUMOK=`expr $SUMOK \+ 1`
    fi
    if [ -z "$RESULT" ]
        then
            RESULT=`dig +short +time=2 +tries=2 @$DNSSERVER $1 `
            SUMOK=`expr $SUMOK \+ 1`
    fi
    if [ -z "$RESULT" ]
        then
            RESULT='NO Result!'
            SUMFAIL=`expr $SUMFAIL \+ 1`
    fi
    echo -e "$ZONE\t${DNSSERVER}\t\t${RESULT}"
    done
done <  ./cn-ldns
echo "---------------------------------------------------------------------------"
echo "Summary: "
echo "           Query succeed: "${SUMOK}"     Query failed: "${SUMFAIL}
