{
  # Login autostart entries.
  #
  # ZapFast is not listed here on purpose: enable it in ZapFast itself
  # (Settings -> "Start at login"). The app registers itself through the
  # desktop's Background portal, which writes ~/.config/autostart/zapfast.desktop
  # with --start-hidden. A home-manager entry would overwrite that file and
  # make the in-app switch stop working.
}
