#!/usr/bin/env bash
set -e

# Load OpenStack credentials (MicroStack)
source /home/user/openrc.sh

# ---- Configuration ----
VM_NAME="alpine-web"
IMAGE="Alpine3.21"
FLAVOR="Minus"
NETWORK="LAN-LABO"
KEY="zoly-key"
USER_DATA="cloud-init/alpine-web.yaml"

# ---- Sanity checks ----
command -v openstack >/dev/null 2>&1 || {
  echo "❌ OpenStack CLI not found"
  exit 1
}

openstack token issue >/dev/null

# ---- Deploy VM ----
openstack server create \
  --image "$IMAGE" \
  --flavor "$FLAVOR" \
  --network "$NETWORK" \
  --key-name "$KEY" \
  --user-data "$USER_DATA" \
  "$VM_NAME"

echo "✅ VM '$VM_NAME' deployment triggered"
