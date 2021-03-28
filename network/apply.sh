#!/bin/bash

set -ex

workspaces=(
"general"
"kubernetes"
"vpn"
)

for workspace in ${workspaces[@]}
do
  terraform workspace select $workspace
  terraform apply -auto-approve
done
