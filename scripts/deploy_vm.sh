#!/bin/bash

VM_NAME="alpine-web"
IMAGE="Alpine3.21"
FLAVOR="Leger"
NETWORK="LAN-LABO"
KEY="mykey"

openstack server create \
  --image "$IMAGE" \
  --flavor "$FLAVOR" \
  --network "$NETWORK" \
  --key-name "$KEY" \
  --user-data cloud-init/alpine-nginx.yaml \
  "$VM_NAME"
