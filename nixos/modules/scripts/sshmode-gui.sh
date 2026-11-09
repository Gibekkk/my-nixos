# sshmode-gui: pick the SSH mode in a small window (KDE).

current=$(sshmode status --short)

radio() {
  if [ "$current" = "$1" ]; then
    echo on
  else
    echo off
  fi
}

choice=$(kdialog --title "SSH server mode" \
  --radiolist "Current mode: $current

Choose how the SSH server can be reached:" \
  off "Off - SSH server disabled" "$(radio off)" \
  tailscale "Tailscale only (default)" "$(radio tailscale)" \
  public "Public - reachable from any network" "$(radio public)") || exit 0

if [ "$choice" = "$current" ]; then
  exit 0
fi

if [ "$choice" = "public" ]; then
  kdialog --title "SSH server mode" --warningcontinuecancel \
    "Public mode makes the SSH server reachable from any network, including the internet if your router forwards port 22.

Make sure you use strong passwords or SSH keys." || exit 0
fi

if out=$(pkexec "$(command -v sshmode)" set "$choice" 2>&1); then
  kdialog --passivepopup "SSH mode is now: $choice" 4
else
  kdialog --title "SSH server mode" --error "Could not change the mode:

$out"
fi
