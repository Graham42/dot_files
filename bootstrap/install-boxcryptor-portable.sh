#!/usr/bin/env bash

set -ex
set -o pipefail

rm -f /tmp/Boxcryptor_Portable_Linux64.tar.gz
curl -JL -o /tmp/Boxcryptor_Portable_Linux64.tar.gz https://www.boxcryptor.com/l/download-linux-portable

if [ -e /opt/boxcryptor ]; then
    echo "Boxcryptor seems to already be installed. Check /opt/boxcryptor"
    exit 1
fi

sudo mkdir /opt/boxcryptor
sudo chown -R graham.graham /opt/boxcryptor
(cd /opt/boxcryptor && \
    tar xzf /tmp/Boxcryptor_Portable_Linux64.tar.gz)

cat <<EOF >/opt/boxcryptor/boxcryptor.desktop
[Desktop Entry]
Name=Boxcryptor
Exec=/opt/boxcryptor/Boxcryptor_Portable.sh
Terminal=false
Type=Application
Categories=
EOF

sudo desktop-file-install /opt/boxcryptor/boxcryptor.desktop
