#!/usr/bin/env bash
set -e

# -------------------------------------------------
# Always run from repository root
# -------------------------------------------------
cd "$(dirname "$0")/.."

# -------------------------------------------------
# Load OpenStack credentials
# -------------------------------------------------
source /home/user/openrc.sh

# -------------------------------------------------
# Configuration
# -------------------------------------------------
VM_NAME="alpine-web"
IMAGE="Alpine3.21"
FLAVOR="Minus"
NETWORK="LAN-LABO"
KEY="zoly-key"

CLOUD_INIT_SRC="cloud-init/alpine-web.yaml"
CLOUD_INIT_TMP="/tmp/alpine-web.yaml"

# -------------------------------------------------
# Sanity checks
# -------------------------------------------------
MICROSTACK_OPENSTACK="$(command -v microstack.openstack || true)"
if [ -z "$MICROSTACK_OPENSTACK" ]; then
  echo "❌ microstack.openstack CLI not found"
  exit 1
fi

if [ ! -f "$CLOUD_INIT_SRC" ]; then
  echo "❌ cloud-init file not found:"
  echo "   $(pwd)/$CLOUD_INIT_SRC"
  ls -l cloud-init || true
  exit 1
fi

# -------------------------------------------------
# Prepare cloud-init for sudo
# -------------------------------------------------
cp "$CLOUD_INIT_SRC" "$CLOUD_INIT_TMP"
chmod 644 "$CLOUD_INIT_TMP"

# -------------------------------------------------
# Verify sudo works non-interactively
# -------------------------------------------------
sudo -n "$MICROSTACK_OPENSTACK" token issue >/dev/null 2>&1 || {
  echo "❌ sudo microstack.openstack is not allowed without password"
  exit 1
}

# -------------------------------------------------
# Deploy VM
# -------------------------------------------------
sudo "$MICROSTACK_OPENSTACK" server create \
  --image "$IMAGE" \
  --flavor "$FLAVOR" \
  --network "$NETWORK" \
  --key-name "$KEY" \
  --user-data "$CLOUD_INIT_TMP" \
  "$VM_NAME"

echo "✅ VM '$VM_NAME' deployment triggered"

# -------------------------------------------------
# Cleanup
# -------------------------------------------------
rm -f "$CLOUD_INIT_TMP"

