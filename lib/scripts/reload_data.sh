#!/bin/bash

# Please customize the following four lines to suit the needs of your environment.
HOST_INFO="127.0.0.1:3000"
HOST_NAME_INFO="localhost:3000"
USER_NAME=foo
PASSWORD=hello
WORK_DIR=$HOME

## don't modify the lines below
DELETE_PATH=delete_all_data
LOAD_PATH=start_load
BASE_URL=http://$HOST_INFO

cd $WORK_DIR

## login
echo
echo "- authenticate -"
curl -o ${WORK_DIR}/login.html -c ${WORK_DIR}/cookie.txt -H "Accept:application/json" -X POST ${BASE_URL}/sessions -F "email=${USER_NAME}" -F "password=${PASSWORD}" -F "commit=Log in" -F "utf8=true", -H "Host:${HOST_NAME_INFO}", -H "Origin: ${BASE_URL}", -H "Referer: ${BASE_URL}/login"

sleep 5
## delete all data
echo
echo "- Deleting All Data -"
curl -o ${WORK_DIR}/delete_all_data.html -b ${WORK_DIR}/cookie.txt -H "Accept:application/json" -X GET ${BASE_URL}/${DELETE_PATH} -F "email=${USER_NAME}" -F "password=${PASSWORD}" -F "commit=Log in" -F "utf8=true", -H "Host:${HOST_NAME_INFO}", -H "Origin: ${BASE_URL}", -H "Referer: ${BASE_URL}/" 

sleep 5

## load
echo
echo "- Loading All Data -"
curl -o ${WORK_DIR}/load.html -b ${WORK_DIR}/cookie.txt -H "Accept:application/json" -X GET ${BASE_URL}/${LOAD_PATH} -F "email=${USER_NAME}" -F "password=${PASSWORD}" -F "commit=Log in" -F "utf8=true", -H "Host:${HOST_NAME_INFO}", -H "Origin: ${BASE_URL}", -H "Referer: ${BASE_URL}/load"

## data load can take two hours, depending on the load of github servers
sleep 7200
## Here one must wait until data load completes.

echo "- update caches for analytics page -"
curl -o ${WORK_DIR}/load.html -b ${WORK_DIR}/cookie.txt -H "Accept:application/json" -X GET ${BASE_URL}/${LOAD_PATH} -F "email=${USER_NAME}" -F "password=${PASSWORD}" -F "commit=Log in" -F "utf8=true", -H "Host:${HOST_NAME_INFO}", -H "Origin: ${BASE_URL}", -H "Referer: ${BASE_URL}"

sleep 6

curl -o ${WORK_DIR}/load.html -b ${WORK_DIR}/cookie.txt -H "Accept:application/json" -X GET ${BASE_URL}/${LOAD_PATH} -F "email=${USER_NAME}" -F "password=${PASSWORD}" -F "commit=Log in" -F "utf8=true", -H "Host:${HOST_NAME_INFO}", -H "Origin: ${BASE_URL}", -H "Referer: ${BASE_URL}/analytics"

sleep 6

echo "- update caches for reports page -"
curl -o ${WORK_DIR}/load.html -b ${WORK_DIR}/cookie.txt -H "Accept:application/json" -X GET ${BASE_URL}/${LOAD_PATH} -F "email=${USER_NAME}" -F "password=${PASSWORD}" -F "commit=Log in" -F "utf8=true", -H "Host:${HOST_NAME_INFO}", -H "Origin: ${BASE_URL}", -H "Referer: ${BASE_URL}/report"
