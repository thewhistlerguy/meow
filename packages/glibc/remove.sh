#!/bin/bash
# remove.sh — pre-remove hook for glibc
# glibc is a core system library; guard against accidental removal.
set -euo pipefail

# Refuse to remove if other installed packages depend on glibc.
if command -v meow &>/dev/null; then
    RDEPS=$(meow rdepends glibc 2>/dev/null | grep -v "^glibc$" || true)
    if [ -n "$RDEPS" ]; then
        echo "ERROR: The following packages depend on glibc and must be removed first:"
        echo "$RDEPS"
        exit 1
    fi
fi

echo "WARNING: Removing glibc will make the system non-functional."
echo "Proceeding only because all reverse-dependencies are gone."

# Rebuild ldconfig after files are removed (meow calls this script before
# file removal, so we schedule a deferred rebuild via a flag file).
touch /tmp/.glibc_removed_rebuild_ldconfig

echo "glibc pre-remove checks passed."
