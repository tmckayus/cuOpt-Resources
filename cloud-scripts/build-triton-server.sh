#!/bin/bash

# SPDX-FileCopyrightText: Copyright (c) 2022 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: MIT

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

DIR=$(dirname $(realpath "$0"))
#if [ "$AZURE_STORAGE_ACCOUNT" == "" ]; then
#    read -sp 'Enter an AZURE_STORAGE_ACCOUNT: ' AZURE_STORAGE_ACCOUNT
#fi

#if [ "$AZURE_STORAGE_KEY" == "" ]; then
#    read -sp 'Enter an AZURE_STORAGE_KEY: ' AZURE_STORAGE_KEY
#fi

#TF_VAR_azure_storage_account TF_VAR_azure_storage_key terraform apply --auto-approve
terraform apply --auto-approve
if [ "$?" -ne 0 ]; then
    exit -1
fi
terraform output --json outputs > values.json
$DIR/utilities/parse.py values.json values.sh
source values.sh

echo "The triton server http port is $ip:30000"
echo "The triton server grpc port is $ip:30001"
echo "The triton server metrics port is $ip:30002"
