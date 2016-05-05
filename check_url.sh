#!/bin/bash
# FILE: "check_url"
# DESCRIPTION: Check url using curl. Crafted to get numerous performance data.
# AUTHOR: Toni Comerma
# DATE: may-2016
# $Id:$
#
# Notes:

# Examples
#  To follow redirects
#  check_url.sh -u http://www.google.com -o "-L" 


PROGNAME=`basename $0`
PROGPATH=`echo $PROGNAME | sed -e 's,[\\/][^\\/][^\\/]*$,,'`
REVISION=`echo '$Revision: 1.0 $' `

CURL=`which curl`
CURL_WRITE_OUT="%{http_code},size_download=%{size_download}B,speed_download=%{speed_download}B,\
time_connect=%{time_connect}s,time_starttransfer=%{time_starttransfer}s,time_total=%{time_total}s,\
num_redirects=%{num_redirects},time_redirect=%{time_redirect}s"
OPTIONS=""

print_help() {
  echo "Usage:"
  echo "  $PROGNAME -u <url> -t <timeout> "
  echo "  $PROGNAME -h "
	echo ""
	echo "Opcions:"
	echo "  -u URL a testejar Exemple: rtmp://server/app/streamName"
	echo "  -t timeout"
	echo "  -o 'curl options': any curl command line switch to use. Don't forget to quote them"
	echo ""
  exit $STATE_UNKNOWN
}

STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3

URL=""
TIMEOUT=40

# Parameters processing
while getopts ":u:t:ho:" Option
do
	case $Option in
		u ) URL=$OPTARG;;
		t ) TIMEOUT=$OPTARG;;
		h ) print_help;;
        o ) OPTIONS=$OPTARG;;
		* ) echo "unimplemented option";;
		esac
done

if [ ! $URL ] ; then
	echo " Error - No URL to monitor "
	echo ""
	print_help
	echo ""
fi



# Read URL

OUT=`curl $URL $OPTIONS --max-time $TIMEOUT -o /dev/null -s --write-out "$CURL_WRITE_OUT"`
CURL_STATUS=$?
# curl return status
if [ $CURL_STATUS -eq 0 ]
then
   RETURN_CODE=`echo $OUT | cut -f 1 -d ","`
   FIRST_CHAR_RETURN_CODE=`echo $RETURN_CODE | cut -c 1`
   PERF=`echo $OUT | cut -f 2- -d ","`
   # 4xx, 5xx are errors; the rest is OK
   if [ "$FIRST_CHAR_RETURN_CODE" == "4" ] || [ "$FIRST_CHAR_RETURN_CODE" == "5" ]
   then
     echo "ERROR: $RETURN_CODE code returned while fetching $URL|$PERF"
     exit STATE_CRITICAL 
   else
     echo "OK: $URL fetched; return code $RETURN_CODE|$PERF"
     exit $STATE_OK
   fi
else
   echo "ERROR: Unable to fetch url $URL (curl error $CURL_STATUS)"
   exit $STATE_CRITICAL
fi

# bye