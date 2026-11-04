{
  programs.vesktop = {
    enable = true;

    vencord = {
      settings = {
        autoUpdate = false;
        useQuickCss = true;
        enabledThemes = [ "system24.theme.css" ];

#         plugins = {
#           ClearURLs.enabled = true;
#           FixYoutubeEmbeds.enabled = true;
#         };
       };

      themes = {
        system24 = ./themes/vesktop/system24.theme.css;
      };
    };
  };
}
