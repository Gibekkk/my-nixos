# rainmeter-stats: one snapshot of system stats as key=value lines for the
# Rainmeter clock widget (rainmeter.nix). Same sources as conky's clock.lua.
# Prints raw counters only; the widget turns consecutive snapshots into rates.

rd() {  # first line of a file, empty when missing or unreadable
  local v=""
  if [ -r "$1" ]; then IFS= read -r v < "$1" 2>/dev/null || true; fi
  printf '%s' "$v"
}

# ---- CPU (jiffies since boot)
read -r _ u n s i w q sq st _ < /proc/stat
echo "cpu_total=$((u + n + s + i + w + q + sq + st))"
echo "cpu_idle=$((i + w))"

# ---- memory / swap (percent used)
mt=0 ma=0 swt=0 swf=0
while IFS=': ' read -r k v _; do
  case "$k" in
    MemTotal) mt=$v ;;
    MemAvailable) ma=$v ;;
    SwapTotal) swt=$v ;;
    SwapFree) swf=$v ;;
  esac
done < /proc/meminfo
if [ "$mt" -gt 0 ]; then echo "mem=$(( (mt - ma) * 100 / mt ))"; fi
if [ "$swt" -gt 0 ]; then echo "swap=$(( (swt - swf) * 100 / swt ))"; fi

# ---- CPU package temperature (hwmon numbers change between boots: find by name)
temp_path=""
for d in /sys/class/hwmon/hwmon*; do
  if [ "$(rd "$d/name")" = coretemp ]; then
    temp_path="$d/temp1_input"
    for j in 1 2 3 4 5 6 7 8; do
      case "$(rd "$d/temp${j}_label")" in
        Package*) temp_path="$d/temp${j}_input"; break ;;
      esac
    done
    break
  fi
done
if [ -z "$temp_path" ]; then temp_path=/sys/class/thermal/thermal_zone0/temp; fi
t=$(rd "$temp_path")
if [ -n "$t" ]; then echo "temp=$(( (t + 500) / 1000 ))"; fi

# ---- battery
echo "bat=$(rd /sys/class/power_supply/BAT0/capacity)"

# ---- uptime (for the Intel RC6 rate)
read -r up _ < /proc/uptime
echo "up=$up"

# ---- GPUs: first dedicated (boot_vga 0) and first integrated card
#   busy: gpu_busy_percent (amdgpu), only read while the GPU is awake, so a
#         sleeping dGPU is never woken up
#   rc6:  i915 RC6 idle residency (ms), turned into busy % by the widget
#   freq: actual vs min/max frequency, rough last resort
have_d="" have_i=""
for card in /sys/class/drm/card[0-9]; do
  [ -e "$card" ] || continue
  dev="$card/device"
  vendor=$(rd "$dev/vendor")
  [ -n "$vendor" ] || continue
  case "$vendor" in
    0x8086) name=INTEL ;;
    0x1002) name=AMD ;;
    0x10de) name=NVIDIA ;;
    *) name=GPU ;;
  esac
  status=$(rd "$dev/power/runtime_status")
  method="" value=""
  if [ -e "$dev/gpu_busy_percent" ]; then
    method=busy
    if [ "$status" != suspended ]; then value=$(rd "$dev/gpu_busy_percent"); fi
  elif [ -r "$card/gt/gt0/rc6_residency_ms" ]; then
    method=rc6; value=$(rd "$card/gt/gt0/rc6_residency_ms")
  elif [ -r "$card/power/rc6_residency_ms" ]; then
    method=rc6; value=$(rd "$card/power/rc6_residency_ms")
  elif [ -r "$card/gt_act_freq_mhz" ]; then
    method=freq
    act=$(rd "$card/gt_act_freq_mhz"); min=$(rd "$card/gt_RPn_freq_mhz"); max=$(rd "$card/gt_RP0_freq_mhz")
    min=${min:-0}
    if [ -n "$act" ] && [ -n "$max" ] && [ "$max" -gt "$min" ]; then
      above=$(( act - min ))
      if [ "$above" -lt 0 ]; then above=0; fi
      value=$(( (100 * above + (max - min) / 2) / (max - min) ))
    fi
  fi
  [ -n "$method" ] || continue
  if [ "$(rd "$dev/boot_vga")" = 0 ]; then kind=dedicated; else kind=integrated; fi
  if [ "$kind" = dedicated ]; then
    if [ -n "$have_d" ]; then continue; fi
    have_d=1
  else
    if [ -n "$have_i" ]; then continue; fi
    have_i=1
  fi
  echo "gpu_$kind=$name|$method|$value|$status"
done
