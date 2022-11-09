#!/bin/bash

# Install terraform cli if it is not installed
command -v terraform
if [ "$?" -ne 0 ]; then
    ./install_terraform.sh
fi

# generate an ssh key if not present (echo "n" for "overwrite?")
echo "n" | ssh-keygen -t RSA -b 4096 -f aws_rsa -N ""
echo
export TF_VAR_public_key_path=$(pwd)"/aws_rsa.pub"
export TF_VAR_private_key_path=$(pwd)"/aws_rsa"
echo Running build script ...
./up.sh aws
up_res=$?

# Even if the spin up fails, we want to run down.sh before failing
# so that we do not accidentally leave infra deployed on AWS
echo Running teardown script ...
./down.sh aws
down_res=$?

if [ "$up_res" -ne 0 ]; then
    echo Build test fails
    exit $up_res
elif [ "$down_res" -ne 0 ]; then
    echo Teardown test fails
    exit $down_res
fi
