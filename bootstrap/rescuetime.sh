# see https://www.rescuetime.com/get_rescuetime
if ! command -v rescuetime ; then
    rm -f /tmp/rescuetime.deb
    curl -JL https://www.rescuetime.com/installers/rescuetime_current_amd64.deb -o /tmp/rescuetime.deb
    sudo apt install -f /tmp/rescuetime.deb
fi

cat << EOF > ~/.config/autostart/rescuetime.desktop
[Desktop Entry]
Type=Application
Name=Rescuetime
Exec=/usr/bin/rescuetime
X-GNOME-Autostart-enabled=true
EOF
