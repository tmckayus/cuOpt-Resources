#!/bin/bash
if [ "$#" -lt 1 ]; then
    echo "usage: up.sh (aws|gcp|azure)"
    exit 1
fi
if [ -z "$API_KEY" ]; then
    echo API_KEY environment variable not set
    exit 1
fi
cd ../$1

# In case something foundational has changed ...
terraform init

res=$(terraform state list)
# if the result is 0 and the list is non-empty,
# we have current state
if [ "$?" -eq 0 ] && [ "$res" != "" ]; then
    echo Previous terraform state exists
    exit 1
fi

../build-cuopt-server.sh
if [ "$?" -ne 0 ]; then
    echo build-cuopt-server.sh failed
    exit 1
fi

if [ ! -f values.sh ]; then
    echo build-cuopt-server.sh did not produce values.sh
    exit 1
fi

source values.sh

function jupyter {
    i=0
    while true; do
        res=$(curl -s --connect-timeout 10 -o /dev/null -w '%{http_code}\n' $ip:30001/tree)
        if [ "$res" -ne 200 ]; then
            i=$((i+1))
            if [ "$i" -gt 6 ]; then
                echo Cannot reach Jupyter server
                exit 1
            else
                sleep 5
            fi
        else
            echo Reached Jupyter server
            break
        fi
    done
}

function api {
    i=0
    while true; do
        res=$(curl -s --connect-timeout 10 -o /dev/null -w '%{http_code}\n' $ip:30000/cuopt/docs)
        if [ "$res" -ne 200 ]; then
            i=$((i+1))
            if [ "$i" -gt 6 ]; then
                echo Cannot reach Jupyter server
                exit 1
            else
                sleep 5
            fi
        else
            echo Reached API server
            break
        fi
    done
}

case $cuopt_server_type in
  "jupyter")
     jupyter
     ;;
  "both")
     jupyter
     api
     ;;
  *)
     api
     ;;
esac
