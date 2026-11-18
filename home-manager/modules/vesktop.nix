{ lib, ... }:
let
  # Every *.css file in themes/vesktop/ is installed into ~/.config/vesktop/themes
  # under its own filename, so the repo folder is the single source of truth.
  # home-manager writes a theme as "<name>.css", so the attribute name is the
  # filename without ".css" (system24.theme.css -> "system24.theme").
  themeDir = ../../themes/vesktop;
  themes = lib.mapAttrs'
    (file: _: lib.nameValuePair (lib.removeSuffix ".css" file) (themeDir + "/${file}"))
    (lib.filterAttrs (file: type: type == "regular" && lib.hasSuffix ".css" file)
      (builtins.readDir themeDir));
in
{
  programs.vesktop = {
    enable = true;

    vencord = {
      # settings.json is read-only (managed here), so themes picked in the
      # Vesktop UI are not saved: change enabledThemes instead. Use the
      # filename as it appears in themes/vesktop/.
      settings = {
        autoUpdate = false;
        useQuickCss = true;
        enabledThemes = [ "system24.theme.css" ];

#         plugins = {
#           ClearURLs.enabled = true;
#           FixYoutubeEmbeds.enabled = true;
#         };
       };

      inherit themes;
    };
  };
}
