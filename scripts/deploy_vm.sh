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
USER_DATA="$(pwd)/cloud-init/alpine-web.yaml"

# ---- Sanity checks ----
MICROSTACK_OPENSTACK=$(command -v microstack.openstack || true)
if [ -z "$MICROSTACK_OPENSTACK" ]; then
    echo "❌ microstack.openstack CLI not found"
    exit 1
fi

# Make sure we can run it with sudo
sudo -n $MICROSTACK_OPENSTACK token issue >/dev/null 2>&1 || {
    echo "❌ Cannot run 'sudo microstack.openstack'. Make sure NOPASSWD sudo is set for this user."
    exit 1
}

# ---- Deploy VM ----
sudo $MICROSTACK_OPENSTACK server create \
    --image "$IMAGE" \
    --flavor "$FLAVOR" \
    --network "$NETWORK" \
    --key-name "$KEY" \
    --user-data "$USER_DATA" \
    "$VM_NAME"

echo "✅ VM '$VM_NAME' deployment triggered"
