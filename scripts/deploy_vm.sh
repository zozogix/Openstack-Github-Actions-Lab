#!/bin/bash
set -e

VM_NAME="alpine-web"
IMAGE="Alpine3.21"
FLAVOR="Minus"
NETWORK="LAN-LABO"
KEY="zoly-key"

openstack server create \
  --image "$IMAGE" \
  --flavor "$FLAVOR" \
  --network "$NETWORK" \
  --key-name "$KEY" \
  --user-data cloud-init/alpine-web.yaml \
  "$VM_NAME"
