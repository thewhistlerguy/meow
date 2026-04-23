#!/bin/bash
# build.sh — wpa_supplicant
# Env vars: MEOW_WORK  MEOW_STAGE  MEOW_NAME  MEOW_VER  MEOW_REL
set -euo pipefail

set -euo pipefail
cd wpa_supplicant

# Build config
cat > .config << 'EOF'
CONFIG_BACKEND=file
CONFIG_CTRL_IFACE=unix
CONFIG_DEBUG_FILE=y
CONFIG_DRIVER_NL80211=y
CONFIG_DRIVER_WEXT=y
CONFIG_IEEE8021X_EAPOL=y
CONFIG_EAP_MD5=y
CONFIG_EAP_MSCHAPV2=y
CONFIG_EAP_TLS=y
CONFIG_EAP_PEAP=y
CONFIG_EAP_TTLS=y
CONFIG_EAP_FAST=y
CONFIG_EAP_GTC=y
CONFIG_EAP_OTP=y
CONFIG_EAP_LEAP=y
CONFIG_PKCS12=y
CONFIG_PEERKEY=y
CONFIG_TLS=openssl
CONFIG_WPS=y
CONFIG_WPA_CLI_EDIT=y
EOF

make -j$(nproc)
install -Dm755 wpa_supplicant "$MEOW_STAGE/usr/sbin/wpa_supplicant"
install -Dm755 wpa_cli        "$MEOW_STAGE/usr/sbin/wpa_cli"
install -Dm755 wpa_passphrase "$MEOW_STAGE/usr/sbin/wpa_passphrase"
install -Dm644 doc/docbook/wpa_supplicant.conf.5 "$MEOW_STAGE/usr/share/man/man5/" || true

# runit service
install -Dm755 /dev/stdin "$MEOW_STAGE/etc/sv/wpa_supplicant/run" << 'EOF'
#!/bin/sh
exec /usr/sbin/wpa_supplicant -c /etc/wpa_supplicant/wpa_supplicant.conf -i wlan0
EOF

install -Dm600 /dev/stdin "$MEOW_STAGE/etc/wpa_supplicant/wpa_supplicant.conf" << 'EOF'
# /etc/wpa_supplicant/wpa_supplicant.conf
ctrl_interface=/run/wpa_supplicant
update_config=1
# network={
#     ssid="YourNetwork"
#     psk="YourPassword"
# }
EOF
