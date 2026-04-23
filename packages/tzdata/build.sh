#!/bin/bash
# build.sh — tzdata
# Env vars: MEOW_WORK  MEOW_STAGE  MEOW_NAME  MEOW_VER  MEOW_REL
set -euo pipefail

set -euo pipefail
ZONEINFO="$MEOW_STAGE/usr/share/zoneinfo"
install -d "$ZONEINFO"/{posix,right}

# Compile all zone files
for TZ_FILE in africa antarctica asia australasia                europe northamerica southamerica                etcetera backward factory; do
    zic -L /dev/null   -d "$ZONEINFO"       "$TZ_FILE"
    zic -L /dev/null   -d "$ZONEINFO/posix" "$TZ_FILE"
    zic -L leapseconds -d "$ZONEINFO/right" "$TZ_FILE"
done

cp zone.tab zone1970.tab iso3166.tab "$ZONEINFO"
zic -d "$ZONEINFO" -p America/New_York

# Install posixrules
install -m 644 "$ZONEINFO/America/New_York" "$ZONEINFO/posixrules"

# Default timezone
install -Dm644 /dev/stdin "$MEOW_STAGE/etc/localtime" <<< ""
# User should symlink: ln -sf /usr/share/zoneinfo/Region/City /etc/localtime
