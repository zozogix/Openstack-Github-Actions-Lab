#!/usr/bin/env bash
set -e

echo "Starting OpenStack VM deployment"

# -------------------------------------------------
# Always run from repository root
# -------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

echo "Repository root: $REPO_ROOT"

# -------------------------------------------------
# Load OpenStack credentials
# -------------------------------------------------
OPENRC="/home/user/openrc.sh"

if [ ! -f "$OPENRC" ]; then
  echo "❌ OpenStack credentials file not found: $OPENRC"
  exit 1
fi

source "$OPENRC"
echo "OpenStack credentials loaded"

# -------------------------------------------------
# Configuration
# -------------------------------------------------
VM_NAME="alpine-web"
IMAGE="Alpine3.21"
FLAVOR="Minus"
NETWORK="LAN-LABO"
KEY_NAME="zoly-key"

CLOUD_INIT_FILE="$REPO_ROOT/cloud-init/alpine-web.yaml"

# -------------------------------------------------
# Sanity checks
# -------------------------------------------------
MICROSTACK_OPENSTACK="$(command -v microstack.openstack || true)"

if [ -z "$MICROSTACK_OPENSTACK" ]; then
  echo "❌ microstack.openstack CLI not found"
  exit 1
fi

if [ ! -f "$CLOUD_INIT_FILE" ]; then
  echo "❌ cloud-init file not found:"
  echo "   $CLOUD_INIT_FILE"
  ls -l "$REPO_ROOT/cloud-init" || true
  exit 1
fi

echo "cloud-init file detected:"
ls -l "$CLOUD_INIT_FILE"

# -------------------------------------------------
# Verify sudo access (non-interactive)
# -------------------------------------------------
if ! sudo -n "$MICROSTACK_OPENSTACK" token issue >/dev/null 2>&1; then
  echo "❌ sudo access to microstack.openstack is not allowed without password"
  exit 1
fi

echo "sudo access verified"

# -------------------------------------------------
# Check if VM already exists (idempotency)
# -------------------------------------------------
if sudo "$MICROSTACK_OPENSTACK" server show "$VM_NAME" >/dev/null 2>&1; then
  echo "⚠️ VM '$VM_NAME' already exists — deployment skipped"
  exit 0
fi

# -------------------------------------------------
# Deploy VM
# -------------------------------------------------
echo "Deploying VM '$VM_NAME'..."

sudo "$MICROSTACK_OPENSTACK" server create \
  --image "$IMAGE" \
  --flavor "$FLAVOR" \
  --network "$NETWORK" \
  --key-name "$KEY_NAME" \
  --user-data "$CLOUD_INIT_FILE" \
  "$VM_NAME"

echo "VM '$VM_NAME' deployment successfully triggered"
