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

# cloud-init file (copy to /tmp for sudo safety)
USER_DATA_SRC="cloud-init/alpine-web.yaml"
USER_DATA_TMP="/tmp/alpine-web.yaml"

# ---- Sanity checks ----
MICROSTACK_OPENSTACK="$(command -v microstack.openstack || true)"
if [ -z "$MICROSTACK_OPENSTACK" ]; then
    echo "❌ microstack.openstack CLI not found"
    exit 1
fi

# Ensure cloud-init file exists
if [ ! -f "$USER_DATA_SRC" ]; then
    echo "❌ cloud-init file not found: $USER_DATA_SRC"
    exit 1
fi

# Copy cloud-init to /tmp so root can read it
cp "$USER_DATA_SRC" "$USER_DATA_TMP"
chmod 644 "$USER_DATA_TMP"

# Make sure sudo works non-interactively
sudo -n "$MICROSTACK_OPENSTACK" token issue >/dev/null 2>&1 || {
    echo "❌ Cannot run 'sudo microstack.openstack'. Check sudoers (NOPASSWD)."
    exit 1
}

# ---- Deploy VM ----
sudo "$MICROSTACK_OPENSTACK" server create \
    --image "$IMAGE" \
    --flavor "$FLAVOR" \
    --network "$NETWORK" \
    --key-name "$KEY" \
    --user-data "$USER_DATA_TMP" \
    "$VM_NAME"

echo "✅ VM '$VM_NAME' deployment triggered"

# Optional cleanup
rm -f "$USER_DATA_TMP"
