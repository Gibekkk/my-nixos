# sshmode: show or change how the SSH server is exposed.
#
#   off        SSH + RDP servers stopped
#   tailscale  reachable only through the tailscale0 interface
#   public     reachable from every network
#
# The KRDP RDP server (systemd user service "krdpserver", services.rdp)
# follows the same mode: it binds to tailscale0 in 'tailscale' and is
# stopped in 'off'. Its runtime state lives in /run/rdpmode, so every
# reboot returns to the default configured in Nix (services.sshmode.default).

unit="sshd.socket"
dropin_dir="/run/systemd/system/sshd.socket.d"
dropin="$dropin_dir/10-sshmode.conf"
ts_if="tailscale0"
rdp_user="gibekkk"
rdp_unit="krdpserver.service"

# Update the KRDP server to match $1 (off|tailscale|public). Runs as root;
# talks to the user's systemd instance if a session is up. Silent on failure:
# RDP must never break an SSH mode switch (and vice versa).
apply_rdp() {
  local mode="$1" uid xdg
  printf '%s\n' "$mode" > /run/rdpmode 2>/dev/null || true
  uid=$(id -u "$rdp_user" 2>/dev/null) || return 0
  xdg="/run/user/$uid"
  [ -d "$xdg" ] || return 0   # no session running: nothing to (re)(un)start; launcher picks the mode up on next login
  if [ "$mode" = "off" ]; then
    runuser -u "$rdp_user" -- env XDG_RUNTIME_DIR="$xdg" systemctl --user stop "$rdp_unit" </dev/null >/dev/null 2>&1 || true
  else
    runuser -u "$rdp_user" -- env XDG_RUNTIME_DIR="$xdg" systemctl --user restart "$rdp_unit" </dev/null >/dev/null 2>&1 || true
  fi
}

usage() {
  cat <<'USAGE'
Usage:
  sshmode                      show the current mode and details
  sshmode status [--short]     same; --short prints only: off | tailscale | public
  sshmode off|tailscale|public [--drop]
  sshmode set <mode> [--drop]  same as above

Options:
  --drop   also disconnect existing remote (SSH) sessions after switching.
           Switching to "off" always disconnects them.
USAGE
}

current_mode() {
  local state dev
  state=$(systemctl is-active "$unit" 2>/dev/null || true)
  dev=$(systemctl show "$unit" --value -p BindToDevice 2>/dev/null || true)
  if [ "$state" != "active" ]; then
    echo "off"
  elif [ "$dev" = "$ts_if" ]; then
    echo "tailscale"
  elif [ -z "$dev" ]; then
    echo "public"
  else
    echo "custom:$dev"
  fi
}

remote_sessions() {
  local id remote
  while read -r id _; do
    [ -n "$id" ] || continue
    remote=$(loginctl show-session "$id" --value -p Remote 2>/dev/null || true)
    if [ "$remote" = "yes" ]; then
      echo "$id"
    fi
  done < <(loginctl list-sessions --no-legend 2>/dev/null || true)
}

drop_sessions() {
  local id
  for id in $(remote_sessions); do
    loginctl terminate-session "$id" || true
  done
}

show_status() {
  local mode default count
  mode=$(current_mode)
  default="unknown"
  if [ -r /etc/sshmode/default ]; then
    default=$(cat /etc/sshmode/default)
  fi
  count=$(remote_sessions | wc -l)

  echo "SSH mode        : $mode"
  echo "RDP (KRDP) mode : $( { cat /run/rdpmode 2>/dev/null || true; } | head -n1 ), default at boot: $default"
  echo "Remote sessions : $count"
  echo "Listening on    :"
  if ! ss -H -tln 'sport = :22' | awk '{print "  " $4}' | grep .; then
    echo "  (nothing)"
  fi
  echo "Tailscale ($ts_if):"
  if ip -brief addr show "$ts_if" 2>/dev/null | grep .; then
    :
  else
    echo "  interface not present"
  fi
}

set_mode() {
  local mode="$1" drop="$2" now

  if [ "$(id -u)" -ne 0 ]; then
    if [ "$drop" = "yes" ]; then
      exec sudo -- "$0" set "$mode" --drop
    fi
    exec sudo -- "$0" set "$mode"
  fi

  case "$mode" in
    off)
      systemctl stop "$unit"
      systemctl stop 'sshd@*.service' 2>/dev/null || true
      rm -f "$dropin"
      systemctl daemon-reload
      drop_sessions
      apply_rdp off
      ;;
    tailscale)
      if ! ip link show "$ts_if" >/dev/null 2>&1; then
        # fail closed: never leave SSH (or RDP) reachable when we could not restrict it
        systemctl stop "$unit" || true
        apply_rdp off
        echo "sshmode: interface $ts_if not found (is tailscaled running?)." >&2
        echo "sshmode: SSH and RDP have been switched OFF instead." >&2
        exit 1
      fi
      mkdir -p "$dropin_dir"
      printf '[Socket]\nBindToDevice=%s\n' "$ts_if" > "$dropin"
      systemctl daemon-reload
      systemctl restart "$unit"
      apply_rdp tailscale
      ;;
    public)
      mkdir -p "$dropin_dir"
      printf '[Socket]\nBindToDevice=\n' > "$dropin"
      systemctl daemon-reload
      systemctl restart "$unit"
      apply_rdp public
      ;;
    *)
      echo "sshmode: unknown mode '$mode'" >&2
      usage >&2
      exit 2
      ;;
  esac

  if [ "$drop" = "yes" ] && [ "$mode" != "off" ]; then
    drop_sessions
  fi

  now=$(current_mode)
  if [ "$now" != "$mode" ]; then
    echo "sshmode: wanted '$mode' but the system reports '$now'." >&2
    exit 1
  fi
  echo "SSH mode is now: $now"
}

cmd="${1:-status}"
case "$cmd" in
  status)
    if [ "${2:-}" = "--short" ]; then
      current_mode
    else
      show_status
    fi
    ;;
  off | tailscale | public)
    drop="no"
    [ "${2:-}" = "--drop" ] && drop="yes"
    set_mode "$cmd" "$drop"
    ;;
  set)
    [ -n "${2:-}" ] || { usage >&2; exit 2; }
    drop="no"
    [ "${3:-}" = "--drop" ] && drop="yes"
    set_mode "$2" "$drop"
    ;;
  -h | --help | help)
    usage
    ;;
  *)
    usage >&2
    exit 2
    ;;
esac
