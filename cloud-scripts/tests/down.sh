#!/bin/bash
if [ "$#" -lt 1 ]; then
    echo "usage: down.sh (aws|gcp|azure)"
    exit 1
fi
cd ../$1

# In case something foundational has changed ...
terraform init

# if the result is 0 and the list is non-empty,
# we have current state
res=$(terraform state list)
if [ "$?" -eq 1 ] || [ "$res" == "" ]; then
    echo No current terraform state \(no machine to tear down\)
    exit 1
fi

../teardown-cuopt-server.sh
if [ "$?" -ne 0 ]; then
    echo Teardown failed, test fails
    exit 1
fi
if [ ! -f values.sh ]; then
    echo "Build script has not been run or didn't complete, test fails"
    exit 1
fi
source values.sh
rm values.sh

function jupyter {
    i=0
    while true; do
        res=$(curl -s --connect-timeout 10 -o /dev/null -w '%{http_code}\n' $ip:30001/tree)
        if [ "$res" -ne 200 ]; then
            echo Jupyter server down
            break
        else
            i=$((i+1))
            if [ "$i" -gt 6 ]; then
                echo Can still reach Jupyter server
                exit 1
            else
                sleep 5
            fi
        fi
    done
}

function api {
    i=0
    while true; do
        res=$(curl -s --connect-timeout 10 -o /dev/null -w '%{http_code}\n' $ip:30000/cuopt/docs)
        if [ "$res" -ne 200 ]; then
            echo API server down
            break
        else
            i=$((i+1))
            if [ "$i" -gt 6 ]; then
                echo Can still reach API server
                exit 1
            else
                sleep 5
            fi
        fi
    done
        
}

case $cuopt_server_type in
  "jupyter")
     jupyter
     ;;
  "both")
     api
     jupyter
     ;;
  *)
     api
     ;;
esac
